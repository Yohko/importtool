// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.
#pragma version = 0.5

#pragma version=importloaderversion

#include <file name utilities>
#include <String Substitution>
#include <TranslateChars>
#include <strings as lists> 

constant false				= 0
constant true				= 1
strconstant loader_directory = "root:Packages:Import_Tool:flags:"
strconstant f_includeADC = "f_includeADC" //includeADC
strconstant f_divbyNscans = "f_divbyNscans" // CB_DivScans
strconstant f_divbytime = "f_divbytime" // CB_DivLifeTime
strconstant f_divbygain = "f_divbygain" // DivDetectorGain
strconstant f_interpolate = "f_interpolate" // Interpolieren
strconstant f_includeNDET = "f_includeNDET" // ChanneltronEinzeln
strconstant f_suffix = "f_suffix" // suffix
strconstant f_posEbin = "f_posEbin" //posbinde
strconstant f_includeNscans = "f_includeNscans" // singlescans
strconstant f_importtoroot = "f_importtoroot" // importtoroot
strconstant f_converttoWN = "f_converttoWN" // converttoWN
strconstant f_includeTF = "f_includeTF" // includetransmission
strconstant f_vsEkin = "f_vsEkin" // vskineticenergy
strconstant f_askforEXT = "f_askforEXT" //askforappenddet
strconstant f_onlyDET = "f_onlyDET" //justdetector
strconstant f_divbyTF = "f_divbyTF" // f_DivTF
strconstant f_askforE = "f_askforE" // f_askenergy

//importflags #################################################
function init_flags()
	NewDatafolder /O root:Packages
	NewDatafolder /O root:Packages:Import_Tool
	NewDatafolder /O root:Packages:Import_Tool:flags
	string mypath = "root:Packages:Import_Tool:flags"
	if(exists(mypath+":"+f_includeADC)!=2)
		variable /G  $(mypath+":"+f_includeADC) 			= 1			// Include ADC channels
	endif
	if(exists(mypath+":"+f_divbyNscans)!=2)
		variable /G  $(mypath+":"+f_divbyNscans) 		= 1			// Devide counts by #Scans
	endif
	if(exists(mypath+":"+f_divbytime)!=2)
		variable /G  $(mypath+":"+f_divbytime) 			= 1			// Devide counts by lifetime (dwelltime)
	endif
	if(exists(mypath+":"+f_divbygain)!=2)
		variable /G  $(mypath+":"+f_divbygain) 			= 1			// Devide counts of Detectors by Gain
	endif
	if(exists(mypath+":"+f_interpolate)!=2)
		variable /G  $(mypath+":"+f_interpolate) 			= 1			// 0 .. like in Origin 1 .. Schmei§er interpolation (omicron method)
	endif
	if(exists(mypath+":"+f_includeNDET)!=2)
		variable /G  $(mypath+":"+f_includeNDET) 		= 0			// Export each channel as a single wave --> DLD has up to 1000 channels!!! 
	endif
	if(exists(mypath+":"+f_suffix)!=2)
		string /G  $(mypath+":"+f_suffix) 					= "_new"	// Attach if the Region... already exists
	endif
	if(exists(mypath+":"+f_posEbin)!=2)
		variable /G  $(mypath+":"+f_posEbin) 				= 0 		// Positive (1) or negative (0) binding energy
	endif
	if(exists(mypath+":"+f_includeNscans)!=2)
		variable /G  $(mypath+":"+f_includeNscans) 		= 0			// Export each scan as a single spectrum
	endif
	if(exists(mypath+":"+f_importtoroot)!=2)
		variable /G  $(mypath+":"+f_importtoroot)		= 1			// Import into root (1) or into active directory (0)
	endif
	if(exists(mypath+":"+f_converttoWN)!=2)
		variable /G  $(mypath+":"+f_converttoWN)		= 1			// Convert eV to Wavenumber (cm-1)
	endif
	if(exists(mypath+":"+f_includeTF)!=2)
		variable /G  $(mypath+":"+f_includeTF) 			= 0			// Include transmission function of the detector
	endif
	if(exists(mypath+":"+f_vsEkin)!=2)
		variable /G  $(mypath+":"+f_vsEkin) 				= 0			// Plot against kinetic or binding energy
	endif
	if(exists(mypath+":"+f_askforEXT)!=2)
		variable /G  $(mypath+":"+f_askforEXT)	 		= 0			// Ask for a different name to be added to detector
	endif
	if(exists(mypath+":"+f_onlyDET)!=2)
		variable /G  $(mypath+":"+f_onlyDET)				= 0			// export just the detector (only for Dsets)
	endif
	if(exists(mypath+":"+f_divbyTF)!=2)
		variable /G  $(mypath+":"+f_divbyTF) 				= 0			// create a new wave and devide Detector by Transmission function
	endif
	if(exists(mypath+":"+f_askforE)!=2)
		variable /G  $(mypath+":"+f_askforE) 				= 0			// ask for the excitation energy
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
	if(str2num(get_flags(f_importtoroot))==1)
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
	if(str2num(get_flags(f_importtoroot))==1)
		SetDataFolder root:
	endif
	if(DataFolderExists(newexpname))
		Debugprintf2("Folder exists, adding suffix!",0)
		newexpname += get_flags(f_suffix)
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
	line = PadString(line, count, 0x20)
	fstatus file
	if(V_filepos+count<V_logeof)
		FBinread/B=3 file, line
	else
		line = ""
	endif
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
	return shortname(str, 20)
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
	variable i=0
	string tmps=""
	for(i=0;i<dimsize(matrix,1);i+=1)
		tmps=name+"_spk"+num2str(i)
		//Rename loaded wave to cleaned-up filename
		duplicate /R=[0,*][i] matrix, $tmps
		redimension /N=( dimsize(matrix,0)) $tmps // I dont want to have a (rows x 1) matrix
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
		fstatus file
	while (V_logEOF>V_filePOS)  

	do
		if(strsearch(line," ",0)==0)
			line=line[1,inf]
		else
			break
		endif
	while(strsearch(line," ",0)!=0)

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
	
	variable n_objects_NVAR = CountObjects(loader_directory,2)
	variable n_objects_SVAR = CountObjects(loader_directory,3)
	string cmp_type
	variable i=0
	for(i=0;i<n_objects_NVAR;i+=1)
		cmp_type = GetIndexedObjName(loader_directory,2,i)
		if(cmpstr(type, cmp_type,1) ==0)
			NVAR f_type_N =$(loader_directory+cmp_type)
			return num2str(f_type_N)
		endif
	endfor
	for(i=0;i<n_objects_SVAR;i+=1)
		cmp_type = GetIndexedObjName(loader_directory,3,i)
		if(cmpstr(type, cmp_type,1) ==0)
			SVAR f_type_S =$(loader_directory+cmp_type)
			return f_type_S
		endif
	endfor
	
	debugprintf2("Unknown Flag: "+type,2)
	return "-1"
end


function /S loader_addtowavename(sn, sna)
	string sn, sna
	string srn=""
	//PossiblyQuoteName(objname)
	if (strsearch(sn[strlen(sn)-1,strlen(sn)],"'",0) ==0)
		srn= sn[0,strlen(sn)-2]+sna+"'"
	else
		srn=sn+sna
	endif
	return srn
end
