// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.


function VGScientaSES_check_file(file)
	variable file
	fsetpos file, 0
	fstatus file
	if(strsearch(S_fileName,".pxt",inf,1)!=-1)
		return 1
	endif
	if(strsearch(S_fileName,".ibw",inf,1)!=-1)
		return 2
	endif
	// test if a SES *.txt file - not complete
	if(strsearch(S_fileName,".txt",inf,1)!=-1)
		string line = ""
		FReadLine file, line
		fstatus file
		if(strlen(line) == 0) // hit EOF
			fsetpos file, 0
			return -1
		endif
		if(strsearch(line,"[Info]", 0) !=0)
			fsetpos file, 0
			return -1
		endif
		FReadLine file, line
		fstatus file
		if(strlen(line) == 0) // hit EOF
			fsetpos file, 0
			return -1
		endif
		if(strsearch(line,"Number of Regions=", 0) !=0)
			fsetpos file, 0
			return -1
		endif
		return 3
	endif
	fsetpos file, 0
	return -1
end


function VGScientaSES_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "VG Scienta SES"
	importloader.filestr = "*.pxt,*.ibw,*.txt"
	importloader.category = "PES"
end


function VGScientaSES_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	VGScientaSES_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	
	variable file = importloader.file
	variable type = VGScientaSES_check_file(file)
	
	variable i=0
	switch(type)
		case 1: // *.pxt
			VGScientaSES_loadpxt(file)
			break
		case 2: // *.ibw
			VGScientaSES_loadibw(file)
			break	
		case 3: // *.txt
			VGScientaSES_loadtxt(file)
			break
		default:
			Debugprintf2("Unknown file type!",0)
			loaderend(importloader)
			return -1
			break
	endswitch

	variable n_objects = CountObjects("",1)
	for(i=0;i<n_objects;i+=1)
		VGScientaSES_add_notes(header, $GetIndexedObjName("",1,i))
	endfor

	importloader.success = 1
	loaderend(importloader)
end


static function VGScientaSES_loadibw(file)
	variable file
	fstatus file
	Loadwave /Q/M/H/W (S_path+S_fileName)
	return 0
end


static function VGScientaSES_loadpxt(file)
	variable file
	fstatus file
	LoadData/Q /L=1 (S_path+S_fileName)
end


