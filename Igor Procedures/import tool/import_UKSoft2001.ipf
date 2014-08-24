// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// This implementation is based on:
// https://github.com/michaf/Gxsm-2.0/blob/23ad6ae2b9d400bff2495412fe33276492fa91bb/plug-ins/scan/uksoft2001_im_export.C
// https://github.com/codedump/paul/blob/fd832f22b44ccb6ff33d013856d259e06378be3d/paul/loader/elmitec.py


static structure UKSOFT2001_FileHeader // size: 104
	char id[20]
	int16 size
	int16 version
	int16 BitsPerPixel
	char align8[6]
	//int64 starttime
	int32 starttime1
	int32 starttime2
	int16 ImageWidth
	int16 ImageHeight
	int16 NrImages
	int16 attachedRecipeSize	// --> Size of attached recipe data (up to 128 bytes); only if > 0; 128byte block present
	char spare[56]
endstructure


static structure UKSOFT2001_ImageHeader // size: 48; version < 5
	int16 size
	int16 version
	//char align8[4]
	int16 colorScaleLow
	int16 colorScaleHigh
	//int64 imagetime // 64 bit value with the number of 100ns units since 1. January 1601
	int32 imagetime1
	int32 imagetime2
	int32 LEEMdata1_source
	float LEEMdata1_data
	int16 spin
	int16 spareShort // leemDataVersion??
	float LEEMdata2_data
	char spare[16]
endstructure


static structure UKSOFT2001_ImageHeaderv5 // size: 288; version >= 5
	int16 size
	int16 version
	//char align8[4]
	int16 colorScaleLow
	int16 colorScaleHigh
	//int64 imagetime // 64 bit value with the number of 100ns units since 1. January 1601
	int32 imagetime1
	int32 imagetime2
	int16 maskXShift
	int16 maskYShift
	char useMask
	char spare0
	int16 attachedMarkupSize // ImageMarkup block (attached to ImageHeader+LeemData if ImageHeader.attacehdMarkupSize > 0)
	//char spare[8]
	int16 spin
	int16 LEEMdataVersion
	char LEEMdata[256]
	char space[4]
endstructure


static function uksoft2001_LDgetfloat(imageheaderv5, offset)
	struct UKSOFT2001_ImageHeaderv5 &imageheaderv5
	variable &offset

	struct myflt myflt
	struct fourbytes myfloat
	myfloat.bytes[0] = imageheaderv5.LEEMdata[offset+1]
	myfloat.bytes[1] = imageheaderv5.LEEMdata[offset+2]
	myfloat.bytes[2] = imageheaderv5.LEEMdata[offset+3]
	myfloat.bytes[3] = imageheaderv5.LEEMdata[offset+4]
	StructGet /S /B =3 myflt, myfloat.bytes
	offset+=4
	return myflt.val
end


static function /S uksoft2001_LDgetstring(imageheaderv5, offset, len)
	struct UKSOFT2001_ImageHeaderv5 &imageheaderv5
	variable &offset
	variable len
	
	variable k
	string tmps = ""
	struct LDarg arg
	for(k=offset+1;k<len+offset+1;k+=1)
		if(imageheaderv5.LEEMdata[k] >= 32 && imageheaderv5.LEEMdata[k] < 255)
			arg.arg[k-offset-1] = imageheaderv5.LEEMdata[k]
		else
			break
		endif
		if(k==255)
			break
		endif
	endfor
	structput /S arg, tmps
	tmps = tmps[0,k-offset-2]
	offset += k-offset // there is a trailing 0

	return tmps
end


function uksoft2001_check_file(file)
	variable file
	fsetpos file, 0
	string ID = mybinread(file, 20)
	fsetpos file, 0
	if(cmpstr(ID,"UKSOFT2001",1)!=0)
		return -1
	endif
	return 1
end


function uksoft2001_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "UKSOFT2001" // (UView) image data files (CCD/ELMITEC-LEEM)
	importloader.filestr = "*.dat,*.dav"
	importloader.category = "PEEM"
end


