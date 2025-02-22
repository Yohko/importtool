// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

// The VAMAS procedure is based on xylib by Marcin Wojdyr:
// https://github.com/wojdyr/xylib (https://github.com/wojdyr/xylib/blob/master/xylib/vamas.cpp)

// ISO14976 VAMAS Surface Chemical Analysis Standard Data Transfer Format File
// This implementation is based on 
// Dench, W. A., Hazell, L. B., Seah, M. P., the VAMAS Community. (1988). 
// VAMAS Surface chemical analysis standard data transfer format with skeleton decoding programs. 
// Surface and Interface Analysis, 13(2-3), 63�122. doi:10.1002/sia.740130202
// National Physics Laboratory Report DMA(A)164 July 1988
//  and on the analysis of sample files.


// dictionaries for VAMAS data
static strconstant exps = "MAP;MAPDP;MAPSV;MAPSVDP;NORM;SDP;SDPSV;SEM;NOEXP"
static strconstant techs = "AES diff;AES dir;EDX;ELS;FABMS;FABMS energy spec;ISS;SIMS;SIMS energy spec;SNMS;SNMS energy spec;UPS;XPS;XRF"
static strconstant scans = "REGULAR;IRREGULAR;MAPPING"


static structure Vamas_param
	variable first_start_x
	variable first_start_y
	variable first_end_x
	variable first_end_y
	variable last_end_x
	variable last_end_y
	variable discrete_xdim
	variable discrete_ydim
	variable FOV_x
	variable FOV_y
	string waveprefix
endstructure


static structure Vamas_CasaXPS_region
	string name
	variable RSF
	variable startBG
	variable endBG
	string BGType
	variable avwidth
	variable startoffset
	variable endoffset
	string crosssection
	string tag
	variable energy
endstructure


static structure Vamas_CasaXPS_comp
	string name
	variable RSF
	string lineshape
	variable shape
	variable area
	variable area_L
	variable area_U
	variable FWHM
	variable FWHM_L
	variable FWHM_U
	variable position
	variable position_L
	variable position_U
	string tag
	variable compindex
	variable asymmetryindex
	variable concentration
	variable MASS
	variable energy
endstructure


function Vamas_check_file(file)
	variable file
	fsetpos file, 0
	variable i = 0
	string key="", val=""
	for(i=0;i<50;i+=1)
		if (getkeyval(file, key, val)==-1)
			return -1 // end of file
		endif
		if(strsearch(key,"VAMAS Surface Chemical Analysis Standard Data Transfer Format 1988 May 4",0)==0)
			fsetpos file, 0
			return 1
		endif
		if(strsearch(key,"VAMAS",0)==0)
			fsetpos file, 0
			return 1 // maybe not really because could be non standard
		endif
		key=""
		val=""
		Fstatus file
		if(V_logEOF<=V_filePOS)
			return -1
		endif
	endfor
	fsetpos file, 0
	return -1
end


function Vamas_load_data_info(importloader)
	struct importloader &importloader
	importloader.name =  "VAMAS"
	importloader.filestr = "*.vms"
	importloader.category = "PES"
end


// Vamas file is organized as
// file_header block_header block_data [block_header block_data] ...
// There is only a value in every line without a key or label; the meaning is
// determined by its position and values in preceding lines
function Vamas_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	Vamas_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string headercomment = importloader.header+"\r"
	variable file = importloader.file


	// load complete file into a text wave for faster processing
	struct loader_file filewave
	if(loader_initfile(file, filewave)==-1)
		loaderend(importloader)
		return -1	
	endif


	struct Vamas_param param
	variable i=0, optf=0
	string tmps=""


	param.waveprefix = ""
	if(str2num(get_flags(f_askforwaveprefix)))
		tmps = param.waveprefix
		prompt tmps, "What string to use for wave prefix?"
		doprompt "Import flags!", tmps
		if(V_flag==1)
			Debugprintf2("Cancel import!",0)
			loaderend(importloader)
			return -1
		endif
		param.waveprefix = tmps
	endif

	// sometimes there are empty lines at the beginning
	// need to find the magic line
	string key="", val=""
	do 
		if (Vamas_getkeyval(filewave, key, val)==-1)
			Debugprintf2("Unexpected end of VMS-file (header).",0)
			loaderend(importloader)
			return -1
		endif

		if(strsearch(key,"VAMAS Surface Chemical Analysis Standard Data Transfer Format 1988 May 4",0)==0)
			Debugprintf2("Found beginning of standard Vamas file.",0)
			break
		endif
		if(strsearch(key,"VAMAS",0)==0)
			Debugprintf2("Found beginning of non standard Vamas file. Trying to import!",0)
			break
		endif
		key=""
		val=""
		if(filewave.line>=dimsize(filewave.file,0))
			Debugprintf2("Unexpected end of VMS-file (header).",0)
			loaderend(importloader)
			return -1
		endif
	while(filewave.line<dimsize(filewave.file,0))

	headercomment += "institution identifier: " + loader_readline_str(filewave) + "\r"
	headercomment += "institution model identifier" + loader_readline_str(filewave) + "\r"
	headercomment += "operator identifier: " + loader_readline_str(filewave) + "\r"
	headercomment += "experiment identifier: " + loader_readline_str(filewave) + "\r"

    // comment lines, n is number of lines
	variable n = loader_readline_num(filewave)
	for (i = 0; i <n; i+=1) 
		tmps = filewave.file[filewave.line]; filewave.line +=1
