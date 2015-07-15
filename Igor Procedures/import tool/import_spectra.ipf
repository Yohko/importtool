// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

// Supports:
// - Omicron SPECTRA-Presenter
// - Presenter (SPECTRA files)
// - SPECS LHS (*.#) ??

function Spectra_check_file(file)
	variable file
	fsetpos file, 0
	string line = ""
	line = read_line_trim(file)// first line should be experimentname
	line = splitintolist(read_line_trim(file), " ")// second line should be parameters
	if ( strlen(line)==0 || strlen(line) > 200 || (itemsinlist(line,"_") != 8 && itemsinlist(line,"_") != 7))
		fsetpos file, 0
		return -1
	endif
	line = read_line_trim(file)// third line should be spectrumname
	// check that the next few lines have only single integer number
	variable i=0
	for (i = 0; i != 3; i+=1)
		line = read_line_trim(file)
		if ( strlen(line)==0|| strlen(line) > 30 || numtype(str2num(line)) != 0)
			fsetpos file, 0
			return -1
		endif
		fstatus file
		if(V_logEOF<=V_filePOS)
			fsetpos file, 0
			return -1
		endif
    endfor
    fsetpos file, 0
    return 1
end


function Spectra_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "Omicron-Spectra"
	importloader.filestr = "*.1,*.2,*.3,*.4,*.5,*.6,*.7,*.8,*.9,*.dat"
	importloader.category = "PES"
end


