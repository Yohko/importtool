// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.


static structure SRI_param
	string key
	string val
endstructure


static structure SRI_header
	variable size
	variable rate
	wave x_wave
	wave y_wave
endstructure


function SRI_check_file(file)
	variable file
	fsetpos file, 0
	variable i=0
	string tmps
	for(i=0;i<10;i+=1)
		tmps = mycleanupstr(myreadline(file))
		if(strsearch(tmps,"<",0) == -1 && strsearch(tmps,">",0) == -1)
			fsetpos file, 0
			return -1
		else
			if(strsearch(tmps,"SRI Instruments",0) != -1)
			fsetpos file, 0
			return 1
			endif
		endif

		fstatus file
		if(V_logEOF<=V_filePOS)
			fsetpos file, 0
			return -1
		endif
	endfor
	fsetpos file, 0
	return -1
end


function SRI_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "SRI GC"
	importloader.filestr = "*.asc,*.chr,*.thu"
	importloader.category = "GC"
end


function SRI_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	SRI_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file
	fstatus file
	
	string tmps
	variable oldpos
	struct SRI_param param
	struct SRI_header sriheader
	do
		tmps = mycleanupstr(myreadline(file))
		if(strsearch(tmps,"<",0) == -1 && strsearch(tmps,">",0) == -1)
			fsetpos file, oldpos
			break
		else
			SRI_getparam(tmps, param)
			strswitch(param.key)
				case "LAB NAME":
					break
				case "CLIENT":
					break
				case "CLIENT ID":
					break
				case "COLLECTION DATE":
					break
				case "HOLDING TIME":
					break
				case "METHOD":
					break
				case "LAB ID":
					break
				case "DESCRIPTION":
					break
				case "COLUMN":
					break
				case "CARRIER":
					break
				case "TEMPERATURE":
					break
				case "EVENTS":
					break
				case "COMPONENTS":
					break
				case "SAMPLE":
					break
				case "OPERATOR":
					break
				case "QC BATCH":
					break
				case "CONDITIONS":
					break
				case "DATE":
					break
				case "TIME":
					break
				case "SAMP WEIGHT":
					break
				case "STD WEIGHT":
					break
				case "CONTROL FILENAME":
					break
				case "":
					break
				case "SIZE":
					sriheader.size = str2num(param.val)
					break
				case "RATE":
					sriheader.rate = str2num(param.val)
					break
			endswitch
		endif

		fstatus file
		oldpos = V_filePOS
	while(V_logEOF>V_filePOS)
	variable i
	
	tmps = "rawdata"
	//Make /O/D/N=(sriheader.size) $tmps /wave= x_wave
	Make /O/D/N=(sriheader.size) $tmps ; wave sriheader.x_wave = $tmps
	tmps = "normalizeddata"
	//Make /O/D/N=(sriheader.size) $tmps /wave= y_wave
	Make /O/D/N=(sriheader.size) $tmps ; wave sriheader.y_wave = $tmps
	
	SetScale/P  x,0,1/sriheader.rate,"sec", sriheader.x_wave
	SetScale/P  x,0,1/sriheader.rate,"sec", sriheader.y_wave
	
	fstatus file
	if(strsearch(S_fileName,".asc",inf,3)!=-1)
		SRI_readascii(file, sriheader)
	elseif(strsearch(S_fileName,".chr",inf,3)!=-1)
		SRI_readbinary(file, sriheader)
	endif
	SRI_readidpoints(file, sriheader)

	importloader.success = 1
	loaderend(importloader)
end


static function SRI_getparam(str, param)
	string str ; struct SRI_param &param
	param.key = ""
	param.val = ""
	if(strsearch(str,"<",0)!=-1)
		if(strsearch(str,">",0)!=-1)
			param.key = stripstrfirstlastspaces(str[strsearch(str,"<",0)+1,strsearch(str,">",0)-1])
			param.val=stripstrfirstlastspaces(str[strsearch(str,"=",0)+1,inf])
		endif
	endif
end


static function SRI_readascii(file, sriheader)
	variable file
	struct SRI_header &sriheader
	Debugprintf2("ASCII data",0)

	variable i
	string tmps
	for(i=0;i<sriheader.size;i+=1)
		tmps =  mycleanupstr(myreadline(file))
		sriheader.x_wave[i] = str2num(StringFromList(0, tmps, ","))
		sriheader.y_wave[i] = str2num(StringFromList(1, tmps, ","))
		fstatus file
		if(V_logEOF<=V_filePOS)
			break
		endif
	endfor
end


static function SRI_readbinary(file, sriheader)
	variable file
	struct SRI_header &sriheader
	Debugprintf2("Binary data",0)
	
	wave tempwave = sriheader.x_wave
	fbinread /B=3/f=3 file, tempwave
	// Background has to be calculated based on the next values... (not yet fully implemented)
end


static function SRI_readidpoints(file, sriheader)
	variable file
	struct SRI_header &sriheader
	string tmps
	tmps = "idpoints"
	Make /O/D/N=(10,0) $tmps /wave=idwave
	variable i=0,j=0
	do
		i+=1
		redimension /n=(i,10) idwave
		tmps = mycleanupstr(myreadline(file))
		tmps = tmps[strsearch(tmps,"=",0)+1,inf]
		for(j=0;j<10;j+=1)
			idwave[i-1][j] = str2num(stringfromlist(j,tmps,","))
		endfor
		fstatus file
	while(V_logEOF>V_filePOS)
end
