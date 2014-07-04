// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.


// The FOURYA/XFIT/Koalariet XDD procedure is based on xylib by Marcin Wojdyr:
// https://github.com/wojdyr/xylib (https://github.com/wojdyr/xylib/blob/master/xylib/xfit_xdd.cpp)

Menu "Macros"
	submenu "Import Tool "+importloaderversion
			submenu "XRD"
				"Load XFIT						*.xdd	file... b1", XfitXdd_load_data()
			end
	end
end


// ###################### FOURYA/XFIT/Koalariet XDD file ########################
// FOURYA/XFIT/Koalariet XDD file

static function /S XfitXdd_skip_c_style_comments(file)
	variable file
	string line =""
	string comment = ""
	FReadLine file, line
	if(strlen(line)==0)
		Debugprintf2("Unexpected end of file",0)
		return "-1"
	endif
	line=mycleanupstr(line)
	if(strsearch(line,"/*",0)==-1)
		return line
	endif
	comment = cleanupname(line[strsearch(line,"/*",0)+2,inf],1) +"\r" //  header can have illegal characters
	do
		FReadLine file, line
		if(strlen(line)==0)
			Debugprintf2("Unexpected end of file",0)
			return "-1"
		endif
		line=mycleanupstr(line)
		if(strsearch(line,"*/",0)!=-1)
			comment += cleanupname(line[0,strsearch(line,"*/",0)-1],1)  //  header can have illegal characters
			return comment+"####"+line[strsearch(line,"*/",0)+2,inf]
		endif
		comment += line +"\r"
		Fstatus file
	while(V_logEOF>V_filePOS)
	return "-1"
end


function XfitXdd_check_file(file)
	variable file
	fsetpos file, 0
	string line = XfitXdd_skip_c_style_comments(file)
	line = line[strsearch(line,"####",0)+4,inf]
	if(cmpstr(line,"-1")==0)
		fsetpos file, 0
		return -1
	endif
	string templine = ReplaceString(" ",line,"")
	templine = ReplaceString("\t",line,"")
	if (strlen(templine) ==0)
		FReadLine file, line
	endif
	// we are looking for the first line with start-step-end numeric triple,
	// it should be one of the first (max_headers+1) lines
	string sep=","
	if(strlen(line)==0)
		fsetpos file, 0
		return -1
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
	if(itemsinlist(line,sep)<3)
		fsetpos file, 0
		return -1
	endif
	variable start = str2num(stringfromlist(0,line,sep))
	variable step = str2num(stringfromlist(1,line,sep))
	variable stop = str2num(stringfromlist(2,line,sep))
	variable counts = (stop-start)/step+1
	if(numtype(start) != 0 || numtype(stop) != 0 || numtype(step) != 0 || numtype(counts) != 0)
		fsetpos file, 0
		return -1
	endif
	fsetpos file, 0
	return 1
end


function XfitXdd_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "FOURYA/XFIT/Koalariet XDD"
	importloader.filestr = "*.xdd"
	importloader.category = "XRD"
end


function XfitXdd_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	XfitXdd_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header +"\r"
	variable file = importloader.file


	string line = XfitXdd_skip_c_style_comments(file)
	header += line[0,strsearch(line,"####",0)-1]
	line = line[strsearch(line,"####",0)+4,inf]
	if(cmpstr(line,"-1")==0)
		Debugprintf2("Error in comments! Bug in src??",0)
		close file
		return -1
	endif
	string templine = ReplaceString(" ",line,"")
	templine = ReplaceString("\t",line,"")
	if (strlen(templine) ==0)
		FReadLine file, line
	endif
	
	// we are looking for the first line with start-step-end numeric triple,
	// it should be one of the first (max_headers+1) lines
	string sep=","
	if(strlen(line)==0)
		Debugprintf2("Unexpected end of file",0)
		return -1
		close file
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
	if(itemsinlist(line,sep)<3)
		Debugprintf2("Header to short",0)
		Debugprintf2(line,0)
		close file
		return -1
	endif
	variable start = str2num(stringfromlist(0,line,sep))
	variable step = str2num(stringfromlist(1,line,sep))
	variable stop = str2num(stringfromlist(2,line,sep))
	variable counts = (stop-start)/step+1
	
	string tmps = getnameforwave(file)//"raw_scan"
	Make /O/R/N=(0)  $tmps /wave=ycols
	SetScale/P  x,start,step,"", ycols
	note ycols, header
	note ycols, "Start: "+num2str(start)
	note ycols, "Stop: "+num2str(stop)
	note ycols, "Step: "+num2str(step)
	note ycols, "Counts: "+num2str(counts)

	// in PSI_DMC there is a text following the data, so we read only as many
	// data lines as necessary
	sep = ","
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

		variable i=0
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
	while(size<counts)

	importloader.success = 1
	loaderend(importloader)
end

// ###################### FOURYA/XFIT/Koalariet XDD file END ######################
