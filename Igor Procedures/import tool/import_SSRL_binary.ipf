// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

function SSRLB_check_file(file)
	variable file
	fsetpos file, 0
	fstatus file
	if(V_logEOF<=800)
		return -1
	endif
	string line = mybinread(file,38); mybinread(file,2)
	if(strsearch(line, "SSRL - EXAFS Data Collector",0) !=0)
		fsetpos file, 0
		return -1
	endif
	line = mybinread(file,38); mybinread(file,2)
	line = mybinread(file,38); mybinread(file,2)
	if(strsearch(line, "PTS:",0) !=0 || strsearch(line, "COLS:",0) == -1)
		fsetpos file, 0
		return -1
	endif
	fsetpos file, 0
	return 1
end


function SSRLB_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "Binary SSRL EXAFS data"
	importloader.filestr = "*.dat"
	importloader.category = "XAS"
end


function SSRLB_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	SSRLB_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file
	
	string tmps = mybinread(file,38); mybinread(file,2)
	tmps = stripstrfirstlastspaces(tmps)
	variable version = str2num(tmps[strlen("SSRL - EXAFS Data Collector "),inf])
	tmps = mybinread(file,38); mybinread(file,2)
	header += "\rDate: "+stripstrfirstlastspaces(tmps)
	tmps = mybinread(file,38); mybinread(file,2)
	variable pts = str2num(stringfromlist(1,tmps, " "))
	variable cols = 	str2num(stringfromlist(3,tmps, " "))
	tmps = mybinread(file,38); mybinread(file,2) // scaler_file
	header += "\rScaler file: "+tmps
	tmps = mybinread(file,38); mybinread(file,2) // region_file
	header += "\rRegion file: "+tmps
	tmps = mybinread(file,78); mybinread(file,2) // mirror info
	header += "\rMirror Info: "+tmps
	tmps = mybinread(file,38); mybinread(file,2) // mirror param
	header += "\rMirror param: "+tmps
	tmps = mybinread(file,78); mybinread(file,2) // User comments #1
	header += "\rComment #1: "+tmps
	tmps = mybinread(file,78); mybinread(file,2) // User comments #2
	header += "\rComment #2: "+tmps
	tmps = mybinread(file,78); mybinread(file,2) // User comments #3
	header += "\rComment #3: "+tmps
	tmps = mybinread(file,78); mybinread(file,2) // User comments #4
	header += "\rComment #4: "+tmps
	tmps = mybinread(file,78); mybinread(file,2) // User comments #5
	header += "\rComment #5: "+tmps
	tmps = mybinread(file,78); mybinread(file,2) // User comments #6
	header += "\rComment #6: "+tmps
	variable i=0, tmpd=0
	// offsets
	string offsets = ""
	for(i=0;i<cols;i+=1)
		if(version<2)
			tmpd = from_pdp11(mybinread(file,4))
		else
			Fbinread /B=3/F=4 file, tmpd
		endif
		offsets +=num2str(tmpd)+";"
	endfor
	// weights
	string weights = ""
	for(i=0;i<cols;i+=1)
		if(version<2)
			tmpd = from_pdp11(mybinread(file,4))
		else
			Fbinread /B=3/F=4 file, tmpd
		endif
		weights +=num2str(tmpd)+";"
	endfor		
	// labels for each column
	string labels = ""
	for(i=0;i<cols;i+=1)
		labels +=stripstrfirstlastspaces(mybinread(file, 18))+";"; mybinread(file,2)
	endfor
	// 16 bytes
	Fbinread /U/B=3/F=3 file, tmpd // pts
	Fbinread /B=3/F=3 file, tmpd //??
	from_pdp11(mybinread(file,4)) //??
	Fbinread /U/B=3/F=2 file, tmpd //??
	Fbinread /U/B=3/F=2 file, tmpd //??
	// pts x cols x 4bytes data array
	tmps = "tmpddata"
	Make /O/R/N=(pts, cols)  $tmps /wave=tmpdata
	variable j=0
	for(i=0;i<pts;i+=1)
		for(j=0;j<cols;j+=1)
			if(version<2)
				tmpdata[i][j]=from_pdp11(mybinread(file,4))
			else
				Fbinread /B=3/F=4 file, tmpd
				tmpdata[i][j] = tmpd
			endif
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
			note $tmps, "Weight: "+stringfromlist(i,weights,";")
			note $tmps, "Offset: "+stringfromlist(i,offsets,";")
	endfor	
	importloader.success = 1
	loaderend(importloader)
end
