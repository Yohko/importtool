// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

Menu "Macros"
	submenu "Import Tool "+importloaderversion
			submenu "AFM-Microscopes"
				"Load Gwyddion SPM				*.gwy	file... b1", gwy_load_data()
			end
	end
end

// ###################### Gwyddion gwy ########################
// http://gwyddion.net/documentation/user-guide-en/gwyfile-format.html
// http://gwyddion.net/gwydump.php

static function gwy_getchannelnumber(file, str)
	variable file
	string str
	Fstatus file
	variable fpos = V_filePos
	variable size = V_logEOF
	Fsetpos file, fpos-strlen(str)
	variable i=0
	string number="    " //only 3 for up to 999 channels
	string tmps=""
	
	for(i=0;i<3;i+=1)
		Fsetpos file, fpos-strlen(str)-1-i
		tmps=mybinread(file,1)
		if(strsearch(tmps,"/",0)==0 || strsearch(tmps,num2char(0),0)==0)
			break
		else
			number[strlen(number)-1-i]=tmps
		endif
	endfor
	FSetPos file,fpos
	return round(str2num(number))
end

static function gwy_findparam(name,file)
	string name
	variable file
	Fstatus file
	variable fpos = V_filePos
	variable size = V_logEOF
	variable i
	string tmps=""
	for (i=fpos;i<size-strlen(name);i+=1)
		FsetPos file, i
		tmps=mybinread(file,strlen(name))
		if (strsearch(tmps,name,0)==0)
			Fstatus file
			Debugprintf2("Found param: "+name+"; Position: "+num2str(V_filePos),1)
			return true
		endif
	endfor
	Debugprintf2("Param not found: "+name,1)

	return -1
end

static function gwy_getparam(name, type,file)
	string name
	string type
	variable file
	string tmps
	FStatus file
	if (gwy_findparam(name,file)!=true)
		return -1
	endif
	FStatus file
	Fsetpos file, V_filePos+2 // skip 'x' and nul
	variable val=0
	strswitch(type)
		case "int32":
			FBinread/B=3/F=3 file, val
			break
		case "double":
			FBinread/B=3/F=5 file, val
			break
		default:
			break
	endswitch
	Debugprintf2("Value: "+num2str(val),1)
	return val
end

static function /S gwy_getstring(file)
	variable file
	string val="1"
	Fstatus file
	variable fpos = V_filePos
	variable size = V_logEOF
	variable i=0
	string line = ""
	for(i=fpos;i<size-1;i+=1)
		val = mybinread(file,1)
		if(strsearch(val,num2char(0),0)==0)
			break
		endif
		line += val
	endfor
	return line
	
end

