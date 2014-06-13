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
	constant includeADC 			= 1			// Include ADC channels
	constant CB_DivScans 			= 1			// Devide counts by #Scans
	constant CB_DivLifeTime 		= 1			// Devide counts by lifetime (dwelltime)
	constant DivDetectorGain   		= 1			// Devide counts of Detectors by Gain
	constant Interpolieren 			= 1			// 0 .. like in Origin 1 .. Schmei§er interpolation (omicron method)
	constant ChanneltronEinzeln 	= 0			// Export each channel as a single wave --> DLD has up to 1000 channels!!! 
	strconstant suffix 				= "_new"	// Attach if the Region... already exists
	constant posbinde 				= 0 		// Positive (1) or negative (0) binding energy
	constant singlescans				= 0			// Export each scan as a single spectrum
	constant importtoroot			= 1			// Import into root (1) or into active directory (0)
	constant converttoWN			= 1			// Convert eV to Wavenumber (cm-1)
	constant includetransmission	= 0			// Include transmission function of the detector
	constant vskineticenergy		= 0			// Plot against kinetic or binding energy
	constant askforappenddet		= 0			// Ask for a different name to be added to detector
	constant justdetector			= 1			// export just the detector (only for Dsets)
	
//ende importflags ##############################################

function /S loaderstart(name, filestr,file,dfSave)
	string name //name of importer
	string filestr //file endings "*.xxx,*.xxx"
	variable &file
	String &dfSave
	
	// workaround for a bug in OSX 10.9
	NewDatafolder /O root:Packages
	NewDatafolder /O root:Packages:Import_Tool
	string /G  root:Packages:Import_Tool:mypath
	SVAR mypath = root:Packages:Import_Tool:mypath
	newpath /O/Q myimportpath , mypath
	Debugprintf2("##########################",0)
	Debugprintf2("Start new "+name+" File Import",0)
	dfSave = GetDataFolder(1)
	if(importtoroot==1)
		SetDataFolder root:
	endif
	variable  i=0
	String fileFilters = name+" Files ("+filestr+"):"+ReplaceString("*",filestr,"")+";"
	fileFilters += "All Files:.*;"
	open/z=2/F=fileFilters/P=myimportpath/m="Looking for a "+name+" file"/r file
	if(V_flag==-1)
		Debugprintf2("No file given, aborting",0)
		return ""
	endif

	//CleanupName
	string ExperimentName = ReplaceString(" ",getnameforwave(file),"")
	ExperimentName = ReplaceString(",",ExperimentName,"")
	ExperimentName = ReplaceString("(",ExperimentName,"")
	ExperimentName = ReplaceString(")",ExperimentName,"")
	ExperimentName = ReplaceString(".",ExperimentName,"")	
	ExperimentName = cleanname(ExperimentName)
	string newexpname =""
	if(importtoroot==1)
		newexpname = "root:"+ExperimentName
	else
		newexpname = dfSave+ExperimentName
	endif
	Debugprintf2(".. exporting to: "+newexpname,0)
	if(DataFolderExists(newexpname))
		Debugprintf2("Folder exists, adding suffix!",0)
		ExperimentName += suffix
		i=0
		do
			i+=1
			if(importtoroot==1)
				newexpname = "root:"+Experimentname + num2str(i)
			else
				newexpname = dfSave+Experimentname + num2str(i)
			endif
		while(DataFolderExists(newexpname))
		Experimentname +=num2str(i)
	endif
	if(importtoroot==1)
		NewDataFolder/s root:$(ExperimentName)
		SetDataFolder root:$(ExperimentName)
	else
		NewDataFolder/s $(dfSave+ExperimentName)
		SetDataFolder $(dfSave+ExperimentName)
	endif
	fstatus file
	string header = "Fileinfo: " + S_path + S_filename
	mypath=S_path // save the last filepath (workaround for a bug)
	return header
end


function loaderend(name,success,file, dfSave)
	variable file
	string name
	variable success 
	String dfSave
	if(success==1)
		close file
	endif
	if(importtoroot==1)
	 	setdatafolder $(dfSave)
	endif
	Debugprintf2("Finished "+name+" File Import",0)
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
	str= stripstr(str,"_","")
	str= stripstr(str," ","")
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
	
	if(strlen(str) >= maxlen)
		print "Name too long. Shortened."
		print "Before: "+str
		str = str[0,maxlen-2]
		print "After: "+str
	endif
	return str
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
		print "Name too long. Shortened."
		print "Before: "+name
		name = name[0,len-2]
		print "After: "+name
	endif
	return name
end


Function/S stripstr(str, zeicheni,zeicheno)
		string str, zeicheni,zeicheno
		string stro=""
		variable i=0,j=0, length=strlen(str)
		For (i=0;i<ItemsInList(str,zeicheni);i+=1)
			if (strlen(StringFromList(i,str,zeicheni)) !=0)
				stro = stro+zeicheno+StringFromList(i,str,zeicheni)
			endif
		endfor
		if (strlen(zeicheno) != 0)
			stro=stro[1,strlen(stro)]
		endif
		return stro
end


function /S read_line_trim(file)
	variable file
	string line
	FReadLine file, line
	if(strlen(line) == 0)
		Debugprintf2("Unexpected end of file.",0)
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
		tmps=stripstr(tmps," ","")
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

static Structure myflt
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
