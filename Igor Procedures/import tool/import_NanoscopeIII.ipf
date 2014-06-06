// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

// used by:
// - Veeco Nanoscope III
// - Bruker Dimension Icon (with Nanoscope V controller)

// http://www.physics.arizona.edu/~smanne/DI/software/fileformats.html

Menu "Macros"
	submenu "Import Tool "+importloaderversion
		submenu "AFM-Microscopes"
			"Load Veeco Nanoscope III		*.00#		file... alpha",nanoscopeIII_load_data()
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
	variable ScanLine
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


function nanoscopeIII_load_data()
	string dfSave=""
	variable file
	string impname="Veeco Nanoscope III"
	string filestr="*.000,*.001,*.002,*.003,*.004,*.005,*.006,*.007,*.008,*.009"
	string header = loaderstart(impname, filestr,file,dfSave)
	if (strlen(header)==0)
		return -1
	endif

	if(cmpstr(cleanup_(myreadline(file)),"\*File list")!=0)
		Debugprintf2("Wrong file!",0)
		loaderend(impname,1,file, dfSave)
		return -1
	endif

	string tmps
	struct keyval keyval
	struct nanoscopeheader nanoscopeheader
	variable run = 1
	variable imagecount = 0

	// read ascii header
	do
		nanoscopeIII_getparams(cleanup_(myreadline(file)), keyval)
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
			case "Valid data len X":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].ValiddatalenX=str2num(keyval.val)
				endif
				break
			case "Valid data len Y":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].ValiddatalenY=str2num(keyval.val)
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
			case "Aspect Ratio":
				if(imagecount != 0)
					nanoscopeheader.imageobject[imagecount-1].AspectRatio= str2num(keyval.val)
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
							loaderend(impname,1,file, dfSave)
							return -1
							break					
					endswitch
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
			default:
				break
		endswitch
		fstatus file
	while(V_logEOF>V_filePOS && run == 1)

	// read binary part
	variable i=0
	for(i=0;i<imagecount;i+=1)
		fsetpos file, nanoscopeheader.imageobject[i].dataoffset
		tmpS = num2str(i)+"_"+cleanname(nanoscopeheader.imageobject[i].name) ; Make /O/D/N=(nanoscopeheader.imageobject[i].ValiddatalenX,nanoscopeheader.imageobject[i].ValiddatalenY) $tmpS ; wave image = $tmpS

		FBInread /B=0/F=(nanoscopeheader.imageobject[i].bytes_pixel) file, image
		tmps = nanoscopeheader.imageobject[i].ScanSizeUnit
		SetScale/I  x,0,nanoscopeheader.imageobject[i].ScanSizeX, tmps, image
		SetScale/I  y,0,nanoscopeheader.imageobject[i].AspectRatio/nanoscopeheader.imageobject[i].ScanSizeY, tmps, image
		Duplicate/FREE image, imagetemp
		image[][]=imagetemp[p][DimSize(image, 1)-q-1] // we have to mirror the wave to get the original picture
	endfor

	loaderend(impname,1,file, dfSave)
end

