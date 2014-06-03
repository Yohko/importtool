// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.
Menu "Macros"
	submenu "Import Tool "+importloaderversion
		submenu "PES"
			"Load OmicronSpectra			*.1		file... v1.1", Spectra_load_data()
		end
	end
end


// ###################### Omicron Spectra ########################


function Spectra_check(file)
	variable file
	string line
	line = read_line_trim(file) // first line should be experimentname
	
	line = aufspalten(read_line_trim(file), " ")// second line should be parameters
	if ( strlen(line)==0 || strlen(line) > 200 || itemsinlist(line,"_") != 8)
		return 0
	endif
	line = read_line_trim(file) // third line should be spectrumname
	// check that the next few lines have only single integer number
	variable i=0
	for (i = 0; i != 3; i+=1)
		line = read_line_trim(file)
		if ( strlen(line)==0|| strlen(line) > 30 || numtype(str2num(line)) != 0)
			return 0
		endif
    endfor
    return 1
end


function Spectra_load_data()
	string dfSave=""
	variable file
	string impname="Omicron-Spectra"
	string filestr="*.1,*.2,*.3,*.4,*.5,*.6,*.7,*.8,*.9"
	string header = loaderstart(impname, filestr,file,dfSave)
	if (strlen(header)==0)
		return -1
	endif
	fstatus file
 	variable  AnzahlRegionen = 0
 	string Experimentname = "", Regionname = ""
 	variable importieren = 0
 	string  buffer
	variable Start = 0,Ende = 0,Schrittweite = 0,Scans = 0,Torzeit = 0,Messpunkte = 0,EPass = 0, ExEnergie = 0
 	variable spalte = 0
	variable val = 0
      FReadLine file, Experimentname
	header+="\rExperimentname: "+ cleanup_(Experimentname)

	If (importieren != 1)
		Anzahlregionen = 0		
		Do
		      FReadLine file, buffer
			If (strlen(buffer)==0)
				If (AnzahlRegionen > 0)
					importieren = 2
				else
					importieren = 1
				endif					
				Break  
			Endif
		      	buffer = cleanup_(buffer)
			AnzahlRegionen +=1
			Debugprintf2("Import Region: "+ num2str(AnzahlRegionen),1)
			Debugprintf2("Header: "+buffer,1)
			buffer= aufspalten(buffer," ")

			if (ItemsInList(buffer,"_") != 8)
				importieren = 1
				print buffer
				Debugprintf2("Check parameters in header?",0)
				break
			endif
			Start = str2num(StringFromList(0,buffer,"_"))			
			Debugprintf2("Start: "+StringFromList(0,buffer,"_"),1)
			Ende = str2num(StringFromList(1,buffer,"_"))			
			Debugprintf2("End: "+StringFromList(1,buffer,"_"),1)
			Schrittweite = str2num(StringFromList(2,buffer,"_"))			
			Debugprintf2("Step: "+StringFromList(2,buffer,"_"),1)
			Scans = str2num(StringFromList(3,buffer,"_"))			
			Debugprintf2("Scans: "+StringFromList(3,buffer,"_"),1)
			Torzeit = str2num(StringFromList(4,buffer,"_"))			
			Debugprintf2("Dwelltime: "+StringFromList(4,buffer,"_"),1)
			Messpunkte = str2num(StringFromList(5,buffer,"_"))			
			Debugprintf2("Measpoints: "+StringFromList(5,buffer,"_"),1)
			EPass = str2num(StringFromList(6,buffer,"_"))			
			Debugprintf2("EPass: "+StringFromList(6,buffer,"_"),1)
			ExEnergie = str2num(StringFromList(7,buffer,"_"))			
			Debugprintf2("ExEnergie: "+StringFromList(7,buffer,"_"),1)

		     FReadLine file, Regionname
     	      		if(strlen(buffer) == 0)
				Debugprintf2("Unexpected end of file after header",0)
				importieren = 1
				break
			endif
		     Regionname = cleanup_(Regionname)
		     If (strlen(Regionname)==0)
				importieren = 1
				break
			Endif
			Regionname = cleanname(Regionname)
			Debugprintf2("regionname: " + Regionname,1)
			If (WaveExists($Regionname))
				Debugprintf2("Wave '"+Regionname+"' has been overwritten!",0)
			Endif
			 
			Make /O/R/N=(Messpunkte) $Regionname /wave=Detector
			 spalte = 0
			 do
			  	FReadLine file, buffer
				If (strlen(buffer)==0)
					Debugprintf2("Unexpected end of file in data block!",0)
					importieren = 1
					break
				Endif
		  		buffer = cleanup_(buffer)

				val=str2num(buffer)
				if(numtype(val) != 0)
					Debugprintf2("Error in reading numeric value!",0)
					importieren = 1
					break
				endif
				if(CB_DivLifeTime==true)
					val=val/Torzeit
				endif
				if(CB_DivScans==true)
					val=val/Scans
				endif
				Detector[spalte] = val
			 	spalte +=1
			while (spalte != Messpunkte)
			if (posbinde == 0)
				SetScale/I  x,start-Exenergie,ende-Exenergie,"eV", Detector
			else
				SetScale/I  x,-start+Exenergie,-ende+Exenergie,"eV", Detector
			endif
			Note Detector, header
			Note Detector, "x-axis: binding energy"
			Note Detector, "y-axis: intensity"

			SetScale d, 0,0, "cps", Detector
			Note Detector, "Scans: " + num2str(scans)
			Note Detector, "Step:  "+ num2str(schrittweite) + "eV"
			Note Detector,"Method: XPS"
			Note Detector,"Dwell time: " + num2str(Torzeit)+"s"
			Note Detector,"Excitation energy: " + num2str(ExEnergie)+"eV"
			Note Detector,"Pass energy: " + num2str(EPass)+"eV"
			Debugprintf2("exported: "+Regionname,0)
			if (importieren ==1)
				break
			endif
			Fstatus file
		While (V_logEOF>V_filePOS)
	Endif
	if (importieren == 1)
		print "somthing went wrong!!"
	endif
	if (importieren == 2)
		print "Import succeeded but empty line at the end (bug??)!"
	endif
	loaderend(impname,1,file, dfSave)
end

// ###################### Omicron Spectra END ######################
