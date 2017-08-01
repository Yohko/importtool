// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.


static structure OMNICSPA_param
	string header
	string spectrum_name
	variable nSpectra
	variable nblock
	wave w_blockType
	wave w_blockOffset
	wave w_blockLength
	wave w_data
	wave w_data102
	wave w_data103
	string comments
	string infos
	struct OMNICSPA_SpectrumHeader SpectrumHeader
	struct OMNICSPA_BenchInfo BenchInfo
	struct OMNICSPA_AFFTHeader AFFTHeader
endstructure


structure OMNICSPA_SpectrumHeader
	variable DataType_ID // 3=Sample
	variable NumPoints
	variable XUnits_ID // 1=Wavenumbers (cm-1)
	variable YUnits_ID // 16=% Transmission;17=Absorbance
	variable FirstX
	variable LastX
	variable Noise
	variable NumScanPts
	variable FinalPeakPos	
	variable NumScans
	variable InterpPeak
	variable NumTransformPts
	variable NumPostPeakPts
	variable BKNumScans
	variable BKGain
	variable ApodID // 0=Happ-Genzel;5=Norton-Beer, medium
	variable ApodValue
	variable Duration
	variable BurstPeakHeight
	variable PhaseCorrID // 0=Mertz
	variable LaserFreq
	variable SSP
	variable ApertureRef
	variable Aperture
	variable RamanFreq
	variable StageX
	variable StageY
	variable StageZ
	variable Flags
	variable OldYUnits
	variable OldType
endstructure


structure OMNICSPA_BenchInfo
	variable BenchID // 29=Magnum 550;115=Unknown
	variable DetectorID // 1=MCT/A;10=DTGS KBr;12=DTGS KRS5
	variable BeamSplitID // 1=GE KBr
	variable SourceID // 2=IR Source
	variable ADBits
	variable HPF
	variable LPF
	variable SwitchGainHi
	variable SwitchGainLo
	variable SwitchGainP1
	variable SwitchGainP2
	variable Gain
	variable Velocity
	variable AccessoryID
endstructure


structure OMNICSPA_AFFTHeader // Archived Interferogram Header
	variable NumPoints
	variable NumScans
	variable Noise
	variable InterpPeak
	variable FinalPeakPos
	variable Laser
endstructure


function OMNICSPA_check_file(file)
	variable file
	fsetpos file, 0
	string tmps = mybinread(file, 18)
	fsetpos file, 0	
	if(cmpstr(tmps,"Spectral Data File")!=0)
		return -1
	endif
	return 1
end


function OMNICSPA_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "Nicolet OMNIC"
	importloader.filestr = "*.spa"
	importloader.category = "FTIR"
end


