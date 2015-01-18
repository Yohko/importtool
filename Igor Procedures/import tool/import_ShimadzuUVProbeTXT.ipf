// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

// Shimadzu SolidSpec-3700 UV-VIS-NIR SPECTROPHOTOMETER


function ShimadzuTXT_check_file(file)
	variable file
	fsetpos file, 0
	string line = ""

	FReadLine file, line
	if(strlen(line) == 0)
		fsetpos file, 0
		return -1
	endif
	line = mycleanupstr(line)
	if(strsearch(line, "\"average",0) !=0 && strsearch(line, "\"Dataset ",0) !=0 && strsearch(line, "\"RawData",0) !=0)
		fsetpos file, 0
		return -1
	endif

	FReadLine file, line
	fsetpos file, 0
	if(strlen(line) == 0)
		return -1
	endif
	line = mycleanupstr(line)
	if(strsearch(line, "\"Wavelength ",0) !=0)
		return -1
	endif
	return 1
end


function ShimadzuTXT_load_data_info(importloader)
	struct importloader &importloader
	importloader.name =  "Shimadzu UVProbe TXT"
	importloader.filestr = "*.txt"
	importloader.category = "UVvis"
end


function ShimadzuTXT_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	ShimadzuTXT_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file

	string tmps= ""

	FReadLine file, tmps
	tmps = mycleanupstr(tmps)
	If (strlen(tmps)==0)
		return 0
	endif
	header+="\rcomment1: "+tmps[1,strlen(tmps)-2]

	FReadLine file, tmps
	tmps = mycleanupstr(tmps)
	If (strlen(tmps)==0)
		return 0
	endif
	header+="\rcomment2: "+tmps

	variable offset0 = 1
	variable offset1 = strsearch(tmps,"\"",offset0)
	string xaxis = tmps[offset0,offset1-1]
	offset0=strsearch(tmps,"\"",offset1+1)
	offset1 = strsearch(tmps,"\"",offset0+1)
	string yaxis = tmps[offset0+1, offset1-1] 
	
	variable points = 1
	tmps="data_xeV"
	Make /O/R/N=(points)  $tmps /wave=data_xeV
	tmps="data_xnm"
	Make /O/R/N=(points)  $tmps /wave=data_xnm
	tmps="data_y"
	Make /O/R/N=(points)  $tmps /wave=data_y

	Note data_xnm, header
	Note data_xeV, header
	Note data_y, header

	do
		FReadLine file, tmps
		tmps = mycleanupstr(tmps)
		If (strlen(tmps)==0)
			return 0
		endif
		Redimension/N=(points) data_xeV, data_xnm, data_y
		data_xeV[points-1] = 1239.8424/str2num(StringFromList(0,tmps,"\t"))
		data_xnm[points-1] = str2num(StringFromList(0,tmps,"\t"))
		data_y[points-1] =str2num(StringFromList(1,tmps,"\t"))
		points +=1
		Fstatus file
	while (V_logEOF>V_filePOS)  
	if(checkEnergyScale(data_xnm, 0.01))
		SetScale/P  x,data_xnm[0],data_xnm[1]-data_xnm[0],"nm", data_y
		SetScale d, 0,0,"%", data_y
		//killwaves data_xnm
		Debugprintf2("Equally spaced x-axis, setting appropriate ywave scaling and deleting xwave!",0)
	else
		SetScale/I  x,0,1,"%", data_y
		SetScale/I  x,0,1,"nm", data_xnm
		SetScale/I  x,0,1,"eV", data_xeV
		Debugprintf2("Unequally spaced x-axis.",0)
	endif

	importloader.success = 1
	loaderend(importloader)
end
