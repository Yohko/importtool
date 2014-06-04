// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

// The Brucker Raw procedure is based on xylib by Marcin Wojdyr:
// https://github.com/wojdyr/xylib (https://github.com/wojdyr/xylib/blob/master/xylib/brucker_raw.cpp)

Menu "Macros"
	submenu "Import Tool "+importloaderversion
			submenu "XRD"
				"Load Siemens-Bruker Diffrac-AT	*.raw	file... b1", BruckerRaw_load_data()
			end
	end
end

// ###################### Siemens/Bruker Diffrac-AT Raw ########################
// Siemens/Bruker Diffrac-AT Raw Format version 1/2/3
// Licence: Lesser GNU Public License 2.1 (LGPL)

// Contains data from Siemens/Brucker X-ray diffractometers.
// Implementation based on:
// ver. 1 and 2: the file format specification from a diffractometer manual,
// chapter "Appendix B: DIFFRAC-AT Raw Data File Format"
// ver. with magic string "RAW1.01", that probably is v. 4, because
// corresponding ascii files start with ";RAW4.00",
// was contributed by Andreas Breslau, who analysed binary files
// and corresponding ascii files.
// Later it was improved based on section
// "A.1 DIFFRAC^plus V3 RAW File Structure" of the manual:
// "DIFFRAC^plus FILE EXCHANGE and XCH" Release 2002.



static function BruckerRaw_check(file)
	variable file
	string head = mybinread(file,4)
	if (cmpstr(head,"RAW ")==0)
			return 1
	elseif (cmpstr(head,"RAW2")==0)
			return 1
	elseif (cmpstr(head,"RAW1")==0 && cmpstr(mybinread(file,3),".01")==0)
			return 1
	else
		return 0
	endif
	return 0
end


function BruckerRaw_load_data()
	string dfSave=""
	variable file
	string impname="Siemens/Bruker Diffrac-AT Raw"
	string filestr="*.raw"
	string header = loaderstart(impname, filestr,file,dfSave)
	if (strlen(header)==0)
		return -1
	endif

	header+="\r"

	string head = mybinread(file,4)
	if(cmpstr(head,"RAW ")!=0 && cmpstr(head,"RAW2")!=0 && cmpstr(head,"RAW1")!=0)
		Debugprintf2("Wrong Version/Format!",0)
		close file
		return -1
	endif
	if (cmpstr(head[3]," ")==0)
		BruckerRaw_load_version1(file,header)
	elseif (cmpstr(head[3],"2")==0)
		BruckerRaw_load_version2(file,header)
	else // head[3] == '1'
		BruckerRaw_load_version1_01(file,header)
	endif
	
	loaderend(impname,1,file, dfSave)
end


static function BruckerRaw_load_version1(file,header)
	variable file
	string header
	header +="format version: V1" +"\r"
	variable raw_int=0

	variable following_range = 1, i=0, y=0, groupcount=0
	string tmps=""
	do

		variable cur_range_steps = read_uint32_le(file)
		// early DIFFRAC-AT raw data files didn't repeat the "RAW "
		// on additional ranges
		// (and if it's the first block, 4 bytes from file were already read)
		if(groupcount!=0)
			if (cur_range_steps >= 1e+07)
				cur_range_steps = read_uint32_le(file)
			endif
		endif

		header += "MEASUREMENT_TIME_PER_STEP: " + num2str(read_flt_le(file)) + "\r"
		variable x_step = read_flt_le(file)
		header += "SCAN_MODE: " + num2str(read_uint32_le(file)) + "\r"
		mybinread(file,4)
		variable x_start = read_flt_le(file)

		variable t = read_flt_le(file)
		if (-1e6 != t)
			header += "THETA_START: " + num2str(t) + "\r"
		endif
		t = read_flt_le(file)
		if (-1e6 != t)
			header += "KHI_START: " + num2str(t) + "\r"
		endif
		t = read_flt_le(file)
		if (-1e6 != t)
			header += "PHI_START: " +  num2str(t) + "\r"
		endif
		header += "SAMPLE_NAME:" + mybinread(file, 32) + "\r"
		header += "K_ALPHA1: " + num2str(read_flt_le(file)) + "\r"
		header += "K_ALPHA2: " + num2str(read_flt_le(file)) + "\r"

		mybinread(file,72) // unused fields
		following_range = read_uint32_le(file)

		groupcount+=1
		tmps= getnameforwave(file)+"_"+num2str(groupcount)
		Make /O/R/N=( cur_range_steps)  $tmps /wave=ycols
		SetScale/P  x,x_start,x_step,"", ycols
		note ycols, header

		for(i = 0; i < cur_range_steps; i+=1) 
			y = read_flt_le(file)
			ycols[i]=y
		endfor
	while (following_range > 0)
end


