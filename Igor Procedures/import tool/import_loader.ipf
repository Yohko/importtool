// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.
strconstant importloaderversion = "0.43.29"

#pragma version=importloaderversion

#include <file name utilities>
#include <String Substitution>
#include <TranslateChars>
#include <strings as lists> 

constant false				= 0
constant true				= 1


//importflags #################################################
function init_flags()
	NewDatafolder /O root:Packages
	NewDatafolder /O root:Packages:Import_Tool
	NewDatafolder /O root:Packages:Import_Tool:flags
	string mypath = "root:Packages:Import_Tool:flags"
	if(exists(mypath+":includeADC")!=2)
		variable /G  $(mypath+":includeADC") 				= 1			// Include ADC channels
	endif
	if(exists(mypath+":CB_DivScans")!=2)
		variable /G  $(mypath+":CB_DivScans") 			= 1			// Devide counts by #Scans
	endif
	if(exists(mypath+":CB_DivLifeTime")!=2)
		variable /G  $(mypath+":CB_DivLifeTime") 		= 1			// Devide counts by lifetime (dwelltime)
	endif
	if(exists(mypath+":DivDetectorGain")!=2)
		variable /G  $(mypath+":DivDetectorGain") 		= 1			// Devide counts of Detectors by Gain
	endif
	if(exists(mypath+":Interpolieren")!=2)
		variable /G  $(mypath+":Interpolieren") 			= 1			// 0 .. like in Origin 1 .. Schmei§er interpolation (omicron method)
	endif
	if(exists(mypath+":ChanneltronEinzeln")!=2)
		variable /G  $(mypath+":ChanneltronEinzeln") 		= 0			// Export each channel as a single wave --> DLD has up to 1000 channels!!! 
	endif
	if(exists(mypath+":suffix")!=2)
		string /G  $(mypath+":suffix") 						= "_new"	// Attach if the Region... already exists
	endif
	if(exists(mypath+":posbinde")!=2)
		variable /G  $(mypath+":posbinde") 				= 0 		// Positive (1) or negative (0) binding energy
	endif
	if(exists(mypath+":singlescans")!=2)
		variable /G  $(mypath+":singlescans") 				= 0			// Export each scan as a single spectrum
	endif
	if(exists(mypath+":importtoroot")!=2)
		variable /G  $(mypath+":importtoroot") 			= 1			// Import into root (1) or into active directory (0)
	endif
	if(exists(mypath+":converttoWN")!=2)
		variable /G  $(mypath+":converttoWN") 			= 1			// Convert eV to Wavenumber (cm-1)
	endif
	if(exists(mypath+":includetransmission")!=2)
		variable /G  $(mypath+":includetransmission") 	= 0			// Include transmission function of the detector
	endif
	if(exists(mypath+":vskineticenergy")!=2)
		variable /G  $(mypath+":vskineticenergy") 			= 0			// Plot against kinetic or binding energy
	endif
	if(exists(mypath+":askforappenddet")!=2)
		variable /G  $(mypath+":askforappenddet") 			= 0			// Ask for a different name to be added to detector
	endif
	if(exists(mypath+":justdetector")!=2)
		variable /G  $(mypath+":justdetector") 			= 0			// export just the detector (only for Dsets)
	endif
	if(exists(mypath+":f_DivTF")!=2)
		variable /G  $(mypath+":f_DivTF") 				= 0			// create a new wave and devide Detector by Transmission function
	endif
end
//ende importflags ##############################################

structure importloader
	string name 		//name of importer
	string filestr 		//file endings "*.xxx,*.xxx"
	variable file		// holds reference to file
	string dfSave		// holds reference to original folder
	variable success	
	string header		// for some file information
	variable isbinary	// binary file??
	string category		// AFM, PES, XRD, ...
	string version		// version
endstructure


structure importloaderopt
	string header
endstructure


