// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

// used by:
// - Veeco di CP-II 

#ifdef showmenu
Menu "Macros"
	submenu "Import Tool "+importloaderversion
			submenu "AFM-Microscopes"
				"Load Veeco HDF v3.2			*.hdf	file... b1", VeecoHDF_load_data()
			end
	end
end
#endif

static constant MAGIC_SIZE = 4
static constant Micrometer = 1e-6
static constant HDF4_SD    = 702
//static constant HDF4_PSI     = 0x8001
static constant HDF4_PSIHD   = 0x8009
//static constant HDF4_PSISPEC = 0x800a


static structure DataDescriptor
	variable tagg
	variable ref	
	variable offset
	variable length
	variable data
endstructure


static structure Header
	uint32 unknown1
	char title[32]
	char instrument[8]
	char x_dir //boolean x_dir
	char y_dir //boolean y_dir
	char show_offset //boolean show_offset
	char no_units //boolean no_units
	char spacer[2] //???
	uint16 xres //uint32
	uint16 yres //uint32
	char unknown2[12]
	float xscale //double
	float yscale //double
	float xoff //double
	float yoff //double
	float rotation //double
	float unknown3
	float lines_per_sec //double
	float set_point
	char set_point_unit[8]
	float sample_bias
	float tip_bias
	float zgain
	char zgain_unit[8]
	int16 mymin //int32
	int16 mymax //int32
endstructure


function VeecoHDF_check_file(file)
	variable file
	fsetpos file, 0
	variable offset = MAGIC_SIZE, pos = MAGIC_SIZE
	variable size = 0, found = 0

	pos+=2+4+(2+2+4+4)
	fstatus file
	if(V_logEOF<=10) //check for file size
		return -1
	endif
	
	FsetPos file, offset
	Fbinread/B=2/F=2/U file, size
	if(numtype(size)!=0 && size <=0)
		return -1
	endif
	Fbinread/B=2/F=3/U file, offset
	if(numtype(offset)!=0 && offset <0)
		return -1
	endif
	variable t_tag,t_ref,t_offset,t_length, i, t_data
	for(i=0;i<size;i+=1)
		Fbinread/B=2/U/F=2 file,t_tag
		Fbinread/B=2/U/F=2 file,t_ref
		Fbinread/B=2/U/F=3 file,t_offset
		Fbinread/B=2/U/F=3 file,t_length
		Fstatus file
		t_data=V_filePOS+t_offset
		switch(t_tag)
			case HDF4_PSIHD:
				found +=1
				break
			case HDF4_SD:
				found+=1
				break
		endswitch
		if(found == 2)
			fsetpos file, 0
			return 1
		endif
		pos+=(2+2+4+4)
		fstatus file
		if(V_filepos>=V_logEOF || pos >= V_logEOF) //check for file size
			fsetpos file, 0
			return -1
		endif		
	endfor
	fsetpos file, 0
	if(found !=2)
		return -1
	endif
	return 1
end


function VeecoHDF_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "Hierarchical Data Format"
	importloader.filestr = "*.hdf"
	importloader.category = "AFM"
end


function VeecoHDF_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	VeecoHDF_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file
	VeecoHDF_read(file,header)
	importloader.success = 1
	loaderend(importloader)
end


