// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

// The chiplot procedure is based on xylib by Marcin Wojdyr:
// https://github.com/wojdyr/xylib (https://github.com/wojdyr/xylib/blob/master/xylib/chiplot.cpp)


Menu "Macros"
	submenu "Import Tool "+importloaderversion
			submenu "MISC"
				"Load ChiPlot					*.chi	file... beta", ChiPlot_load_data()
			end
	end
end


// ###################### chiplot ########################
// chiplot text format - 4 line of headers followed by x y data lines
// Description from
// http://www.esrf.eu/computing/scientific/FIT2D/FIT2D_REF/node115.html
// http://www.esrf.eu/computing/scientific/FIT2D/FIT2D_REF/node115.html#SECTION0001851500000000000000
// 
// The standard $\chi$PLOT data format is a very simple format allowing input of
// one or more data-sets together with title and axis labels, and accompanying
// text. Error estimates may be defined. (...)
// 
// The minimum file format is as follows: (...)
// 
// The first line is the title of the graph, the second is the label to be written
// for the X-axis, and the third line is the label for the Y-axis. (...)
// 
// The fourth line specifies how many data points are present in each of the
// data-sets, and how many data-sets to input.
// This line should contain two integers separated by a one or more spaces or a
// comma. If the second integer is missing it is assumed that only one curve is
// required.
// 
// The next '*' lines of the file should contain the data to be plotted; where '*'
// is the number of data points specified in line four. Each line should contain
// the value for the X-coordinate, and the values of the Y-coordinates for the
// different curves. (Note: All the curves share the same X-coordinates.)
// (...) the values being separated by a blank space or a comma. (...)
// 
// The following example shows a file which produces a single curve. Note on line
// four of the file the number of curves is not specified so one is assumed.
// 
// Figure 1. SINGLE DATA-SET
// X AXIS UNITS
// Y AXIS UNITS
// 10
// 1 5e-2
// 2., 5.9e-2
// 3. 6.7e-2
// 4 6.8e-2
// 5 6.6e-2
// 6 5e-2
// 7 4.1e-2
// 8 2e-2
// 9 0.6e-2
// 10 -2.6e-2


static function ChiPlot_get_dataline(line)
	string &line
	line = stripstrfirstlastspaces(line)
	if(strlen(line)==0)
		return -1
	endif	
	if(strsearch(line, ",",0)!=-1)
		line = ReplaceString(" ",line,"") // remove space
		line = ReplaceString("\t",line,"") // remove tabs
		line = splitintolist(line, ",")
	else
		line = splitintolist(line, " ")
	endif
	variable i=0
	for(i=0;i<itemsinlist(line,"_");i+=1)
		if(numtype(str2num(stringfromlist(i,line,"_")))!=0)
			return -1
		endif	
	endfor	
	return 1
end


function ChiPlot_check_file(file)
	variable file
	fsetpos file, 0
	string line = ""
	variable i=0
	for(i = 0; i < 4; i+=1)
		FReadLine file, line
		if(strlen(line) == 0)
			fsetpos file, 0
			return -1
		endif
	endfor
	// check 4. line
	line = mycleanupstr(line)
	if(ChiPlot_get_dataline(line)==-1)
		fsetpos file, 0
		return -1
	endif
	if(itemsinlist(line,"_") < 1 || itemsinlist(line,"_") > 2) // max two cols
		fsetpos file, 0
		return -1
	endif
	variable n_points = str2num(StringFromList(0,line,","))
	variable n_ycols = 1
	if(itemsinlist(line,"_")>1)
		n_ycols = str2num(StringFromList(1,line,","))
	endif
	if(n_points <= 0 || n_ycols <= 0 || n_points > 2E6) // expect positive number
		fsetpos file, 0
		return -1
	endif
	// check 5. line
	FReadLine file, line
	fsetpos file, 0
	if(strlen(line) == 0)
		return -1
	endif
	line = mycleanupstr(line)
	if(ChiPlot_get_dataline(line)==-1)
		return -1
	endif
	if(itemsinlist(line,"_") != (n_ycols+1))
		return -1
	endif
	return 1
end



function ChiPlot_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "ChiPlot"
	importloader.filestr = "*.chi"
	importloader.category = "plot"
end


function ChiPlot_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	ChiPlot_load_data_info(importloader)
	 if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file
	
	header+="\r"

	string graph_title = read_line_trim(file)
	string x_label = read_line_trim(file)
	string y_label = read_line_trim(file)
	string line = read_line_trim(file)
	if(ChiPlot_get_dataline(line)==-1)
		loaderend(importloader)
		return -1
	endif
	if(itemsinlist(line,"_") < 1 ||itemsinlist(line,"_") > 2)
		Debugprintf2("expected 1 or 2 number(s) in line 4",0)
		loaderend(importloader)
		return -1
	endif
	variable n_points = str2num(StringFromList(0,line,","))
	variable n_ycols = 1
	if(itemsinlist(line,"_")>1)
		n_ycols = str2num(StringFromList(1,line,","))
	endif
	if(n_points <= 0 || n_ycols <= 0)
		Debugprintf2("expected positive number(s) in line 4",0)
		loaderend(importloader)
		return -1
	endif 
	
	Make /O/R/N=(n_points,n_ycols+1)  $graph_title /wave=ycols
	note ycols, header

	variable i=0,j=0
	for (i = 0; i != n_points; i+=1) 
		line = read_line_trim(file)
		if(ChiPlot_get_dataline(line)==-1)
			Debugprintf2("Error in line " + num2str(5+i) + ", column " + num2str(j+1),0)
			loaderend(importloader)
			return -1
		endif
		for (j = 0; j != n_ycols + 1; j+=1) 
			ycols[i][j]=str2num(StringFromList(j,line,"_"))
		endfor
	endfor
	Note ycols, "Graph title: " + graph_title
	Note ycols, "x_label: " + x_label
	Note ycols, "y_label: " + y_label
	splitmatrix(ycols,"spectra")
	importloader.success = 1
	loaderend(importloader)
end

// ###################### chiplot END ######################