//		if(strlen(tmps) == 0)
//			Debugprintf2("Unexpected end of VMS-file.",0)
//			return -1
//		endif
		tmps=mycleanupstr(tmps)
		headercomment += "header comment #"+num2str(i+1)+": "+tmps+"\r"
	endfor
	
	string exp_mode = loader_readline_str(filewave)
	// make sure exp_mode has a valid value
	if(FindListItem(exp_mode, exps, ";")==-1)
		Debugprintf2("exp_mode has an invalid value: "+exp_mode,0)
	endif

	string scan_mode = loader_readline_str(filewave)
	// make sure scan_mode has a valid value
	if(FindListItem(scan_mode, scans, ";")==-1)
		Debugprintf2("Scan mode has an invalid value: "+scan_mode,0)
	endif

	// some exp_mode specific file-scope meta-info
	string numspecregions = ""
	if ((cmpstr("MAP",exp_mode) == 0) || (cmpstr("MAPD",exp_mode) == 0) || (cmpstr("NORM",exp_mode) == 0) || (cmpstr("SDP",exp_mode) == 0) )
		headercomment += "number of spectral regions: " + loader_readline_str(filewave) + "\r"
	endif

	if ((cmpstr("MAP",exp_mode) == 0) || (cmpstr("MAPD",exp_mode) == 0))
		headercomment += "number of analysis positions: " + loader_readline_str(filewave) + "\r"
		param.discrete_xdim = loader_readline_num(filewave)
		param.discrete_ydim = loader_readline_num(filewave)
		headercomment += "number of discrete x coordinates available in full map: " + num2str(param.discrete_xdim) + "\r"
		headercomment += "number of discrete y coordinates available in full map: " + num2str(param.discrete_ydim) + "\r"
	endif

	// experimental variables
	variable exp_var_cnt = loader_readline_num(filewave)
	for (i = 1; i <= exp_var_cnt; i+=1)
		headercomment += "experimental variable label " + num2str(i) + ": " + loader_readline_str(filewave) + "\r"
		headercomment += "experimental variable unit " + num2str(i) + ": "+ loader_readline_str(filewave) + "\r"
	endfor
	headercomment=mycleanupstr(headercomment)
	// fill `include' table
	// This next line is a relic of an earlier version of the format.
	// In that version, this line contained an integer whose value indicated a number of optional features to follow.
	// In the current version of the standard, these optional features have been removed, so the value should always be 0.
	// Software which could read the old file format will therefore remain compatible with the new version, but
	// this VAMASParser will not be able to read the old file format, and must simply throw an exception if the
	// value is not 0.
	n = loader_readline_num(filewave) // # of entries in inclusion or exclusion list
	optf=n
	if(n!=0)
		Debugprintf2("Error reading VAMAS file; expected '0', read '" + num2str(n) + "' at position " + num2str(filewave.line),0)
		Debugprintf2("Somehow a continuous mode which is not supported yet or very old VAMAS standard!",0)
		//loaderend(impname,1,file, dfSave)
		//return -1
	endif


	variable d= (n > 0 ? 0 : 1)

	Make /O/R/N=(40) includew
	Make /O/R/N=(41) inclusionlist

	for (i=0;i<40;i+=1)
		inclusionlist[i]=d
		includew[i]=1
	endfor
	inclusionlist[40]=0
	d = (d==1 ? 0 : 1)
	if (n<0)
		n*=-1
	endif

	variable idx=0
	for (i=0;i<n;i+=1)
		idx = loader_readline_num(filewave)
		inclusionlist[idx]=d
	endfor
	
	// # of manually entered items in block
	// list any manually entered items
	n = loader_readline_num(filewave)
	if(Vamas_skip_lines(filewave, n)==-1)
		loaderend(importloader)
		return -1
	endif
	// list any future experiment upgrade entries
	variable exp_fue = loader_readline_num(filewave)
	variable blk_fue = loader_readline_num(filewave)
	if(Vamas_skip_lines(filewave, exp_fue)==-1)
		loaderend(importloader)
		return -1
	endif
//	variable blk_fue = read_line_int(file)
//	if(Vamas_skip_lines(file, blk_fue)==-1)
//		loaderend(impname,1,file, dfSave)
//		return -1
//	endif


	variable j=0
	variable cor_var=0
	// handle the blocks
	variable blk_cnt = loader_readline_num(filewave)
	
	for (i = 0; i < blk_cnt; i+=1)
	
		if(i==1)
			for(j=0;j<40;j+=1)
				includew[j]=inclusionlist[j]
			endfor
		endif
		if(Vamas_read_block(filewave, includew,exp_mode,exp_var_cnt, scan_mode,blk_fue, headercomment,i, cor_var, param) == -1)
			loaderend(importloader)
			return -1
		endif

	endfor
	killwaves includew
	killwaves inclusionlist
	importloader.success = 1
	loaderend(importloader)
end


