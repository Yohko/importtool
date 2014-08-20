// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

function SSRLA_check_file(file)
	variable file
	fsetpos file, 0
	string line = ""
	line = myreadline(file)
	if(strsearch(line, "SSRL   EXAFS Data Collector ",0) !=0)
		fsetpos file, 0
		return -1
	endif
	line = myreadline(file)
	line = myreadline(file)
	if(strsearch(line, "PTS:",0) !=0 || strsearch(line, "COLS:",0) == -1)
		fsetpos file, 0
		return -1
	endif
	fsetpos file, 0
	return 1
end


function SSRLA_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "ASCII SSRL EXAFS data"
	importloader.filestr = "*.dat"
	importloader.category = "XAS"
end


function SSRLA_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	SSRLA_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file
	
	string tmps = myreadline(file)
	tmps = stripstrfirstlastspaces(tmps)
	variable version = str2num(tmps[strlen("SSRL   EXAFS Data Collector "),inf])
	tmps = myreadline(file)
	header += "\rDate: "+stripstrfirstlastspaces(tmps)
	tmps = splitintolist(myreadline(file), " ")


	variable pts = str2num(stringfromlist(1,tmps, "_"))
	variable cols = 	str2num(stringfromlist(3,tmps, "_"))
	tmps = myreadline(file) // scaler_file
	header += "\rScaler file: "+tmps
	tmps = myreadline(file) // region_file
	header += "\rRegion file: "+tmps
	tmps = myreadline(file) // mirror info
	header += "\rMirror Info: "+tmps
	tmps = myreadline(file) // mirror param
	header += "\rMirror param: "+tmps
	tmps = myreadline(file) // User comments #1
	header += "\rComment #1: "+tmps
	tmps = myreadline(file) // User comments #2
	header += "\rComment #2: "+tmps
	tmps = myreadline(file) // User comments #3
	header += "\rComment #3: "+tmps
	tmps = myreadline(file) // User comments #4
	header += "\rComment #4: "+tmps
	tmps = myreadline(file) // User comments #5
	header += "\rComment #5: "+tmps
	tmps = myreadline(file) // User comments #6
	header += "\rComment #6: "+tmps
	myreadline(file)

	variable i=0, tmpd=0
	// weights	
	tmps = myreadline(file)
	if(strsearch(tmps, "Weights:",0) !=0)
		loaderend(importloader)
		return -1
	endif
	string weights = splitintolist(stripstrfirstlastspaces(myreadline(file)), " ")

	// offsets
	tmps = myreadline(file)
	if(strsearch(tmps, "Offsets:",0) !=0)
		loaderend(importloader)
		return -1
	endif
	string offsets = splitintolist(stripstrfirstlastspaces(myreadline(file)), " ")

	// Data labels
	tmps = myreadline(file)
	if(strsearch(tmps, "Data:",0) !=0)
		loaderend(importloader)
		return -1
	endif
	string labels = ""
	for(i=0;i<cols;i+=1)
		labels +=stripstrfirstlastspaces(myreadline(file))+";"
	endfor
	myreadline(file)
	// pts x cols data array
	tmps = "tmpddata"
	Make /O/R/N=(pts, cols)  $tmps /wave=tmpdata
	variable j=0
	for(i=0;i<pts;i+=1)
		tmps = splitintolist(myreadline(file), " ")

		for(j=0;j<cols;j+=1)
				tmpdata[i][j]=str2num(stringfromlist(j,tmps, "_"))
		endfor
	endfor
	note tmpdata, header
	splitmatrix(tmpdata,"tmpdata")
	for(i=0;i<cols;i+=1)
			tmps = stringfromlist(i,labels,";")
			if(WaveExists($tmps))
				tmps = UniqueName(tmps, 1, 0)
			endif
			rename $("tmpdata_spk"+num2str(i)), $tmps
			note $tmps, "Weight: "+stringfromlist(i,weights,"_")
			note $tmps, "Offset: "+stringfromlist(i,offsets,"_")
	endfor	
	importloader.success = 1
	loaderend(importloader)
end
