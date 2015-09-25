// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

// requires ZIP.XOP (http://www.igorexchange.com/project/ZIP)
// based on createc.c from Gwyddion 2.41 (http://gwyddion.net/download/2.41/)

static constant Angstrom = 1e-10
static constant HEADER_SIZE = 12288
static constant DATA_OFFSET = 16384
static constant CHANNEL_TOPOGRAPHY = 1
static constant CHANNEL_CURRENT = 2
static strconstant tempfilename = "createctempbinfile0815"


static structure keyval
	string key
	string val
endstructure


static structure createc_headerstruct
	variable version
	variable dataoffset
	string DAcType
	variable channels
	variable numx
	variable numy
	variable bpp
	variable Channelselectval
	variable delta_x
	variable delta_y
	variable gain_x
	variable gain_y
	variable gain_z
	variable piezo_x
	variable piezo_y
	variable piezo_z
	string header
	variable channelbit
endstructure


static function createc_getparams(str, keyval)
	string str
	struct keyval &keyval
	keyval.key = ""
	keyval.val = ""
	str = stripstrfirstlastspaces(str)
	if(strsearch(str,"=",0)!=-1)
		keyval.key =  stripstrfirstlastspaces(str[0,strsearch(str,"=",0)-1])
		keyval.val = stripstrfirstlastspaces(str[strsearch(str,"=",0)+1, inf])
	elseif(strlen(str)!=0)
		keyval.key = str
	endif
end


function createc_check_file(file)
	variable file
	fsetpos file, 0
	variable version = createc_get_version(file)
	fsetpos file, 0
	return version
end


function createc_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "Createc STM"
	importloader.filestr = "*.dat"
	importloader.category = "SPM"
end


function createc_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	createc_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file
	
	// reading ASCII header
	struct createc_headerstruct headerstruct
	headerstruct.version =  createc_get_version(file)
	headerstruct.header = header
	headerstruct.Channelselectval = 0
	
	variable run = 1
	struct keyval keyval
	do
		createc_getparams(mycleanupstr(myreadline(file)), keyval)
		if(strlen(keyval.key) == 0 &&strlen(keyval.val) == 0)
			fstatus file
			continue
		endif
		strswitch(keyval.key)
			case "Channels / Channels":
				headerstruct.channels = str2num(keyval.val)
				break
			case "Channels":
				headerstruct.channels = str2num(keyval.val)
				break
			case "Num.X / Num.X":
				headerstruct.Numx = str2num(keyval.val)
				break
			case "Num.X":
				headerstruct.Numx = str2num(keyval.val)
				break
			case "Num.Y / Num.Y":
				headerstruct.Numy = str2num(keyval.val)
				break
			case "Num.Y":
				headerstruct.Numy = str2num(keyval.val)
				break
			case "Channelselectval / Channelselectval":
				headerstruct.Channelselectval = str2num(keyval.val)
				break
			case "DAC-Type":
				headerstruct.DACType = keyval.val
				break
			case "Delta X / Delta X [Dac]":
				headerstruct.Delta_x = str2num(keyval.val)
				break
			case "Delta X":
				headerstruct.Delta_x = str2num(keyval.val)
				break
			case "Delta Y / Delta Y [Dac]":
				headerstruct.Delta_y = str2num(keyval.val)
				break
			case "Delta Y":
				headerstruct.Delta_y = str2num(keyval.val)
				break
			case "GainX / GainX":
				headerstruct.gain_x = str2num(keyval.val)
				break
			case "GainX":
				headerstruct.gain_x = str2num(keyval.val)
				break
			case "xpiezoconst":
				headerstruct.piezo_x = str2num(keyval.val)
				break
			case "GainY / GainY":
				headerstruct.gain_y = str2num(keyval.val)
				break
			case "GainY":
				headerstruct.gain_y = str2num(keyval.val)
				break
			case "YPiezoconst":
				headerstruct.piezo_y = str2num(keyval.val)
				break
			case "GainZ / GainZ":
				headerstruct.gain_z = str2num(keyval.val)
				break
			case "GainZ":
				headerstruct.gain_z = str2num(keyval.val)
				break
			case "ZPiezoconst":
				headerstruct.piezo_z = str2num(keyval.val)
				break
		endswitch
		headerstruct.header += "\r"+keyval.key+": "+keyval.val
		fstatus file
	while(V_logEOF>V_filePOS && HEADER_SIZE>V_filePOS && run == 1)
	
	// reading binary data
	Debugprintf2("Should be ICON: "+mybinread(file, 4),1)
	fsetpos file, (DATA_OFFSET-4)
	Debugprintf2("Should be DATA: "+mybinread(file, 4),1)

	
	// reading binary image data
	if(headerstruct.version == 1)
		headerstruct.dataoffset = DATA_OFFSET+2 //2 unused bytes
		headerstruct.bpp = 2
		createc_readimagedata(file, headerstruct)		
	elseif(headerstruct.version == 2)
		headerstruct.dataoffset = DATA_OFFSET+4 // 4 unused bytes
		headerstruct.bpp = 4
		createc_readimagedata(file, headerstruct)
	elseif (headerstruct.version == 3)
		headerstruct.dataoffset = 4
		headerstruct.bpp = 4
		// decompressing data and saving into new tempfile, requires ZIP.XOP
		fstatus file
		string imageData = ""
		variable tempfile = 0