// read one block from file
static function Vamas_read_block(filewave, includew,exp_mode,exp_var_cnt, scan_mode,blk_fue, headercomment, count, cor_var, param)//,impname, dfSave)
	struct loader_file &filewave
	wave includew
	string exp_mode
	variable exp_var_cnt
	string scan_mode
	variable blk_fue
	string headercomment
	variable count
	variable &cor_var // # of corresponding variables
	struct Vamas_param &param
	variable x_start=0.0, x_step=0.0, i=0, j=0, n=0
	string x_name = "", tmps=""
	variable excenergy = 0
	variable dwelltime = 1
	variable scancount = 1

	string blockid = loader_readline_str(filewave)
	string sampleid = loader_readline_str(filewave)

	blockid = cleanname(blockid)
	//Make /O/R/N=(10)  $(cleanname(sampleid[0,10])+"_"+num2str(count)+"_"+blockid[0,10]) /wave=ycols
	Make /O/R/N=(10)  $(num2str(count)+"_"+cleanname(sampleid[0,10])+"_"+blockid[0,10]) /wave=ycols
	Note ycols, headercomment
	Note ycols, "block id: "+ blockid
	Note ycols, "sample identifier: "+ sampleid
	if (includew[0]==1)
		Note ycols, "year: " + loader_readline_str(filewave)
	endif
	if (includew[1]==1)
		note ycols, "month: " + loader_readline_str(filewave)
	endif
	if (includew[2]==1)
		note ycols, "day: " + loader_readline_str(filewave)
	endif
	if (includew[3]==1)
		note ycols, "hour: " + loader_readline_str(filewave)
	endif
	if (includew[4]==1)
		note ycols, "minute: " +  loader_readline_str(filewave)
	endif
	if (includew[5]==1)
		note ycols, "second: " + loader_readline_str(filewave)
	endif
	if (includew[6]==1)
		note ycols, "no. of hours in advanced GMT: " + loader_readline_str(filewave)
	endif
	variable cmt_lines=0
	if (includew[7]==1) // skip comments on this block
		cmt_lines = loader_readline_num(filewave)
		if(numtype(cmt_lines)!=0)
			Debugprintf2("Error opening Vamas file (cmt_lines)!",0)
			return -1
		endif
		for (i = 0; i <cmt_lines; i+=1) 
			tmps = filewave.file[filewave.line]; filewave.line +=1
			if(strlen(tmps) == 0)
				//Debugprintf2("Unexpected end of VMS-file.",0)
				//return -1
				//empty comment
			endif
			tmps=mycleanupstr(tmps)
			note ycols, "spectra comment #"+num2str(i+1)+": "+stripstrfirstlastspaces(tmps)
		endfor
	endif
	string tech=""
	if (includew[8]==1)
		tech = loader_readline_str(filewave)
		note ycols, "tech: " + tech
		if(FindListItem(tech, techs, ";")==-1)
			Debugprintf2("Tech. has an invalid value: "+tech+"at line "+num2str(filewave.line),0)
			return -1
		endif
	endif

	if (includew[9]==1)
		if ((cmpstr("MAP",exp_mode) == 0) || (cmpstr("MAPDP",exp_mode) == 0))
			note ycols, "x coordinate" + loader_readline_str(filewave)
			note ycols, "y coordinate" + loader_readline_str(filewave)
		endif
	endif

	if (includew[10]==1)
		for (i = 0; i < exp_var_cnt; i+=1)
			note ycols, "experimental variable value " + num2str(i+1)+": "+  loader_readline_str(filewave)
		endfor
	endif

	if (includew[11]==1)
		note ycols, "analysis source label: "+  loader_readline_str(filewave)
	endif
	
	if (includew[12]==1)
		if ((cmpstr("MAPDP",exp_mode) == 0) || (cmpstr("MAPSVDP",exp_mode) == 0) || (cmpstr("SDP",exp_mode) ==0) || (cmpstr("SDPSV",exp_mode )== 0) || (cmpstr("SNMS energy spec",tech) == 0) || (cmpstr("FABMS",tech) == 0) || (cmpstr("FABMS energy spec",tech) == 0) || (cmpstr("ISS",tech) == 0) || (cmpstr("SIMS",tech) == 0) || (cmpstr("SIMS energy spec",tech) == 0) || (cmpstr("SNMS",tech) == 0))
			note ycols, "sputtering ion or atom atomic number: "+ loader_readline_str(filewave)
			note ycols, "number of atoms in sputtering ion or atom particle: "+ loader_readline_str(filewave)
			note ycols, "sputtering ion or atom charge sign and number: "+ loader_readline_str(filewave)
		endif
	endif
	if (includew[13]==1)
		excenergy =  loader_readline_num(filewave)
		note ycols, "analysis source characteristic energy: " + num2str(excenergy)
	endif
	if (includew[14]==1)
		note ycols, "analysis source strength: "+ loader_readline_str(filewave)
	endif

	if (includew[15]==1)
		note ycols, "analysis source beam width x: "+ loader_readline_str(filewave)
		note ycols, "analysis source beam width y: "+ loader_readline_str(filewave)
	endif

	if (includew[16]==1)
		if ((cmpstr("MAP",exp_mode) ==0) || (cmpstr("MAPDP",exp_mode) ==0) || (cmpstr("MAPSV",exp_mode) ==0)  || (cmpstr("MAPSVDP",exp_mode) ==0) || (cmpstr("SEM",exp_mode) ==0))
			param.FOV_x = loader_readline_num(filewave)
			param.FOV_y = loader_readline_num(filewave)
			note ycols, "field of view x: " + num2str(param.FOV_x)
			note ycols, "field of view y: " + num2str(param.FOV_y)
		endif
	endif

	if (includew[17]==1)
		if ((cmpstr("SEM",exp_mode) ==0) || (cmpstr("MAPSV",exp_mode) ==0) || (cmpstr("MAPSVDP",exp_mode) ==0))
			param.first_start_x = loader_readline_num(filewave)
			param.first_start_y = loader_readline_num(filewave)
			param.first_end_x = loader_readline_num(filewave)
			param.first_end_y =loader_readline_num(filewave)
			param.last_end_x = loader_readline_num(filewave)
			param.last_end_y= loader_readline_num(filewave)
			note ycols, "First Line Scan Start X-Coordinate: "+  num2str(param.first_start_x)
			note ycols, "First Line Scan Start Y-Coordinate: "+  num2str(param.first_start_y)
			note ycols, "First Line Scan Finish X-Coordinate: "+  num2str(param.first_end_x)
			note ycols, "First Line Scan Finish Y-Coordinate: "+  num2str(param.first_end_y)
			note ycols, "Last Line Scan Finish X-Coordinate: "+  num2str(param.last_end_x)
			note ycols, "Last Line Scan Finish Y-Coordinate: "+  num2str(param.last_end_y)
		endif
	endif

	if (includew[18]==1)
		note ycols, "analysis source polar angle of incidence: "+  loader_readline_str(filewave)
	endif
	if (includew[19]==1)
		note ycols, "analysis source azimuth: "+  loader_readline_str(filewave)
	endif
	if (includew[20]==1)
		note ycols, "analyser mode: "+  loader_readline_str(filewave)
	endif
	if (includew[21]==1)
		note ycols, "analyser pass energy or retard ratio or mass resolution: " + loader_readline_str(filewave)
	endif

	if (includew[22]==1)
		if (cmpstr("AES diff",tech)==0)
			note ycols, "differential width: "+  loader_readline_str(filewave)
		endif
	endif

	if (includew[23]==1)
		note ycols, "magnification of analyser transfer lens: "+  loader_readline_str(filewave)
	endif
	// QAZ semantics of next element depends on technique
	if (includew[24]==1)
		note ycols, "analyser work function or acceptance energy of atom or ion: "+  loader_readline_str(filewave)
	endif
	if (includew[25]==1)
		note ycols, "target bias: "+  loader_readline_str(filewave)
	endif

	if (includew[26]==1)
		note ycols, "analysis width x: "+ loader_readline_str(filewave)
		note ycols, "analysis width y: "+  loader_readline_str(filewave)
	endif

	if (includew[27]==1)
		note ycols, "analyser axis take off polar angle: "+  loader_readline_str(filewave)
		note ycols, "analyser axis take off azimuth: "+  loader_readline_str(filewave)
	endif

	if (includew[28]==1)
		note ycols, "species label: "+  loader_readline_str(filewave)
	endif

	if (includew[29]==1)
		note ycols, "transition or charge state label: "+  loader_readline_str(filewave)
		note ycols, "charge of detected particle: "+  loader_readline_str(filewave)
	endif

	if (includew[30]==1)
		if (cmpstr("REGULAR",scan_mode) == 0)
			x_name =  loader_readline_str(filewave)
			note ycols, "abscissa label: "+ x_name
			note ycols, "abscissa units: "+  loader_readline_str(filewave)
			x_start = loader_readline_num(filewave)
			x_step = loader_readline_num(filewave)
		else
			cor_var = loader_readline_num(filewave)
			if(numtype(cor_var)!=0 || cor_var == 0)
				Debugprintf2("Error opening Vamas file (cor_var)!",0)
				return -1
			endif
			x_name =  loader_readline_str(filewave)
			note ycols, "abscissa label: "+ x_name
			note ycols, "abscissa units: "+  loader_readline_str(filewave)

			for (i = 0; i != cor_var-1; i+=1)
				note ycols,"Name Col"+num2str(i)+": "+loader_readline_str(filewave)
				if(Vamas_skip_lines(filewave, 1)==-1) // corresponding variable unit
					//loaderend(impname,1,file, dfSave)
					return -1
				endif
			endfor
			includew[31] = 0
		endif
	else
		Debugprintf2("how to find abscissa properties in this file?",0)
	endif


	
	if (includew[31]==1)
		cor_var = loader_readline_num(filewave)
		if(numtype(cor_var)!=0)
			Debugprintf2("Error opening Vamas file (cor_var)!",0)
			return -1
		endif
		//inclusionlist[40] = cor_var
		// columns initialization
		Redimension/N=(-1,cor_var) ycols
		for (i = 0; i != cor_var; i+=1)
			note ycols,"Name Col"+num2str(i)+": "+loader_readline_str(filewave)
			if(Vamas_skip_lines(filewave, 1)==-1) // corresponding variable unit
				//loaderend(impname,1,file, dfSave)
				return -1
			endif
		endfor
	endif

	if (includew[32]==1)
		note ycols, "signal mode: "+  loader_readline_str(filewave)
	endif
	if (includew[33]==1)
		dwelltime =  loader_readline_num(filewave)
		note ycols, "signal collection time: "+  num2str(dwelltime)
	endif
	if (includew[34]==1)
		scancount =  loader_readline_num(filewave)
		note ycols, "# of scans to compile this blk: "+  num2str(scancount)
	endif
	if (includew[35]==1)
		note ycols, "signal time correction: "+  loader_readline_str(filewave)
	endif
	if (includew[36]==1)
		if (( (cmpstr("AES diff",tech) == 0) ||  (cmpstr("AES dir",tech) == 0) ||  (cmpstr("EDX",tech) == 0) ||  (cmpstr("ELS",tech) == 0) ||  (cmpstr("UPS",tech) == 0) ||  (cmpstr("XPS",tech) == 0) ||  (cmpstr("XRF",tech) == 0)) && ( (cmpstr("MAPDP",exp_mode) == 0) ||  (cmpstr("MAPSVDP",exp_mode) == 0) ||  (cmpstr("SDP",exp_mode) == 0) ||  (cmpstr("SDPSV",exp_mode) == 0))) 
			note ycols, "Sputtering Source Energy: "+loader_readline_str(filewave)
			note ycols, "Sputtering Source BeamCurrent: "+loader_readline_str(filewave)
			note ycols, "Sputtering Source WidthX: "+loader_readline_str(filewave)
			note ycols, "Sputtering Source WidthY: "+loader_readline_str(filewave)
			note ycols, "Sputtering Source PolarAngle Of Incidence: "+loader_readline_str(filewave)
			note ycols, "Sputtering Source Azimuth: "+loader_readline_str(filewave)
			note ycols, "Sputtering Mode: "+loader_readline_str(filewave)
		endif
	endif

	if (includew[37]==1)
		note ycols, "sample normal polar angle of tilt: "+  loader_readline_str(filewave)
		note ycols, "sample normal polar tilt azimuth: "+  loader_readline_str(filewave)
	endif

	if (includew[38]==1)
		note ycols, "sample rotate angle: "+  loader_readline_str(filewave)
	endif
	if (includew[39]==1)
		n = loader_readline_num(filewave) // # of additional numeric parameters
		for (i = 0; i < n; i+=1)
			// 3 items in every loop: param_label, param_unit, param_value
			string param_label =  loader_readline_str(filewave)
			string param_unit =  loader_readline_str(filewave)
			string param_value =  loader_readline_str(filewave)
			note ycols, param_label +": " + param_value  + param_unit
		endfor
	endif
	if(Vamas_skip_lines(filewave, blk_fue)==-1)
		return -1
	endif
	variable cur_blk_steps = loader_readline_num(filewave)
	if(cur_blk_steps == 0)
		return -1
	endif
	if(Vamas_skip_lines(filewave, 2 * cor_var)==-1) // min & max ordinate
		return -1
	endif
	variable tmpd=0

	variable xdim=0,ydim=0

	//<expression> ? <TRUE> : <FALSE>
	xdim = (param.first_end_x>=param.last_end_x) ? param.first_end_x : param.last_end_x
	ydim = (param.first_end_y>=param.last_end_y) ? param.first_end_y : param.last_end_y
	xdim -=(param.first_start_x-1)
	ydim -=(param.first_start_y-1)
	string ycols_name = nameofwave(ycols)
	ycols_name = param.waveprefix+ycols_name
	strswitch(scan_mode)
		case "MAPPING":
			if(xdim*ydim!=cur_blk_steps)
				Debugprintf2("Error. xdim*ydim != cur_blk_steps.",0)
				return -1
			endif
			Redimension/N=(ydim,xdim) ycols
			for(j=0;j<xdim;j+=1)
				for(i=0;i<ydim;i+=1)
					tmpd=loader_readline_num(filewave)
					ycols[i][j]=tmpd
				endfor
			endfor
			SetScale/I  x,0,param.FOV_x,"�m", ycols
			SetScale/I  y,0,param.FOV_y,"�m", ycols
			break
		default: // regular and irregular
			if ((cmpstr("UPS",tech) == 0) ||  (cmpstr("XPS",tech) == 0)) 
				if(strsearch(x_name,"Kinetic Energy",0,2)!=-1)
					if(str2num(get_flags(f_vsEkin))==0)
						if(str2num(get_flags(f_posEbin)) == 0)
							SetScale/P  x,x_start-excenergy,x_step,"eV", ycols
						else
							SetScale/P  x,-x_start+excenergy,-x_step,"eV", ycols
						endif
					else
							SetScale/P  x,x_start,x_step,"eV", ycols
					endif
				elseif(strsearch(x_name,"Binding Energy",0,2)!=-1)
					if(str2num(get_flags(f_vsEkin))==0)
						if(str2num(get_flags(f_posEbin)) == 0)
							SetScale/P  x,-x_start,-x_step,"eV", ycols
						else
							SetScale/P  x,x_start,x_step,"eV", ycols
						endif		
					else
							SetScale/P  x,excenergy-x_start,x_step,"eV", ycols
					endif
				//elseif(strsearch(x_name,"time of day",0,2)!=-1)
				else
					SetScale/P  x,x_start,x_step,x_name, ycols
				endif
			else
				SetScale/P  x,x_start,x_step,x_name, ycols
			endif
			Redimension/N=(cur_blk_steps/cor_var,cor_var) ycols
			variable col = 0
			n=0
			for (i = 0; i < cur_blk_steps; i+=1)
				tmpd=loader_readline_num(filewave)
				if(numtype(tmpd)==2)
					// some VMS files have empty lines here, CasaXPS still loads these files properly
					Debugprintf2("Error in countlist at position "+num2str(filewave.line)+", trying to skip line!",2)
					i-=1
					continue
				endif
				ycols[n][col]=tmpd
		
				if(filewave.line>=dimsize(filewave.file,0))
					Debugprintf2("Unexpected end of VMS-file (reading data).",0)
					return -1
				endif

		
				col = Mod(col+1,cor_var)
				n = (i+1-mod(i+1,cor_var))/cor_var
			endfor
	
			if(str2num(get_flags(f_divbyNscans)) == 1)
				ycols/=scancount
			endif
			if(str2num(get_flags(f_divbytime)) == 1)
				ycols/=dwelltime
			endif
			if(str2num(get_flags(f_divbyNscans)) == 1 && str2num(get_flags(f_divbytime)) == 1)
				SetScale d 0,100,"cps", ycols
			else
				SetScale d 0,100,"a.u.", ycols
			endif
	
			splitmatrix(ycols, ycols_name)
			if (cmpstr("REGULAR",scan_mode) == 0)
				for(i=0;i<cor_var;i+=1)
					if(i==0) // detector
						rename $(ycols_name+"_spk"+num2str(i)), $(ycols_name)
						if(str2num(get_flags(f_onlyDET))==0)
							Vamas_casaInfo($(ycols_name))
						endif
					elseif(i==1) // transmission function
						if(str2num(get_flags(f_includeTF)) == 1 && str2num(get_flags(f_onlyDET))==0)
							rename $(ycols_name+"_spk"+num2str(i)), $(ycols_name+"_TF")
						else
							killwaves $(ycols_name+"_spk"+num2str(i))
						endif
					else // additional channels??
						if(str2num(get_flags(f_includeADC))==1 && str2num(get_flags(f_onlyDET))==0)	
							rename $(ycols_name+"_spk"+num2str(i)), $(ycols_name+"_ADC"+num2str(i-2))
						else
							killwaves $(ycols_name+"_spk"+num2str(i))
						endif
					endif
				endfor
			else
				for(i=0;i<cor_var;i+=1)
					if(i==0) // x-axis
						rename $(ycols_name+"_spk"+num2str(i)), $(ycols_name+"_X")
					else
						rename $(ycols_name+"_spk"+num2str(i)), $(ycols_name+"_Y"+num2str(i))
					endif
				endfor	
			endif

			break
	endswitch

	Debugprintf2("exported: "+ycols_name,0)
	return 0