function OMNICSPA_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	OMNICSPA_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file

	struct OMNICSPA_param param
	OMNICSPA_init_param(param)
	param.header = header

	variable tmp, i
	string tmps

	mybinread(file, 18) // "Spectral Data File"
	fbinread /B=3 /f=3 file, tmp//; print tmp // ??
	fbinread /B=3 /f=3 file, tmp//; print tmp // ??
	fbinread /B=3 /f=3 file, tmp//; print tmp // ??
	param.spectrum_name = mycleanupstr(mybinread(file, 256))
	fbinread /B=3 /f=2 file, tmp//; print tmp // ??
	fbinread /B=3 /f=2 file, tmp//; print tmp // ??
	fbinread /B=3 /f=2 file, tmp//; print tmp // ??
	fbinread /B=3 /f=2 file, param.nSpectra
	fbinread /B=3 /f=2 file, param.nblock
	mybinread(file, 8) // skip to 304

	Make /FREE/O/D/N=(param.nblock) w_blockType ; wave param.w_blockType = w_blockType
	Make /FREE/O/D/N=(param.nblock) w_blockOffset ; wave param.w_blockOffset = w_blockOffset
	Make /FREE/O/D/N=(param.nblock) w_blockLength ; wave param.w_blockLength = w_blockLength

	// get type, position and length of data blocks
	for(i=0;i<param.nblock;i+=1)
		// each entry is 16byte
		FBinRead/B=3 /F=2 file, tmp; param.w_blockType[i] = tmp
		FBinRead/B=3 /F=3 file, tmp; param.w_blockOffset[i] = tmp
		FBinRead/B=3 /F=3 file, tmp; param.w_blockLength[i] = tmp
		mybinread(file, 6) // skip last few empty bytes
	endfor

	// now load data of each individual block
	for(i=0;i<param.nblock;i+=1)
		switch(param.w_blockType[i])
			case 2: // Spectrum Header (length: 140)
				Debugprintf2("Reading Spectrum Header Block at "+num2str(param.w_blockOffset[i])+"; length: "+num2str(param.w_blockLength[i]),1)
				fsetpos file, param.w_blockOffset[i]
				OMNICSPA_read_SpectrumHeader(file, param)
				break
			case 3: // spectrum
				Debugprintf2("Reading Data Block at "+num2str(param.w_blockOffset[i])+"; length: "+num2str(param.w_blockLength[i]),1)
				fsetpos file, param.w_blockOffset[i]
				// numpoints = param.w_blockLength[i]/4
				tmps = cleanname(param.spectrum_name)
				Make /O/D/N=(param.SpectrumHeader.NumPoints)  $tmps; wave param.w_data = $tmps
				OMNICSPA_read_wave(file, param.w_data) // because fbinread with a struct wave doesn't work
				break
			case 4: // Annotation
				Debugprintf2("Reading Annotation Block at "+num2str(param.w_blockOffset[i])+"; length: "+num2str(param.w_blockLength[i]),1)
				fsetpos file, param.w_blockOffset[i]
				do
					freadline /T=(num2char(0)) file, tmps
					param.comments += tmps[0, strlen(tmps)-2]
					fstatus file
				while((param.w_blockOffset[i]+param.w_blockLength[i])>V_filePOS)
				break
			case 27: // History
				Debugprintf2("Reading History Block at "+num2str(param.w_blockOffset[i])+"; length: "+num2str(param.w_blockLength[i]),1)
				fsetpos file, param.w_blockOffset[i]
				do
					freadline /T=(num2char(0)) file, tmps
					param.infos += stripstrfirstlastspaces(tmps[0, strlen(tmps)-2])+"\r"
					fstatus file
				while((param.w_blockOffset[i]+param.w_blockLength[i])>V_filePOS)
				break
			case 100:
				Debugprintf2("Reading 100 Block at "+num2str(param.w_blockOffset[i])+"; length: "+num2str(param.w_blockLength[i]),1)
				fsetpos file, param.w_blockOffset[i]
				break
			case 101: // Archived Background Interferogram Header (length: 24)
				Debugprintf2("Reading Archived Background Interferogram Header Block at "+num2str(param.w_blockOffset[i])+"; length: "+num2str(param.w_blockLength[i]),1)
				fsetpos file, param.w_blockOffset[i]
				OMNICSPA_read_ABGFFTHeader(file, param)
				break
			case 102: // Archived sample interferogram
				Debugprintf2("Reading Archived sample interferogram Block at "+num2str(param.w_blockOffset[i])+"; length: "+num2str(param.w_blockLength[i]),1)
				fsetpos file, param.w_blockOffset[i]
				tmp = param.w_blockLength[i]/4 // param.ABGFFTHeader.NumPoints
				tmps = "sampleFFT"
				Make /O/D/N=(tmp)  $tmps; wave param.w_data102 = $tmps
				OMNICSPA_read_wave(file, param.w_data102) // because fbinread with a struct wave doesn't work
				break
			case 103: // Archived background interferogram (looks like a FFT?); Unit: VOLTS?
				Debugprintf2("Reading Archived background interferogram Block at "+num2str(param.w_blockOffset[i])+"; length: "+num2str(param.w_blockLength[i]),1)
				fsetpos file, param.w_blockOffset[i]
				tmp = param.w_blockLength[i]/4 // param.AFFTHeader.NumPoints
				tmps = "BGFFT"
				Make /O/D/N=(tmp)  $tmps; wave param.w_data103 = $tmps
				OMNICSPA_read_wave(file, param.w_data103) // because fbinread with a struct wave doesn't work
				break
			case 105: // History Bits
				Debugprintf2("Reading History Bits Block at "+num2str(param.w_blockOffset[i])+"; length: "+num2str(param.w_blockLength[i]),1)
				fsetpos file, param.w_blockOffset[i]
				fbinread /B=3/F=3 file, tmp//; print tmp
				fbinread /B=3/F=3 file, tmp//; print tmp
				fbinread /B=3/F=3 file, tmp//; print tmp
				break
			case 106: // Bench Info  (length: 56)
				Debugprintf2("Reading Bench Info Block at "+num2str(param.w_blockOffset[i])+"; length: "+num2str(param.w_blockLength[i]),1)
				fsetpos file, param.w_blockOffset[i]
				OMNICSPA_read_BenchInfo(file, param)
				break
			case 107:
				Debugprintf2("Reading 107 Block at "+num2str(param.w_blockOffset[i])+"; length: "+num2str(param.w_blockLength[i]),1)
				fsetpos file, param.w_blockOffset[i]
				break
			case 130: // can also appear more than once!
				Debugprintf2("Reading 130 Block at "+num2str(param.w_blockOffset[i])+"; length: "+num2str(param.w_blockLength[i]),1)
				fsetpos file, param.w_blockOffset[i]
				break
			case 146: // some text?
				Debugprintf2("Reading 146 Block at "+num2str(param.w_blockOffset[i])+"; length: "+num2str(param.w_blockLength[i]),1)
				fsetpos file, param.w_blockOffset[i]
				do
					freadline /T=(num2char(0)) file, tmps
					//print tmps[0, strlen(tmps)-2]
					fstatus file
				while((param.w_blockOffset[i]+param.w_blockLength[i])>V_filePOS)
				break
			case 339: // some text (History)
				Debugprintf2("Reading 339 Block at "+num2str(param.w_blockOffset[i])+"; length: "+num2str(param.w_blockLength[i]),1)
				fsetpos file, param.w_blockOffset[i]
				do
					freadline /T=(num2char(0)) file, tmps
					//print tmps[0, strlen(tmps)-2]
					fstatus file
				while((param.w_blockOffset[i]+param.w_blockLength[i])>V_filePOS)
				break
			case 384:
				Debugprintf2("Reading 384 Block at "+num2str(param.w_blockOffset[i])+"; length: "+num2str(param.w_blockLength[i]),1)
				fsetpos file, param.w_blockOffset[i]
				break
			default:
				Debugprintf2("Unknown type: "+num2str(param.w_blockType[i]),0)
				Debugprintf2("Skipping Block.",0)
				break
		endswitch
	
	endfor
	
	// add notes to data
	note param.w_data, header
	note param.w_data, "Comments: "+param.comments
	note param.w_data, ""+param.infos

	string x_unit = "", y_unit = ""
	switch(param.SpectrumHeader.XUnits_ID)
		case 1:
			x_unit = "cm^-1"
			break
		default:
			break
	endswitch

	switch(param.SpectrumHeader.YUnits_ID)
		case 16:
			y_unit = "% Transmission"
		case 17:
			y_unit = "Absorbance"
			break
		default:
			break
	endswitch

	SetScale /I x,param.SpectrumHeader.FirstX,param.SpectrumHeader.LastX,x_unit, param.w_data
	SetScale d 0,100,y_unit, param.w_data

	importloader.success = 1
	loaderend(importloader)
