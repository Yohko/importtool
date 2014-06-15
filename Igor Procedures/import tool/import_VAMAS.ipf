// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

// The VAMAS procedure is based on xylib by Marcin Wojdyr:
// https://github.com/wojdyr/xylib (https://github.com/wojdyr/xylib/blob/master/xylib/vamas.cpp)

// ISO14976 VAMAS Surface Chemical Analysis Standard Data Transfer Format File
// This implementation is based on 
// Dench, W. A., Hazell, L. B., Seah, M. P., the VAMAS Community. (1988). 
// VAMAS Surface chemical analysis standard data transfer format with skeleton decoding programs. 
// Surface and Interface Analysis, 13(2-3), 63Ð122. doi:10.1002/sia.740130202
// National Physics Laboratory Report DMA(A)164 July 1988
//  and on the analysis of sample files.

Menu "Macros"
	submenu "Import Tool "+importloaderversion
			submenu "PES"
				"Load VAMAS					*.vms	file... v1.0", Vamas_load_data()
				"Load and graph CasaXPS reports", Vamas_loadplot_report()
			end
	end
end



// dictionaries for VAMAS data
static strconstant exps = "MAP;MAPDP;MAPSV;MAPSVDP;NORM;SDP;SDPSV;SEM;NOEXP"
static strconstant techs = "AES diff;AES dir;EDX;ELS;FABMS;FABMS energy spec;ISS;SIMS;SIMS energy spec;SNMS;SNMS energy spec;UPS;XPS;XRF"
static strconstant scans = "REGULAR;IRREGULAR;MAPPING"


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
	
	variable i=0, optf=0
	string tmps=""
	// sometimes there are empty lines at the beginning
	// need to find the magic line
	string key="", val=""
	do 
		if (getkeyval(file, key, val)==-1)
			break
		endif

		if(strsearch(key,"VAMAS Surface Chemical Analysis Standard Data Transfer Format 1988 May 4",0)==0)
			Debugprintf2("Found beginning of standard Vamas file.",0)
			break
		endif
		if(strsearch(key,"VAMAS",0)==0)
			Debugprintf2("Found beginning of non standard Vamas file. trying to import!!",0)
			break
		endif
		key=""
		val=""
		Fstatus file
		if(V_logEOF<=V_filePOS)
			Debugprintf2("Unexpected end of VMS-file (header).",0)
			loaderend(importloader)
			return -1
		endif
	while (V_logEOF>V_filePOS)  	

	headercomment += "institution identifier: " + read_line_trim(file) + "\r"
	headercomment += "institution model identifier" + read_line_trim(file) + "\r"
	headercomment += "operator identifier: " + read_line_trim(file) + "\r"
	headercomment += "experiment identifier: " + read_line_trim(file) + "\r"

    // skip comment lines, n is number of lines //todo read comments 
	variable n = read_line_int(file)
	for (i = 0; i <n; i+=1) 
		FReadLine file, tmps
		if(strlen(tmps) == 0)
			Debugprintf2("Unexpected end of VMS-file.",0)
			return -1
		endif
		tmps=mycleanupstr(tmps)
		headercomment += "comment #"+num2str(i+1)+": "+tmps+"\r"
	endfor
	
	string exp_mode = read_line_trim(file)
	// make sure exp_mode has a valid value
	if(FindListItem(exp_mode, exps, ";")==-1)
		Debugprintf2("exp_mode has an invalid value: "+exp_mode,0)
	endif

	string scan_mode = read_line_trim(file)
	// make sure scan_mode has a valid value
	if(FindListItem(scan_mode, scans, ";")==-1)
		Debugprintf2("Scan mode has an invalid value: "+scan_mode,0)
	endif

	// some exp_mode specific file-scope meta-info
	string numspecregions = ""
	if ((cmpstr("MAP",exp_mode) == 0) || (cmpstr("MAPD",exp_mode) == 0) || (cmpstr("NORM",exp_mode) == 0) || (cmpstr("SDP",exp_mode) == 0) )
		headercomment += "number of spectral regions: " + read_line_trim(file) +"\r"
    	endif

	if ((cmpstr("MAP",exp_mode) == 0) || (cmpstr("MAPD",exp_mode) == 0))
		headercomment += "number of analysis positions: " + read_line_trim(file) + "\r"
		headercomment += "number of discrete x coordinates available in full map: " + read_line_trim(file) + "\r"
		headercomment += "number of discrete y coordinates available in full map: " + read_line_trim(file) + "\r"
	endif

	// experimental variables
	variable exp_var_cnt = read_line_int(file)
	//variable i=0
	for (i = 1; i <= exp_var_cnt; i+=1)
		headercomment += "experimental variable label " + num2str(i) + ": " + read_line_trim(file) + "\r"
		headercomment += "experimental variable unit " + num2str(i) + ": "+ read_line_trim(file) + "\r"
	endfor
	headercomment=mycleanupstr(headercomment)
	// fill `include' table
	// This next line is a relic of an earlier version of the format.
	// In that version, this line contained an integer whose value indicated a number of optional features to follow.
	// In the current version of the standard, these optional features have been removed, so the value should always be 0.
	// Software which could read the old file format will therefore remain compatible with the new version, but
	// this VAMASParser will not be able to read the old file format, and must simply throw an exception if the
	// value is not 0.
	n = read_line_int(file) // # of entries in inclusion or exclusion list
	optf=n
	if(n!=0)
		Fstatus file
		Debugprintf2("Error reading VAMAS file; expected '0', read '" + num2str(n) + "' at position " + num2str(V_filePOS),0)
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
		idx = read_line_int(file) - 1
		inclusionlist[idx]=d
	endfor
	
	// # of manually entered items in block
	// list any manually entered items
	n = read_line_int(file)
	if(skip_lines(file, n)==-1)
		loaderend(importloader)
		return -1
	endif
	// list any future experiment upgrade entries
	variable exp_fue = read_line_int(file)
	variable blk_fue = read_line_int(file) //new
	if(skip_lines(file, exp_fue)==-1)
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
	variable blk_cnt = read_line_int(file)
	
	for (i = 0; i < blk_cnt; i+=1)
	
		if(i==1)
			for(j=0;j<40;j+=1)
				includew[j]=inclusionlist[j]
			endfor
		endif
	
		if(Vamas_read_block(file, includew,exp_mode,exp_var_cnt, scan_mode,blk_fue, headercomment,i, cor_var)==-1)
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
static function Vamas_read_block(file, includew,exp_mode,exp_var_cnt, scan_mode,blk_fue, headercomment, count, cor_var)//,impname, dfSave)
	variable file
	wave includew
	string exp_mode
	variable exp_var_cnt
	string scan_mode
	variable blk_fue
	string headercomment
	variable count
	variable &cor_var //= 0 // # of corresponding variables
	variable x_start=0.0, x_step=0.0, i=0, n=0
	string x_name = "", tmps=""
	variable excenergy = 0
	variable dwelltime = 1
	variable scancount = 1