function uksoft2001_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	uksoft2001_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	variable file = importloader.file
	string header = importloader.header
	
	string tmps = ""

	struct UKSOFT2001_FileHeader fileheader
	struct UKSOFT2001_ImageHeader imageheader
	struct UKSOFT2001_ImageHeaderv5 imageheaderv5
	
	// now start importing
	Fbinread file, fileheader // read header
	uksoft2001_get_time(fileheader.starttime1, fileheader.starttime2)

	// file type check
	if(cmpstr(fileheader.id,"UKSOFT2001",1)!=0)
		Debugprintf2("Wrong file. Got "+ fileheader.id+" instead of UKSOFT2001.",0)
		loaderend(importloader)
		return -1
	endif


	if(fileheader.version >= 7 && fileheader.attachedRecipeSize > 0)
		mybinread(file, fileheader.attachedRecipeSize) // just skipping for now
	endif



	variable i=0
	// reading the images
	for(i = 0; i < fileheader.NrImages; i+=1)
		if(fileheader.version < 5)
			Fbinread file, imageheader // read image header
			uksoft2001_get_time(imageheader.imagetime1, imageheader.imagetime2)
		else
			Fbinread file, imageheaderv5// read image header
			uksoft2001_get_time(imageheaderv5.imagetime1, imageheaderv5.imagetime2)
		endif
		
		// read the image
		tmps="image"+num2str(i)
		Make /O/R/N=(fileheader.ImageWidth,fileheader.ImageHeight)  $tmps /wave=imagewave
		switch(fileheader.BitsPerPixel)
			case 16:
				Fbinread /F=2 file, imagewave
				break
			default:
				Debugprintf2(num2str(fileheader.BitsPerPixel)+"Bits per Pixel not implemented yet!",0)
				loaderend(importloader)
				return -1				
		endswitch
		
		// save notes
		note imagewave, header
		note imagewave, "Image Number: "+num2str(i)
		note imagewave, "Start Time: "+num2str(fileheader.starttime1)
		note imagewave, "Image Width: "+num2str(fileheader.ImageWidth)
		note imagewave, "Image Height: "+num2str(fileheader.ImageHeight)
		note imagewave, "Nr Images: "+num2str(fileheader.NrImages)
		if (fileheader.version < 5)
			note imagewave, "Image Size: "+num2str(imageheader.size)
			note imagewave, "Image Version: "+num2str(imageheader.version)
			note imagewave, "image Time: "+num2str(imageheader.imagetime1)
		else
			note imagewave, "Image Size: "+num2str(imageheaderv5.size)
			note imagewave, "Image Version: "+num2str(imageheaderv5.version)
			note imagewave, "Image Time:"+num2str(imageheaderv5.imagetime1)
			note imagewave, "Image spin: "+num2str(imageheaderv5.spin)
			note imagewave, "Image LEEMdataVers: "+num2str(imageheaderv5.LEEMdataVersion)
			variable j=0, tmpd=0

			for(j=0;j<256;j+=1)
				tmpd = imageheaderv5.LEEMdata[j]

				switch(tmpd)
					case -1://255://0xff:
						j=256
						break
					case 2: // #Module #2 [mA]
						note imagewave, uksoft2001_LDgetstring(imageheaderv5, j,64)+" ("+num2str(tmpd)+"): "+num2str(uksoft2001_LDgetfloat(imageheaderv5, j))
						break
					case 3: // #Module #3 [mA]
						note imagewave, uksoft2001_LDgetstring(imageheaderv5, j,64)+" ("+num2str(tmpd)+"): "+num2str(uksoft2001_LDgetfloat(imageheaderv5, j))
						break
					case 11:
						note imagewave, uksoft2001_LDgetstring(imageheaderv5, j,64)+" ("+num2str(tmpd)+"): "+num2str(uksoft2001_LDgetfloat(imageheaderv5, j))
						break					
					case 19:
						note imagewave, uksoft2001_LDgetstring(imageheaderv5, j,64)+" ("+num2str(tmpd)+"): "+num2str(uksoft2001_LDgetfloat(imageheaderv5, j))
						break
					case 21:
						note imagewave, uksoft2001_LDgetstring(imageheaderv5, j,64)+" ("+num2str(tmpd)+"): "+num2str(uksoft2001_LDgetfloat(imageheaderv5, j))
						break					
					case 38: // #Module #38 [V]
						note imagewave, uksoft2001_LDgetstring(imageheaderv5, j,64)+" ("+num2str(tmpd)+"): "+num2str(uksoft2001_LDgetfloat(imageheaderv5, j))
						break
					case 39: // #Module #39 [C] + User Temp. Offset
						note imagewave, uksoft2001_LDgetstring(imageheaderv5, j,64)+" ("+num2str(tmpd)+"): "+num2str(uksoft2001_LDgetfloat(imageheaderv5, j))
						break
					case 100:
						note imagewave, "Pos X [µm]: "+num2str(uksoft2001_LDgetfloat(imageheaderv5, j))
						note imagewave, "Pos Y [µm]: "+num2str(uksoft2001_LDgetfloat(imageheaderv5, j))
						break
					case 101:
						note imagewave, "Field Of View: "+uksoft2001_LDgetstring(imageheaderv5, j,64)
						break
					case 102:
						note imagewave, "Varian Gauge #1: "+num2str(uksoft2001_LDgetfloat(imageheaderv5, j))
						break
					case 103:
						note imagewave, "Varian Gauge #2: "+num2str(uksoft2001_LDgetfloat(imageheaderv5, j))
						break
					case 104:
						note imagewave, "Camera Exposure Time [ms]: "+num2str(uksoft2001_LDgetfloat(imageheaderv5, j)) // 'ms' or 's' ??
						break
					case 105:
						note imagewave, "Title: "+uksoft2001_LDgetstring(imageheaderv5, j,64)
						break
					case 106:
						note imagewave, "Varian#1 Gauge#1: "+uksoft2001_LDgetstring(imageheaderv5, j,64)+ " ["+uksoft2001_LDgetstring(imageheaderv5, j,64)+"]: "+num2str(uksoft2001_LDgetfloat(imageheaderv5, j))
						break
					case 107:
						note imagewave, "Varian#1 Gauge#2: "+uksoft2001_LDgetstring(imageheaderv5, j,64)+ " ["+uksoft2001_LDgetstring(imageheaderv5, j,64)+"]: "+num2str(uksoft2001_LDgetfloat(imageheaderv5, j))
						break
					case 108:
						note imagewave, "Varian#2 Gauge#1: "+uksoft2001_LDgetstring(imageheaderv5, j,64)+ " ["+uksoft2001_LDgetstring(imageheaderv5, j,64)+"]: "+num2str(uksoft2001_LDgetfloat(imageheaderv5, j))
						break
					case 109:
						note imagewave, "Varian#2 Gauge#2: "+uksoft2001_LDgetstring(imageheaderv5, j,64)+ " ["+uksoft2001_LDgetstring(imageheaderv5, j,64)+"]: "+num2str(uksoft2001_LDgetfloat(imageheaderv5, j))
						break
					case 110:
						note imagewave, "FOV, Camera to FOV cal. factor: "+uksoft2001_LDgetstring(imageheaderv5, j,64)+" , "+num2str(uksoft2001_LDgetfloat(imageheaderv5, j))
						break
					case 111:
						note imagewave, "Phi: "+num2str(uksoft2001_LDgetfloat(imageheaderv5, j))
						note imagewave, "Theta: "+num2str(uksoft2001_LDgetfloat(imageheaderv5, j))
						break
					case 112:
						note imagewave, "Spin: "+num2str(uksoft2001_LDgetfloat(imageheaderv5, j))
						break
					default:
						if(tmpd < 100)
							Debugprintf2("Unknown!",0)
							note imagewave, uksoft2001_LDgetstring(imageheaderv5, j,64)+" ("+num2str(tmpd)+"): "+num2str(uksoft2001_LDgetfloat(imageheaderv5, j))
						else
							Debugprintf2("Error",0)
						endif
						break
				endswitch
				
			endfor
		endif
	endfor

	importloader.success = 1
	loaderend(importloader)
end


static Structure LDarg
 	char arg[64]
endstructure


static function uksoft2001_get_time(lowWord, highWord)
	variable lowWord, highWord
	
end

