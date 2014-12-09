// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.


function VGScientaSES_check_file(file)
	variable file
	fsetpos file, 0
	fstatus file
	if(strsearch(S_fileName,".pxt",inf,1)!=-1)
		return 1
	endif
	return -1
end


function VGScientaSES_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "VG Scienta SES"
	importloader.filestr = "*.pxt"//,*.txt"
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
	
	fstatus file
	LoadData/Q /L=1 (S_path+S_fileName)
	variable i=0
	variable n_objects = CountObjects("",1)
	for(i=0;i<n_objects;i+=1)
		VGScientaSES_add_notes(header, $GetIndexedObjName("",1,i))
	endfor

	importloader.success = 1
	loaderend(importloader)
end


static function VGScientaSES_add_notes(header, spectra)
	string header
	wave spectra
	string oldnote = note(spectra)
	note /K spectra, header
	note spectra, oldnote

	variable f_DivScans = str2num(get_flags("CB_DivScans"))
	variable f_DivLifeTime = str2num(get_flags("CB_DivLifeTime"))
	variable f_singlescans = str2num(get_flags("singlescans"))
	//variable f_DivTF = str2num(get_flags("f_DivTF"))
	//variable f_includeTF = str2num(get_flags("includetransmission"))
	variable exenergy, kinstart, kinend

	strswitch(VGScientaSES_parameter(oldnote, "Energy Unit="))
		case "Kinetic":
			exenergy = str2num(VGScientaSES_parameter(oldnote, "Excitation Energy="))
			kinstart = str2num(VGScientaSES_parameter(oldnote, "Low Energy="))
			kinend = str2num(VGScientaSES_parameter(oldnote, "High Energy="))
			break
		default:
			Debugprintf2("Unknown Energy Unit!",0)
			break
	endswitch

	strswitch(VGScientaSES_parameter(oldnote, "Energy Scale="))
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