end


static function Vamas_casaInfo(detector)
	wave detector
	string notes =  note(detector)
	if(cmpstr(stripstrfirstlastspaces(StringByKey("spectra comment #1", notes, ":", "\r")),"Casa Info Follows")==0)
		Debugprintf2("... File is a CasaXPS VMS file.",1)
		variable tmp = str2num(stripstrfirstlastspaces(StringByKey("spectra comment #2", notes, ":", "\r")))
		variable i=2+tmp+1
		if(tmp!=0)
			i+=1
		endif
		tmp = str2num(stripstrfirstlastspaces(StringByKey("spectra comment #"+num2str(i), notes, ":", "\r")))
		i+=tmp+1
		if(tmp!=0)
			i+=1
		endif
		variable nregions = str2num(stripstrfirstlastspaces(StringByKey("spectra comment #"+num2str(i), notes, ":", "\r")))
		if(nregions < 1)
			return -1 // no regions 
		endif
		variable j=0
		for(j=0;j<nregions;j+=1)
			i+=1
			Vamas_casaInfo_region(detector, stripstrfirstlastspaces(StringByKey("spectra comment #"+num2str(i), notes, ":", "\r")), j)
		endfor
		i+=1
		variable ncomp = str2num(stripstrfirstlastspaces(StringByKey("spectra comment #"+num2str(i), notes, ":", "\r")))
		if(ncomp < 1)
			return -1 // no components
		endif
		for(j=0;j<ncomp;j+=1)
			i+=1
			Vamas_casaInfo_comp(detector, stripstrfirstlastspaces(StringByKey("spectra comment #"+num2str(i), notes, ":", "\r")), j)
		endfor
	endif
