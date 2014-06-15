// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

// LK-Tech HREELS Model EA5000MCA
// http://www.lktech.com/products/EA5000MCA.php

Menu "Macros"
	submenu "Import Tool "+importloaderversion
			Submenu "EELS"
				"LK-Tech HREELS Model EA5000MCA	*.dat	file... b1", LKHREELS_load_data()
			end			
	end
end


function LKHREELS_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "LK-Tech HREELS"
	importloader.filestr =  "*.dat"
	importloader.category = "EELS"
end


function LKHREELS_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	LKHREELS_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file

	string tmps="", tmps2=""
	variable tmp=0, tmp2=0, tmpc=0

	do
		Freadline file, tmps
		If (strlen(tmps)==0)
			return 0
		endif
		tmps=mycleanupstr(tmps)
		if(strsearch(tmps,"#",0)==0)
			tmp+=1
			header+="\rComment"+num2str(tmp)+": "+cleanupname(stripstrfirstlastspaces(tmps[strsearch(tmps,"#",0)+1,inf]),1)
			continue
//		else
//			break
		endif

		tmps=splitintolist(tmps, " ")
		if (itemsinlist(tmps,"_") != 3)
			Debugprintf2("Wrong number of items in value list!",0)
			loaderend(importloader)
			return -1
		endif
		tmp=str2num(StringFromList(0,tmps,"_")) // number of spektrum 
		if(tmp2==0) //new spectrum begins
			tmp2=tmp
			tmpc=1
			tmps2="region_X" ; Make /O/R/N=(tmpc)  $tmps2 /wave=detectorX ; note detectorX, header
			tmps2="region_Y" ; Make /O/R/N=(tmpc)  $tmps2 /wave=detectorY ; note detectorY, header
		else
			tmpc+=1
			redimension /N=(tmpc) detectorX
			redimension /N=(tmpc) detectorY
			SetScale d, 0,0,"cps", detectorY
			SetScale d, 0,0,"meV", detectorX
		endif

		detectorX[tmpc-1]=str2num(StringFromList(2,tmps,"_"))
		detectorY[tmpc-1]=str2num(StringFromList(1,tmps,"_"))
		
		Fstatus file
	while (V_logEOF>V_filePOS)
	
	// convert to wavenumbers
	if(converttoWN==1)
		tmps2="region_X_WN" ; Duplicate/O detectorX, $tmps2 ; wave detectorXWN=$tmps2
		detectorXWN=detectorX/1000*8065.54468111324// /(heV*clight*100)
		SetScale d, 0,0,"cm-1", detectorXWN
	endif
	
	importloader.success = 1
	loaderend(importloader)
end

