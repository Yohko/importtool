// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// Log Data File used by Extech Software keep track of data
// http://www.extech.com


function EXTECHASCII_check_file(file)
	variable file
	fsetpos file, 0
	string line = ""
	line = mycleanupstr(myreadline(file))	
	fsetpos file, 0
	if(cmpstr(line,"      NO              DATA              UNIT           TIME  ") == 0)
		return 1
	else
		return -1
	endif
	return -1
end


function EXTECHASCII_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "EXTECH ASCII"
	importloader.filestr = "*.txt"
	importloader.category = "misc"
end


function EXTECHASCII_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	EXTECHASCII_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file
	string tmps=""
	
	tmpS = "NO" ; Make /O/D/N=(0) $tmpS ; wave w_NO = $tmpS
	tmpS = "DATA" ; Make /O/D/N=(0) $tmpS ; wave w_DATA = $tmpS
	tmpS = "UNIT" ; Make /O/T/N=(0) $tmpS ; wave /T w_UNIT = $tmpS
	tmpS = "TIMEstring" ; Make /O/T/N=(0) $tmpS ; wave /T w_TIMEs = $tmpS
	tmpS = "TIMEcode" ; Make /O/D/N=(0) $tmpS ; wave  w_TIMEc = $tmpS
	
	note w_NO, header
	note w_DATA, header
	note w_UNIT, header
	note w_TIMEc, header
	note w_TIMEs, header

	tmps = mycleanupstr(myreadline(file))

	variable i = 0
	do
		i+=1
		redimension /n=(i) w_NO, w_DATA, w_UNIT, w_TIMEc, w_TIMEs
		tmps = mycleanupstr(myreadline(file))
		tmps = splitintolist(tmps, " ")
		w_NO[i-1] = str2num(StringFromList(0, tmps  , "_"))
		w_DATA[i-1] = str2num(StringFromList(1, tmps  , "_"))
		w_UNIT[i-1] = StringFromList(2, tmps  , "_")
		w_TIMEs[i-1] = StringFromList(3, tmps  , "_")
		w_TIMEc[i-1] = str2num(StringFromList(0, w_TIMEs[i-1]  , ":"))*3600+str2num(StringFromList(1, w_TIMEs[i-1]  , ":"))*60+str2num(StringFromList(2, w_TIMEs[i-1]  , ":"))
		fstatus file
	while(V_logEOF>V_filePOS)

	importloader.success = 1
	loaderend(importloader)
end