function loaderstart(importloader,[optfile])
	struct importloader &importloader
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	init_flags()
	// workaround for a bug in OSX 10.9
	NewDatafolder /O root:Packages
	NewDatafolder /O root:Packages:Import_Tool
	string /G  root:Packages:Import_Tool:mypath
	SVAR mypath = root:Packages:Import_Tool:mypath
	newpath /O/Q myimportpath , mypath
	Debugprintf2("##########################",0)
	Debugprintf2("Start new "+importloader.name+" File Import",0)
	importloader.dfSave = GetDataFolder(1)
	if(str2num(get_flags("importtoroot"))==1)
		SetDataFolder root:
	endif
	fstatus optfile
	if(V_flag)
		importloader.file = optfile
	else	
		String fileFilters = importloader.name+" Files ("+importloader.filestr+"):"+ReplaceString("*",importloader.filestr,"")+";"
		fileFilters += "All Files:.*;"
		open/z=2/F=fileFilters/P=myimportpath/m="Looking for a "+importloader.name+" file"/r importloader.file
		if(V_flag==-1)
			Debugprintf2("No file given!",0)
			return -1
		endif
	endif
	//CleanupName
	string ExperimentName = ReplaceString(" ",getnameforwave(importloader.file),"")
	ExperimentName = ReplaceString(",",ExperimentName,"")
	ExperimentName = ReplaceString("(",ExperimentName,"")
	ExperimentName = ReplaceString(")",ExperimentName,"")
	ExperimentName = ReplaceString(".",ExperimentName,"")	
	ExperimentName = cleanname(ExperimentName)
	string newexpname = ExperimentName
	if(str2num(get_flags("importtoroot"))==1)
		SetDataFolder root:
	endif
	if(DataFolderExists(newexpname))
		Debugprintf2("Folder exists, adding suffix!",0)
		newexpname += get_flags("suffix")
		newexpname = UniqueName(newexpname, 11, 0)
	endif
	NewDataFolder/S $newexpname
	Debugprintf2(".. exporting to: "+GetDataFolder(1),0)

	fstatus importloader.file
	importloader.header = "Fileinfo: " + S_path + S_filename
	mypath=S_path // save the last filepath (workaround for a bug)
	return 0
end


function loaderend(importloader)
	struct importloader &importloader
	switch(importloader.success)
		case 0:
			break
		case 1:
			close importloader.file
			break
		default:
			close importloader.file
			break
	endswitch
	setdatafolder $(importloader.dfSave)
	Debugprintf2("Finished "+importloader.name+" File Import",0)
	Debugprintf2("##########################",0)
end


function /S getnameforwave(file)
	variable file
	fstatus file
	string nameforwave = S_filename
	if (strsearch(nameforwave,".",inf,1)>1)//remove filename extension
		nameforwave=nameforwave[0,strsearch(nameforwave,".",inf,1)-1]
	endif
	nameforwave =  cleanupname(nameforwave,1) //0 to use strict name rules or 1 to use liberal name rules
	if (strlen(nameforwave) >= 24)
		do 
			Prompt nameforwave, "Enter new wave Name: "
			DoPrompt "Wave name to long (<=24) (no ,.()", nameforwave
		while (strlen(nameforwave) >= 24)
	endif
	return nameforwave
end


//make a string into a list separated by trennzeichen
function /S splitintolist(buffer, trennzeichen)
	string buffer,trennzeichen
	string buffer2 = ""
	variable i
	For (i=0;i<ItemsInList(buffer,trennzeichen);i+=1)
		if (strlen(StringFromList(i,buffer,trennzeichen)) !=0)
			buffer2 = buffer2+"_"+StringFromList(i,buffer,trennzeichen)
		endif
	endfor
	return 	buffer2[1,strlen(buffer2)]
end


Function Debugprintf2(out,deb)
		String out
		variable deb
		if (deb == 1)
		// comment in for debugging
		//	print out
		elseif(deb == 0)
			print out
		elseif(deb==2)
			print out
			DoAlert 0, out
		endif