//	variable cor_var = 0 // # of corresponding variables

	string blockid =read_line_trim(file)+"_count_"+num2str(count)
	blockid = cleanname(blockid)
	Make /O/R/N=(10)  $blockid /wave=ycols
	Note ycols, headercomment
	
	Note ycols, "block id: "+ blockid
	Note ycols, "sample identifier: "+ read_line_trim(file)

	//print blockid
	if (includew[0]==1)
		Note ycols, "year: " + read_line_trim(file)
	endif
	if (includew[1]==1)
		note ycols, "month: " + read_line_trim(file)
	endif
	if (includew[2]==1)
		note ycols, "day: " + read_line_trim(file)
	endif
	if (includew[3]==1)
		note ycols, "hour: " + read_line_trim(file)
	endif
	if (includew[4]==1)
		note ycols, "minute: " +  read_line_trim(file)
	endif
	if (includew[5]==1)
		note ycols, "second: " + read_line_trim(file)
	endif
	if (includew[6]==1)
		note ycols, "no. of hours in advanced GMT: " + read_line_trim(file)
	endif
	variable cmt_lines=0
	if (includew[7]==1) // skip comments on this block
		cmt_lines = read_line_int(file)
		for (i = 0; i <cmt_lines; i+=1) 
			FReadLine file, tmps
			if(strlen(tmps) == 0)
				Debugprintf2("Unexpected end of VMS-file.",0)
				return -1
			endif
			tmps=mycleanupstr(tmps)
			note ycols, "Comment #"+num2str(i+1)+": "+stripstrfirstlastspaces(tmps)
		endfor