end


static function OMNICSPA_init_param(param)
	struct OMNICSPA_param &param
	param.comments = ""
	param.infos = ""
end


static function OMNICSPA_read_wave(file, w)
	variable file
	wave &w
	FBinRead /B=3/F=4 file, w
end


static function OMNICSPA_read_SpectrumHeader(file, param)
	variable file
	struct OMNICSPA_param &param
	variable tmp
	fbinread /B=3 /f=3 file, param.SpectrumHeader.DataType_ID // 0
	FBinRead /B=3 /F=3 file, param.SpectrumHeader.NumPoints // 4
	fbinread /B=3 /f=3 file, param.SpectrumHeader.XUnits_ID // 8
	fbinread /B=3 /f=3 file, param.SpectrumHeader.YUnits_ID //  12
	fbinRead /B=3 /F=4 file, param.SpectrumHeader.FirstX // 16
	fbinRead /B=3 /F=4 file, param.SpectrumHeader.LastX // 20
	fbinread /B=3 /f=4 file, param.SpectrumHeader.Noise // 24
	fbinread /B=3 /f=3 file, param.SpectrumHeader.NumScanPts // 28
	fbinread /B=3 /f=3 file, param.SpectrumHeader.FinalPeakPos //32
	FBinRead /B=3 /F=3 file, param.SpectrumHeader.NumScans // 36
	fbinread /B=3 /f=4 file, param.SpectrumHeader.InterpPeak // 40
	FBinRead /B=3 /F=3 file, param.SpectrumHeader.NumTransformPts // 44
	FBinRead /B=3 /F=3 file, param.SpectrumHeader.NumPostPeakPts // 48
	FBinRead /B=3 /F=3 file, param.SpectrumHeader.BKNumScans // 52
	FBinRead /B=3 /F=4 file, param.SpectrumHeader.BKGain // 56
	FBinRead /B=3 /F=3 file, param.SpectrumHeader.ApodID // 60
	FBinRead /B=3 /F=3 file, param.SpectrumHeader.ApodValue // 64
	FBinRead /B=3 /F=3 file, param.SpectrumHeader.Duration // 68
	FBinRead /B=3 /F=4 file, param.SpectrumHeader.BurstPeakHeight // 72
	FBinRead /B=3 /F=3 file, param.SpectrumHeader.PhaseCorrID // 76
	FBinRead /B=3 /F=4 file, param.SpectrumHeader.LaserFreq // 80
	FBinRead /B=3 /F=4 file, param.SpectrumHeader.SSP // 84
	FBinRead /B=3 /F=4 file, param.SpectrumHeader.ApertureRef // 88
	FBinRead /B=3 /F=4 file, param.SpectrumHeader.Aperture // 92
	FBinRead /B=3 /F=4 file, param.SpectrumHeader.RamanFreq // 96
	FBinRead /B=3 /F=4 file, param.SpectrumHeader.StageX // 100
	FBinRead /B=3 /F=4 file, param.SpectrumHeader.StageY // 104
	FBinRead /B=3 /F=4 file, param.SpectrumHeader.StageZ // 108
	FBinRead /B=3 /F=3 file, param.SpectrumHeader.Flags // 112
	FBinRead /B=3 /F=3 file, param.SpectrumHeader.OldYUnits // 116
	FBinRead /B=3 /F=3 file, param.SpectrumHeader.OldType // 120
	FBinRead /B=3 /F=3 file, tmp//; print "124", tmp // 124
	FBinRead /B=3 /F=3 file, tmp//; print "128", tmp // 128
	FBinRead /B=3 /F=3 file, tmp//; print "132", tmp // 132
	FBinRead /B=3 /F=3 file, tmp//; print "136", tmp // 136