end


function /S mybinread(file, count)
	variable file
	variable count
	variable i
	string line = ""
	for (i=0;i<count;i+=1)
		line+="1"
	endfor
	FBinread/B=3 file, line
	return line
end


Function /S mycleanupstr(name)
	string name
	if(cmpstr(name[strlen(name)-1],"\r") == 0)
		name = name[0,strlen(name)-2]
	endif
	return name
end


// check to see if we have aquidistante energy scale
Function checkEnergyScale(w, eps)
		Wave w
		variable eps
		variable j=0
		for( j = 1 ; j < dimsize(w,0); j+=1 )
			if( abs( w[1] - w[0] - ( w[j] - w[j-1]) )  >= eps) 
				return 0
			endif
		endfor
		return 1
end


Function /S cleanname(str)
	string str
	str = cleanupname(str,0)
	str= ReplaceString("_",str,"")
	str= ReplaceString(" ",str,"")
	variable maxlen = 20
	
#if 0	
	if (strlen(str) >= max)
		do 
			Prompt str, "Enter new Name: "
			DoPrompt "Experimentname to long (<="+num2str(max)+") (no ,.():_", str
			str=ReplaceString(" ",str,"")
			str=ReplaceString("_",str,"")
			str=ReplaceString(",",str,"")
			str=ReplaceString(".",str,"")
			str=ReplaceString("(",str,"")
			str=ReplaceString(")",str,"")
			str=ReplaceString(":",str,"")
		while (strlen(str) >= max)
	endif
#endif
	return shortname(str, maxlen)
end



Function/S stripstrfirstlastspaces(str)
		string str
		variable i=0,j=0, length=strlen(str)
		for(i=0;i<length;i+=1)
			if(strsearch(str[i]," ",0)==-1)
				break
			endif
		endfor
		str=str[i,inf]
		length=strlen(str)
		for(i=0;i<length;i+=1)
			if(strsearch(str[i],"	",0)==-1)
				break
			endif
		endfor
		str=str[i,inf]
		length=strlen(str)
		for(i=length-1;i>0;i-=1)
			if(strsearch(str[i]," ",0)==-1)
				break
			endif
		endfor
		str=str[0,i]
		length=strlen(str)
		for(i=length-1;i>0;i-=1)
			if(strsearch(str[i],"	",0)==-1)
				break
			endif
		endfor
		str=str[0,i]
		return str		
end


function splitmatrix(matrix,name)
	wave matrix
	string name
	variable rows = dimsize(matrix,0)
	variable cols = dimsize(matrix,1)
	variable i=0, j=0
	string tmps=""
	for(i=0;i<cols;i+=1)
		tmps=name+"_spk"+num2str(i)
		//Rename loaded wave to cleaned-up filename
		duplicate matrix, $tmps
		WAVE w = $tmps
		redimension /N=(rows) w
		for(j=0;j<rows;j+=1)
			w[j]=matrix[j][i]		
		endfor	
	endfor
	KillWaves/Z matrix	
end


function /S mybinreadBE(file, count)
	variable file
	variable count
	variable i
	string line = ""
	for (i=0;i<count;i+=1)
		line+="1"
	endfor
	FBinread/B=2 file, line
	return line
end


function /S shortname(name, len)
	string name
	variable len
	if(strlen(name) > len)
		Debugprintf2("Name too long. Shortened.",1)
		Debugprintf2("Before: "+name,1)
		name = name[0,len-2]
		Debugprintf2("After: "+name,1)
	endif
	return name
end


function /S read_line_trim(file)
	variable file
	string line
	FReadLine file, line
	if(strlen(line) == 0)
		Debugprintf2("Unexpected end of file.",1)
		return "-1"
	endif
	line = mycleanupstr(line)
	return line
end


function read_line_int(file)
	variable file
	return str2num(read_line_trim(file))
end


function read_dbl_le(file)
	variable file
	variable val
	Fbinread/B=3/f=5 file, val
	return val