static function BruckerRaw_load_version2(file,header)
	variable file
	string header
   	header +="format version: V2"

	variable i=0, y=0, cur_range= 0
	string tmps=""
	variable range_cnt = read_uint16_le(file)
	Debugprintf2("range_cnt: "+num2str(range_cnt),1)
	mybinread(file,162)
	header += "DATE_TIME_MEASURE: " + mybinread(file, 20) + "\r"
	header += "CEMICAL SYMBOL FOR TUBE ANODE: " + mybinread(file, 2) + "\r"
	header += "LAMDA1: " + num2str(read_flt_le(file)) + "\r"
	header += "LAMDA2: " + num2str(read_flt_le(file)) + "\r"
	header += "INTENSITY_RATIO: " + num2str(read_flt_le(file)) + "\r"

	mybinread(file,8)
	header += "TOTAL_SAMPLE_RUNTIME_IN_SEC: " + num2str(read_flt_le(file)) + "\r"

	mybinread(file,42) // move ptr to the start of 1st block
	for (cur_range = 0; cur_range < range_cnt; cur_range+=1) 
		variable cur_header_len = read_uint16_le(file)
		if(cur_header_len<=48)
			print num2str(cur_header_len)
			Debugprintf2("Header to small! (<=48)",0)
			close file
			return -1
		endif

		variable cur_range_steps = read_uint16_le(file)
		mybinread(file,4)
		header += "SEC_PER_STEP: " + num2str(read_flt_le(file)) + "\r"

		variable x_step = read_flt_le(file)
		variable x_start = read_flt_le(file)

		mybinread(file,26)
		header += "TEMP_IN_K: " + num2str(read_uint16_le(file)) + "\r"

		tmps= getnameforwave(file)+"_"+num2str(cur_range)
		Make /O/R/N=( cur_range_steps)  $tmps /wave=ycols
		SetScale/P  x,x_start,x_step,"", ycols
		note ycols, header

		mybinread(file,cur_header_len - 48) // move ptr to the data_start
		for(i = 0; i < cur_range_steps; i+=1)
			y = read_flt_le(file)
			ycols[i]=y
		endfor
	endfor
end