//		if(Vamas_skip_lines(file, cmt_lines)==-1)
//			//loaderend(impname,1,file, dfSave)
//			return -1
//		endif
	endif

	string tech=""
	if (includew[8]==1)
		tech = read_line_trim(file)
		note ycols, "tech: " + tech
		if(FindListItem(tech, techs, ";")==-1)
			Debugprintf2("Tech. has an invalid value: "+tech,0)
		endif
	endif

	if (includew[9]==1)
		if ((cmpstr("MAP",exp_mode) == 0) || (cmpstr("MAPDP",exp_mode) == 0))
			note ycols, "x coordinate" + read_line_trim(file)
			note ycols, "y coordinate" + read_line_trim(file)
		endif
	endif

	if (includew[10]==1)
		for (i = 0; i < exp_var_cnt; i+=1)
			note ycols, "experimental variable value " + num2str(i+1)+": "+  read_line_trim(file)
		endfor
	endif

	if (includew[11]==1)
		note ycols, "analysis source label: "+  read_line_trim(file)
	endif
	
	if (includew[12]==1)
		if ((cmpstr("MAPDP",exp_mode) == 0) || (cmpstr("MAPSVDP",exp_mode) == 0) || (cmpstr("SDP",exp_mode) ==0) || (cmpstr("SDPSV",exp_mode )== 0) || (cmpstr("SNMS energy spec",tech) == 0) || (cmpstr("FABMS",tech) == 0) || (cmpstr("FABMS energy spec",tech) == 0) || (cmpstr("ISS",tech) == 0) || (cmpstr("SIMS",tech) == 0) || (cmpstr("SIMS energy spec",tech) == 0) || (cmpstr("SNMS",tech) == 0))
			note ycols, "sputtering ion or atom atomic number: "+ read_line_trim(file)
			note ycols, "number of atoms in sputtering ion or atom particle: "+ read_line_trim(file)
			note ycols, "sputtering ion or atom charge sign and number: "+ read_line_trim(file)
		endif
	endif
	if (includew[13]==1)
		excenergy =  read_line_int(file)
		note ycols, "analysis source characteristic energy: " + num2str(excenergy)
	endif
	if (includew[14]==1)
		note ycols, "analysis source strength: "+ read_line_trim(file)
	endif

	if (includew[15]==1)
		note ycols, "analysis source beam width x: "+ read_line_trim(file)
		note ycols, "analysis source beam width y: "+ read_line_trim(file)
	endif

	if (includew[16]==1)
		if ((cmpstr("MAP",exp_mode) ==0) || (cmpstr("MAPDP",exp_mode) ==0) || (cmpstr("MAPSV",exp_mode) ==0)  || (cmpstr("MAPSVDP",exp_mode) ==0) || (cmpstr("SEM",exp_mode) ==0))
			note ycols, "field of view x: "+  read_line_trim(file)
			note ycols, "field of view y: "+  read_line_trim(file)
		endif
	endif

	if (includew[17]==1)
		if ((cmpstr("SEM",exp_mode) ==0) || (cmpstr("MAPSV",exp_mode) ==0) || (cmpstr("MAPSVDP",exp_mode) ==0))
			Debugprintf2("unsupported MAPPING mode",0)
			return -1
			note ycols, "First Line Scan Start X-Coordinate: "+  read_line_trim(file)
			note ycols, "First Line Scan Start Y-Coordinate: "+  read_line_trim(file)
			note ycols, "First Line Scan Finish X-Coordinate: "+  read_line_trim(file)
			note ycols, "First Line Scan Finish Y-Coordinate: "+  read_line_trim(file)
			note ycols, "Last Line Scan Finish X-Coordinate: "+  read_line_trim(file)
			note ycols, "Last Line Scan Finish Y-Coordinate: "+  read_line_trim(file)
		endif
	endif

	if (includew[18]==1)
		note ycols, "analysis source polar angle of incidence: "+  read_line_trim(file)
	endif
	if (includew[19]==1)
		note ycols, "analysis source azimuth: "+  read_line_trim(file)
	endif
	if (includew[20]==1)
		note ycols, "analyser mode: "+  read_line_trim(file)
	endif
	if (includew[21]==1)
		note ycols, "analyser pass energy or retard ratio or mass resolution: " + read_line_trim(file)
	endif

	if (includew[22]==1)
		if (cmpstr("AES diff",tech)==0)
			note ycols, "differential width: "+  read_line_trim(file)
		endif
	endif

	if (includew[23]==1)
		note ycols, "magnification of analyser transfer lens: "+  read_line_trim(file)
	endif
	// QAZ semantics of next element depends on technique
	if (includew[24]==1)
		note ycols, "analyser work function or acceptance energy of atom or ion: "+  read_line_trim(file)
	endif
	if (includew[25]==1)
		note ycols, "target bias: "+  read_line_trim(file)
	endif

	if (includew[26]==1)
		note ycols, "analysis width x: "+ read_line_trim(file)
		note ycols, "analysis width y: "+  read_line_trim(file)
	endif

	if (includew[27]==1)
		note ycols, "analyser axis take off polar angle: "+  read_line_trim(file)
		note ycols, "analyser axis take off azimuth: "+  read_line_trim(file)
	endif

	if (includew[28]==1)
		note ycols, "species label: "+  read_line_trim(file)
	endif

	if (includew[29]==1)
		note ycols, "transition or charge state label: "+  read_line_trim(file)
		note ycols, "charge of detected particle: "+  read_line_trim(file)
	endif

	if (includew[30]==1)
		if (cmpstr("REGULAR",scan_mode) == 0)
			x_name =  read_line_trim(file)
			note ycols, "abscissa label: "+ x_name
			note ycols, "abscissa units: "+  read_line_trim(file)
			x_start = read_line_int(file)
			x_step = read_line_int(file)
		else
			Debugprintf2("Only REGULAR scans are supported now",0)
		endif
	else
		Debugprintf2("how to find abscissa properties in this file?",0)
	endif


	
	if (includew[31]==1)
		cor_var = read_line_int(file)
		//inclusionlist[40] = cor_var
		// columns initialization
		Redimension/N=(-1,cor_var) ycols
		for (i = 0; i != cor_var; i+=1)
			note ycols,"Name Col"+num2str(i)+": "+read_line_trim(file)
			if(skip_lines(file, 1)==-1) // corresponding variable unit
				//loaderend(impname,1,file, dfSave)
				return -1
			endif
		endfor
	endif

	if (includew[32]==1)
		note ycols, "signal mode: "+  read_line_trim(file)
	endif
	if (includew[33]==1)
		dwelltime =  read_line_int(file)
		note ycols, "signal collection time: "+  num2str(dwelltime)//read_line_trim(file)
	endif
	if (includew[34]==1)
		scancount =  read_line_int(file)
		note ycols, "# of scans to compile this blk: "+  num2str(scancount)//read_line_trim(file)
	endif
	if (includew[35]==1)
		note ycols, "signal time correction: "+  read_line_trim(file)
	endif
	if (includew[36]==1)
		if (( (cmpstr("AES diff",tech) == 0) ||  (cmpstr("AES dir",tech) == 0) ||  (cmpstr("EDX",tech) == 0) ||  (cmpstr("ELS",tech) == 0) ||  (cmpstr("UPS",tech) == 0) ||  (cmpstr("XPS",tech) == 0) ||  (cmpstr("XRF",tech) == 0)) && ( (cmpstr("MAPDP",exp_mode) == 0) ||  (cmpstr("MAPSVDP",exp_mode) == 0) ||  (cmpstr("SDP",exp_mode) == 0) ||  (cmpstr("SDPSV",exp_mode) == 0))) 
			note ycols, "Sputtering Source Energy: "+read_line_trim(file)
			note ycols, "Sputtering Source BeamCurrent: "+read_line_trim(file)
			note ycols, "Sputtering Source WidthX: "+read_line_trim(file)
			note ycols, "Sputtering Source WidthY: "+read_line_trim(file)
			note ycols, "Sputtering Source PolarAngle Of Incidence: "+read_line_trim(file)
			note ycols, "Sputtering Source Azimuth: "+read_line_trim(file)
			note ycols, "Sputtering Mode: "+read_line_trim(file)
			//if(Vamas_skip_lines(file, 7)==-1)
				//loaderend(impname,1,file, dfSave)
			//	return -1
			//endif
		endif
	endif

	if (includew[37]==1)
		note ycols, "sample normal polar angle of tilt: "+  read_line_trim(file)
		note ycols, "sample normal polar tilt azimuth: "+  read_line_trim(file)
	endif

	if (includew[38]==1)
		note ycols, "sample rotate angle: "+  read_line_trim(file)
	endif
	
	if (includew[39]==1)
		n = read_line_int(file) // # of additional numeric parameters
		for (i = 0; i < n; i+=1)
			// 3 items in every loop: param_label, param_unit, param_value
			string param_label =  read_line_trim(file)
			string param_unit =  read_line_trim(file)
			note ycols, param_label +": " + read_line_trim(file) + param_unit
		endfor
	endif

	if(skip_lines(file, blk_fue)==-1)
		return -1
	endif
	variable cur_blk_steps = read_line_int(file)

	if(skip_lines(file, 2 * cor_var)==-1) // min & max ordinate
	//if(Vamas_skip_lines(file, 2 * inclusionlist[40])==-1) // min & max ordinate
		//loaderend(impname,1,file, dfSave)
		return -1
	endif

	if ((cmpstr("UPS",tech) == 0) ||  (cmpstr("XPS",tech) == 0)) 
		if(strsearch(x_name,"Kinetic Energy",0,2)!=-1)
			if(str2num(get_flags("vskineticenergy"))==0)
				if(str2num(get_flags("posbinde")) == 0)
					SetScale/P  x,x_start-excenergy,x_step,"eV", ycols
				else
					SetScale/P  x,-x_start+excenergy,-x_step,"eV", ycols
				endif
			else
					SetScale/P  x,x_start,x_step,"eV", ycols
			endif
		elseif(strsearch(x_name,"Binding Energy",0,2)!=-1)
			if(str2num(get_flags("vskineticenergy"))==0)
				if(str2num(get_flags("posbinde")) == 0)
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
	variable tmpd=0
	for (i = 0; i < cur_blk_steps; i+=1)
		tmpd=read_line_int(file)
		if(numtype(tmpd)==2)
			// some VMS files have empty lines here, CasaXPS still loads these files properly
			Debugprintf2("Nummeric error in countlist, trying to skip line!",2)
			i-=1
		endif
		ycols[n][col]=tmpd
		
		Fstatus file
		if(V_logEOF<=V_filePOS)
			Debugprintf2("Unexpected end of VMS-file (reading data).",0)
			return -1
		endif

		
		col = Mod(col+1,cor_var)
		n = (i+1-mod(i+1,cor_var))/cor_var
	endfor
	
	if(str2num(get_flags("CB_DivScans")) == 1)
		ycols/=scancount
	endif
	if(str2num(get_flags("CB_DivLifeTime")) == 1)
		ycols/=dwelltime
	endif
	
	splitmatrix(ycols, blockid)
	Debugprintf2("exported: "+blockid,0)
	return 0
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
	string header = importloader.header
	variable file = importloader.file
	header+="Line 1: "+myreadline(file)+"\r"
	header+="Line 2: "+myreadline(file)+"\r"
	header+="Line 2: "+myreadline(file)
	string names=myreadline(file)
	variable components =  itemsinlist(names,"	"), i=0
	variable counter=1
	string line="spectra"
	Make /O/R/N=(counter,components)  $line /wave=cols
	Note cols, header
	do
		Redimension/N=(counter, -1) cols
		line=myreadline(file)
		if(strlen(line)==0 || itemsinlist(line,"	") != components)
			print "Error in reading CasaXPS report file!"
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
	
	Display
	string windowname = S_name
	string tmps=""
	for(i=0;i<dimsize(cols,1);i+=1)
		tmps=StringFromList(i,names,"	")+"_"+num2str(i+1)
		//Rename loaded wave to cleaned-up filename
		duplicate cols, $tmps
		WAVE w = $tmps
		redimension /N=(dimsize(cols,0)) w
		for(j=0;j< dimsize(cols,0);j+=1)
			w[j]=cols[j][i]		
		endfor	
		if(i==0)
			if (checkEnergyScale(w, 8E-5))
				ekinstart=w[0]
				ekinend=w[dimsize(w,0)-1]
			endif
		endif
		if(i==1)
			if(checkEnergyScale(w, 8E-5))
				ebinstart=w[0]
				ebinend=w[dimsize(w,0)-1]
			endif
		endif
		if(i>1)
			if(str2num(get_flags("posbinde")) == 0)
				SetScale/I  x,-ebinstart,-ebinend,"eV", w
			else
				SetScale/I  x,ebinstart,ebinend,"eV", w
			endif
			AppendToGraph /W=$windowname w
		endif
		if(i==2)
			tmps="residual_0"
			duplicate w, $tmps
		endif
		if(i==dimsize(cols,1)-1)
			tmps="residual_0"
			WAVE residual = $tmps
			residual-=w
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

