// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// *.dsw --> data
// *.bsw --> batch
// *.csw --> baseline
// *.msw --> method
// *.rsw --> report


// 0 .. 3
static strconstant x_modestr = "nm;Å;cm-1;°"
// 0 .. 10
static strconstant y_modestr = "Abs;%T;Absorptivity;%R;4?;5?;Log(Abs);Absolute %R;F(R);Log(F(R));Log(1/R)"


static structure CARYBIN_param
	string Tstore_type
	variable spec_counter
	variable start_x
	variable end_x
	variable points
	variable blockoffset
	variable blocklen
	variable sbw
	string spectrum_name
	variable spectrum_number
	variable max_x
	variable min_x
	variable data_interval
	wave w_y
	wave w_x
	string header
	variable V_max
	variable V_min
	variable softversion
	variable x_mode
	variable y_mode
	variable flag1
endstructure


function CARYBIN_check_file(file)
	variable file
	fsetpos file, 0
	string line = ""
	fstatus file
	if(V_logEOF<18)
		fsetpos file, 0
		return -1
	endif
	variable tmp
	fbinread /B=3 /f=1 file, tmp
	if(tmp != 17)
		fsetpos file, 0
		return -1	
	endif
	line = mybinread(file, 17)
	fsetpos file, 0
	if(cmpstr(line, "Varian UV-VIS-NIR")==0)
		return 1
	endif
	return -1
end


function CARYBIN_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "Varian Cary WinUV binary"
	importloader.filestr = "*.dsw,*.bsw,*.csw"
	importloader.category = "UVvis"
end


function CARYBIN_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	CARYBIN_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file
	string tmps=""

	variable tmp, len, blocklen, blockoffset
	struct CARYBIN_param param
	param.header = header
	param.spec_counter = -1
	
	fbinread /U/B=3 /f=1 file, len // should be 17
	mybinread(file, len) // "Varian UV-VIS-NIR"
	mybinread(file, 61-len) // skip next 44 empty bytes

	do
		param.spec_counter+=1
		fstatus file
		param.blockoffset = V_filePos
		fbinread /U/B=3 /f=3 file, len
		param.Tstore_type = mybinread(file, len)
		fbinread /U/B=3 /f=3 file, param.blocklen
		strswitch(param.Tstore_type)
			case "TContinuumStore":
				Debugprintf2("TContinuumStore",1)
				// load header
				CARYBIN_load_header(file, param)
				// load binary data
				CARYBIN_load_bindata(file, param)
				// load ASCII footer
				CARYBIN_load_footer(file, param)
				Debugprintf2("... exported spectrum: "+param.spectrum_name,0)
				fsetpos file, (param.blocklen+param.blockoffset) // set to beginning of next block (necessary here for now!)
				break
			case "TGraphStore":
				Debugprintf2("TGraphStore",1)
				//fstatus file; print "###Pos:",V_filePos
				Debugprintf2("skipping block",1)
				fsetpos file, (param.blocklen+param.blockoffset)
				break
			case "TReportStore":
				Debugprintf2("TReportStore",1)
				//fstatus file; print "###Pos:",V_filePos
				Debugprintf2("skipping block",1)
				fsetpos file, (param.blocklen+param.blockoffset)
				break
			case "TDatabaseStore":
				Debugprintf2("TDatabaseStore",1)
				//fstatus file; print "###Pos:",V_filePos
				Debugprintf2("skipping block",1)
				fsetpos file, (param.blocklen+param.blockoffset)
				break
			case "TBaselineInfoStore":
				Debugprintf2("TBaselineInfoStore",1)
				//fstatus file; print "###Pos:",V_filePos
				Debugprintf2("skipping block",1)
				fsetpos file, (param.blocklen+param.blockoffset)
				break
			case "TBaselineStore":
				Debugprintf2("TBaselineStore",1)
				// load header
				CARYBIN_load_header(file, param)
				// load binary data
				CARYBIN_load_bindata(file, param)
				// load ASCII footer
				CARYBIN_load_footer(file, param)
				Debugprintf2("... exported Baseline: "+param.spectrum_name,0)
				fsetpos file, (param.blocklen+param.blockoffset) // set to beginning of next block (not really necessary here)
				break
			default:
				Debugprintf2("Error! Unknown type: "+param.Tstore_type,0)
				fstatus file
				fsetpos file, V_logEOF
				break
		endswitch

		fstatus file
		if(V_filePos==V_logEOF-4)
			break
		endif
	while(V_filePos<V_logEOF)

	importloader.success = 1
	loaderend(importloader)
end


