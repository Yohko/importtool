// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

// The RIET7/LHPM/CSRIET procedure is based on xylib by Marcin Wojdyr:
// https://github.com/wojdyr/xylib (https://github.com/wojdyr/xylib/blob/master/xylib/riet7.cpp)

#ifdef showmenu
Menu "Macros"
	submenu "Import Tool "+importloaderversion
			submenu "XRD"
				"RIET7-ILL_D1A5-PSI_DMC		*.dat	file... b1",  Riet7_load_data()
			end
	end
end
#endif


// ###################### RIET7/LHPM/CSRIET DAT ########################
// RIET7/LHPM/CSRIET DAT,  ILL_D1A5 and PSI_DMC formats
// .dat is popular extension for data, we want to avoid false positives.
// This format has line starting with three numbers: start step end
// somewhere in the first few lines, and it has intensities (in any format)
// in the following lines. We use here following rules:
// - try to read start-step-end from the first 6 lines:
// one of the first 6 lines must start with three numbers, such that
// n = (end - start) / step is an integer,
// - the start-step-end line and the next line must have different format
// (if they have the same format, it's more likely xy format)


function Riet7_check_file(file)
	variable file
	fsetpos file, 0
	variable i=0, n=0, count =0, dcount =0,n2=0
	variable start=0, stop=0, step=0
	string line = ""
	for(i = 0; i < 6; i+=1)
		FReadLine file, line
		if(strlen(line)==0)
			fsetpos file, 0
			return -1
		endif
		line=mycleanupstr(line)
		line = splitintolist(line," ")
		n=0
		for(count=0; count < itemsinlist(line,"_"); count+=1)
			if(numtype(str2num(stringfromlist(count,line,"_")))==0)
				n+=1
			endif
		endfor
		if (n < 3)
			continue
		endif
		start = str2num(stringfromlist(0,splitintolist(line," "),"_"))
		step = str2num(stringfromlist(1,splitintolist(line," "),"_"))
		stop = str2num(stringfromlist(2,splitintolist(line," "),"_"))
		
		if(numtype(start)!=0|| numtype(step)!=0 || numtype(stop)!=0)
			continue
		endif
		dcount = (stop - start) / step + 1
		count = floor(dcount + 0.5)
		if ((count < 4) || (abs(count - dcount) > 1e-2))
			continue
		endif
		FReadLine file, line
		if(strlen(line)==0)
			fsetpos file, 0
			return -1
		endif
		line=mycleanupstr(line)
		n2=0
		for(count=0; count < itemsinlist(line,"_"); count+=1)
			if(numtype(str2num(stringfromlist(count,line,"_")))==0)
				n2+=1
			endif
		endfor
		if(n2!=n)
			fsetpos file, 0
			return 1
		else
			fsetpos file, 0
			return -1
		endif
	endfor
	fsetpos file, 0
	return -1
end


function Riet7_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "RIET7"
	importloader.filestr = "*.dat,*.rit"
	importloader.category = "XRD"
end


function Riet7_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	Riet7_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file

	variable start=0, stop=0, step=0, n=0, count =0, dcount =0
	variable tmp=0,i=0
	string line = "",tmps="", tmps2="", comment = ""
	for(i = 0; i < 6; i+=1)
		FReadLine file, line
		if(strlen(line)==0)
			return 0
		endif
		line=mycleanupstr(line)
		tmps2=line
		line = splitintolist(line," ")
		n=0
		for(count=0; count < itemsinlist(line,"_"); count+=1)
			tmps=stringfromlist(count,line,"_")
			tmp = str2num(tmps)
			if(numtype(tmp)==0)
				n+=1
			endif
		endfor
		if (n < 3)
			comment += cleanupname(tmps2,1)+"\r" // they have illegal chars in header
			continue
		endif
		start = str2num(stringfromlist(0,splitintolist(line," "),"_"))
		step = str2num(stringfromlist(1,splitintolist(line," "),"_"))
		stop = str2num(stringfromlist(2,splitintolist(line," "),"_"))
		if(numtype(start)!=0|| numtype(step)!=0 || numtype(stop)!=0)
			comment += cleanupname(tmps2,1)+"\r"  // they have illegal chars in header
			continue
		endif
		count = (stop - start) / step + 1
		Debugprintf2("Start: "+num2str(start),1)
		Debugprintf2("Step: "+num2str(step),1)
		Debugprintf2("Stop: "+num2str(stop),1)
		Debugprintf2("Count: "+num2str(count),1)
				
		dcount = floor(count + 0.5)//iround(dcount)
		if ((dcount < 4) || (abs(count - dcount) > 1e-2))
			Debugprintf2("Error: " + num2str(abs(count - dcount)),1)
			comment += cleanupname(tmps2,1)+"\r" // they have illegal chars in header
			continue
		else
			break
		endif
	endfor

	tmps = getnameforwave(file)//"raw_scan"
	Make /O/R/N=(0)  $tmps /wave=ycols
	SetScale/P  x,start,step,"", ycols
	note ycols, header
	note ycols, comment
	note ycols, "Start: "+num2str(start)
	note ycols, "Stop: "+num2str(stop)
	note ycols, "Step: "+num2str(step)
	note ycols, "Counts: "+num2str(count)

	// in PSI_DMC there is a text following the data, so we read only as many
	// data lines as necessary
	string sep = ","
	variable size = 0
	do
		FReadLine file, line
		if(strlen(line)==0)
			break
		endif
		line=mycleanupstr(line)
		if(strsearch(line,sep,0)!=-1)
			line= ReplaceString(" ",line,"")
		else
			if(strsearch(line,"\t",0)==-1)
				line=splitintolist(line, " ")
				sep = "_"
			else
				line=splitintolist(line, "\t")
				sep = "_"
			endif
		endif


		for(i=0;i<itemsinlist(line,sep);i+=1)
			if(numtype(str2num(StringFromList(i,line,sep))) != 0)
				Debugprintf2("Numeric value expected",0)
				close file
				return -1
			endif
			Redimension/N=(size+1) ycols
			ycols[size] = str2num(StringFromList(i,line,sep))
			size+=1
		endfor
	while(size<dcount)
	importloader.success = 1
	loaderend(importloader)
end


// ###################### RIET7/LHPM/CSRIET DAT END ######################
