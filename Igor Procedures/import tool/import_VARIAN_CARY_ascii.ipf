// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


function CARYASCII_check_file(file)
	variable file
	fsetpos file, 0
	string names = mycleanupstr(myreadline(file))
	string names2  = mycleanupstr(myreadline(file))
	string numbers  = mycleanupstr(myreadline(file))
	fsetpos file, 0
	if(itemsinlist(names,",")!=itemsinlist(names2,",") || itemsinlist(names,",")!=itemsinlist(numbers,","))
		return -1
	endif
	variable i
	for(i=0;i<itemsinlist(names,",")/2;i+=1)
		if(strlen(stringfromlist(2*i+1,names,","))!=0)
			return -1
		endif
		if(cmpstr(stringfromlist(2*i,names2,","),"Wavelength (nm)")!=0)
			return -1
		endif
	endfor
	for(i=0;i<itemsinlist(names,",");i+=1)
		if(numtype(str2num(stringfromlist(i,numbers,",")))!=0)
			return -1
		endif
	endfor
	return 1
end


function CARYASCII_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "Varian Cary WinUV ASCII"
	importloader.filestr = "*.csv"
	importloader.category = "UVvis"
end


function CARYASCII_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	CARYASCII_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file
	string tmps=""

	string names = mycleanupstr(myreadline(file))
	string names2  = mycleanupstr(myreadline(file))

	variable columns = itemsinlist(names2,",")
	tmpS = "tmpDATA" ; Make /O/D/N=(0,columns) $tmpS ; wave w_tmpDATA = $tmpS
	
	variable i = 0, j=0
	do
		i+=1
		tmps = mycleanupstr(myreadline(file))
		if(strlen(tmps) == 0  || itemsinlist(names2,",") != columns)
			break
		endif

		redimension /n=(i,-1) w_tmpDATA
		for(j=0;j<columns;j+=1)
			w_tmpDATA[i-1][j] = str2num(StringFromList(j, tmps, ","))
		endfor
		fstatus file
	while(V_logEOF>V_filePOS)
	note w_tmpDATA, header
	
	// points now to the end of data where additional params follow
	do
		tmps = mycleanupstr(myreadline(file))
		note w_tmpDATA, tmps
		fstatus file
	while(V_logEOF>V_filePOS)

	// split data matrix into single waves and rename them
	splitmatrix(w_tmpDATA, "DATA")
	string s_unit, s_name

	// first x columns
	for(j=0;j<columns;j+=2)
		tmps = StringFromList(j, names2, ",")		
		s_unit = tmps[strsearch(tmps, " (", 0)+2,strlen(tmps)-2]
		s_name = tmps[0,strsearch(tmps, " (", 0)-1]
		tmps = num2str(j/2)+"_"+CleanupName(s_name,0)
		// shorten name if necessary
		tmps =  shortname(tmps, 28)
		SetScale /P x, 0, 1  ,s_unit , $("DATA_spk"+num2str(j))
		rename $("DATA_spk"+num2str(j)), $(tmps+"_"+s_unit)
		if(cmpstr(s_unit,"nm") == 0 && str2num(get_flags(f_onlyDET))==0)
			wave w_t1 = $(tmps+"_"+s_unit)
			duplicate $(tmps+"_"+s_unit),$(tmps+"_eV")
			wave w_t2 = $(tmps+"_eV")
			w_t2[] = 1239.8424/w_t1[p] //energy = h*c/length
			SetScale /P x, 0, 1  ,"eV" , w_t2
		endif
	endfor

	// second y columns
	for(j=1;j<columns;j+=2)
		tmps = StringFromList(j-1, names, ",")
		tmps = num2str((j-1)/2)+"_"+CleanupName(tmps,0)
		// shorten name if necessary
		tmps =  shortname(tmps, 31)
		rename $("DATA_spk"+num2str(j)), $(tmps)
		wave w_t1 = $(num2str((j-1)/2)+"_Wavelength_nm")
		if(WaveExists(w_t1)!=0)
			if(checkEnergyScale(w_t1, 1E-6) == 1)
				variable startx = w_t1[0]
				variable stepx = w_t1[1] - w_t1[0]
				SetScale/P  x,startx,stepx,"nm", $(tmps)
				killwaves w_t1
			endif
		endif
	endfor
	
	importloader.success = 1
	loaderend(importloader)
end
