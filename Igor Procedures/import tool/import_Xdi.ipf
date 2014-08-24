// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

// Documentation:
// https://github.com/XraySpectroscopy/XAS-Data-Interchange/wiki/Xdispec


function Xdi_check_file(file)
	variable file
	fsetpos file, 0
	
	string tmps = stripstrfirstlastspaces(myreadline(file))
	if(strsearch(tmps,"#",0) !=0)
		fsetpos file, 0
		return -1
	endif
	tmps = stripstrfirstlastspaces(tmps[1,inf])
	if(itemsinlist(tmps, " ") <2)
		fsetpos file, 0
		return -1
	endif
	string xdiversion = stringfromlist(0,tmps, " ")
	if(cmpstr(xdiversion[0,3],"XDI/",1)!=0)
		fsetpos file, 0
		return -1
	endif
	if(numtype(str2num(xdiversion[4,inf])) !=0)
		fsetpos file, 0
		return -1
	endif
	string program = stringfromlist(0,tmps, " ")

	// check for the fields which must be present
	variable found =0
	do
		tmps = stripstrfirstlastspaces(myreadline(file)) ; tmps = stripstrfirstlastspaces(tmps[1,inf])
		if(strsearch(tmps,"Column.1:",0) == 0)
			found +=1
		endif
		if(strsearch(tmps,"Element.symbol:",0) == 0)
			found +=1
		endif
		if(strsearch(tmps,"Element.edge:",0) == 0)
			found +=1
		endif
		if(strsearch(tmps,"---",0) == 0)
			found +=1
		endif
//		if(strsearch(tmps,"outer.value:",0) == 0)
//			found +=1
//		endif
//		if(strsearch(tmps,"outer.name:",0) == 0)
//			found +=1
//		endif
		fstatus file
	while(V_filePos < V_logEOF && found < 3)
	fsetpos file, 0
	if(found !=3)
		return -1
	endif
	return 1
end


function Xdi_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "XAS Data Interchange  data"
	importloader.filestr = "*.xdi"
	importloader.category = "XAS"
end


function Xdi_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	Xdi_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file
	
	// reading header
	struct Xdifield myXdifield
	struct Xdiheader myXdiheader
	myXdiheader.collabels = ""
	myXdiheader.header = ""

	string tmps = stripstrfirstlastspaces(myreadline(file)) ; tmps = stripstrfirstlastspaces(tmps[1,inf])
	string xdiversion = stringfromlist(0,tmps, " ")
	string program = stringfromlist(0,tmps, " ")

	do
		tmps = stripstrfirstlastspaces(myreadline(file)) ; tmps = stripstrfirstlastspaces(tmps[1,inf])
		if(strsearch(tmps, "///",0)==0)
			// reached field-end token
			break
		endif
		if(Xdi_get_field(tmps, myXdifield) == -1)
			Debugprintf2("Error reading Xdi field!",0)
			loaderend(importloader)
			return -1
		endif
		Xdi_check_field(myXdifield, myXdiheader)
		fstatus file
	while(V_filePos < V_logEOF)
	
	// reading comments	
	do
		tmps = stripstrfirstlastspaces(myreadline(file)) ; tmps = stripstrfirstlastspaces(tmps[1,inf])
		if(strsearch(tmps, "---",0)==0)
			// reached header-end token
			break
		endif
		header +="\rComment: "+tmps
		fstatus file
	while(V_filePos < V_logEOF)

	// reading data
	fstatus file
	variable oldpos = V_filePos
	tmps = stripstrfirstlastspaces(myreadline(file))
	//optional comment line with col.labels
	if(strsearch(tmps[0,1],"#",0)==0)
		tmps =  splitintolist(stripstrfirstlastspaces(tmps[1,inf])," ") 
		variable cols = itemsinlist(myXdiheader.collabels,";")
		if(itemsinlist(tmps, "_") != cols)
			Debugprintf2("Error reading data subheader!",0)
			loaderend(importloader)
			return -1
		endif
	else
		fsetpos file, oldpos
	endif
	
	tmps = "tmpddata"
	Make /O/R/N=(0, itemsinlist(myXdiheader.collabels,";"))  $tmps /wave=tmpdata

	variable i=0, j=0
	do
		tmps =  splitintolist(stripstrfirstlastspaces(myreadline(file))," ")
		
		if(strsearch(tmps[0,1],"#",0)==0)
			continue
		endif		
		if(cols == itemsinlist(tmps, "_"))
			j+=1
			redimension  /N=(j,-1) tmpdata
			for(i=0;i<cols;i+=1)
				tmpdata[j-1][i] = str2num(stringfromlist(i,tmps, "_"))
			endfor
		else
			Debugprintf2("Error reading data!",0)
			loaderend(importloader)
			return -1
		endif
		fstatus file
	while(V_filePos < V_logEOF)


	// save waves and notes
	note tmpdata, header
	tmps = myXdiheader.header[0,strlen(myXdiheader.header)-3]
	note tmpdata, tmps
	splitmatrix(tmpdata,"tmpdata")
	for(i=0;i<cols;i+=1)
			tmps = stringfromlist(i,myXdiheader.collabels,";")
			if(WaveExists($tmps))
				tmps = UniqueName(tmps, 1, 0)
			endif
			rename $("tmpdata_spk"+num2str(i)), $tmps
			// convert angle to energy
			if(strsearch(tmps,"angle",0)!=-1 && strsearch(tmps,"degrees",0)!=-1 && numtype(myXdiheader.Mono_dspacing) == 0 && myXdiheader.Mono_dspacing !=0 )
				variable omega = (1973.269718 * 2 * Pi)/(2*myXdiheader.Mono_dspacing)
				wave angle = $tmps
				tmps = "energy"
				Make /O/R/N=(1)  $tmps /wave=energy
				duplicate /O angle, energy
				energy[] =  omega/sin(angle[p]/180*Pi)
			endif
	endfor	
	importloader.success = 1
	loaderend(importloader)
