// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

Menu "Macros"
	submenu "Import Tool "+importloaderversion
			submenu "AFM-Microscopes"
				"Load Nanotec WSxM				*.stp	file... b1", WSxM_load_data()
			end
	end
end

// ###################### Nanotec WSxM ########################
//http://www.igorexchange.com/node/1825
//http://www.nanotec.es/products/wsxm/file_structure.php

static function /S WSxM_getparams(str)
	string str
	string type="", val="", unit=""
	str = stripstrfirstlastspaces(str)
	if(strsearch(str,":",0)!=-1)
		type = 	stripstrfirstlastspaces(str[0,strsearch(str,":",0)-1])
		str = stripstrfirstlastspaces(str[strsearch(str,":",0)+1, inf])
		if(strsearch(str," ",0)!=-1)
			val = stripstrfirstlastspaces(str[0,strsearch(str," ",0)-1])
			unit = stripstrfirstlastspaces(str[strsearch(str," ",0)+1, inf])
		else
			val = str
		endif
	elseif(strlen(str)!=0)
		type = str
	endif
	return type+"#"+val+"#"+unit
end


function WSxM_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "Nanotec WSxM"
	importloader.filestr = "*.stp"
end


function WSxM_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	WSxM_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file

	// checking for the file type
	if(strsearch(myreadline(file),"WSxM file copyright Nanotec Electronica",0)!=0)
		Debugprintf2("Wrong header!",0)	
		loaderend(importloader)
 		return -1
	endif

	if(strsearch(myreadline(file),"SxM Image file",0)!=0)
		Debugprintf2("Wrong header!",0)	
		loaderend(importloader)
 		return -1
	endif
	
	string tmps=myreadline(file)
	if(strsearch(tmps,"Image header size: ",0)!=0)
		Debugprintf2("Wrong header!",0)	
		loaderend(importloader)
 		return -1
	endif

	variable headersize=str2num(tmps[strlen("Image header size: "),inf])
	variable siggain=0, Zgain=0,Xamp=0,Yamp=0,Zamp=0,rows=0,cols=0, headerread=1
	string Xunit="",Yunit="",PreGain="",Zcal="",Xcal="",headtype="",Zunit="",datatype="", comments="", version="", acqchannel=""

	do
		tmps=myreadline(file)
		tmps = WSxM_getparams(mycleanupstr(tmps))
		strswitch(StringFromList(0, tmps, "#"))
			case "[Header end]":
				headerread = 0
				break
			case "[Control]":
				Debugprintf2("Found control!",1)
				break
			case "Signal Gain":
				siggain=str2num(StringFromList(1, tmps, "#"))
				Debugprintf2("Signal Gain: "+num2str(siggain),1)
				break
			case "X Amplitude":
				Xamp=str2num(StringFromList(1, tmps, "#"))
				Xunit=StringFromList(2, tmps, "#")
				Debugprintf2("Xamp: "+num2str(Xamp),1)
				Debugprintf2("Xunit: "+Xunit,1)
				break
			case "Y Amplitude":
				Yamp=str2num(StringFromList(1, tmps, "#"))
				Yunit=StringFromList(2, tmps, "#")
				Debugprintf2("Yamp: "+num2str(Yamp),1)
				Debugprintf2("Yunit: "+Yunit,1)
				break
			case "Z Gain":
				Zgain=str2num(StringFromList(1, tmps, "#"))
				break
			case "[General Info]":
				Debugprintf2("Found general info!",1)
				break
			case "Head type":
				headtype=StringFromList(1, tmps, "#")+" "+StringFromList(2, tmps, "#")
				break
			case "Number of rows":
				cols=str2num(StringFromList(1, tmps, "#"))
				break	
			case "Number of columns":
				rows=str2num(StringFromList(1, tmps, "#"))
				break
			case "Z Amplitude":
				Zamp=str2num(StringFromList(1, tmps, "#"))
				Zunit=StringFromList(2, tmps, "#")
				break
			case "Image Data Type":
				datatype=StringFromList(1, tmps, "#")+" "+StringFromList(2, tmps, "#")
				break
			case "Acquisition channel":
				acqchannel=StringFromList(1, tmps, "#")+" "+StringFromList(2, tmps, "#")
				break
			case "[Head Settings]":
				Debugprintf2("Found head settings!",1)
				break	
			case "Preamp Gain":
				PreGain=StringFromList(1, tmps, "#")+" "+StringFromList(2, tmps, "#")
				break
			case "X Calibration":
				Xcal=StringFromList(1, tmps, "#")+" "+StringFromList(2, tmps, "#")
				break
			case "Z Calibration":
				Zcal=StringFromList(1, tmps, "#")+" "+StringFromList(2, tmps, "#")
				break
			case "[Miscellaneous]":
				Debugprintf2("Found misc settings!",1)
				break
			case "Comments":
				comments = StringFromList(1, tmps, "#")+" "+StringFromList(2, tmps, "#")
				break		
			case "Version":
				version = StringFromList(1, tmps, "#")+" "+StringFromList(2, tmps, "#")
				break
		endswitch
		fstatus file
	while(V_logEOF>V_filePOS && headerread)

	variable type=0
	
	strswitch(datatype)
		case "short":
			type = 2
			break
		case "float":
			type = 4
			break
		case "double":
			type = 5
			break
		default:	
			Debugprintf2("Unknown datatype: "+datatype,0)	
			Debugprintf2("Guessing data type based on size of imagedata!",0)	
			Fstatus File
			variable gues=(V_logEOF-headersize)/(cols*rows)	
			switch((V_logEOF-headersize)/(cols*rows))
				case 2:
					Debugprintf2("Found short!",0)
					type=2
					break
				case 4:
					Debugprintf2("Found float!",0)
					type=4
					break
				case 8:
					Debugprintf2("Found double!",0)
					type=5
					break
				default:
					Debugprintf2("Could not guess the type!",0)	
					loaderend(importloader)
					return -1
	 				break
			endswitch
			break	
	endswitch


	FsetPos file, headersize
	tmps="image"//getnameforwave(file)
	variable val=0,i=0,j=0
	Make /O/R/N=(rows,cols)  $tmps /wave=image
	SetScale/I  x,0,Xamp, Xunit, image
	SetScale/I  y,0,Yamp, Yunit, image

	note image, header
	note image, "Signal Gain: "+num2str(siggain)
	note image, "Z gain: "+num2str(Zgain)
	note image, "X Amplitude: "+num2str(Yamp)
	note image,  "X unit: "+Yunit
	note image, "Y Amplitude: "+num2str(Yamp)
	note image,  "Y unit: "+Yunit
	note image, "Preamp Gain: "+Pregain
	note image, "X Calibration: "+Xcal
	note image, "Z Calibration: "+Zcal
	note image, "Z Amplitude: "+num2str(Zamp)
	note image, "Z unit: "+Zunit
	note image, "Head type: "+headtype
	note image, "Comments: "+comments
	note image, "Version: "+version
	note image, "Acquisition channel: "+acqchannel

	FBinRead/B=3/F=(type) file,image

	Duplicate/FREE image, imagetemp
	image[][]=imagetemp[DimSize(image, 0)-p-1][DimSize(image, 1)-q-1] // we have to mirror the wave to get the original picture
	importloader.success = 1
	loaderend(importloader)
end

// ###################### Nanotec WSxM END ######################
