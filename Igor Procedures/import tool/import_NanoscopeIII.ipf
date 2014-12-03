// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

// used by:
// - Veeco Nanoscope III
// - Bruker Dimension Icon (with Nanoscope V controller)

// http://www.physics.arizona.edu/~smanne/DI/software/fileformats.html

static structure keyval
	string key
	string val
endstructure


structure nanoscopeheader
	variable dataoffset
	struct imageobject imageobject[100]
endstructure


structure imageobject
	variable Dataoffset
	variable Datalength
	variable bytes_pixel
	string Startcontext
	string Datatype
	string DataTypeDescription
	string myNote
	string Planefit
	string Framedirection
	variable Capturestartline
	variable ColorTableIndex
	variable Sampsline
	variable Numberoflines
	variable AspectRatio
	variable ScanSizeX
	variable ScanSizeY
	string ScanSizeUnit
	string ScanLine
	string LineDirection
	variable Highpass
	variable Lowpass
	string RealtimePlanefit
	string OfflinePlanefit
	variable ValiddatastartX
	variable ValiddatastartY
	variable ValiddatalenX
	variable ValiddatalenY
	variable Tipxwidthcorrectionfactor
	variable Tipywidthcorrectionfactor
	variable Tipxwidthcorrectionfactorsigma
	variable Tipywidthcorrectionfactorsigma
	string ImageData
	string magnify
	string scale
	string offset
	string name
endstructure


static function /S nanoscopeIII_getparams(str, keyval)
	string str
	struct keyval &keyval
	keyval.key = ""
	keyval.val = ""
	str = stripstrfirstlastspaces(str)
	if(strsearch(str[0],"\\",0)!=-1)
		str=str[1,inf]
		if(strsearch(str,":",0)!=-1)
			keyval.key = 	stripstrfirstlastspaces(str[0,strsearch(str,":",0)-1])
			keyval.val = stripstrfirstlastspaces(str[strsearch(str,":",0)+1, inf])
		elseif(strlen(str)!=0)
			keyval.key = str
		endif
	else
	
	endif	
end


static function nanoscopeIII_clearheader(nanoscopeheader)
	struct nanoscopeheader &nanoscopeheader
	variable i=0
	for(i=0;i<100;i+=1)
		nanoscopeheader.imageobject[i].Dataoffset = NaN
		nanoscopeheader.imageobject[i].Datalength = NaN
		nanoscopeheader.imageobject[i].bytes_pixel = NaN
		nanoscopeheader.imageobject[i].Startcontext = ""
		nanoscopeheader.imageobject[i].Datatype = ""
		nanoscopeheader.imageobject[i].DataTypeDescription = ""
		nanoscopeheader.imageobject[i].myNote = ""
		nanoscopeheader.imageobject[i].Planefit = ""
		nanoscopeheader.imageobject[i].Framedirection = ""
		nanoscopeheader.imageobject[i].Capturestartline = NaN
		nanoscopeheader.imageobject[i].ColorTableIndex = NaN
		nanoscopeheader.imageobject[i].Sampsline = NaN
		nanoscopeheader.imageobject[i].Numberoflines = NaN
		nanoscopeheader.imageobject[i].AspectRatio = NaN
		nanoscopeheader.imageobject[i].ScanSizeX = NaN
		nanoscopeheader.imageobject[i].ScanSizeY = NaN
		nanoscopeheader.imageobject[i].ScanSizeUnit = ""
		nanoscopeheader.imageobject[i].ScanLine = ""
		nanoscopeheader.imageobject[i].LineDirection = ""
		nanoscopeheader.imageobject[i].Highpass = NaN
		nanoscopeheader.imageobject[i].Lowpass = NaN
		nanoscopeheader.imageobject[i].RealtimePlanefit = ""
		nanoscopeheader.imageobject[i].OfflinePlanefit = ""
		nanoscopeheader.imageobject[i].ValiddatastartX = NaN
		nanoscopeheader.imageobject[i].ValiddatastartY = NaN
		nanoscopeheader.imageobject[i].ValiddatalenX = NaN
		nanoscopeheader.imageobject[i].ValiddatalenY = NaN
		nanoscopeheader.imageobject[i].Tipxwidthcorrectionfactor = NaN
		nanoscopeheader.imageobject[i].Tipywidthcorrectionfactor = NaN
		nanoscopeheader.imageobject[i].Tipxwidthcorrectionfactorsigma = NaN
		nanoscopeheader.imageobject[i].Tipywidthcorrectionfactorsigma = NaN
		nanoscopeheader.imageobject[i].ImageData = ""
		nanoscopeheader.imageobject[i].magnify = ""
		nanoscopeheader.imageobject[i].scale = ""
		nanoscopeheader.imageobject[i].offset = ""
		nanoscopeheader.imageobject[i].name = ""
	endfor
