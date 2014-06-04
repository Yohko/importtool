// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

// The Rigaku procedure is based on xylib by Marcin Wojdyr:
// https://github.com/wojdyr/xylib (https://github.com/wojdyr/xylib/blob/master/xylib/rigaku_dat.cpp)

Menu "Macros"
	submenu "Import Tool "+importloaderversion
			submenu "XRD"
				"Load Rigaku						*.dat	file... b1", Rigaku_load_data()
			end
	end
end


// ###################### Rigaku ########################
// Rigaku .dat format - powder diffraction data from Rigaku diffractometers
// http://sdpd.univ-lemans.fr/course/week-1/sdpd-1.html

// The format has a file header indicating some file-scope parameters.
// It may contain multiple blocks/ranges/groups of data, and each block has its
// own group header. Each group header contains some parameters ("*START", "*STOP"
// and "*STEP" included).The data body of one group begins after "*COUNT=XXX").
// 
///////////////////////////////////////////////////////////////////////////////
// * Sample Fragment: ("#xxx": comments added by me; ...: omitted lines)
// 
// # file header
// *TYPE = Raw
// *CLASS = Standard measurement
// ...
// *GROUP_COUNT = 2
// ...
// # group 0 header
// *BEGIN
// *GROUP = 0
// ...
// *START = 10.0000
// *STOP = 103.1200
// *STEP = 0.0200
// ...
// *COUNT = 4657
// # data in group 0
// 1048, 1162, 1108, 1163
// 1071, 1057, 1055, 973
// # group 0 end
// *END
// # repeat group segment if extra group(s) exist
// ...
// # end of file
// *EOF
///////////////////////////////////////////////////////////////////////////////


// return true if is this type, false otherwise
static function Rigaku_check(file)
	variable file
	string head 
	FReadLine /N=5 file, head
	if(cmpstr(head,"*TYPE")==0)
		return 1
	endif
	return 0
end


function Rigaku_load_data()
	string dfSave=""
	variable file
	string impname="Rigaku"
	string filestr="*.dat"
	string header0 = loaderstart(impname, filestr,file,dfSave)
		if (strlen(header0)==0)
		return -1
	endif

	header0+="\r"

	variable i=0
	string header = ""

	variable grp_cnt = 0
	variable start = 0.0, step = 0.0
	variable count = 0
	string line = "", linecheck=""
	
	variable foundbegin = 0
	variable ycolcount = 0
	variable groupcount = 0
	string tmps=""
	variable run = 1
	do
		do // all lines which start with # a comments and are not usefull
			FReadLine file, line
			if(strlen(line) == 0)
				run = 0
				break
			endif
			line=cleanup_(line)
			linecheck = stripstr(line," ","")
			if ((strsearch(linecheck,"#",0)!=0) && (strlen(linecheck) !=0))
				break
			endif
			fstatus file
		while (V_logEOF>V_filePOS)
		if(run==0)
			break
		endif
	
		if (strsearch(line,"*",0)==0)
			if (strsearch(line,"*BEGIN",0)==0) // block starts
				Debugprintf2("Block starts",0)
				groupcount +=1
				tmps = "Group"+num2str(groupcount)
				Make /O/R/N=(0)  $tmps /wave=ycols
				ycolcount = 0
				note ycols, header
				foundbegin = 1
			elseif (strsearch(line,"*END",0)==0) // block ends
				Debugprintf2("Block ends",0)
				if(foundbegin == 0)
					Debugprintf2("*END without *BEGIN",0)
					close file
					return -1
				endif
				if(count != ycolcount)
					Debugprintf2("count of x and y differ",0)
					close file
					return -1
				endif
				foundbegin = 0
				note ycols, header0+header
				header = ""
				SetScale/P  x,start,step,"", ycols
			elseif (strsearch(line,"*EOF",0)==0) // file ends
				Debugprintf2("Reached EOF",0)
				run=0
				break
			else // meta key-value pair
			
				string key, val
				line = line[1,inf]
				key=stripstr(line[0,strsearch(line,"=",0)-1]," ","")
				val=line[strsearch(line,"=",0)+1,inf]

				Debugprintf2(key+": "+val,1)
				strswitch(key)
					case "START":
						 start = str2num(val)
					break
					case "STEP":
						step = str2num(val)
					break
					case "COUNT":
						count = str2num(val)
					break
					case "GROUP_COUNT":
						grp_cnt = str2num(val)
					break
				endswitch
				if(foundbegin==1)
					header+= key+": " + val+"\r"
					//Note ycols,key+": " + val
				else
					header0+= key+": " + val+"\r"
				endif
			endif	
				
		else // should be a line of values
			
			if(foundbegin == 0)
				Debugprintf2("values without *BEGIN",0)
			endif
			for(i=0;i<itemsinlist(line,",");i+=1)
				if(numtype(str2num(StringFromList(i,line,","))) != 0)
					Debugprintf2("Numeric value expected",0)
					close file
					return -1
				endif
				ycolcount += 1
				Redimension/N=(ycolcount) ycols
				ycols[ycolcount-1] = str2num(StringFromList(i,line,","))
			endfor
		endif
		
		Fstatus file
	while (run == 1 && V_logEOF>V_filePOS)
	if(grp_cnt == 0)
		Debugprintf2("no GROUP_COUNT attribute given",0)
	endif
	if(grp_cnt != groupcount)
		Debugprintf2("block count different from expected",0)
	endif
                  
	loaderend(impname,1,file, dfSave)
end

// ###################### Rigaku END ######################
