// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.


Menu "Macros"
	submenu "Import Tool "+importloaderversion
			"Multi file loader v0.1", multiLoader_MakePanel()
	end
end


// -------- function prototypes; start
function multiLoader_protoload_data_info(importloader)
	struct importloader &importloader
	return 0
end


function multiLoader_protoload_data([optfile])
	variable optfile
	return 0
end


function multiLoader_proto_check_file(file)
	variable file
	return 0
end
// -------- function prototypes; end


function /S multiLoader_select_files(fileFilters)
	string fileFilters
	NewDatafolder /O root:Packages
	NewDatafolder /O root:Packages:Import_Tool
	string /G  root:Packages:Import_Tool:mypath
	SVAR mypath = root:Packages:Import_Tool:mypath
	newpath /O/Q myimportpath , mypath
	//open/z=2/F=fileFilters/P=myimportpath/m="Looking for a "+importloader.name+" file"/r importloader.file
	Open /D /R /MULT=1 /F=fileFilters/P=myimportpath/M="Select one or more files" file
	String outputPaths = S_fileName
	if(strlen(outputPaths) == 0)
		Debugprintf2("No file given!",0)
		return "-1"
	else
		mypath = stringfromlist(0, outputPaths,"\r")
		if(defined(MACINTOSH))
			mypath = mypath[0,strsearch(mypath,":",inf,1)]
			
		elseif(defined(WINDOWS))
			mypath = mypath[0,strsearch(mypath,"\\",inf,1)]
		endif
	endif
	return outputPaths
end

function multiLoader_autoloader()

	string fileFilters = "All Files:.*;"
	string outputPaths = multiLoader_select_files(fileFilters)
	if(cmpstr(outputPaths,"-1")==0)
		return -1
	endif

	variable file, i=0
	Variable numFilesSelected = ItemsInList(outputPaths, "\r")
	for(i=0; i<numFilesSelected; i+=1)
		String path = StringFromList(i, outputPaths, "\r")
		Printf " .. loading file (%d/%d): %s\r", (i+1),numFilesSelected, path	
		open /R file as StringFromList(i, outputPaths, "\r")

		string tmps = multiLoader_guess_filetype(file)
		if(cmpstr(tmps,"-1")!=0)
			FUNCREF multiLoader_protoload_data f_load = $(tmps+"_load_data")
			f_load(optfile=file)
		else
			Debugprintf2("no file",1)
		endif
	endfor
	return 0
end


function multiLoader_loader(funcname)
	string funcname
	if(strlen(stringfromlist(0,funcname,";"))==0 || strlen(stringfromlist(1,funcname,";"))==0)
		return -1
	endif

	struct importloader importloader
	FUNCREF multiLoader_protoload_data_info f = $(stringfromlist(1,funcname,";"))
	importloader.category = "misc"
	f(importloader)
	
	String fileFilters = importloader.name+" Files ("+importloader.filestr+"):"+ReplaceString("*",importloader.filestr,"")+";"
	fileFilters += "All Files:.*;"

	String outputPaths = multiLoader_select_files(fileFilters)
	if(cmpstr(outputPaths,"-1")==0)
		return -1
	endif

	variable file, i=0
	Variable numFilesSelected = ItemsInList(outputPaths, "\r")
	for(i=0; i<numFilesSelected; i+=1)
		String path = StringFromList(i, outputPaths, "\r")
		Printf " .. loading file (%d/%d): %s\r", (i+1),numFilesSelected, path	
		open /R file as StringFromList(i, outputPaths, "\r")
		FUNCREF multiLoader_protoload_data ff = $(stringfromlist(0,funcname,";"))
		ff(optfile=file)
	endfor
end


function /S multiLoader_listfuncofcateg()
	ControlInfo popup_category;	string selectedcategory = S_Value
	string funcinfolist =  FunctionList("*_load_data_info",";","KIND:2")
	string funclist= FunctionList("*_load_data",";","KIND:2")
	string returnlist = ""
	variable i =0
	struct importloader importloader
	for(i=0;i<itemsinlist(funcinfolist,";");i+=1)
		if(exists(stringfromlist(i,funcinfolist,";"))==6)
			FUNCREF multiLoader_protoload_data_info f = $(stringfromlist(i,funcinfolist,";"))
			importloader.category = "misc"
			f(importloader)
			if(strsearch(selectedcategory,importloader.category,0)!=-1)
				returnlist += importloader.name+";"//ReplaceString("_load_data",stringfromlist(i,funclist,";"),"")+";"
			endif
		endif
	endfor
	return returnlist
end