static function VGScientaSES_add_notes(header, spectra)
	string header
	wave spectra
	string oldnote = note(spectra)


	variable f_DivScans = str2num(get_flags("CB_DivScans"))
	variable f_DivLifeTime = str2num(get_flags("CB_DivLifeTime"))
	variable f_singlescans = str2num(get_flags("singlescans"))
	variable f_askenergy = str2num(get_flags("f_askenergy"))

	note /K spectra, header

	variable exenergy, kinstart, kinend
	
	if(f_askenergy == 1)
			Prompt exenergy, "Eph: "
			DoPrompt "Enter excitation energy", exenergy
			if(V_flag == 1)
				exenergy = -1
			else
				note spectra, "Excitation energy: "+num2str(exenergy)
			endif
	endif

	note spectra, oldnote

	string energyscale=""
	energyscale = VGScientaSES_parameter(oldnote, "Energy Unit=")
	if(strlen(VGScientaSES_parameter(oldnote, "Energy Unit=")) == 0)
		energyscale=VGScientaSES_parameter(oldnote, "Dimension 1 name=")
	endif

	strswitch(energyscale)
		case "Binding Energy [eV]":
			if(f_askenergy == 0 || exenergy == -1)
				exenergy = str2num(VGScientaSES_parameter(oldnote, "Excitation Energy="))
			endif
			kinstart = exenergy-str2num(VGScientaSES_parameter(oldnote, "High Energy="))
			kinend = exenergy-str2num(VGScientaSES_parameter(oldnote, "Low Energy="))
			break
		case "Kinetic Energy [eV]":
			if(f_askenergy == 0 || exenergy == -1)
				exenergy = str2num(VGScientaSES_parameter(oldnote, "Excitation Energy="))
			endif
			kinstart = str2num(VGScientaSES_parameter(oldnote, "Low Energy="))
			kinend = str2num(VGScientaSES_parameter(oldnote, "High Energy="))
			break
		case "Kinetic":
			if(f_askenergy == 0 || exenergy == -1)
				exenergy = str2num(VGScientaSES_parameter(oldnote, "Excitation Energy="))
			endif
			kinstart = str2num(VGScientaSES_parameter(oldnote, "Low Energy="))
			kinend = str2num(VGScientaSES_parameter(oldnote, "High Energy="))
			break
		case "Binding":
			break
		default:
			Debugprintf2("Unknown Energy Unit!",0)
			break
	endswitch

	strswitch(VGScientaSES_parameter(oldnote, "Energy Scale="))
		case "Binding Energy [eV]":
			break
		case "Kinetic Energy [eV]":
			break
		case "Binding":
					if(str2num(get_flags("vskineticenergy"))==0)
						if(str2num(get_flags("posbinde")) == 0)
							SetScale/I  x,-exenergy+kinstart,-exenergy+kinend,"eV", spectra
						else
							SetScale/I  x,exenergy-kinstart,exenergy-kinend,"eV", spectra
						endif
					else
						SetScale/I  x,kinstart,kinend,"eV", spectra
					endif
			break
			case "Kinetic":
					if(str2num(get_flags("vskineticenergy"))==0)
						if(str2num(get_flags("posbinde")) == 0)
							SetScale/I  x,-exenergy+kinstart,-exenergy+kinend,"eV", spectra
						else
							SetScale/I  x,exenergy-kinstart,exenergy-kinend,"eV", spectra
						endif
					else
						SetScale/I  x,kinstart,kinend,"eV", spectra
					endif
				break
		default:
			Debugprintf2("Unknown Energy Scale!",0)
			break
	endswitch

	if(!f_DivScans)
		spectra *=(str2num(VGScientaSES_parameter(oldnote, "Number of Sweeps=")))
	endif
	
	if(!f_DivLifeTime)
		spectra *=(str2num(VGScientaSES_parameter(oldnote, "Step Time="))/1000)
	endif
	
	if(dimsize(spectra,1)>0)
		string tmps = loader_addtowavename(GetWavesDataFolder(spectra, 2), "CHES")
		duplicate /O spectra, $tmps
		wave spectraall = $tmps
		redimension /N=-1 spectra
		spectra = 0
		variable i=0
		for(i=0;i<dimsize(spectraall,1);i+=1)
			spectra[]+= spectraall[p][i]
		endfor
		spectra /= dimsize(spectraall,1)
		if(!f_singlescans)
			killwaves spectraall
		endif
	endif
end


static function /S VGScientaSES_parameter(notein, param)
	string notein, param
	string tmps
	if (strsearch(notein, param,0) != -1)
		tmps=notein[strsearch(notein, param,0)+strlen(param),inf]
		return tmps[0,strsearch(tmps,"\r",0)-1]
	else
		return ""
	endif
end


static function /S VGScientaSES_loadtxt(file)
	variable file

	string line =""
	struct VGScientaSES_param param
	
	struct VGScientaSES_header	SES_header
	SES_header.header = ""
	string header = ""
	do
	
		FReadLine file, line
		fstatus file
		if(strlen(line) == 0) // hit EOF
			break
		endif
		
		VGScientaSES_txtgetparam(mycleanupstr(line), param)
		fstatus file
		strswitch(param.key)
			case "Info":
				break
			case "Data":
				VGScientaSES_txtdata(file, SES_header)
				SES_header.header = header
				break
			case "Low Energy":
				SES_header.header += "\r"+param.key+"="+param.val
				SES_header.lowenergy = str2num(param.val)
				break
			case "High Energy":
				SES_header.header += "\r"+param.key+"="+param.val
				SES_header.highenergy = str2num(param.val)
				break
			case "Energy Step":
				SES_header.header += "\r"+param.key+"="+param.val
				SES_header.energystep = str2num(param.val)
				break
			case "Dimension 1 size":
				SES_header.header += "\r"+param.key+"="+param.val
				SES_header.Dimension1size = str2num(param.val)
				break
			case "Dimension 2 size":
				SES_header.header += "\r"+param.key+"="+param.val
				SES_header.Dimension2size = str2num(param.val)
				break
			case "Region Name":
				SES_header.header += "\r"+param.key+"="+param.val
				SES_header.RegionName = param.val
				break
			case "Info":
				if(strlen(param.val) !=0)
					header += "\r"+param.key+"="+param.val
				else
					SES_header.header += "\r"+param.key+"="+param.val
				endif
			default:
				if(strlen(param.key) != 0 && strlen(param.val) !=0)
					SES_header.header += "\r"+param.key+"="+param.val
				endif
				break
		endswitch
		fstatus file
	while(V_logEOF>V_filePOS)
