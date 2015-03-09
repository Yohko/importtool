// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

// http://www.certif.com/content/spec/
// ascan / a2scan *.csv file


// SSRL BL 13-2:
// Ch0:		#
// Ch1:		MONO132
// Ch2:		Seconds
// Ch3:		n1c1--> 13-0M0
// Ch4:		n1c2 --> m1vert
// Ch5:		n1c3 --> after 13-0ENS (Ipink)
// Ch6:		n1c4 --> Izob (Ch5??), after 13-0SGM
// Ch7:		n1c5
// Ch8:		n1c6
// Ch9:		n1c7
// Ch10:	n2c0
// Ch11:	n2c1 --> Is
// Ch12:	n2c2 --> SES
// Ch13:	n2c3 --> XES
// Ch14:	n2c4 --> I0
// Ch15:	n2c5
// Ch16:	n2c6
// Ch17:	n2c7

// n2c1 - Ch11 --> Is
// n2c2 - Ch12 --> SES
// n2c3 - ch13 --> XES
// n2c4 - Ch14 --> I0


static function spec_get_dataline(line)
	string &line
	line = stripstrfirstlastspaces(line)
	if(strlen(line)==0)
		return -1
	endif	
	if(strsearch(line, ",",0)!=-1)
		line = ReplaceString(" ",line,"")
		line = ReplaceString("\t",line,"")
		line = splitintolist(line, ",")
	else
		line = splitintolist(line, ",")
	endif
	return 1
end


function spec_check_file(file)
	variable file
	fsetpos file, 0
	string line = ""
	FReadLine file, line
	fsetpos file, 0
	if(strlen(line) == 0) // hit EOF
		return -1
	endif
	if(strsearch(line, "#",0) == -1 || strsearch(line, "Seconds",0) == -1 || strsearch(line, "n1c1",0) == -1 || strsearch(line, "n1c2",0) == -1)
		return -1
	endif
	return 1
end


function spec_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "spec"
	importloader.filestr = "*.CSV"
	importloader.category = "XAS"
end


function spec_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	spec_load_data_info(importloader)
	 if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file
	
	string col_name = read_line_trim(file)
	string line
	
	if(spec_get_dataline(col_name)==-1)
		loaderend(importloader)
		return -1
	endif

	// reading the data
	Make /FREE/D/N=(0,ItemsInList(col_name,"_")) datawave
	variable datacount = 1, i=0
	do
		redimension /N=(datacount,-1) datawave
		line = read_line_trim(file)
		if(spec_get_dataline(line)==-1)
			loaderend(importloader)
			return -1
		endif
		
		if(ItemsInList(col_name,"_")!=ItemsInList(line,"_"))
			Debugprintf2("Column count mismatch!",0)
			loaderend(importloader)
			return -1
		endif

		for(i=0;i<ItemsInList(line,"_");i+=1)
			if(numtype(str2num(StringFromList(i,line, "_")))!=0)
				Debugprintf2("Error reading data!",0)
				loaderend(importloader)
				return -1
			else
				datawave[datacount-1][i] =str2num(StringFromList(i,line, "_"))
			endif
		endfor
		
		datacount+=1
		fstatus file
	while(V_logEOF>V_filePOS)
	
	splitmatrix(datawave,"spectra")
	string tmpname = ""
	for(i=0;i<ItemsInList(col_name,"_");i+=1)
		note $("spectra_spk"+num2str(i)), header
		tmpname = StringFromList(i,col_name, "_")
		note $("spectra_spk"+num2str(i)), "Name: "+tmpname
		
		// rename channels
		// for SSRL BL 13-2
		strswitch(tmpname)
			case "MONO132":
				tmpname = "energy"
				break
			case "n1c1":
				tmpname = "M0"
				break
			case "n1c2":
				tmpname = "M1"
				break
			case "n1c3":
				tmpname = "Ipink"
				break
			case "n1c4":
				tmpname = "Izob"
				break
			case "n2c1":
				tmpname = "Is"
				break
			case "n2c2":
				tmpname = "SES"
				break
			case "n2c3":
				tmpname = "XES"
				break
			case "n2c4":
				tmpname = "I0"
				break
			default:
				break
		endswitch
		
		rename $("spectra_spk"+num2str(i)), $(num2str(i)+"_"+ tmpname)
		Debugprintf2("... exporting: "+StringFromList(i,col_name, "_"),0)
	endfor	
	
	importloader.success = 1
	loaderend(importloader)
end
