// Licence: Lesser GNU Public License 2.1 (LGPL)#pragma rtGlobals=1		// Use modern global access method.// file generated by EC-Lab (Bio-Logic-Science Instruments)// http://www.bio-logic.info/potentiostat-electrochemistry-ec-lab/Menu "Macros"	submenu "Import Tool "+importloaderversion		submenu "E-Chem"			"EC-Lab text						*.mpt	file... beta", BIOLOGICmpt_load_data()		end	endendfunction BIOLOGICmpt_load_data_info(importloader)	struct importloader &importloader	importloader.name = "EC-Lab text"	importloader.filestr = "*.mpt"endfunction  BIOLOGICmpt_load_data([optfile])	variable optfile	optfile = paramIsDefault(optfile) ? -1 : optfile	struct importloader importloader	BIOLOGICmpt_load_data_info(importloader)	if(loaderstart(importloader, optfile=optfile)!=0)		return -1	endif	string header = importloader.header	variable file = importloader.file	string tmps = mycleanupstr(myreadline(file))	if(cmpstr(tmps, "EC-Lab ASCII FILE")!=0)		Debugprintf2("Invalid header!",0)		loaderend(importloader)		return -1		endif		// how many header lines in total	tmps = mycleanupstr(myreadline(file))	variable headerlines = 0	if(strsearch(tmps, "Nb header lines",0)!=-1)		headerlines = str2num(tmps[strsearch(tmps, ":",0)+1,inf])		if(numtype(headerlines)!=0)			Debugprintf2("Error in header lines!",0)			loaderend(importloader)			return -1			endif	else		Debugprintf2("Invalid header!",0)		loaderend(importloader)		return -1	endif	variable i=0	// three lines: EC-LAB ASCII, header lines, and header names; rest are comments 	for(i=3;i<headerlines;i+=1)		header +="\r+Comment "+num2str(i-2)+": "+mycleanupstr(myreadline(file))	endfor	// now getting name of columns	string wavenamelist = mycleanupstr(myreadline(file))//splitintolist(myreadline(file),"\t")	tmpS = "tmpwavearray" ; Make /O/D/N=(0,ItemsInList(wavenamelist,"\t")) $tmpS ; wave datawave = $tmpS	variable datacount = 1		// reading the data	do		redimension /N=(datacount,-1) datawave		tmps =mycleanupstr(myreadline(file))		if(ItemsInList(wavenamelist,"\t")!=ItemsInList(tmps,"\t"))			Debugprintf2("Column count mismatch!",0)			loaderend(importloader)			return -1		endif		tmps =ReplaceString(",",tmps,".")		for(i=0;i<ItemsInList(tmps,"\t");i+=1)			if(numtype(str2num(StringFromList(i,tmps, "\t")))!=0)				Debugprintf2("Error reading data!",0)				loaderend(importloader)				return -1			else				datawave[datacount-1][i] =str2num(StringFromList(i,tmps, "\t"))			endif		endfor				datacount+=1		fstatus file	while(V_logEOF>V_filePOS)		// adding notes and renaming waves	note datawave, header	splitmatrix(datawave, "0")	for(i=0;i<ItemsInList(wavenamelist,"\t");i+=1)		note $("0_spk"+num2str(i)), "Name: "+StringFromList(i,wavenamelist, "\t")		rename $("0_spk"+num2str(i)), $(num2str(i)+"_"+ cleanname(StringFromList(i,wavenamelist, "\t")))		Debugprintf2("... exporting: "+StringFromList(i,wavenamelist, "\t"),0)	endfor		importloader.success = 1	loaderend(importloader)end