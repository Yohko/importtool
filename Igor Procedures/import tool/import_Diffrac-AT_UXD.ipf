// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

// The Diffrac-AT UXD procedure is based on xylib by Marcin Wojdyr:
// https://github.com/wojdyr/xylib (https://github.com/wojdyr/xylib/blob/master/xylib/uxd.cpp)


Menu "Macros"
	submenu "Import Tool "+importloaderversion
			submenu "XRD"
				"Load Siemens-Bruker Diffrac-AT	*.uxd	file... b1", Uxd_load_data()
			end
	end
end

// ###################### Diffrac-AT UXD ########################
// Siemens/Bruker Diffrac-AT UXD text format (for powder diffraction data)

// A header (with file-scope parameters) is followed by block sections.
// Each section consists of:
// _DRIVE=...
// parameters - key-value pairs
// _COUNT keyword
// list of intensities
// comments start with semicolon ';'
// 
// Format example:
// 
// ; File header with some file-scope prarmeters.
// _FILEVERSION=1
// _SAMPLE='test'
// _WL1=1.540600
// ...
// ; Data for Block 1
// _DRIVE='COUPLED'
// _STEPTIME=37.000000
// _STEPSIZE=0.020000 # x_step
// _STEPMODE='C'
// _START=10.0000 # x_start
// ...
// ; Block 1 data starts
// _COUNTS
// 1048 1162 1108 1163 1071 1057 1055 973
// 1000 1031 1068 1015 983 1028 1030 1019
// ...
// ; Repeat if there are more blocks/ranges
// 
// Later versions of this format are more complicated.
// In particular, two column data, e.g. angle and counts, are supported.


static function Uxd_check(file)
	variable file
	string line
	do
		line = read_line_trim(file)
		line =stripstr(line," ","")
		line =stripstr(line,"\t","")
		line =stripstr(line,"\r","")
		line =stripstr(line,"\n","")
		
		if(strsearch(line,"_FILEVERSION",0)!=0)
			break
		endif
		fstatus file
	while(V_logEOF>V_filePOS)
    if(strsearch(line,"_FILEVERSION",0)==0)
		return 1
	endif
    return 0
end


// get all numbers in the first legal line
// sep is _optional_ separator that can be used in addition to white space
static function Uxd_add_values_from_str(str, sep, ycol,xcol, ncols)
	string str
	string sep
	wave ycol
	wave xcol
	variable ncols
	if(strsearch(str,sep,0)!=-1)
		str = stripstr(str, " ","")
	else
		if(strsearch(str,"\t",0)==-1)
			str=splitintolist(str, " ")//only whitespaces as sep
			sep = "_"
		else
			str=splitintolist(str, "\t")//only whitespaces as sep
			sep = "_"
		endif
	endif
	variable n = 0
	variable i = 0
	variable val
	variable size = dimsize(ycol,0)
	if (ncols!=1)
		Redimension/N=(size+1) ycol
		Redimension/N=(size+1) xcol
	else
		Redimension/N=(size+1) ycol
	endif 
	
	for (i=0;i<itemsinlist(str,sep);i+=1)
		if (n == ncols)
			n = 0
			size+=1
			if (ncols!=1)
				Redimension/N=(size+1) ycol
				Redimension/N=(size+1) xcol
			else
				Redimension/N=(size+1) ycol
			endif 
		endif

		if (strlen(StringFromList(i,str,sep))==0)
			Debugprintf2("Number not found in line:\n" + str,0)
			return -1
		endif
		val = str2num(StringFromList(i,str,sep))
		if (numtype(val) != 0)
			Debugprintf2("Numeric overflow or underflow in line:\n"+ str,0)
			return -1
		endif
		
		if (ncols!=1)
			if (n==0)
				ycol[size]=val
			else
				xcol[size]=val
			endif
		else
			ycol[size]=val
		endif 
		n+=1
	endfor
	return 1
end


function Uxd_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "Siemens/Bruker Diffrac-AT UXD"
	importloader.filestr = "*.uxd"
end


function Uxd_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	Uxd_load_data_info(importloader)
	 if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string comments0 = importloader.header+"\r"
	variable file = importloader.file
	
	variable ncols = 0
	string line
	variable start=0.0, step=0.0
	variable peak_list = 0 // xylib has false
	variable founddrive = 0
	variable groupcount = 0
	string tmps=""
	string key, val
	string comments = ""
	do
		line = get_valid_line(file, ";") 
    		if (cmpstr(line,"-1")==0)
    			break
    		endif
		if(strsearch(line,";",0)!=-1)
			print "Bug found comment"
		endif
    		
		if (strsearch(line, "_DRIVE",0	)==0) // block starts
			founddrive = 1
			comments = comments0
		elseif ((strsearch(line, "_COUNT",0)==0) || (strsearch(line, "_CPS",0)==0))
			if(founddrive!=1)
				Debugprintf2( "missing _DRIVE",0)
				close file
				return -1
			endif
			ncols = 1
			groupcount +=1
			tmps = "Group"+num2str(groupcount)
			
			Make /O/R/N=(0,1)  $tmps /wave=ycols
			SetScale/P  x,start,step,"", ycols
			note ycols, comments
			Debugprintf2("Created wave with 1 col!",1)
			ncols = 1
			peak_list = 0
			founddrive = 0
		elseif ((strsearch(line, "_2THETACOUNTS",0)==0) || (strsearch(line, "_2THETACPS",0)==0) || (strsearch(line, "_2THETACOUNTSTIME",0)==0)) // data starts
			if(founddrive!=1)
				Debugprintf2( "missing _DRIVE",0)
				close file
				return -1
			endif
			groupcount +=1
			tmps = "Group"+num2str(groupcount)+"y"
			Make /O/R/N=(0,2)  $tmps /wave=ycols
			tmps = "Group"+num2str(groupcount)+"x"
			Make /O/R/N=(0,2)  $tmps /wave=xcols
			//SetScale/P  x,start,step,"", ycols 
			note ycols, comments
			Debugprintf2("Created wave with 2 cols!",1)
			ncols = 2
			peak_list = 0
			founddrive = 0
		// these keywords specify peak list, which we are not interested in
		elseif ((strsearch(line, "_D-I",0) ==0) || (strsearch(line, "_2THETA-I",0)==0))
			peak_list = 1
		elseif (strsearch(line, "_",0)==0) // meta-data
			// other meta key-value pair.
			// NOTE the order, it must follow other "_XXX" branches
			line =line[1,inf]
			key=stringfromlist(0,line,"=")
			val=stringfromlist(1,line,"=")

			if (cmpstr(key,"START")==0)
				start = str2num(val)
			elseif (cmpstr(key,"STEPSIZE")==0)
				step = str2num(val)
			else 
				if(founddrive!=1)
					comments0 += key + ": "+val +"\r"
				else
					comments += key + ": "+val +"\r"
				endif
			endif

		elseif (peak_list !=1 && WaveExists(ycols)!=0 ) //data
			Uxd_add_values_from_str(line, ",", ycols,xcols, ncols)
		endif
		fstatus file
	while(V_logEOF>V_filePOS)

	importloader.success = 1
	loaderend(importloader)
end

// ###################### Diffrac-AT UXD END ######################