static function VeecoHDF_read(file,header)
	variable file
	string header
	variable ddb_offset = MAGIC_SIZE
	variable ddb_size=0,i,j,t_tag,t_ref,t_offset,t_length,t_data,tmp
	
	struct  DataDescriptor headerpos
	struct  DataDescriptor imagepos
	String cmd="",tmps
	do
		Debugprintf2("Reading DDB at 0x"+num2str(ddb_offset),1)
		FsetPos file, ddb_offset
		Fbinread/B=2/F=2/U file, ddb_size
		Fbinread/B=2/F=3/U file, ddb_offset
		Debugprintf2("DDB size: "+num2str(ddb_size)+", next offset: 0x"+num2str( ddb_offset),1)
		Fstatus file
		for(i=0;i<ddb_size;i+=1)
			Fbinread/B=2/U/F=2 file,t_tag ; Debugprintf2("Tag: "+num2str(t_tag),1)
			Fbinread/B=2/U/F=2 file,t_ref ; Debugprintf2("Ref: "+num2str(t_ref),1)
			Fbinread/B=2/U/F=3 file,t_offset ; Debugprintf2("Offset: "+num2str(t_offset),1)
			Fbinread/B=2/U/F=3 file,t_length ; Debugprintf2("Length: "+num2str(t_length),1)
			Fstatus file
			t_data=V_filePOS+t_offset
			Debugprintf2("Datastart at: "+num2str(t_data),1)
			// Ignore NULL and invalid tags
			switch(t_tag)
				case HDF4_PSIHD:
					// found header
					headerpos.tagg=t_tag
					headerpos.ref=t_ref
					headerpos.length=t_length
					headerpos.offset=t_offset
					headerpos.data=t_data
					break
				case HDF4_SD:
					//found image in int16
					imagepos.tagg=t_tag
					imagepos.ref=t_ref
					imagepos.offset=t_offset
					imagepos.length=t_length
					imagepos.data=t_data
					break			
			endswitch
		endfor	

		Fstatus file
		if(V_filepos>=V_logEOF || ddb_offset<=0)
			break
		endif
	while(V_logEOF>V_filePOS)
	
	//reading header
	Fsetpos file,headerpos.offset
	struct header fileheader
	FBinread/B=3 file, fileheader

	Debugprintf2("Title: "+fileheader.title,1)
	Debugprintf2("Instrument: "+fileheader.instrument,1)
	Debugprintf2("xdir: "+num2str(fileheader.x_dir),1)
	Debugprintf2("ydir: "+num2str(fileheader.y_dir),1)
	Debugprintf2("Show offset?: "+num2str(fileheader.show_offset),1)
	Debugprintf2("No units?: "+num2str(fileheader.no_units),1)
	Debugprintf2("xres: "+num2str(fileheader.xres),1)
	Debugprintf2("yres: "+num2str(fileheader.yres),1)
	Debugprintf2("xscale: "+num2str(fileheader.xscale),1)
	Debugprintf2("yscale: "+num2str(fileheader.xscale),1)
	Debugprintf2("xoff: "+num2str(fileheader.xoff),1)
	Debugprintf2("yoff: "+num2str(fileheader.yoff),1)
	Debugprintf2("rotation: "+num2str(fileheader.rotation),1)
	Debugprintf2("lines/s: "+num2str(fileheader.lines_per_sec),1)
	Debugprintf2("Set point: "+num2str(fileheader.set_point)+" "+fileheader.set_point_unit,1)
	Debugprintf2("Sample bias: "+num2str(fileheader.sample_bias),1)
	Debugprintf2("Tip bias: "+num2str(fileheader.tip_bias),1)
	Debugprintf2("Zgain: "+num2str(fileheader.zgain)+fileheader.zgain_unit,1)
	Debugprintf2("Min: "+num2str(fileheader.mymin),1)
	Debugprintf2("Max: "+num2str(fileheader.mymax),1)


	//reading image
	tmps=getnameforwave(file)//"rawimage"
	Debugprintf2("... exporting: "+tmps,0)
	Make /O/R/N=(fileheader.xres,fileheader.xres)  $tmps /wave=image
	SetScale/I  x,0,fileheader.xscale, "µm", image
	SetScale/I  y,0,fileheader.xscale, "µm", image

	note image, header
	note image, "Title: "+cleanupname(fileheader.title,1)
	note image, "Instrument: "+cleanupname(fileheader.instrument,1)
	note image, "xdir: "+num2str(fileheader.x_dir)
	note image, "ydir: "+num2str(fileheader.y_dir)
	note image, "Show offset?: "+num2str(fileheader.show_offset)
	note image, "No units?: "+num2str(fileheader.no_units)
	note image, "xres: "+num2str(fileheader.xres)
	note image, "yres: "+num2str(fileheader.yres)
	note image, "xscale: "+num2str(fileheader.xscale)
	note image, "yscale: "+num2str(fileheader.xscale)
	note image, "xoff: "+num2str(fileheader.xoff)
	note image, "yoff: "+num2str(fileheader.yoff)
	note image, "rotation: "+num2str(fileheader.rotation)
	note image, "lines/s: "+num2str(fileheader.lines_per_sec)
	note image, "Set point: "+num2str(fileheader.set_point)+cleanupname(fileheader.set_point_unit,1)
	note image, "Sample bias: "+num2str(fileheader.sample_bias)
	note image, "Tip bias: "+num2str(fileheader.tip_bias)
	note image, "Zgain: "+num2str(fileheader.zgain)+fileheader.zgain_unit

	
	Fsetpos file,imagepos.offset
	Fbinread/B=3/F=2 file, image
	Duplicate/FREE image, imagetemp
	image[][]=imagetemp[p][DimSize(image, 1)-q-1] // we have to mirror the wave to get the original image
	return 0
end

