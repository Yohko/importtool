// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// Log Data File used by Extech Software keep track of data
// http://www.extech.com

function EXTECHBIN_check_file(file)
	variable file
	fsetpos file, 0
	string line = ""
	fstatus file
	variable size = 6
	if(V_logEOF<size)
		fsetpos file, 0
		return -1
	endif
	variable tmp, length
	variable datapoints, hour, minutes, seconds, sampling
	string unit
	fbinread /B=3/f=3 file, datapoints
	fbinread /B=3 /f=1 file, tmp //?
	fbinread /B=3/U/f=1 file, length
	size += length+1
	if(V_logEOF<size)
		fsetpos file, 0
		return -1
	endif
	string starttime = mybinread(file, length)
	if(ItemsInList(starttime  , ":")!=3)
			fsetpos file, 0
		return -1
	endif
	fbinread /B=3/U/f=1 file, length
	size += length+1
	if(V_logEOF<size)
		fsetpos file, 0
		return -1
	endif
	string endtime = mybinread(file, length)
	if(ItemsInList(endtime  , ":")!=3)
		fsetpos file, 0
		return -1
	endif
	fbinread /B=3/U/f=1 file, length
	size += length+16
	if(V_logEOF<size)
		fsetpos file, 0
		return -1
	endif
	unit = mybinread(file, length)
	fbinread /B=3/f=3 file, hour // start h
	fbinread /B=3/f=3 file, minutes // start min
	fbinread /B=3/f=3 file, seconds // start sec
	fbinread /B=3/f=3 file, sampling // sampling rate in msec

	// check for data length
	size += datapoints*14
	if(V_logEOF<size)
		fsetpos file, 0
		return -1
	endif
	fsetpos file, 0
	return 1
end


function EXTECHBIN_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "EXTECH BINARY"
	importloader.filestr = "*.AsmDat"
	importloader.category = "misc"
end


function EXTECHBIN_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	EXTECHBIN_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file
	string tmps=""
	
	variable tmp, length
	variable datapoints, hour, minutes, seconds, sampling
	string unit
	fsetpos file, 0
	fbinread /B=3/f=3 file, datapoints
	fbinread /B=3 /f=1 file, tmp //?
	fbinread /B=3/U/f=1 file, length
	string starttime = mybinread(file, length)
	fbinread /B=3/U/f=1 file, length
	string endtime = mybinread(file, length)
	fbinread /B=3/U/f=1 file, length
	unit = mybinread(file, length)	
	
	fbinread /B=3/f=3 file, hour // start h
	fbinread /B=3/f=3 file, minutes // start min
	fbinread /B=3/f=3 file, seconds // start sec
	fbinread /B=3/f=3 file, sampling // sampling rate in msec
	sampling /=1000
	variable timeoff = hour *3600+minutes*60+seconds
	header+="\rStart time: "+starttime+"\r"
	header+="End time: "+endtime+"\r"
	header+="Sampling: "+num2str(sampling)+"\r"
	header+="Unit: "+unit+"\r"

	tmpS = "DATA" ; Make /O/D/N=(datapoints) $tmpS ; wave w_DATA = $tmpS
	fbinread /B=3/f=4 file, w_DATA

	tmpS = "DATA2" ; Make /O/D/N=(datapoints) $tmpS ; wave w_DATA2 = $tmpS
	fbinread /B=3/f=4 file, w_DATA2

	tmpS = "DATAtext" ; Make /O/T/N=(datapoints) $tmpS ; wave /T w_DATAtext = $tmpS
	variable i = 0
	for(i=0;i<datapoints;i+=1)
		w_DATAtext[i] = mybinread(file, 6)
	endfor

	SetScale /P x, timeoff, sampling  ,"sec" , w_DATA
	SetScale /P x, timeoff, sampling  ,"sec" , w_DATA2
	SetScale /P x, timeoff, sampling  ,"sec" , w_DATAtext
	SetScale d, 0,0,unit, w_DATA
	SetScale d, 0,0,unit, w_DATA2
	setScale d, 0,0,unit, w_DATAtext
	note w_DATA, header
	note w_DATA2, header
	note w_DATAtext, header

	importloader.success = 1
	loaderend(importloader)
end