end


static function /wave VGScientaSES_txtdata(file, SES_header)
	variable file
	struct VGScientaSES_header	&SES_header
	variable points = (SES_header.highenergy-SES_header.lowenergy)/SES_header.energystep +1
	make /O/D/N = (SES_header.Dimension1size, SES_header.Dimension2size-1) $SES_header.RegionName /wave=datay
	make /O/D/N = (SES_header.Dimension1size) $(SES_header.RegionName+"_X") /wave=datax
	variable i=0, j=0
	string line
	
	for(i=0;i<SES_header.Dimension1size;i+=1)
		line = mycleanupstr(myreadline(file))
		line = splitintolist(line, " ")
		datax[i] = str2num(StringFromList(0,line, "_"))
		for(j=0;j<SES_header.Dimension2size-1;j+=1)
			datay[i][j] = str2num(StringFromList(j+1,line, "_"))
		endfor
	endfor
	
	SetScale/P  x,SES_header.highenergy, -SES_header.energystep, "",datax, datay
	SES_header.header = SES_header.header[1,inf] // remove first "\r"
	string tmps = SES_header.header
	
	if(checkEnergyScale(datax,1E-6))
		killwaves datax
	else
		note  datax, tmps
	endif
	note  datay, tmps
	
	Debugprintf2("... exporting spectrum: "+SES_header.RegionName,0)	
end


static function VGScientaSES_txtgetparam(line, param)
	string line
	struct VGScientaSES_param &param
	param.key = ""
	param.val = ""
	variable num = 0
	if(strsearch(line,"[",0)!=-1 && strsearch(line,"]",0)!=-1 && strsearch(line,"=",0) == -1)
		line = line[strsearch(line,"[",0)+1, strsearch(line,"]",0)-1]
		if(strsearch(line," ",inf,1) !=-1)
			num = str2num(line[strsearch(line," ",inf,1)+1,inf])
			if(numtype(num) == 0)
				param.key = line[0,strsearch(line," ",inf,1)-1]
				param.val = line[strsearch(line," ",inf,1)+1,inf]
			else
				param.key = line
			endif
		else
				param.key = line
		endif
	else
		if(strsearch(line,"=",0)!=-1)
			param.key = line[0,strsearch(line,"=",0)-1]
			param.val = line[strsearch(line,"=",0)+1,inf]
		else
			return -1
		endif
	endif
end


static structure VGScientaSES_param
	string key
	string val
endstructure


static structure VGScientaSES_header
	variable Dimension1size
	variable Dimension2size
	string header
	string 	RegionName
//	variable ExcitationEnergy
//	string EnergyScale
//	string AcquisitionMode
	variable CenterEnergy
	variable LowEnergy
	variable HighEnergy
	variable EnergyStep
	variable StepTime
//	variable DetectorFirstX-Channel
//	variable Detector Last X-Channel
//	variable Detector First Y-Channel
//	variable Detector Last Y-Channel
//	variable NumberofSlices
	string LensMode
	variable PassEnergy
//	variable NumberofSweeps
	string File
	string Sequence
//	string SpectrumName
	string Instrument
	variable Location
	string User
	string Sample
	string Comments
//	string Date
//	string Time
//	variable TimeperSpectrumChannel
endstructure