static function gwy_importGWYP(file, header)
	variable file
	string header
	Fstatus file
	string tmps=""
	variable imagecount =0
	variable fpos =0
	variable channelnumber=0, newchannelnumber=0
	string datatitle=""
	variable xres=0,yres=0,xreal=0,yreal=0
	string si_unit_xy=""
	string si_unit_z=""
	string imagelist = ""
	string namelist = ""
	do
		//gwy_findparam("/0/data",file) //beginn of data of channel 0
		if(gwy_findparam("/data",file)==true) //beginn of data of channel
			mybinread(file,1) //skip nul or /
			
			tmps=gwy_getstring(file)
			if(strsearch(tmps,"title",0)==0)
				channelnumber=gwy_getchannelnumber(file,"/data/title ")
				mybinread(file,1)//skip only s
				datatitle = gwy_getstring(file)
				Debugprintf2("Found title of channel "+num2str(channelnumber),1)
				// save channel title in a list
				namelist = AddListItem(num2str(channelnumber)+"="+datatitle,namelist, ";", 0)
			elseif(strsearch(tmps,"oGwyDataField",0)==0)
				// Found oGwyDataField

				channelnumber=gwy_getchannelnumber(file,"/data oGwyDataField ")
				xres=gwy_getparam("xres", "int32",file) //Find the image size in pixel (x direction)
				if (xres ==-1)
					break
				endif
				yres=gwy_getparam("yres", "int32",file) //Find the image size in pixel (y direction)
				if (yres ==-1)
					break
				endif
				xreal=gwy_getparam("xreal", "double",file) //... the real image size (x direction)
				if (xreal ==-1)
					break
				endif
				yreal=gwy_getparam("yreal", "double",file) //... the real image size (y direction)
				if (yreal ==-1)
					break
				endif
				if(gwy_findparam("si_unit_xy",file)!=true)
					break
				endif
				if(gwy_findparam("unitstr",file)!=true)
					break
				endif
				mybinread(file,2)//skip nul and s
				si_unit_xy= gwy_getstring(file)
				if(gwy_findparam("si_unit_z",file)!=true)
					break
				endif
				if(gwy_findparam("unitstr",file)!=true)
					break
				endif
				mybinread(file,2)//skip nul and s
				si_unit_z= gwy_getstring(file)
				if(gwy_findparam("data",file)!=true) // now the beginning of the image
					Debugprintf2("Error finding imagedata!",0)
					break
				endif
				Debugprintf2("Should be 'nul': "+mybinread(file,1),1) //should be a nul from the string before
				string test = mybinread(file,1)//shoud be 'D'  --> array of doubles
				Debugprintf2("Should be 'D': "+test,1) 
				if (cmpstr(test,"D"))
					Debugprintf2("Error finding image data!",0) 
					close file
					return -1
				endif
				mybinread(file,4) //what are these 4 chars for?? --> unsigned 32bit array length (xres*yres)
				tmps=getnameforwave(file)+"_ch"+num2str(channelnumber)
				imagecount+=1
				Make /O/R/N=(xres,yres)  $tmps /wave=image
				SetScale/I  x,0,xreal, si_unit_xy, image
				SetScale/I  y,0,yreal, si_unit_xy, image
				note image, header
				note image, "SI unit xy: "+ si_unit_xy
				note image, "SI unit z: "+ si_unit_z
				note image, "GWY channel: "+num2str(channelnumber)
				FBinread/B=3/F=5 file, image

				Debugprintf2("... exported image: ch"+num2str(channelnumber),0)

				imagelist = AddListItem(num2str(channelnumber)+"="+tmps,imagelist, ";", 0)
			endif
		else
			break	
		endif
		fstatus file
	while(V_logEOF>V_filePOS)
	
	// now assign imagename to image
	if(ItemsInList(imagelist,";") ==ItemsInList(namelist,";") && ItemsInList(namelist,";") > 0)
		variable i=0
		for(i=0;i<ItemsInList(namelist,";");i+=1)
			tmps = StringFromList(0,StringFromList(i,namelist,";"),"=")
			if(waveexists($(StringByKey(tmps, imagelist, "=",";"))))
				Rename $(StringByKey(tmps, imagelist, "=",";")), $(StringByKey(tmps, namelist, "=",";")+"_ch"+tmps)
			endif
		endfor
	endif
	
end

function gwy_load_data()
	string dfSave=""
	variable file
	string impname="Gwyddion GWY"
	string filestr="*.gwy"
	string header = loaderstart(impname, filestr,file,dfSave)
	if (strlen(header)==0)
		return -1
	endif

	string identifier = mybinread(file, 4)
	
	if (strsearch(identifier, "GWYO", 0) == 0)
			Debugprintf2("Found a Gwyddion 1.x GWY0 file, not supported yet!",2)
	elseif (strsearch(identifier, "GWYP", 0) == 0)
			Debugprintf2("Found a Gwyddion 2.x GWYP file!",1)
			gwy_importGWYP(file, header)
	elseif (strsearch(identifier, "GWYQ", 0) == 0)
			Debugprintf2("Found a Gwyddion GWYQ file, not supported yet!",2)
	endif
	
	loaderend(impname,1,file, dfSave)
end

// ###################### Gwyddion gwy END ######################