end


static function Vamas_casaInfo_region(detector, param, n)
	wave detector
	string param
	variable n

	struct Vamas_CasaXPS_region region_param

	param=param[strlen("CASA region (*"),inf]
	region_param.name = param[0,strsearch(param,"*)",0)-1] ; param = param[strlen(region_param.name)+strlen("*) (*"),inf]
	region_param.BGType = param[0,strsearch(param,"*)",0)-1]; param = param[strlen(region_param.BGType)+strlen("*) "),inf]
	region_param.startBG = str2num(stringfromlist(0,param," "))
	region_param.endBG = str2num(stringfromlist(1,param," "))
	region_param.RSF = str2num(stringfromlist(2,param," "))
	region_param.avwidth = str2num(stringfromlist(3,param," "))
	region_param.startoffset = str2num(stringfromlist(4,param," "))
	region_param.endoffset = str2num(stringfromlist(5,param," "))
	region_param.tag = param[strsearch(param,"(*",0)+2,strsearch(param,"*)",0)-1]

	if(str2num(get_flags(f_vsEkin))==0)
		region_param.energy = str2num(stripstrfirstlastspaces(StringByKey("analysis source characteristic energy", note(detector), ":", "\r")))
		region_param.startBG = region_param.energy - region_param.startBG
		region_param.endBG = region_param.energy - region_param.endBG
		
		if(str2num(get_flags(f_posEbin)) == 0)
			region_param.startBG *=-1
			region_param.endBG *=-1
		endif	
	endif

	strswitch(region_param.BGType)
		case "Shirley":
			string tmps = nameofwave(detector)+"R"+num2str(n)
			Duplicate /O/R=(region_param.startBG,region_param.endBG) detector, $tmps
			wave back = $tmps
			tmps = nameofwave(detector)+"BGR"+num2str(n)
			Duplicate /O/R=(region_param.startBG,region_param.endBG) detector, $tmps
			wave spec = $tmps
			Vamas_BG_Shirley(back,iterations=50)
			spec-=back
			break
		default:
			Debugprintf2("Unknown BG type!",1)
			break
	endswitch
	
	return 0