#if Exists("zipdecode") // check for ZIP.XOP function
		imageData = padstring(imageData,V_logEOF-DATA_OFFSET,1)
		fbinread /B=3 file, imageData //read in the data
		Debugprintf2("Input Size: "+num2str(strlen(imagedata)),1)
		// unzipped data will be larger but the difference to the expected size will be just filled with "NULLs"
		Debugprintf2("Decompressing data using ZIP.XOP",1)
		imageData = zipdecode(imageData)
		// save decompressed output in temp file
		open/Z=1 /P=myimportpath tempfile as tempfilename
		if(tempfile == 0)
			Debugprintf2("Error: Temp file was already opened, closing all files! Try again!",0)
			close /A
			importloader.success = 0
			loaderend(importloader)
			return -1
		endif
		FBinWrite /B=3 tempfile, imageData
		Debugprintf2("Expected size: "+num2str(headerstruct.Numx*headerstruct.Numy*headerstruct.channels*headerstruct.bpp+4),1)
		Debugprintf2("Decompressed size: "+num2str(strlen(imagedata)),1)
		createc_readimagedata(tempfile, headerstruct)
		fstatus tempfile
		close tempfile
		Debugprintf2("Deleting temp file: "+S_path+S_fileName,1)
		DeleteFile /P=myimportpath  tempfilename
#else
		Debugprintf2("ZIP.XOP needed for decompression.\rDownload it here: http://www.igorexchange.com/project/ZIP",2)
#endif
	endif

	importloader.success = 1
	loaderend(importloader)
end


static function createc_readimagedata(file, headerstruct)
	variable file
	struct createc_headerstruct &headerstruct
	fsetpos file, headerstruct.dataoffset
	variable xsize = 0
	variable ysize = 0
	variable zscale
	variable dacbits = 0
	strswitch(headerstruct.DAcType)
		case "20bit":
			dacbits = 20
			break
		default:
			dacbits = str2num(headerstruct.DAcType[0,strlen(headerstruct.DAcType)-4])
			break
	endswitch

	// calculate scaling
	xsize = headerstruct.Numx * headerstruct.delta_x //dacs
	xsize *= 20.0/(2.0^dacbits) * headerstruct.gain_x // voltage per dac
	xsize *= Angstrom * headerstruct.piezo_x // piezoconstant [A/V]
   	if (!(xsize == abs(xsize)))
   		xsize = 1
   	endif
	ysize = headerstruct.Numy * headerstruct.delta_y //dacs
	ysize *= 20.0/(2.0^dacbits) * headerstruct.gain_y // voltage per dac
	ysize *= Angstrom * headerstruct.piezo_y // piezoconstant [A/V]
   	if (!(ysize == abs(ysize)))
   		ysize = 1
   	endif
   	zscale = 1.0 //unity dac
   	zscale *= 20.0/(2.0^dacbits) *  headerstruct.gain_z //voltage per dac
   	zscale *= Angstrom * headerstruct.piezo_z //piezoconstant [A/V]


	// finally read the image
	variable i=0, m=0,n=0
	headerstruct.channelbit = 1
	for(i=0;i<headerstruct.channels;i+=1)
		do
			if(headerstruct.channelbit>65535)
				headerstruct.channelbit = 0
			endif
			if(!(headerstruct.channelselectval && headerstruct.channelbit && !(headerstruct.channelbit & headerstruct.channelselectval)))
				break
			endif
			//A left shift by 1 position is analogous to multiplying by 2. A right shift is analogous to dividing by 2.
			//headerstruct.channelbit <<= 1 // left shift
			headerstruct.channelbit *=2
		while(headerstruct.channelselectval && headerstruct.channelbit && !(headerstruct.channelbit & headerstruct.channelselectval))

		if(!headerstruct.channelselectval || !headerstruct.channelbit)
			headerstruct.channelbit = 1
		endif
		
		string unit = ""
		string tmps = ""
		if(headerstruct.channelbit & CHANNEL_TOPOGRAPHY)
			unit = "m"
			tmps = "Topography_"+"ch"+num2str(i)
		elseif(headerstruct.channelbit & CHANNEL_CURRENT)
			unit = "A"
			tmps = "Current_"+"ch"+num2str(i)
		else
			unit = "V"
			tmps = "Voltage_"+"ch"+num2str(i)
		endif
		Debugprintf2("... importing image: "+tmps,0)
		Make /O/R/N=(headerstruct.Numx,headerstruct.Numy)  $tmps /wave=image
		switch(headerstruct.bpp)
			case 2:
				Fbinread/B=3/F=2 file, image
				image *=((1/256)^2)
				break
			case 4:
				Fbinread/B=3/F=4 file, image
				break
		endswitch

		// apply scaling
		SetScale/I  x,0,xsize, "m", image
		SetScale/I  y,0,ysize, "m", image
		image *=zscale
		SetScale d,0,0,unit image		
		// add notes
		tmps = headerstruct.header
		note image, tmps
		headerstruct.channelbit *=2
	endfor
end


static function createc_get_version(file)
	variable file
	string identifier = mycleanupstr(myreadline(file))
	if (strsearch(identifier, "[Parameter]", 0) == 0)
		return 1
	elseif (strsearch(identifier, "[Paramet32]", 0) == 0)
		return 2
	elseif (strsearch(identifier, "[Paramco32]", 0) == 0)
		return 3
	endif
	return -1
end