end


function nanoscopeIII_check_file(file)
	variable file
	fsetpos file, 0
	if(cmpstr(mycleanupstr(myreadline(file)),"\*File list")!=0)
		fsetpos file, 0
		return -1
	endif
	if(strsearch(mycleanupstr(myreadline(file)),"\Version",0)!=0)
		fsetpos file, 0
		return -1
	endif
	fsetpos file, 0
	return 1
end


function nanoscopeIII_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "Veeco Nanoscope III"
	importloader.filestr =  "*.000,*.001,*.002,*.003,*.004,*.005,*.006,*.007,*.008,*.009"
	importloader.category = "SPM"
end


function nanoscopeIII_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	nanoscopeIII_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file

	if(cmpstr(mycleanupstr(myreadline(file)),"\*File list")!=0)
		Debugprintf2("Wrong file!",0)
		loaderend(importloader)
		return -1
	endif

	string tmps
	struct keyval keyval
	struct nanoscopeheader nanoscopeheader
	nanoscopeIII_clearheader(nanoscopeheader)
	variable run = 1
	variable imagecount = 0

	// read ascii header
	do
		nanoscopeIII_getparams(mycleanupstr(myreadline(file)), keyval)
		strswitch(keyval.key)
			case "*File list end":
				Debugprintf2("End of ASCII header!",1)
				run = 0
				break
			case "*Ciao image list":
				imagecount +=1
				break
			case "Data offset":
				if(imagecount == 0)
					nanoscopeheader.dataoffset = str2num(keyval.val)
				else
					nanoscopeheader.imageobject[imagecount-1].dataoffset=str2num(keyval.val)
					Debugprintf2("Data offset: "+num2str(nanoscopeheader.imageobject[imagecount-1].dataoffset),1)
				endif
				break
			case "Data length":
				if(imagecount == 0)
				else
					nanoscopeheader.imageobject[imagecount-1].datalength=str2num(keyval.val)
					Debugprintf2("Data length: "+num2str(nanoscopeheader.imageobject[imagecount-1].datalength),1)
				endif
				break
			case "Bytes/pixel":
				if(imagecount != 0)
					switch(str2num(keyval.val))
						case 2:
							nanoscopeheader.imageobject[imagecount-1].bytes_pixel = 2
							break	
						case 4:
							nanoscopeheader.imageobject[imagecount-1].bytes_pixel = 3
							break	
						default:
							Debugprintf2("Unnown datatype!",0)
							loaderend(importloader)
							return -1
							break					
					endswitch
				endif
				break
			case "Start context":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].Startcontext = keyval.val
				endif
				break				
			case "Data type":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].Datatype = keyval.val
				endif
				break				
			case "Data Type Description":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].DataTypeDescription = keyval.val
				endif
				break				
			case "Note":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].myNote = keyval.val
				endif
				break				
			case "Plane fit":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].Planefit = keyval.val
				endif
				break								
			case "Frame direction":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].Framedirection = keyval.val
				endif
				break
			case "Capture start line":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].Capturestartline = str2num(keyval.val)
				endif
				break
			case "Color Table Index":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].ColorTableIndex = str2num(keyval.val)
				endif
				break
			case "Samps/line":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].Sampsline = str2num(keyval.val)
				endif
				break
			case "Number of lines":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].Numberoflines = str2num(keyval.val)
				endif
				break
			case "Aspect Ratio":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].AspectRatio= str2num(keyval.val)
				endif
				break
			case "Scan Size":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].ScanSizeX = str2num(stringfromlist(0,keyval.val," "))
					nanoscopeheader.imageobject[imagecount-1].ScanSizeY = str2num(stringfromlist(1,keyval.val," "))
					strswitch(stringfromlist(2,keyval.val," "))
						case "~m":
							nanoscopeheader.imageobject[imagecount-1].ScanSizeUnit = "µm"
							break
						default:
							nanoscopeheader.imageobject[imagecount-1].ScanSizeUnit = stringfromlist(2,keyval.val," ")
							break
					endswitch
				endif
				break
			case "Scan Line":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].ScanLine =keyval.val
				endif
				break
			case "Line Direction":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].LineDirection = keyval.val
				endif
				break
			case "Highpass":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].Highpass = str2num(keyval.val)
				endif
				break
			case "Lowpass":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].Highpass = str2num(keyval.val)
				endif
				break
			case "Realtime Planefit":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].RealtimePlanefit = keyval.val
				endif
				break
			case "Offline Planefit":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].OfflinePlanefit = keyval.val
				endif
				break
			case "Valid data start X":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].ValiddatastartX = str2num(keyval.val)
				endif
				break
			case "Valid data start Y":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].ValiddatastartY = str2num(keyval.val)
				endif
				break
			case "Valid data len X":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].ValiddatalenX = str2num(keyval.val)
				endif
				break
			case "Valid data len Y":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].ValiddatalenY = str2num(keyval.val)
				endif
				break
			case "Tip x width correction factor":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].Tipxwidthcorrectionfactor = str2num(keyval.val)
				endif
				break
			case "Tip y width correction factor":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].Tipywidthcorrectionfactor = str2num(keyval.val)
				endif
				break
			case "Tip x width correction factor sigma":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].Tipxwidthcorrectionfactorsigma = str2num(keyval.val)
				endif
				break
			case "Tip y width correction factor sigma":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].Tipywidthcorrectionfactorsigma = str2num(keyval.val)
				endif
				break
			default:
				if(strsearch(keyval.key,"@",0)==0 && numtype(str2num(keyval.key[1,inf]))==0 )
					variable num = str2num(keyval.key[1,inf])
					if(num>100)
						break
					endif
					string key = keyval.val[0,strsearch(keyval.val,":",1)-1]
					string val = keyval.val[strsearch(keyval.val,":",1)+1,inf]
					strswitch(key)
						case "Image Data":
							tmps=val[strsearch(val,"\"",0)+1,inf]
							nanoscopeheader.imageobject[imagecount-1].name = tmps[0,strsearch(tmps,"\"",0)-1]
							break
						default:
							break					
					endswitch
				endif			
				break
		endswitch
		fstatus file
	while(V_logEOF>V_filePOS && run == 1)

	// read binary part
	variable i=0
	for(i=0;i<imagecount;i+=1)
		// goto start of image
		fsetpos file, nanoscopeheader.imageobject[i].dataoffset

		tmpS = num2str(i)+"_"+cleanname(nanoscopeheader.imageobject[i].name) ; Make /O/D/N=(nanoscopeheader.imageobject[i].Sampsline,nanoscopeheader.imageobject[i].Numberoflines) $tmpS ; wave image = $tmpS
		FBInread /B=0/F=(nanoscopeheader.imageobject[i].bytes_pixel) file, image

		tmps = nanoscopeheader.imageobject[i].ScanSizeUnit
		SetScale/I  x,0,nanoscopeheader.imageobject[i].ScanSizeX, tmps, image
		if(nanoscopeheader.imageobject[i].AspectRatio == 1)
			SetScale/I  y,0,nanoscopeheader.imageobject[i].ScanSizeY, tmps, image
		else
			SetScale/I  y,0,nanoscopeheader.imageobject[i].AspectRatio/nanoscopeheader.imageobject[i].ScanSizeY, tmps, image
		endif
		Duplicate/FREE image, imagetemp
		image[][]=imagetemp[p][DimSize(image, 1)-q-1] // we have to mirror the wave to get the original picture

		// save notes to image
		nanoscopeIII_addnotestr(image, "", header)
		nanoscopeIII_addnotestr(image, "Start context: ", nanoscopeheader.imageobject[i].Startcontext)
		nanoscopeIII_addnotestr(image, "Data type: ", nanoscopeheader.imageobject[i].Datatype)
		nanoscopeIII_addnotestr(image, "Data Type Description: ", nanoscopeheader.imageobject[i].DataTypeDescription)
		nanoscopeIII_addnotestr(image, "Note: ", nanoscopeheader.imageobject[i].myNote)
		nanoscopeIII_addnotestr(image, "Plane fit: ", nanoscopeheader.imageobject[i].Planefit)
		nanoscopeIII_addnotestr(image, "Frame direction: ", nanoscopeheader.imageobject[i].Framedirection)
		nanoscopeIII_addnotenum(image, "Capture start line: ", nanoscopeheader.imageobject[i].Capturestartline)
		nanoscopeIII_addnotenum(image, "Color Table Index: ", nanoscopeheader.imageobject[i].ColorTableIndex)
		nanoscopeIII_addnotenum(image, "Samps/line: ", nanoscopeheader.imageobject[i].Sampsline)
		nanoscopeIII_addnotenum(image, "Number of lines: ", nanoscopeheader.imageobject[i].Numberoflines)