end


static function Vamas_casaInfo_comp(detector, param, n)
	wave detector
	string param
	variable n
	string tmps = nameofwave(detector)+"c"+num2str(n)
	duplicate detector, $tmps
	wave comp = $tmps
	struct Vamas_CasaXPS_comp comp_param

	param=param[strlen("CASA comp (*"),inf]
	comp_param.name = param[0,strsearch(param,"*)",0)-1] ; param = param[strlen(comp_param.name)+strlen("*) (*"),inf]
	comp_param.lineshape = param[0,strsearch(param,"*)",0)-1]; param = param[strlen(comp_param.lineshape)+strlen("*) "),inf]
	comp_param.shape = str2num(comp_param.lineshape[strsearch(comp_param.lineshape,"(",0)+1,strsearch(comp_param.lineshape,")",0)-1])
	comp_param.lineshape = comp_param.lineshape[0,strsearch(comp_param.lineshape,"(",0)-1]
	comp_param.area=str2num(stringfromlist(1,param," "))
	comp_param.area_L=str2num(stringfromlist(2,param," "))
	comp_param.area_U=str2num(stringfromlist(3,param," "))
	comp_param.FWHM=str2num(stringfromlist(7,param," "))
	comp_param.FWHM_L=str2num(stringfromlist(8,param," "))
	comp_param.FWHM_U=str2num(stringfromlist(9,param," "))
	comp_param.position=str2num(stringfromlist(13,param," "))
	comp_param.position_L=str2num(stringfromlist(14,param," "))
	comp_param.position_U=str2num(stringfromlist(15,param," "))
	comp_param.RSF=str2num(stringfromlist(19,param," "))
	comp_param.MASS=str2num(stringfromlist(21,param," "))
	comp_param.compindex=str2num(stringfromlist(23,param," "))
	comp_param.tag=param[strsearch(param,"(*",0)+2,strsearch(param,"*)",0)-1]
	comp_param.energy = 0
	variable posbind=1
	if(str2num(get_flags(f_vsEkin))==0)
		comp_param.energy = str2num(stripstrfirstlastspaces(StringByKey("analysis source characteristic energy", note(detector), ":", "\r")))
		comp_param.position = comp_param.energy - comp_param.position
		if(str2num(get_flags(f_posEbin)) == 0)
			posbind=-1
		endif	
	endif
	
	strswitch(comp_param.lineshape)
		case "GL":
			comp = Vamas_LS_GLA(x, comp_param.area, posbind*comp_param.position, comp_param.FWHM/2, comp_param.shape/100)
			break
		case "SGL":
			comp = Vamas_LS_SGLA(x, comp_param.area, posbind*comp_param.position, comp_param.FWHM/2, comp_param.shape/100)
			break
		default:
			Debugprintf2("Unknown line shape!",1)
			break
	endswitch
	return 0
end


