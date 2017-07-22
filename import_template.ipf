// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

// template for adding new file types:
// 
// 
// - "template_check_file(file)"	procedure to detect file type
// - "template_load_data_info(importloader)"	contains infos about file and is used to add new file types to the gui
// - "template_load_data([optfile])"		main procedure which is called to load the data
//
//	- change "template" in the procedure names to something else which is not used by other loaders


function template_check_file(file) // change "template" to something else
	variable file
	fsetpos file, 0

	variable is_valid_file = 0

	if(is_valid_file) // detected file
			fsetpos file, 0
			return 1
	else	// didn't detect file
			fsetpos file, 0
			return -1	
	endif

	fsetpos file, 0
	return -1
end


function template_load_data_info(importloader)  // change "template" to something else
	struct importloader &importloader
	importloader.name = "template" // name of file type
	importloader.filestr = "*.txt,*.dat" // file extensions (no *.*)
	importloader.category = "PES"	// category of file, e.g. XRD, PES, GC, AFM...
end


function template_load_data([optfile]) // change "template" to something else
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	template_load_data_info(importloader) // change "template" to something else
	if(loaderstart(importloader, optfile=optfile)!=0) // load file
		return -1
	endif
	string header = importloader.header // some infos about the file which can be attached as a note to the waves
	variable file = importloader.file // refernce to the data file


	// a new subdirectory was already created and set as the active data folder
	
	// import flags can be accessed via (see import_loader.ipf for details):

	// get_flags(f_includeADC)	//includeADC
	// get_flags(f_divbyNscans)	// CB_DivScans
	// get_flags(f_divbytime)	// CB_DivLifeTime
	// get_flags(f_divbygain)	// DivDetectorGain
	// get_flags(f_interpolate)	// Interpolieren
	// get_flags(f_includeNDET)	// ChanneltronEinzeln
	// get_flags(f_suffix)	// suffix
	// get_flags(f_posEbin)	//posbinde
	// get_flags(f_includeNscans)	// singlescans
	// get_flags(f_importtoroot)	// importtoroot
	// get_flags(f_converttoWN)	// converttoWN
	// get_flags(f_includeTF)	// includetransmission
	// get_flags(f_vsEkin)	// vskineticenergy
	// get_flags(f_askforEXT)	//askforappenddet
	// get_flags(f_askforwaveprefix)
	// get_flags(f_onlyDET)	//justdetector
	// get_flags(f_divbyTF)	// f_DivTF
	// get_flags(f_askforE)	// f_askenergy


	// in case something goes wrong:
	
	// importloader.success = 0
	// loaderend(importloader)
	//	return -1


	importloader.success = 1
	loaderend(importloader)
end