//		nanoscopeIII_addnotenum(image, "Aspect Ratio: ", nanoscopeheader.imageobject[i].AspectRatio)
//		nanoscopeIII_addnotenum(image, "", nanoscopeheader.imageobject[i].ScanSizeX)
//		nanoscopeIII_addnotenum(image, "", nanoscopeheader.imageobject[i].ScanSizeY)
//		nanoscopeIII_addnotestr(image, "", nanoscopeheader.imageobject[i].ScanSizeUnit)
		nanoscopeIII_addnotestr(image, "Scan Line: ", nanoscopeheader.imageobject[i].ScanLine)
		nanoscopeIII_addnotestr(image, "Line Direction: ", nanoscopeheader.imageobject[i].LineDirection)
		nanoscopeIII_addnotenum(image, "Highpass: ", nanoscopeheader.imageobject[i].Highpass)
		nanoscopeIII_addnotenum(image, "Lowpass: ", nanoscopeheader.imageobject[i].Lowpass)
		nanoscopeIII_addnotestr(image, "Realtime Planefit: ", nanoscopeheader.imageobject[i].RealtimePlanefit)
		nanoscopeIII_addnotestr(image, "Offline Planefit: ", nanoscopeheader.imageobject[i].OfflinePlanefit)
		nanoscopeIII_addnotenum(image, "Valid data start X: ", nanoscopeheader.imageobject[i].ValiddatastartX)
		nanoscopeIII_addnotenum(image, "Valid data start Y: ", nanoscopeheader.imageobject[i].ValiddatastartY)
		nanoscopeIII_addnotenum(image, "Valid data len X: ", nanoscopeheader.imageobject[i].ValiddatalenX)
		nanoscopeIII_addnotenum(image, "Valid data len Y: ", nanoscopeheader.imageobject[i].ValiddatalenY)
		nanoscopeIII_addnotenum(image, "Tip x width correction factor: ", nanoscopeheader.imageobject[i].Tipxwidthcorrectionfactor)
		nanoscopeIII_addnotenum(image, "Tip y width correction factor: ", nanoscopeheader.imageobject[i].Tipywidthcorrectionfactor)
		nanoscopeIII_addnotenum(image, "Tip x width correction factor sigma: ", nanoscopeheader.imageobject[i].Tipxwidthcorrectionfactorsigma)
		nanoscopeIII_addnotenum(image, "Tip y width correction factor sigma: ", nanoscopeheader.imageobject[i].Tipywidthcorrectionfactorsigma)
	endfor

	importloader.success = 1
	loaderend(importloader)
end


static function nanoscopeIII_addnotestr(waves, name, str)
	wave waves
	string name
	string str
	if(strlen(str)>0)
		note waves, name+str
	endif
end


static function nanoscopeIII_addnotenum(waves, name, num)
	wave waves
	string name
	variable num
	if(numtype(num)==0)
		string tmps = ""
		sprintf tmps, "%f", num
		note waves, name+tmps
	endif
end