end


static function OMNICSPA_read_BenchInfo(file, param)
	variable file
	struct OMNICSPA_param &param
	FBinRead /B=3 /U/F=3 file, param.BenchInfo.BenchID // 0
	FBinRead /B=3 /U/F=3 file, param.BenchInfo.DetectorID // 4
	FBinRead /B=3 /U/F=3 file, param.BenchInfo.BeamSplitID // 8
	FBinRead /B=3 /U/F=3 file, param.BenchInfo.SourceID // 12
	FBinRead /B=3 /U/F=3 file, param.BenchInfo.ADBits // 16
	FBinRead /B=3 /F=4 file, param.BenchInfo.HPF // 20
	FBinRead /B=3 /F=4 file, param.BenchInfo.LPF // 24
	FBinRead /B=3 /F=3 file, param.BenchInfo.SwitchGainHi // 28
	FBinRead /B=3 /F=3 file, param.BenchInfo.SwitchGainLo // 32
	FBinRead /B=3 /F=3 file, param.BenchInfo.SwitchGainP1 // 36
	FBinRead /B=3 /F=3 file, param.BenchInfo.SwitchGainP2 // 40
	FBinRead /B=3 /F=4 file, param.BenchInfo.Gain // 44
	FBinRead /B=3 /F=4 file, param.BenchInfo.Velocity // 48
	FBinRead /B=3 /U/F=3 file, param.BenchInfo.AccessoryID // 52
end


static function OMNICSPA_read_ABGFFTHeader(file, param)
	variable file
	struct OMNICSPA_param &param
	FBinRead /B=3 /U/F=3 file, param.AFFTHeader.NumPoints // 0
	FBinRead /B=3 /U/F=3 file, param.AFFTHeader.NumScans // 4
	FBinRead /B=3 /F=4 file, param.AFFTHeader.Noise // 8
	FBinRead /B=3 /F=4 file, param.AFFTHeader.InterpPeak // 12
	FBinRead /B=3 /U/F=3 file, param.AFFTHeader.FinalPeakPos // 16
	FBinRead /B=3 /F=4 file, param.AFFTHeader.Laser // 20
end