function Vamasrpt_check_file(file)
	variable file
	fsetpos file, 0
	string line = ""

	variable headerpresent = 0
	
	FReadLine file, line
	if(strlen(line) == 0)
		headerpresent += -1
	else
		headerpresent += 1
	endif
	line = mycleanupstr(line)
	if(strsearch(line, ".vms",0) ==-1)
		headerpresent += -1
	else
		headerpresent += 1
	endif

	FReadLine file, line // name of spectra
	if(strlen(line) == 0)
		headerpresent += -1
	else
		headerpresent += 1
	endif

	FReadLine file, line
	if(strlen(line) == 0)
		fsetpos file, 0
		return -1
	endif
	line = mycleanupstr(line)
	if(strsearch(line, "Characteristic Energy eV",0) ==-1 && strsearch(line, "Acquisition Time s",0) ==-1)
		headerpresent += -1
	else
		headerpresent += 1
	endif
	if(headerpresent != 4)
		fsetpos file, 0
		FReadLine file, line
		if(strlen(line) == 0)
			fsetpos file, 0
			return -1
		endif
		// read nametags
		line = mycleanupstr(line)
		line = stripstrfirstlastspaces(line)
		variable components =  itemsinlist(line,"	"), i=0
		if(components <= 1)
			fsetpos file, 0
			return -1	
		endif
		// read first line of numbers
		line=myreadline(file)
		line = stripstrfirstlastspaces(line)
		if(strlen(line)==0 || itemsinlist(line,"	") != components)
			fsetpos file, 0
			return -1
		endif
		for(i=0;i<itemsinlist(line,"	");i+=1)
			if(numtype(str2num(StringFromList(i,line,"	")))!=0)
				fsetpos file, 0
				return -1	
			endif
		endfor
		fsetpos file, 0
		return 2 // 2 .. no header
	endif
	fsetpos file, 0
	return 1
end


function Vamasrpt_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "Vamas report (CasaXPS)"
	importloader.filestr = "*.txt"
	importloader.category = "PES"
end


function Vamasrpt_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	Vamasrpt_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header+"\r"
	variable file = importloader.file

	variable type = Vamasrpt_check_file(file)
	switch(type)
		case 1:
			header+="Line 1: "+myreadline(file)+"\r"
			header+="Line 2: "+myreadline(file)+"\r"
			header+="Line 2: "+myreadline(file)
			break
		case 2:
			break
		default:
			loaderend(importloader)
			break
	endswitch

	string names=myreadline(file)
	names = stripstrfirstlastspaces(names)
	variable components =  itemsinlist(names,"	"), i=0
	variable counter=1
	string line="spectra"
	Make /O/D/N=(counter,components)  $line /wave=cols
	Note cols, header
	do
		Redimension/N=(counter, -1) cols
		line=myreadline(file)
		line = stripstrfirstlastspaces(line)
		if(strlen(line)==0 || itemsinlist(line,"	") != components)
			Debugprintf2("Error in reading CasaXPS report file!",0)
			break
		endif
		for(i=0;i<itemsinlist(line,"	");i+=1)
			cols[counter-1][i]=str2num(StringFromList(i,line,"	"))
		endfor
		counter+=1
		Fstatus file
	while (V_logEOF>V_filePOS)  
		
	variable j=0
	variable ekinstart=0, ekinend=1, ebinstart=0, ebinend=1
	variable mymax=0, mymin=0
	
	Display /K=1 // Kills window with no dialog
	string windowname = S_name
	string tmps=""
	variable sub = 0
	
	switch(type)
		case 1:
			sub = 0
			break
		case 2:
			sub = 1
			break
	endswitch			

	for(i=0;i<dimsize(cols,1);i+=1)
		tmps=cleanname(StringFromList(i,names,"	"))+"_"+num2str(i+1)
		//Rename loaded wave to cleaned-up filename
		duplicate cols, $tmps
		WAVE w = $tmps
		redimension /N=(dimsize(cols,0)) w
		for(j=0;j< dimsize(cols,0);j+=1)
			w[j]=cols[j][i]		
		endfor	
		switch(type)
			case 1:
				if(i==0)
					//if (checkEnergyScale(w, 8E-5))
					ekinstart=w[0]
					ekinend=w[dimsize(w,0)-1]
					//endif
				endif
				break
			case 2:
				break
		endswitch			

		if(i==(1-sub))
//			if(checkEnergyScale(w, 8E-5))
				ebinstart=w[0]
				ebinend=w[dimsize(w,0)-1]
//			endif
		endif
		if(i==(2-sub))
			WaveStats/Q w
			mymax =  V_max
			mymin = V_min
		endif
		
		if(i>(1-sub))
		
			if(str2num(get_flags(f_posEbin)) == 0)
				SetScale/I  x,-ebinstart,-ebinend,"eV", w
			else
				SetScale/I  x,ebinstart,ebinend,"eV", w
			endif

			if (  strsearch(tmps[strlen(tmps)-1,strlen(tmps)],"'",0) ==0)
				tmps= tmps[0,strlen(tmps)-2]+"N"+"'"
			else
				tmps=tmps+"N"
			endif

			duplicate /O w, $tmps
			wave wn =$tmps
			if(mymax !=0)
				wn -=V_min
				wn /= (mymax -mymin)
			endif
			AppendToGraph /W=$windowname wn


			if(i==dimsize(cols,1)-1)
				tmps="residual_0"
				WAVE residual = $tmps
				residual-=w

				tmps="residual_0N"
				WAVE residual = $tmps
				residual-=wn
			endif
		endif
		if(i==(2-sub))
			tmps="residual_0"
			duplicate w, $tmps
			tmps="residual_0N"
			duplicate wn, $tmps
		endif

	endfor
	KillWaves/Z cols
	AppendToGraph /W=$windowname residual
	
	ModifyGraph /W=$windowname mirror=2
	Label /W=$windowname left "intensity [cps \E]"
	label /W=$windowname bottom "binding energy [\\U]"
	
	
	string tracesInGraph = TraceNameList(windowname, ";",1)
	tmps=StringFromList(0, tracesInGraph) // measured spectrum
	ModifyGraph /W=$windowname mode($tmps)=3,marker($tmps)=8,rgb($tmps)=(0,0,0) 

	for( i = 1; i < ItemsInList(tracesInGraph); i += 1 )
		tmps=StringFromList(i, tracesInGraph)
		ModifyGraph /W=$windowname lstyle($tmps)=0,lsize($tmps)=2
	endfor
	tmps=StringFromList(ItemsInList(tracesInGraph)-3, tracesInGraph)// background
	ModifyGraph /W=$windowname rgb($tmps)=(0,0,0), rgb($tmps)=(1,16019,65535) 
	tmps=StringFromList(ItemsInList(tracesInGraph)-2, tracesInGraph) // envelope
	ModifyGraph /W=$windowname rgb($tmps)=(0,0,0), rgb($tmps)=(2,39321,1)

	
	Legend /W=$windowname/C/N=text0/M/A=LT/X=0.00/Y=0.00
	
	importloader.success = 1
	loaderend(importloader)