static function CARYBIN_load_header(file, param)
	variable file
	struct CARYBIN_param &param
	variable len, tmp
	
	fbinread /U/B=3 /f=3 file, param.softversion // Scan Software Version x100
	fbinread /U/B=3 /f=3 file, tmp//; print tmp // alyways 149??
	fbinread /B=3 /f=4 file, param.end_x
	fbinread /B=3 /f=4 file, param.start_x
	fbinread /B=3 /f=4 file, param.V_min
	fbinread /B=3 /f=4 file, param.V_max
	fbinread /U/B=3 /f=3 file, param.points
	fbinread /B=3 /f=3 file, tmp//; print tmp
	fbinread /U/B=3 /f=2 file, tmp//; print tmp
	fbinread /U/B=3 /f=2 file, tmp//; print tmp
	fbinread /B=3 /f=3 file, tmp//; print tmp
	fbinread /B=3 /f=3 file, param.spectrum_number
	fbinread /B=3 /f=4 file, tmp//; print tmp
	fbinread /B=3 /f=3 file, tmp // skip (FFFF)
	fbinread /B=3 /f=4 file, tmp//; print tmp
	fbinread /B=3 /f=3 file, tmp//; print tmp // always 100??
	fbinread /B=3 /f=4 file, param.x_mode
	fbinread /B=3 /f=4 file, param.y_mode
#if 0
	fbinread /B=3 /f=3 file, tmp // skip (9595)
	fbinread /B=3 /f=4 file, tmp; print "UV-Vis Ave. Time (sec)",tmp
	fbinread /B=3 /f=4 file, tmp; print tmp
	fbinread /B=3 /f=4 file, tmp; print tmp
	fbinread /B=3 /f=4 file, param.max_x; print "max_x?", param.max_x
	fbinread /B=3 /f=4 file, param.min_x; print "min_x?", param.min_x
	fbinread /B=3 /f=4 file, param.sbw; print "sbw?",param.sbw
	fbinread /B=3 /f=4 file, tmp // endx again?
	fbinread /B=3 /f=4 file, tmp // startx again?
	fbinread /B=3 /f=4 file, tmp // skip (9595)
	fbinread /B=3 /f=4 file, tmp // skip (9595)
	fbinread /B=3 /f=4 file, tmp // skip (9595)
	fbinread /B=3 /f=4 file, tmp // skip (9595)
	fbinread /B=3 /f=4 file, tmp // skip (9595)
	fbinread /B=3 /f=4 file, tmp // skip (9595)
	fbinread /B=3 /f=4 file, tmp; print tmp
	fbinread /B=3 /f=4 file, tmp; print tmp
	fbinread /B=3 /f=4 file, tmp; print "Acceptable S/N?", tmp
	fbinread /B=3 /f=4 file, tmp; print tmp
	fbinread /B=3 /U/f=3 file, tmp; print tmp
	fbinread /B=3 /f=4 file, tmp; print tmp
	fbinread /B=3 /f=4 file, tmp; print "UV-Vis Ave. Time (sec) or for NIR",tmp
	fbinread /B=3 /f=4 file, tmp; print tmp
	fbinread /B=3 /f=4 file, tmp; print tmp
	fbinread /B=3 /f=4 file, tmp; print tmp
	fbinread /B=3 /f=4 file, tmp; print tmp
	fbinread /B=3 /f=4 file, tmp; print "Beammode?: ",tmp // 0 .. SingleFront; 1 .. SingleRear; 4 .. Double
	fbinread /B=3 /f=4 file, tmp; print tmp
	fbinread /B=3 /f=4 file, tmp; print tmp
	fbinread /B=3 /f=4 file, tmp; print tmp
	fbinread /B=3 /f=4 file, tmp // skip (9595)
	fbinread /B=3 /f=4 file, tmp // skip (9595)
	fbinread /B=3 /f=4 file, tmp // skip (9595)
	fbinread /B=3 /f=4 file, tmp // skip (9595)
	fbinread /B=3 /f=4 file, tmp // skip (9595)
	fbinread /B=3 /f=4 file, tmp // skip (9595)
	fbinread /B=3 /f=4 file, tmp // skip (9595)
	fbinread /B=3 /f=4 file, tmp // skip (9595)
	fbinread /B=3 /f=4 file, tmp // skip (9595)
	fbinread /B=3 /f=4 file, tmp // skip (9595)
	fbinread /B=3 /f=4 file, tmp // skip (9595)
	fbinread /B=3 /f=4 file, tmp // skip (9595)
	fbinread /B=3 /f=4 file, tmp // skip (9595)
	fbinread /B=3 /f=4 file, tmp // skip (9595)
	fbinread /B=3 /f=4 file, tmp // skip (9595)
	fbinread /B=3 /f=4 file, tmp // skip (9595)
	fbinread /B=3 /f=4 file, tmp // skip (9595)
	fbinread /B=3 /f=4 file, tmp // skip (9595)
	fbinread /B=3 /U/f=2 file, param.flag1; print "filepath flag?", param.flag1 // 512 filepath at 589 --> 527
	fbinread /B=3 /f=2 file, tmp; print tmp
	fbinread /B=3 /f=3 file, tmp; print tmp
	fbinread /B=3 /f=3 file, tmp; print tmp
	fbinread /B=3 /f=4 file, tmp; print tmp
	fbinread /B=3 /f=2 file, tmp; print tmp
	fbinread /B=3 /f=2 file, tmp; print tmp
	fbinread /B=3 /f=3 file, tmp; print tmp
	fbinread /B=3 /f=3 file, tmp; print tmp
	fbinread /B=3 /f=3 file, tmp; print tmp
	fbinread /B=3 /f=3 file, tmp; print tmp
	fbinread /B=3 /f=3 file, tmp; print tmp
	fbinread /B=3 /f=3 file, tmp; print tmp
	fbinread /B=3 /f=3 file, tmp; print tmp
	fbinread /B=3 /f=3 file, tmp; print tmp
	fbinread /B=3 /f=3 file, tmp; print tmp
	fbinread /B=3 /f=3 file, tmp; print tmp
	fbinread /B=3 /f=3 file, tmp; print tmp
	fbinread /B=3 /f=3 file, tmp; print tmp
	fbinread /B=3 /U/f=2 file, tmp; print tmp
	fbinread /B=3 /U/f=2 file, tmp; print tmp
	fbinread /B=3 /f=2 file, tmp; print tmp
	fbinread /B=3 /f=2 file, tmp; print tmp
	// position of file path (How to determine the correct offset?)
	//fsetpos file, param.blockoffset+603 // 665-66+4 = 603 or 589-66+4 = 527 or 725-66+4 = 663
	if(param.flag1 == 512)
		fsetpos file, param.blockoffset+527 // 589-66+4 = 527
		print CARYBIN_read_UTF16(file, 12/2) // potential file path?
		mybinread(file, 2) // skip next char, should always be 0
		print CARYBIN_read_UTF16(file, 254/2) // potential file path?
	endif