function /S multiLoader_getcategories()
	string funcinfolist =  FunctionList("*_load_data_info",";","KIND:2")
	variable i =0
	string categorylist = ""
	struct importloader importloader
	for(i=0;i<itemsinlist(funcinfolist,";");i+=1)
		if(exists(stringfromlist(i,funcinfolist,";"))==6)
			FUNCREF multiLoader_protoload_data_info f = $(stringfromlist(i,funcinfolist,";"))
			importloader.category = "misc"
			f(importloader)
			if(FindListItem(importloader.category,categorylist,";")==-1)
				categorylist +=importloader.category+";"
			endif
		endif
	endfor
	return categorylist
end


function multiLoader_autoloadbutton(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			multiLoader_autoloader()
			break
	endswitch
	return 0
end


function multiLoader_loadbutton(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			ControlInfo popup_loader//; print S_Value
			string funclist = FunctionList("*_load_data",";","KIND:2")
			string funclistinfo = FunctionList("*_load_data_info",";","KIND:2")
			struct importloader importloader
			variable i = 0
			for(i=0;i<itemsinlist(funclistinfo,";");i+=1)
				if(exists(stringfromlist(i,funclistinfo,";"))==6)
					FUNCREF multiLoader_protoload_data_info f = $(stringfromlist(i,funclistinfo,";"))
					importloader.category = "misc"
					f(importloader)
					if(strsearch(importloader.name, S_Value,0)!=-1)
						multiLoader_loader(stringfromlist(i,funclist,";")+";"+stringfromlist(i,funclistinfo,";"))
						//FUNCREF protoload_data ff = $(stringfromlist(i,funclist,";"))
						//ff()
					endif
				endif
			endfor
			break
	endswitch
	return 0
end


Function multiLoader_changedcategory(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa
	switch(pa.eventCode)
		case 2:
			PopupMenu popup_loader, mode=1,value=#"multiLoader_listfuncofcateg()"
			break
	endswitch
	return 0
End


Function multiLoader_MakePanel()
	if (WinType("Multiloader") == 7)
		// if the panel already exists, show it
		DoWindow/F Multiloader
	else
		init_flags()

		NewPanel/K=1/W=(381,55,680,420)/N=Multiloader
		ModifyPanel fixedSize=1,noEdit=1

		PopupMenu popup_category,pos={10,10},size={115,20},title="Category  ",fSize=12, proc=multiLoader_changedcategory
		PopupMenu popup_category,mode=1,value=#"multiLoader_getcategories()"
		PopupMenu popup_loader,pos={10,36},size={115,20},title="File Loader",fSize=12
		PopupMenu popup_loader,mode=1,value=#"multiLoader_listfuncofcateg()"

		Button button_load,pos={100,330},size={80,20},title="Load",fSize=14, proc=multiLoader_loadbutton
		Button button_autoload,pos={10,330},size={80,20},title="Auto Load",fSize=14, proc=multiLoader_autoloadbutton // need a working xx_check_file() function for each file type

		SetDrawEnv textrgb= (26205,52428,1),fstyle= 21,fsize= 14;DelayUpdate
		DrawText 110,80,"Settings"
		variable y = 35
		// spectra
		SetDrawEnv textrgb= (65535,0,0),fstyle= 1;DelayUpdate
		DrawText 10,70+y,"Spectra"
		CheckBox check0 title="include ADC",pos={10,80+y},variable=$("root:Packages:Import_Tool:flags:includeADC")
		CheckBox check1 title="single channeltrons",pos={10,100+y},variable=$("root:Packages:Import_Tool:flags:ChanneltronEinzeln")
		CheckBox check2 title="single scans",pos={10,120+y},variable=$("root:Packages:Import_Tool:flags:singlescans")
		CheckBox check3 title="just detector",pos={10,140+y},variable=$("root:Packages:Import_Tool:flags:justdetector")
		CheckBox check4 title="incl. transmission Func.",pos={10,160+y},variable=$("root:Packages:Import_Tool:flags:includetransmission")
		// counts (y-axis)	
		SetDrawEnv textrgb= (65535,0,0),fstyle= 1;DelayUpdate
		DrawText 150,70+y,"Y-axis"
		CheckBox check5 title="div by #scans",pos={150,80+y},variable=$("root:Packages:Import_Tool:flags:CB_DivScans")
		CheckBox check6 title="div by lifetime",pos={150,100+y},variable=$("root:Packages:Import_Tool:flags:CB_DivLifeTime")
		CheckBox check7 title="div by DetectorGain",pos={150,120+y},variable=$("root:Packages:Import_Tool:flags:DivDetectorGain")
		CheckBox check8 title="interpolate counts",pos={150,140+y},variable=$("root:Packages:Import_Tool:flags:Interpolieren")
		CheckBox check14 title="div by TF",pos={150,160+y},variable=$("root:Packages:Import_Tool:flags:f_DivTF")
		y=80
		// x-axis
		SetDrawEnv textrgb= (65535,0,0),fstyle= 1;DelayUpdate
		DrawText 150,160+y,"X-axis"
		CheckBox check9 title="convert to cm^-1",pos={150,170+y},variable=$("root:Packages:Import_Tool:flags:converttoWN")
		CheckBox check10 title="vs. Ekin",pos={150,190+y},variable=$("root:Packages:Import_Tool:flags:vskineticenergy")
		CheckBox check11 title="pos. Ebind",pos={150,210+y},variable=$("root:Packages:Import_Tool:flags:posbinde")
		// storing
		SetDrawEnv textrgb= (65535,0,0),fstyle= 1;DelayUpdate
		DrawText 10,160+y,"Storing"
		CheckBox check12 title="store@root",pos={10,170+y},variable=$("root:Packages:Import_Tool:flags:importtoroot")
		CheckBox check13 title="ask for append",pos={10,190+y},variable=$("root:Packages:Import_Tool:flags:askforappenddet")
		SetVariable setvar0  title="suffix",pos={10,210+y},size={115,20},value=$("root:Packages:Import_Tool:flags:suffix")

		SetDrawLayer UserBack
		SetDrawEnv linethick= 2,linefgc= (65535,21845,0),fillpat= 0
		DrawRRect 5,85,135, 215
		SetDrawEnv linethick= 2,linefgc= (65535,21845,0),fillpat= 0
		DrawRRect 5,220,135, 315
		SetDrawEnv linethick= 2,linefgc= (65535,21845,0),fillpat= 0
		DrawRRect 145,85,275, 215
		SetDrawEnv linethick= 2,linefgc= (65535,21845,0),fillpat= 0
		DrawRRect 145,220,275, 315
	endif
	return 0
end


function /S multiLoader_guess_filetype(file)
	variable file
	
	fstatus file
	if(V_logEOF==0)
		Debugprintf2("Zero byte file!",0)
		return "-1"
	endif
	
	string funclist = FunctionList("*_load_data",";","KIND:2")
	string funclistinfo = FunctionList("*_load_data_info",";","KIND:2")
	string funclistcheck = FunctionList("*_check_file",";","KIND:2")
	string already_checked= ""
	struct importloader importloader

	// get extension of file
	fstatus file
	string file_extension = S_filename
	if (strsearch(file_extension,".",inf,1)>1)//remove filename
		file_extension=file_extension[strsearch(file_extension,".",inf,1)+1, inf]
	else
		file_extension = ""
	endif
	Debugprintf2(".. file extension: *."+file_extension,0)
	
	// get matching file loader for extension, and check against these loaders
	string tmps = ""
	variable i=0
	for(i=0;i<itemsinlist(funclistinfo,";");i+=1)
		FUNCREF multiLoader_protoload_data_info f_info = $(stringfromlist(i,funclistinfo,";"))
		f_info(importloader)
		if(strsearch(importloader.filestr, "*."+file_extension,0,2)!=-1)
			tmps = ReplaceString("_load_data_info",stringfromlist(i,funclistinfo,";"),"")+"_check_file"
			already_checked+=tmps+";" // exclude for second check if no hit
			if(exists(tmps)==6)
				FUNCREF multiLoader_proto_check_file f_check = $(tmps)
				Debugprintf2(" ... checking against: "+ReplaceString("_check_file",tmps,""),1)
				if(f_check(file)==1)
					Debugprintf2(".. found: "+ReplaceString("_check_file",tmps,""),0)
					return ReplaceString("_check_file",tmps,"")
				endif
			endif
		endif
	endfor
	Debugprintf2(" .. no hit with quick check!",0)

	// if no hit check against rest of loader
	for(i=0;i<itemsinlist(funclistinfo,";");i+=1)
			tmps = ReplaceString("_load_data_info",stringfromlist(i,funclistinfo,";"),"")+"_check_file"
			if(strsearch(already_checked, tmps, 0)!=-1)
				Debugprintf2(" .. already checked against: "+tmps,1)
				continue
			endif
			if(exists(tmps)==6)
				FUNCREF multiLoader_proto_check_file f_check = $(tmps)
				Debugprintf2(" ... checking against: "+ReplaceString("_check_file",tmps,""),1)
				if(f_check(file)==1)
					Debugprintf2(" .. found: "+ReplaceString("_check_file",tmps,""),0)
					return ReplaceString("_check_file",tmps,"")
				endif
			endif	
	endfor
	
	Debugprintf2(" .. no suitable loader found !",0)
	return "-1"	
end


function test_for_missing_checks()
	string funclist = FunctionList("*_load_data",";","KIND:2")
	variable i=0
	for(i=0;i<itemsinlist(funclist,";");i+=1)
		if(exists( ReplaceString("_load_data",stringfromlist(i,funclist,";"),"_check_file") )==6)
		else
			print ReplaceString("_load_data",stringfromlist(i,funclist,";"),"_check_file")
		endif
	endfor
end