function Spectra_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	Spectra_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file
	fstatus file
 	variable nregions = 0
 	string Experimentname = "", Regionname = ""
 	variable importieren = 0
 	string  buffer
	variable sweepStart = 0,sweepEnd = 0,evPerStep = 0,Scans = 0,Dwelltime = 0,nstep = 0,EPass = 0, ExEnergy = 0
 	variable i = 0
	variable val = 0
	FReadLine file, Experimentname
	header+="\rExperimentname: "+ mycleanupstr(Experimentname)

	If (importieren != 1)
		nregions = 0
		Do
			FReadLine file, buffer
			If (strlen(buffer)==0)
				If (nregions > 0)
					importieren = 2
				else
					importieren = 1
				endif					
				Break  
			Endif
			buffer = mycleanupstr(buffer)
			nregions +=1
			Debugprintf2("Import Region: "+ num2str(nregions),1)
			Debugprintf2("Header: "+buffer,1)
			buffer= splitintolist(buffer," ")

			if (ItemsInList(buffer,"_") != 8 && ItemsInList(buffer,"_") != 7)
				importieren = 1
				Debugprintf2("Check parameters in header?",0)
				break
			endif
			sweepStart = str2num(StringFromList(0,buffer,"_"))
			Debugprintf2("Start: "+StringFromList(0,buffer,"_"),1)
			sweepEnd = str2num(StringFromList(1,buffer,"_"))
			Debugprintf2("End: "+StringFromList(1,buffer,"_"),1)
			evPerStep = str2num(StringFromList(2,buffer,"_"))
			Debugprintf2("Step: "+StringFromList(2,buffer,"_"),1)
			Scans = str2num(StringFromList(3,buffer,"_"))
			Debugprintf2("Scans: "+StringFromList(3,buffer,"_"),1)
			Dwelltime = str2num(StringFromList(4,buffer,"_"))
			Debugprintf2("Dwelltime: "+StringFromList(4,buffer,"_"),1)
			nstep = str2num(StringFromList(5,buffer,"_"))
			Debugprintf2("Measpoints: "+StringFromList(5,buffer,"_"),1)
			EPass = str2num(StringFromList(6,buffer,"_"))
			Debugprintf2("EPass: "+StringFromList(6,buffer,"_"),1)
			if(itemsinlist(buffer,"_") == 8)
				ExEnergy = str2num(StringFromList(7,buffer,"_"))
				Debugprintf2("ExEnergy: "+StringFromList(7,buffer,"_"),1)
			else
				ExEnergy = 0
				Debugprintf2("No ExEnergy in file!",1)
			endif

			FReadLine file, Regionname
			if(strlen(buffer) == 0)
				Debugprintf2("Unexpected end of file after header",0)
				importieren = 1
				break
			endif
			Regionname = mycleanupstr(Regionname)
			If (strlen(Regionname)==0)
				Debugprintf2("Empty region name!",1)
				Regionname = "Spectra_"+num2str(nregions)
			Endif
			Regionname = cleanname(Regionname)
			Debugprintf2("regionname: " + Regionname,1)
			If (WaveExists($Regionname))
				Debugprintf2("Wave '"+Regionname+"' has been overwritten!",0)
			Endif
			 
			Make /O/R/N=(nstep) $Regionname /wave=Detector
			 i = 0
			 do
			  	FReadLine file, buffer
				If (strlen(buffer)==0)
					Debugprintf2("Unexpected end of file in data block!",0)
					importieren = 1
					break
				Endif
		  		buffer = mycleanupstr(buffer)

				val=str2num(buffer)
				if(numtype(val) != 0)
					Debugprintf2("Error in reading numeric value!",0)
					importieren = 1
					break
				endif
				if(str2num(get_flags(f_divbytime))==true)
					val=val/Dwelltime
				endif
				if(str2num(get_flags(f_divbyNscans))==true)
					val=val/Scans
				endif
				Detector[i] = val
			 	i +=1
			while (i != nstep)
			if(str2num(get_flags(f_posEbin)) == 0)
				if(ExEnergy != 0)
					SetScale/I  x,sweepStart-ExEnergy,sweepEnd-ExEnergy,"eV", Detector
				else
					// ExEnergy was not given and start and end are positive binding energy
					SetScale/I  x,-sweepStart,-sweepEnd,"eV", Detector
				endif
			else
				if(ExEnergy != 0)
					SetScale/I  x,-sweepStart+ExEnergy,-sweepEnd+ExEnergy,"eV", Detector
				else
					// ExEnergy was not given and start and end are positive binding energy
					SetScale/I  x,sweepStart,sweepEnd,"eV", Detector
				endif
			endif
			Note Detector, header
			Note Detector, "x-axis: binding energy"
			Note Detector, "y-axis: intensity"

			SetScale d, 0,0, "cps", Detector
			Note Detector, "Scans: " + num2str(scans)
			Note Detector, "Step:  "+ num2str(evPerStep) + "eV"
			Note Detector,"Method: XPS"
			Note Detector,"Dwell time: " + num2str(Dwelltime)+"s"
			Note Detector,"Excitation energy: " + num2str(ExEnergy)+"eV"
			Note Detector,"Pass energy: " + num2str(EPass)+"eV"
			
			if(str2num(get_flags(f_includeTF)) == 1&& str2num(get_flags(f_onlyDET))==0)
				Spectra_calcTF(ExEnergy, detector)
			endif
			
			Debugprintf2("exported: "+Regionname,0)
			if (importieren ==1)
				break
			endif
			Fstatus file
		While(V_logEOF>V_filePOS)
	Endif
	if (importieren == 1)
		Debugprintf2("Something went wrong!",0)
	endif
	if (importieren == 2)
		Debugprintf2("Import succeeded but empty line at the end (bug??)!",0)
	endif
	importloader.success = 1
	loaderend(importloader)
end


static function Spectra_calcTF(energy, detector)
	variable energy
	wave detector
	if(energy==0)
		return -1
	endif
	string tmps = nameofwave(detector)+"TF"
	duplicate detector, $tmps
	wave TF = $tmps
	variable maxx=pnt2x(detector, 0)
	variable posbind = 1
	if(str2num(get_flags(f_posEbin)) == 0)
		posbind = -1
	else		
		posbind = 1
	endif
	variable maxy=detector[0]
	variable ec = 0.28 //energy correction factor
	TF[] = ((maxy*((energy-posbind*maxx)^ec)/maxy))/((energy-posbind*x)^ec)
	return 0
end