end


static function Xdi_get_field(str, myXdifield)
	string str
	struct Xdifield &myXdifield
	if(strsearch(str,".",0) != -1 && strsearch(str,":",0) != -1)
		myXdifield.namespace = str[0,strsearch(str,".",0)-1]
		myXdifield.key = str[strsearch(str,".",0)+1,strsearch(str,":",0)-1]
		myXdifield.value = stripstrfirstlastspaces(str[strsearch(str,":",0)+1,inf])
	else
		return -1
	endif
	return 0
end


static function Xdi_check_field(myXdifield, myXdiheader)
	struct Xdifield &myXdifield
	struct Xdiheader &myXdiheader
	
	strswitch(myXdifield.namespace)
//		case "Element":
//			break
		case "Column":
			myXdiheader.collabels +=myXdifield.value+";"
			break
//		case "Facility":
//			break
		case "Mono":
			strswitch(myXdifield.key)
				case "d_spacing":
					myXdiheader.Mono_dspacing = str2num(myXdifield.value)
					break
			endswitch
			myXdiheader.header += myXdifield.namespace+" "+myXdifield.key+ ": "+myXdifield.value+"\r"
			break
//		case "Scan":
//			break
//		case "Beamline":
//			break
//		case "MX":
//			break
//		case "Sample":
//			break
//		case "Detector":
//			break
		default:
			myXdiheader.header += myXdifield.namespace+" "+myXdifield.key+ ": "+myXdifield.value+"\r"
			break
	endswitch
end


static structure Xdifield
	string namespace
	string key
	string value
endstructure


static structure Xdiheader
	string collabels
	string header
	string element_symbol
	string element_name
	string facility_name
	string facility_energy
	string Facility_xray_source
	string Scan_start_time
	string Mono_name
	variable Mono_dspacing
	string Beamline_name
	string Beamline_undulatorharmonic
	string Beamline_collimation
	string Beamline_focusing
	string Beamline_harmonicrejection
	string MX_Num_regions
	string MX_SRB
	string MX_SRSS
	string MX_SPP
	string MX_Settlingtime
	string MX_Offsets
	string MX_Gains
endstructure