#endif
	


	strswitch(param.Tstore_type)
		case "TContinuumStore":
			fsetpos file, 789+param.blockoffset+4+2
			param.spectrum_name = mycleanupstr(mybinread(file, 256))
			break
		case "TBaselineStore":
			fsetpos file, 788+param.blockoffset+4+2
			param.spectrum_name = mycleanupstr(mybinread(file, 256))
			break
	endswitch

end


static function CARYBIN_load_footer(file, param)
	variable file
	struct CARYBIN_param &param
	string tmps
	variable len
	
	do
		// the last entry (last 100 bytes are strange for TContinuumStore)
		fbinread /U/B=3 /f=3 file, len
		tmps = stripstrfirstlastspaces(mycleanupstr(mybinread(file, len)))
		note param.w_y, tmps
		fstatus file
	while(V_filePos<(param.blockoffset+param.blocklen))
end



static function CARYBIN_load_bindata(file, param)
	variable file
	struct CARYBIN_param &param
	
	string x_unit, y_unit
	variable factoreV = 1
	x_unit = stringfromlist(param.x_mode,x_modestr)
	y_unit = stringfromlist(param.y_mode,y_modestr)
	switch(param.x_mode)
		case 0: // nm
			//x_unit = "nm"
			factoreV = 1239.8424
			break
		case 1: // Angstroms
			//x_unit = "A"
			factoreV = 12398.424
			break
		case 2: // Wavenumbers
			//x_unit = "cm-^1"
			factoreV = 8065.54429
			break
		case 3: // angle?
			//x_unit = "°"
			break
	endswitch

	string tmps = num2str(param.spec_counter)+"_"+cleanname(param.spectrum_name)+"_"+x_unit
	Make /O/D/N=(param.points)  $tmps; wave param.w_x = $tmps
	tmps = num2str(param.spec_counter)+"_"+cleanname(param.spectrum_name)
	Make /O/D/N=(param.points)  $tmps; wave param.w_y = $tmps

	variable i, tmp
	for(i=0;i<param.points;i+=1)
		fbinread /B=3 /f=4 file, tmp
		param.w_x[i] = tmp
		fbinread /B=3 /f=4 file, tmp
		param.w_y[i] = tmp
	endfor
	tmps = param.header
	note param.w_y, tmps
	note param.w_x, tmps



	SetScale /I x, param.start_x, param.end_x  ,x_unit , param.w_y
	SetScale d 0,100,y_unit, param.w_y

	
	if(str2num(get_flags(f_onlyDET))==0)
		tmps = num2str(param.spec_counter)+"_"+cleanname(param.spectrum_name)+"_eV"
		duplicate param.w_x,$tmps
		wave w_xeV = $tmps		
		if(param.x_mode == 2)
			w_xeV = param.w_x[p]/factoreV
		else
			w_xeV = factoreV/param.w_x[p] // energy = h*c/length
		endif
		SetScale /P x, 0, 1  ,"eV" , w_xeV
	endif

	if(checkEnergyScale(param.w_x, 1E-6) == 1)
		variable startx = param.w_x[0]
		variable stepx = param.w_x[1] - param.w_x[0]
		SetScale/P  x,startx,stepx,x_unit, param.w_y
		wave tmpwave = param.w_x
		killwaves tmpwave
	endif
end


static function /S CARYBIN_read_UTF16(file, counts)
	variable file, counts
	variable i
	string tmps = ""
	for(i=0;i<counts;i+=1)
		fstatus file
		if(V_filePos>=V_logEOF-2)
			break
		endif
		tmps += mybinreadBE(file, 1)	// read char
		mybinreadBE(file, 1)			// skip byte
	endfor
	return tmps
end