end


static function Vamas_LS_Gauss(x, height, center, hwhm, shape)
	variable x, height, center, hwhm, shape
	return height*exp(-ln(2)*(1-shape)*((x-center)/hwhm)^2)
end


static function Vamas_LS_GaussA(x, area, center, hwhm, shape)
	variable x, area, center, hwhm, shape
	return Vamas_LS_Gauss(x, area/hwhm/sqrt(pi/ln(2)), center, hwhm, shape)
end


static function Vamas_LS_Lorentz(x, height, center, hwhm, shape)
	variable x, height, center, hwhm, shape
	return height/(1+(shape)*((x-center)/hwhm)^2)
end


static function Vamas_LS_LorentzA(x, area, center, hwhm, shape)
	variable x, area, center, hwhm, shape
	return  Vamas_LS_Lorentz(x, area/hwhm/pi, center, hwhm, shape)
end


static function Vamas_LS_GL(x, height, center, hwhm, shape)
	variable x, height, center, hwhm, shape
	return height*Vamas_LS_Gauss(x, 1, center, hwhm, shape)*Vamas_LS_Lorentz(x, 1, center, hwhm, shape)
end


static function Vamas_LS_GLA(x, area, center, hwhm, shape)
	variable x, area, center, hwhm, shape
	return area/hwhm*sqrt(1/pi/sqrt(pi/ln(2)))*Vamas_LS_Gauss(x, 1, center, hwhm, shape)*Vamas_LS_Lorentz(x, 1, center, hwhm, shape)
end


static function Vamas_LS_SGL(x, height, center, hwhm, shape)
	variable x, height, center, hwhm, shape
	return height*((1-shape)*Vamas_LS_Gauss(x, 1, center, hwhm, 0)+shape*Vamas_LS_Lorentz(x, 1, center, hwhm, 1))
end


static function Vamas_LS_SGLA(x, area, center, hwhm, shape)
	variable x, area, center, hwhm, shape
	return Vamas_LS_Gauss(x, area*(1-shape), center, hwhm, 0)+shape*Vamas_LS_LorentzA(x, area*shape, center, hwhm, 1)
end


static function Vamas_BG_Shirley(back, [iterations])
	// http://www.casaxps.com/help_manual/manual_updates/peak_fitting_in_xps.pdf page 5
	wave back
	variable iterations
	iterations = paramIsDefault(iterations) ? 100 : iterations
	
	duplicate  /O/FREE back, A1
	duplicate  /O/FREE back, A2
	duplicate  /O/FREE back, S1; S1 = 0
	duplicate  /O/FREE back, tmpspec
	// refining the BG
	variable k=0, i=0
	for(k=0;k<iterations;k+=1)
		A2[]=back[p]
		integrate A2
		A1[]=A2[dimsize(back,0)-1]-A2[p]
		// BG calculation based on original spectra
		S1[]=tmpspec[p]-tmpspec[0]+abs(tmpspec[dimsize(tmpspec,0)-1]-tmpspec[0])*(A2[p]/(A1[p]+A2[p]))
		// http://www.phy.ilstu.edu/slh/chi-square.pdf
		variable chi =0
		for(i=0;i<dimsize(back, 0);i+=1)
			if(back[i]!=0)
				chi += ((back[i]-S1[i])^2)/back[i]
			endif
		endfor
		Debugprintf2("Chi^2: "+num2str(chi),1)
		if(chi==0)
			break
		endif
		// save new BG corrected spectra
		duplicate /O S1, back
	endfor
	// save the Shirley BG
	back[]=tmpspec[p]-S1[p]
	return 0
end


static function Vamas_BG_Tougaard(back, B, C, D, T0)
	wave back
	variable B, C, D, T0
	
	
	
	return 0
end


function Vamas_getkeyval(filewave, key, val)
	struct loader_file &filewave
	string &key
	string &val
	string tmps
	
//	tmps = loader_readline_str(filewave)
	tmps = filewave.file[filewave.line]
	filewave.line +=1
	If (strlen(tmps)==0)
		return -1
	endif
	tmps = mycleanupstr(tmps)
	tmps=stripstrfirstlastspaces(tmps)
	if(strsearch(tmps,"=",0)!=-1)
		key = stripstrfirstlastspaces(tmps[0,strsearch(tmps,"=",0)-1])
		val=stripstrfirstlastspaces(tmps[strsearch(tmps,"=",0)+1,inf])
	elseif(strlen(tmps)==1 && strsearch(tmps,"{",0)==0)
		key = "{"
		val=""
	elseif(strlen(tmps)==1 && strsearch(tmps,"}",0)==0)
		key = "}"
		val=""
	elseif(strlen(tmps)>1) //single keyword
		key =stripstrfirstlastspaces(tmps)
		val =""
	endif
end


function Vamas_skip_lines(filewave, count)
	struct loader_file &filewave
	variable count
	string tmps
	variable i=0
	for (i = 0; i < count; i+=1) 
		tmps = loader_readline_str(filewave)
		if(strlen(tmps) == 0)
			Debugprintf2("Unexpected end of file.",0)
			return -1
		endif
	endfor
	return 0
end
