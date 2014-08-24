// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.


function NSLSX15B_check_file(file)
	variable file
	fsetpos file, 0
	fstatus file
	if(V_logEOF<=4)
		return -1
	endif
	variable tmpd = 0
	fbinread /U/B=3/F=3 file, tmpd
	fstatus file
	if(numtype(tmpd)!=0 || tmpd<=0 || tmpd >= V_logEOF)
		fsetpos file, 0
		return -1
	endif
	fsetpos file, (tmpd-4)
	variable tmpd2 = 0
	fbinread /U/B=3/F=3 file, tmpd2
	fsetpos file, 0
	if(tmpd != tmpd2)
		return -1
	endif
	return 1
end


function NSLSX15B_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "NSLS beamline X15B"
	importloader.filestr = "*.dat"
	importloader.category = "XAS"
end


function NSLSX15B_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	NSLSX15B_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file

	variable headerlen =0, tmpd = 0
	fbinread /U/B=3/F=3 file, headerlen // length of header (mosly 212)
	Fbinread /B=3/F=3 file, tmpd
	header +="\rcomment: "+mybinread(file, tmpd)
	mybinread(file, 80-tmpd)
	variable start = 0, ende = 0
	Fbinread /B=3/F=4 file, start
	Fbinread /B=3/F=4 file, ende
	variable pts = 0, cols = 0
	Fbinread /B=3/F=3 file,pts
	Fbinread /B=3/F=3 file,cols
	fsetpos file, headerlen-4
	fbinread /U/B=3/F=3 file, tmpd
	if(headerlen != tmpd)
			Debugprintf2("Error reading header!",0)
			loaderend(importloader)
			return -1
	endif

	
	string tmps = "savewave"
	Make /O/R/N=(pts, cols+2)  $tmps /wave=savewave
	variable i=0, j=0
	for(j=0;j<pts;j+=1)
		Fbinread /B=3/F=3 file, cols
		for(i=0;i<(cols/4-2);i+=1)
			Fbinread /B=3/F=4 file, tmpd
			savewave[j][i]=tmpd
		endfor
		Fbinread /B=3/F=3 file,tmpd
		if(cols != tmpd)
			Debugprintf2("Error reading data array!",0)
			loaderend(importloader)
			return -1
		endif
	endfor
	note savewave, header
	SetScale/I  x,start,ende,"",  savewave


	splitmatrix(savewave,"data")
	for(i=0;i<(cols/4-2);i+=1)

			switch(i)
				case 0:
					tmps = "energy"
					break
				case 4:
					tmps = "I0"
					break
				case 6:
					tmps = "ch1"
					break
				case 7:
					tmps = "ch2"
					break
				case 8:
					tmps = "ch3"
					break
				case 9:
					tmps = "ch4"
					break
				case 10:
					tmps = "ch5"
					break
				default:
					tmps = "spk"+num2str(i)
					break
			endswitch
			if(WaveExists($tmps))
				tmps = UniqueName(tmps, 1, 0)
			endif
			rename $("data_spk"+num2str(i)), $tmps
	endfor	


	importloader.success = 1
	loaderend(importloader)
end