static function BruckerRaw_load_version1_01(file,header)
	variable file
	string header
   	header +="format version: V3"+"\r"
	variable i=0, y=0, cur_range=0
	string tmps=""
	// file header - 712 bytes
	// the offset is already 4
	mybinread(file,4) // ignore bytes 4-7
	variable file_status = read_uint32_le(file) // address 8
	if (file_status == 1)
		header +="file status: done"
	elseif (file_status == 2)
		header +="file status: active"
	elseif (file_status == 3)
		header +="file status: aborted"
	elseif (file_status == 4)
		header +="file status: interrupted"
	endif
	variable range_cnt = read_uint32_le(file) // address 12


	string hdate = "MEASURE_DATE: " +cleanupname(mybinread(file,10),1) // address 16
	string htime = "MEASURE_TIME: " +cleanupname(mybinread(file,10),1) // address 26
	string huser = "USER: " +cleanupname(mybinread(file,72),1) // address 36
	string hsite = "SITE: " +cleanupname(mybinread(file,218),1) // address 108
	string hsample = "SAMPLE_ID: " +cleanupname(mybinread(file,60),1) // address 326
	string hcomment = "COMMENT: " +cleanupname(mybinread(file,160),1) // address 386

	
	mybinread(file,2)// apparently there is a bug in docs, 386+160 != 548
	mybinread(file,4)// goniometer code // address 548
	mybinread(file,4)// goniometer stage code // address 552
	mybinread(file,4)// sample loader code // address 556
	mybinread(file,4)// goniometer controller code // address 560
	mybinread(file,4)// (R4) goniometer radius // address 564
	mybinread(file,4)// (R4) fixed divergence... // address 568
	mybinread(file,4)// (R4) fixed sample slit... // address 572
	mybinread(file,4)// primary Soller slit // address 576
	mybinread(file,4)// primary monochromator // address 580
	mybinread(file,4)// (R4) fixed antiscatter... // address 584
	mybinread(file,4)// (R4) fixed detector slit... // address 588
	mybinread(file,4)// secondary Soller slit // address 592
	mybinread(file,4)// fixed thin film attachment // address 596
	mybinread(file,4)// beta filter // address 600
	mybinread(file,4) // secondary monochromator // address 604
	string hanode = "ANODE_MATERIAL: " +cleanupname(mybinread(file,4),1) // address 608
	mybinread(file,4)// unused // address 612
	string haverage = "ALPHA_AVERAGE: " + num2str(read_dbl_le(file)) // address 616
	string ha1 = "ALPHA1: " + num2str(read_dbl_le(file)) // address 624
	string ha2 = "ALPHA2: " + num2str(read_dbl_le(file)) // address 632
	string hbeta= "BETA: "+ num2str(read_dbl_le(file)) // address 640
	string hratio= "ALPHA_RATIO: " +num2str(read_dbl_le(file)) // address 648
	mybinread(file,4)// (C4) unit name // address 656
	mybinread(file,4)// (R4) intensity beta:a1 // address 660
	string hmeastime= "measurement time: "+ num2str(read_flt_le(file)) // address 664
	mybinread(file,43)// unused // address 668
	mybinread(file,1)// hardware dependency ... // address 711


	// range header
	for (cur_range = 0; cur_range < range_cnt; cur_range+=1)
		variable header_len = read_uint32_le(file) // address 0
		if(header_len != 304)
			Debugprintf2("Wrong header size (<>304)",0)
			close file
			return 0	
		endif
		variable steps = read_uint32_le(file) // address 4
		string hsteps = "STEPS: " + num2str(steps)
		variable start_theta = read_dbl_le(file) // address 8
		string htheta = "START_THETA: " + num2str(start_theta)
		variable start_2theta = read_dbl_le(file) // address 16
		string h2theta = "START_2THETA: " + num2str(start_2theta)

		mybinread(file,8)// Chi drive start // address 24
		mybinread(file,8)// Phi drive start // address 32
		mybinread(file,8)// x drive start // address 40
		mybinread(file,8)// y drive start // address 48
		mybinread(file,8)// z drive start // address 56
		mybinread(file,8)// address 64
		mybinread(file,6)// address 72
		mybinread(file,2)// unused // address 78
		mybinread(file,8)// (R8) variable antiscat. // address 80
		mybinread(file,6)// address 88
		mybinread(file,2)// unused // address 94
		mybinread(file,4)// detector code // address 96
		string hhighV= "HIGH_VOLTAGE: " + num2str(read_flt_le(file)) // address 100
		string hgain= "AMPLIFIER_GAIN: " + num2str(read_flt_le(file)) // 104
		string hlowerlevel = "DISCRIMINATOR_1_LOWER_LEVEL: " + num2str(read_flt_le(file))// 108
		mybinread(file,4) // address 112
		mybinread(file,4) // address 116
		mybinread(file,8)// address 120
		mybinread(file,4) // address 128
		mybinread(file,4) // address 132
		mybinread(file,5) // address 136
		mybinread(file,3) // unused // address 141
		mybinread(file,8)// address 144
		mybinread(file,8)// address 152
		mybinread(file,8)// address 160
		mybinread(file,4) // address 168
		mybinread(file,4) // unused // address 172
		variable step_size = read_dbl_le(file) // address 176
		string hstepsize = "STEP_SIZE: " + num2str(step_size)
		mybinread(file,8)// address 184
		string htimestep= "TIME_PER_STEP: " + num2str(read_flt_le(file)) // 192
		mybinread(file,4) // address 196
		mybinread(file,4) // address 200
		mybinread(file,4) // address 204
		string hrpm = "ROTATION_SPEED [rpm]: " + num2str(read_flt_le(file)) // 208
		mybinread(file,4) // address 212
		mybinread(file,4) // address 216
		mybinread(file,4) // address 220
		string hgenV = "GENERATOR_VOLTAGE: " + num2str(read_uint32_le(file)) // 224 
		string hgenC = "GENERATOR_CURRENT: " + num2str(read_uint32_le(file)) // 228
		mybinread(file,4) // address 232
		mybinread(file,4) // unused // address 236
		string husedL = "USED_LAMBDA: " + num2str(read_dbl_le(file)) // 240
		mybinread(file,4) // address 248
		mybinread(file,4) // address 252
		variable supplementary_headers_size = read_uint32_le(file) // address 256
		mybinread(file,4) // address 260
		mybinread(file,4) // address 264
		mybinread(file,4) // unused // address 268
		mybinread(file,8)// address 272
		mybinread(file,24) // unused // address 280

		if (supplementary_headers_size > 0)
			mybinread(file,supplementary_headers_size)
		endif

		tmps= getnameforwave(file)+"_"+num2str(cur_range)
		Make /O/R/N=(steps)  $tmps /wave=ycols
		SetScale/P  x,start_2theta,step_size,"", ycols
		note ycols, header
		note ycols, hdate
		note ycols, htime
		note ycols, huser
		note ycols, hsite
		note ycols, hsample
		note ycols, hcomment
		note ycols, hanode
		note ycols, haverage
		note ycols, ha1
		note ycols, ha2
		note ycols, hbeta
		note ycols, hratio
		note ycols, hmeastime
		note ycols, hsteps
		note ycols, htheta
		note ycols, h2theta
		note ycols, hhighV
		note ycols, hgain
		note ycols, hlowerlevel
		note ycols, hstepsize
		note ycols, htimestep
		note ycols, hrpm
		note ycols, hgenV
		note ycols, hgenC
		note ycols, husedL

		for (i = 0; i < steps; i+=1)
			y = read_flt_le(file)
			ycols[i]=y
		endfor
	endfor
end

// ###################### Siemens/Bruker Diffrac-AT Raw END ######################
