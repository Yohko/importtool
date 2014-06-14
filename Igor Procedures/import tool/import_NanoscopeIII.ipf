// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

// used by:
// - Veeco Nanoscope III
// - Bruker Dimension Icon (with Nanoscope V controller)

// http://www.physics.arizona.edu/~smanne/DI/software/fileformats.html

Menu "Macros"
	submenu "Import Tool "+importloaderversion
		submenu "AFM-Microscopes"
			"Load Veeco Nanoscope III		*.00#	file... alpha",nanoscopeIII_load_data()
		end
	end
end


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


function nanoscopeIII_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "Veeco Nanoscope III"
	importloader.filestr =  "*.000,*.001,*.002,*.003,*.004,*.005,*.006,*.007,*.008,*.009"
	importloader.category = "AFM"
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
			case "@2":
				if(imagecount != 0)
					if(strsearch(keyval.val,"Image Data",0)==0)
						tmps=keyval.val
						tmps=tmps[strsearch(keyval.val,"\"",0)+1,inf]
						nanoscopeheader.imageobject[imagecount-1].name = tmps[0,strsearch(tmps,"\"",0)-1]
					endif
				endif
				break
			default:
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
		note image, header
		note image, "Start context: "+nanoscopeheader.imageobject[i].Startcontext
		note image, "Data type: "+nanoscopeheader.imageobject[i].Datatype
		note image, "Data Type Description: "+nanoscopeheader.imageobject[i].DataTypeDescription
		note image, "Note: "+nanoscopeheader.imageobject[i].myNote
		note image, "Plane fit: "+nanoscopeheader.imageobject[i].Planefit
		note image, "Frame direction: "+nanoscopeheader.imageobject[i].Framedirection
		note image, "Capture start line: "+num2str(nanoscopeheader.imageobject[i].Capturestartline)
		note image, "Color Table Index: "+num2str(nanoscopeheader.imageobject[i].ColorTableIndex)
		note image, "Samps/line: "+num2str(nanoscopeheader.imageobject[i].Sampsline)
		note image, "Number of lines: "+num2str(nanoscopeheader.imageobject[i].Numberoflines)
//		note image, "Aspect Ratio: "+num2str(nanoscopeheader.imageobject[i].AspectRatio)
//		note image, num2str(nanoscopeheader.imageobject[i].ScanSizeX)
//		note image, num2str(nanoscopeheader.imageobject[i].ScanSizeY)
//		note image, nanoscopeheader.imageobject[i].ScanSizeUnit
		note image, "Scan Line: "+nanoscopeheader.imageobject[i].ScanLine
		note image, "Line Direction: "+nanoscopeheader.imageobject[i].LineDirection
		note image, "Highpass: "+num2str(nanoscopeheader.imageobject[i].Highpass)
		note image, "Lowpass: "+num2str(nanoscopeheader.imageobject[i].Lowpass)
		note image, "Realtime Planefit: "+nanoscopeheader.imageobject[i].RealtimePlanefit
		note image, "Offline Planefit: "+nanoscopeheader.imageobject[i].OfflinePlanefit
		note image, "Valid data start X: "+num2str(nanoscopeheader.imageobject[i].ValiddatastartX)
		note image, "Valid data start Y: "+num2str(nanoscopeheader.imageobject[i].ValiddatastartY)
		note image, "Valid data len X: "+num2str(nanoscopeheader.imageobject[i].ValiddatalenX)
		note image, "Valid data len Y: "+num2str(nanoscopeheader.imageobject[i].ValiddatalenY)
		note image, "Tip x width correction factor: "+num2str(nanoscopeheader.imageobject[i].Tipxwidthcorrectionfactor)
		note image, "Tip y width correction factor: "+num2str(nanoscopeheader.imageobject[i].Tipywidthcorrectionfactor)
		note image, "Tip x width correction factor sigma: "+num2str(nanoscopeheader.imageobject[i].Tipxwidthcorrectionfactorsigma)
		note image, "Tip y width correction factor sigma: "+num2str(nanoscopeheader.imageobject[i].Tipywidthcorrectionfactorsigma)
	endfor

	importloader.success = 1
	loaderend(importloader)
end