end


function read_int16_le(file)
	variable file
	variable val
	Fbinread/B=3/f=2 file, val
	return val
end

function read_int32_le(file)
	variable file
	variable val
	Fbinread/B=3/f=3 file, val
	return val
end


function read_flt_le(file)
	variable file
	variable val
	Fbinread/B=3/f=4 file, val
	return val
end

	
function read_uint32_le(file)
	variable file
	variable val
	Fbinread/B=3/U/f=3 file, val
	return val
end


function read_uint16_le(file)
	variable file
	variable val
	Fbinread/B=3/U/f=2 file, val
	return val
end


Function/S TimeColon(timestr) //format HHMMSS (161959)
	string timestr
	string hh, mm, ss
	hh=timestr[0,1]
	mm=timestr[2,3]
	ss=timestr[4,5]
	return hh+":"+mm+":"+ss
End


Function/S StripDoubleQuotes(str)
	String str					// A string starting and ending with double quotes
	if (CmpStr(str[0], "\"") != 0)
		return str				// String did not start with double quotes
	endif
	
	Variable len  = strlen(str)
	str = str[1,len-2]
	return str
End


function /S myreadline(file)
	variable file
	string str
	FReadLine file, str
	if(strlen(str) == 0) // hit EOF
		close file
		return "-1"
	endif
	return mycleanupstr(str)
end


function skip_lines(file, count)
	variable file, count
	string tmps
	variable i=0
	for (i = 0; i < count; i+=1) 
		FReadLine file, tmps
		if(strlen(tmps) == 0)
			Debugprintf2("Unexpected end of file.",0)
			return -1
		endif
	endfor
	return 0
end


function getkeyval(file, key, val)
	variable file
	string &key
	string &val
	string tmps
	FReadLine file, tmps
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



// get a trimmed line that is not empty and not a comment
function /S get_valid_line(file, comment_char)
	variable file
	string comment_char
	string line = "",tmps=""
	do
		FReadLine file, line
		if(strlen(line) == 0)
			return "-1"
		endif
		line = mycleanupstr(line)
		tmps=line
		tmps=ReplaceString(" ",tmps,"")
		if((strlen(tmps)!=0) && (strsearch(tmps,comment_char,0)!=0))
			break
		endif
	while (1)
	
	do
		if(strsearch(line," ",0)==0)
			line=line[1,inf]
		else
			break
		endif
	while(1)
	
	if (strsearch(line,comment_char,0)!=-1)
		line = line[0,strsearch(line,comment_char,0)-1]    	
	endif   
    return line
end

Structure fourbytes
 	char bytes[4]
endstructure

Structure myflt
	float val
endstructure


// function that converts single precision 32-bit floating point in DEC PDP-11
// format to double
// good description of the format is at:
// http://home.kpn.nl/jhm.bonten/computers/bitsandbytes/wordsizes/hidbit.htm
//
// TODO: consider this comment from S.M.:
// PDP-11 F floating point numbers can be converted very easily (and
// efficently) into standard IEEE 754 format: Swap the higher an lower
// 16-bit words, cast to float and divide by 4.
function from_pdp11(pvar)//(const unsigned char* p) // funcktioniert
	string pvar

	struct fourbytes value
	struct fourbytes value2
	struct myflt fltval
	variable retval	
	//from pvar to value
	StructGet/S/B=3 value, pvar

	// (1) Swap the higher an lower 16bit words
	value2.bytes[0]=value.bytes[2]
	value2.bytes[1]=value.bytes[3]
	value2.bytes[2]=value.bytes[0]
	value2.bytes[3]=value.bytes[1]

	// (2) from value2 to retval (cast to float)
	StructPut/S/B=3 value2, pvar
	StructGet/S/B=3 fltval, pvar
	retval = fltval.val

	// (3) devide by 4
	retval = retval /4
	return retval

