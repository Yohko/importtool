// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


function BrukerXYE_check_file(file)
	variable file
	fsetpos file, 0
	string line = ""
	line = mycleanupstr(myreadline(file))	
	fsetpos file, 0
	if(strsearch(line, "'Id: \"",0) != 0)
		return -1
	endif
	if(strsearch(line, "\" Comment: \"",0) == -1)
		return -1
	endif
	if(strsearch(line, "\" Operator: \"",0) == -1)
		return -1
	endif
	if(strsearch(line, "\" Anode: ",0) == -1)
		return -1
	endif
	if(strsearch(line, " Scantype: \"",0) == -1)
		return -1
	endif
	return 1
end


function BrukerXYE_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "Bruker XYE"
	importloader.filestr = "*.xye,*.xy"
	importloader.category = "XRD"
end


function BrukerXYE_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	BrukerXYE_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file
	string tmps=""
	
	tmpS = "2theta" ; Make /O/D/N=(0) $tmpS ; wave w_x = $tmpS
	tmpS = "intensity" ; Make /O/D/N=(0) $tmpS ; wave w_y = $tmpS
	tmpS = "ext" ; Make /O/D/N=(0) $tmpS ; wave w_e = $tmpS
	
	
	// load complete file into a text wave for faster processing
	fstatus file
	LoadWave/Q/J/V={"", "", 0, 0}/K=2/A=$("file") (S_path+S_fileName)
	if(V_flag !=1)
		loaderend(importloader)
		return -1
	endif
	wave /T filewave = $(StringFromList(0, S_waveNames))
	variable linecount = 0

	string comments = mycleanupstr(filewave[linecount]); linecount +=1
	header+="\r"+comments

	variable i = 0
	do
		i+=1
		redimension /n=(i) w_x, w_y, w_e
		tmps = mycleanupstr(filewave[linecount]); linecount +=1

		w_x[i-1] = str2num(StringFromList(0, tmps  , " "))
		w_y[i-1] = str2num(StringFromList(1, tmps  , " "))
		w_e[i-1] = str2num(StringFromList(2, tmps  , " "))
	while(linecount<dimsize(filewave,0))

	note w_x, header
	note w_y, header
	note w_e, header
	
	if(checkEnergyScale(w_x, 1E-6) == 1)
		variable startx = w_x[0]
		variable stepx = w_x[1] - w_x[0]
		SetScale/P  x,startx,stepx,"°", w_y
		SetScale/P  x,startx,stepx,"°", w_e
		SetScale d, 0,0,"cps", w_y
		SetScale d, 0,0,"cps", w_e
		killwaves w_x
	endif
	
	// check if w_e is empty (*.xy)
	if(checkemptywave(w_e) == 0)
		killwaves w_e
	endif
	
	killwaves filewave
	importloader.success = 1
	loaderend(importloader)
end