#if 0
	variable signn = (str2num(pvar[1]) & 0x80) == 0 ? 1 : -1
	debugprintf2("Sign: "+num2str(signn),0)
	//variable exb = ((str2num(pvar[1]) & 0x7F) << 1) + ((str2num(pvar[0]) & 0x80) >> 7)
	variable exb = shiftleft((str2num(pvar[1]) & 0x7F),1) + shiftright((str2num(pvar[0]) & 0x80),7)
	debugprintf2("exb: "+num2str(exb),0)

	if (exb == 0)
		if (signn == -1)
			// DEC calls it Undefined
			return NaN//numeric_limits<double>::quiet_NaN();
		else
			// either clean-zero or dirty-zero
			return 0
		endif
	endif
	variable h = str2num(pvar[2]) / 256. / 256. / 256. + str2num(pvar[3]) / 256. / 256. + (128 + (str2num(pvar[0]) & 0x7F)) / 256.
	return signn*h*2^(exb-128)
//	#if 0
//		return ldexp(sign*h, exb-128);
//	#else
//    		return sign * h * pow(2., exb-128);
//	#endif

#endif
end


function /S get_flags(type)
	string type
	
	NVAR myincludeADC = root:Packages:Import_Tool:flags:includeADC
	NVAR myCB_DivScans = root:Packages:Import_Tool:flags:CB_DivScans
	NVAR myCB_DivLifetime = root:Packages:Import_Tool:flags:CB_DivLifeTime
	NVAR myDivDetectorGain = root:Packages:Import_Tool:flags:DivDetectorGain
	NVAR myInterpolieren = root:Packages:Import_Tool:flags:Interpolieren
	NVAR myChanneltronEinzeln = root:Packages:Import_Tool:flags:ChanneltronEinzeln
	SVAR mysuffix = root:Packages:Import_Tool:flags:suffix
	NVAR myposbinde = root:Packages:Import_Tool:flags:posbinde
	NVAR mysinglescans = root:Packages:Import_Tool:flags:singlescans
	NVAR myimporttoroot = root:Packages:Import_Tool:flags:importtoroot
	NVAR myconverttoWN = root:Packages:Import_Tool:flags:converttoWN
	NVAR myincludetransmission = root:Packages:Import_Tool:flags:includetransmission
	NVAR myvskineticenergy = root:Packages:Import_Tool:flags:vskineticenergy
	NVAR myaskforappenddet = root:Packages:Import_Tool:flags:askforappenddet
	NVAR myjustdetector = root:Packages:Import_Tool:flags:justdetector
	NVAR f_DivTF = root:Packages:Import_Tool:flags:f_DivTF
	
	strswitch(type)
		case "includeADC":
			return num2str(myincludeADC)
			break
		case "CB_DivScans":
			return num2str(myCB_DivScans)
			break
		case "CB_DivLifeTime":
			return num2str(myCB_DivLifeTime)
			break
		case "DivDetectorGain":
			return num2str(myDivDetectorGain)
			break
		case "Interpolieren":
			return num2str(myInterpolieren)
			break
		case "ChanneltronEinzeln":
			return num2str(myChanneltronEinzeln)
			break
		case "suffix":
			return mysuffix
			break
		case "posbinde":
			return num2str(myposbinde)
			break
		case "singlescans":
			return num2str(mysinglescans)
			break
		case "importtoroot":
			return num2str(myimporttoroot)
			break
		case "converttoWN":
			return num2str(myconverttoWN)
			break
		case "includetransmission":
			return num2str(myincludetransmission)
			break
		case "vskineticenergy":
			return num2str(myvskineticenergy)
			break
		case "askforappenddet":
			return num2str(myaskforappenddet)
			break
		case "justdetector":
			return num2str(myjustdetector)
			break
		case "f_DivTF":
			return num2str(f_DivTF)
			break
		default:
			debugprintf2("Unknown Flag: "+type,1)
			return "-1"
			break
	endswitch
	
	return "-1"
end