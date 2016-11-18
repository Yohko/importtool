// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

// The WinSpec procedure is based on xylib by Marcin Wojdyr:
// https://github.com/wojdyr/xylib (https://github.com/wojdyr/xylib/blob/master/xylib/winspec_spe.cpp)
// and 
// http://www.igorexchange.com/node/2756

// ftp://ftp.princetoninstruments.com/Public/Manuals/Princeton%20Instruments/SPE%203.0%20File%20Format%20Specification.pdf

// no 2D spectra tested yet.... but should work

// Princeton Instruments WinSpec SPE Format
// Licence: Lesser GNU Public License 2.1 (LGPL)

// According to the format specification, SPE format has several versions
// (v1.43, v1.6 and the newest v2.25). But we need not implement every version
// of it, because it's backward compatible.
// The official programs to deal with this format is WinView/WinSpec.
//
// Implementation is based on the file format specification sent us by
// David Hovis (the documents came with his equipment)
// and source code of a program written by Pablo Bianucci.


static structure headerstart
	uint16 ControllerVersion				//0  Hardware Version
	uint16 LogicOutput						//2  Definition of Output BNC
	int16 AmpHiCapLowNoise				//4  Amp Switching Mode
	int16 xDimDet							//6  Detector x dimension of chip.
	uint16 mode							//8  timing mode
	float exp_sec							//10  alternitive exposure, in sec.
	uint16 VChipXdim						//14  Virtual Chip X dim
	uint16 VChipYdim						//16  Virtual Chip Y dim
	int16 yDimDet							//18  y dimension of CCD or detector.
	char datec[10]							//20  date
	uint16 VirtualChipFlag					//30  On/Off
	char Spare_1[2]						//32
	uint16 noscan							//34  Old number of scans - should always be -1
	float DetTemperature					//36  Detector Temperature Set
	uint16 DetType							//40  CCD/DiodeArray type
	int16 xdim								//42  actual # of pixels on x axis
	uint16 stdiode							//44  trigger diode
	float DelayTime							//46  Used with Async Mode
	int16 ShutterControl					//50  Normal, Disabled Open, Disabled Closed
	uint16 AbsorbLive						//52  On/Off
	int16 AbsorbMode						//54  Reference Strip or File
	uint16 CanDoVirtualChipFlag			//56  T/F Cont/Chip able to do Virtual Chip
	uint16 ThresholdMinLive				//58  On/Off
	float ThresholdMinVal					//60  Threshold Minimum Value
	uint16 ThresholdMaxLive				//64  On/Off
	float ThresholdMaxVal					//66  Threshold Maximum Value
	uint16 SpecAutoSpectroMode			//70  T/F Spectrograph Used
	float SpecCenterWlNm					//72  Center Wavelength in Nm
	uint16 SpecGlueFlag					//76  T/F File is Glued
	float SpecGlueStartWlNm				//78  Starting Wavelength in Nm
	float SpecGlueEndWlNm					//82  End Wavelength in Nm
	float SpecGlueMinOvrlpNm				//86  Minimum Overlap in Nm
	float SpecGlueFinalResNm				//90  Final Resolution in Nm
	uint16 PulserType						//94  0=None, PG200=1, PTG=2, DG535=3
	uint16 CustomChipFlag					//96  T/F Custom Chip Used
	uint16 XPrePixels						//98  Pre Pixels in X direction
	uint16 XPostPixels						//100  Post Pixels in X direction
	uint16 YPrePixels						//102  Pre Pixels in Y direction 
	uint16 YPostPixels						//104  Post Pixels in Y direction
	uint16 asynen							//106  asynchron enable flag  0 = off
	uint16 datatype							//108  experiment datatype (0 =   float (4 bytes); 1 =   long (4 bytes); 2 =   short (2 bytes); 3 =   unsigned short (2 bytes))
	uint16 PulserMode						//110  Repetitive/Sequential
	int16 PulserOnChipAccums				//112  Num PTG On-Chip Accums
	int32 PulserRepeatExp					//114  Num Exp Repeats (Pulser SW Accum)
	float PulseRepWidth						//118  Width Value for Repetitive pulse (usec)
	float PulseRepDelay						//122  Width Value for Repetitive pulse (usec)
	float PulseSeqStartWidth				//126  Start Width for Sequential pulse (usec)
	float PulseSeqEndWidth					//130  End Width for Sequential pulse (usec)
	float PulseSeqStartDelay				//134  Start Delay for Sequential pulse (usec)
	float PulseSeqEndDelay					//138  End Delay for Sequential pulse (usec)
	uint16 PulseSeqIncMode					//142  Increments: 1=Fixed, 2=Exponential
	uint16 PImaxUsed						//144  PI-Max type controller flag
	uint16 PImaxMode						//146  PI-Max mode
	uint16 PImaxGain						//148  PI-Max Gain
	uint16 BackGrndApplied					//150  1 if background subtraction done
	uint16 PImax2nsBrdUsed				//152  T/F PI-Max 2ns Board Used
	int16 minblk							//154  min. # of strips per skips
	int16 numminblk						//156  # of min-blocks before geo skps
	uint16 SpecMirrorLocation[2]			//158  Spectro Mirror Location, 0=Not Present
	uint16 SpecSlitLocation[4]				//162  Spectro Slit Location, 0=Not Present
	uint16 CustomTimingFlag				//170  T/F Custom Timing Used
	char ExperimentTimeLocal[7]			//172  Experiment Local Time as hhmmss\0
	char ExperimentTimeUTC[7]			//179  Experiment UTC Time as hhmmss\0
	uint16 ExposUnits						//186  User Units for Exposure
	int16 ADCoffset							//188  ADC offset
	int16 ADCrate							//190  ADC rate
	int16 ADCtype							//192  ADC type
	int16 ADCresolution					//194  ADC resolution
	int16 ADCbitAdjust						//196  ADC bit adjust
	int16 gain								//198  gain
	char Comments0[80]					//200  File Comments
	char Comments1[80]					//200  File Comments
	char Comments2[80]					//200  File Comments
	char Comments3[80]					//200  File Comments
	char Comments4[80]					//200  File Comments
	int16 geometric							//600  geometric ops: rotate 0x01, reverse 0x02, flip 0x04
	char xlabel[16]							//602  intensity display string
	int16 cleans							//618  cleans
	int16 NumSkpPerCln					//620  number of skips per clean.
	uint16 SpecMirrorPos[2]				//622  Spectrograph Mirror Positions
	float SpecSlitPos[4]						//626  Spectrograph Slit Positions
	uint16 AutoCleansActive					//642  T/F
	uint16 UseContCleansInst				//644  T/F
	uint16 AbsorbStripNum					//646  Absorbance Strip Number
	uint16 SpecSlitPosUnits				//648  Spectrograph Slit Position Units
	float SpecGrooves						//650  Spectrograph Grating Grooves
	uint16 srccmp							//654  number of source comp. diodes
	int16 ydim								//656  y dimension of raw data.
	uint16 scramble						//658  0=scrambled,1=unscrambled
	uint16 ContinuousCleansFlag			//660  T/F Continuous Cleans Timing Option
	uint16 ExternalTriggerFlag				//662  T/F External Trigger Timing Option
	uint32 lnoscan							//664  Number of scans (Early WinX)
	uint32 lavgexp							//668  Number of Accumulations
	float ReadoutTime						//672  Experiment readout time
	uint16 TriggeredModeFlag				//676  T/F Triggered Timing Option
	char xml_offset[10]					//678  offset to the XML footer in bytes (v3.x) 64bit unsigned integer --> not yet supported by igor
	char sw_version[16]					//688  Version of SW creating this file
	uint16 type								//704   1 = new120 (Type II); 2 = old120 (Type I ); 3 = ST130; 4 = ST121; 5 = ST138; 6 = DC131 (PentaMax); 7 = ST133 (MicroMax/SpectroMax); 8 = ST135 (GPIB); 9 = VICCD; 10 = ST116 (GPIB); 11 = OMA3 (GPIB); 12 = OMA4
	uint16 flatFieldApplied					//706  1 if flat field was applied.
	char Spare_3[16]						//708  
	uint16 kin_trig_mode					//724  Kinetics Trigger Mode
	char dlabel[16]							//726  Data label.
	char Spare_4_1[218]					//742
	char Spare_4_2[218]					//742
	char PulseFileName[120]				//1178  Name of Pulser File with Pulse Widths/Delays (for Z-Slice)
	char AbsorbFileName[120]				//1298 Name of Absorbance File (if File Mode)
	int32 NumExpRepeats					//1418  Number of Times experiment repeated
	int32 NumExpAccums					//1422  Number of Time experiment accumulated
	uint16 YT_Flag							//1426  Set to 1 if this file contains YT data
	float clkspd_us							//1428  Vert Clock Speed in micro-sec
	uint16 HWaccumFlag					//1432  set to 1 if accum done by Hardware.
	uint16 StoreSync						//1434  set to 1 if store sync used
	uint16 BlemishApplied					//1436  set to 1 if blemish removal applied
	uint16 CosmicApplied					//1438  set to 1 if cosmic ray removal applied
	uint16 CosmicType						//1440  if cosmic ray applied, this is type
	float CosmicThreshold					//1442  Threshold of cosmic ray removal.  
	uint32 NumFrames						//1446  number of frames in file.         
	float MaxIntensity						//1450  max intensity of data (future)    
	float MinIntensity						//1454  min intensity of data (future)    
	char ylabel[16]							//1458  y axis label.                     
	int16 ShutterType						//1474  shutter type.                     
	float shutterComp						//1476  shutter compensation time.        
	int16 readoutMode						//1480  readout mode, full,kinetics, etc  
	int16 WindowSize						//1482  window size for kinetics only.    
	int16 clkspd							//1484  clock speed for kinetics & frame transfer
	int16 interface_type					//1486  computer interface (isa-taxi, pci, eisa, etc.)
	uint16 NumROIsInExperiment			//1488  May be more than the 10 allowed in this header (if 0, assume 1)
	char Spare_5[16]						//1490
	int16 controllerNum					//1506  if multiple controller system will have controller number data came from this is a future item.
	int16 SWmade							//1508  Which software package created this file
	uint16 NumROI							//1510  number of ROIs used. if 0 assume 1.
	//ROI Starting Offsets:     
	//ROI  1  =  1512
	//ROI  2  =  1524
	//ROI  3  =  1536
	//ROI  4  =  1548
	//ROI  5  =  1560
	//ROI  6  =  1572
	//ROI  7  =  1584
	//ROI  8  =  1596
	//ROI  9  =  1608
	//ROI 10  =  1620
	struct ROIinfo ROIs[10]
	char FlatField[120]			//1632  Flat field file name.       
	char background[120]		//1752  background sub. file name.  
	char blemish[120]			//1872  blemish file name.          
	float file_header_ver		//1992  version of this file header 
	char YT_Infopart1[250]	//1996-2995  Reserved for YT information
	char YT_Infopart2[250]	//1996-2995  Reserved for YT information
	char YT_Infopart3[250]	//1996-2995  Reserved for YT information
	char YT_Infopart4[250]	//1996-2995  Reserved for YT information
	UINT32 WinView_id		//2996  == 0x01234567L if file created by WinX
endstructure


static structure ROIinfo
	int16  startx	//left x start value.
	int16  endx		//right x value.
	int16  groupx	//amount x is binned/grouped in hw.
	int16  starty	//top y start value.
	int16  endy		//bottom y value.
	int16  groupy	//amount y is binned/grouped in hw.
endstructure // ROIinfoblk[ROIMAX]                   


// Calibration structure in SPE format.
static structure spe_calib
	variable offset 				// +0 offset for absolute data scaling
	variable factor 				// +8 factor for absolute data scaling
	variable current_unit 		// +16 selected scaling unit
	variable reserved1 			// +17 reserved
	string strings	 			// +18 special string for scaling
	string reserved2	 		// +58 reserved
	variable calib_valid 		// +98 flag of whether calibration is valid
	variable input_unit 		// +99 current input units for "calib-value"
	variable polynom_unit 		// +100 linear UNIT and used  in the "polynom-coeff"
	variable polynom_order 	// +101 ORDER of calibration POLYNOM
	variable calib_count		// +102 valid calibration data pairs
	double pixel_position[10] 	// +103 pixel pos. of calibration data
	double calib_value[10] 		// +183 calibration VALUE at above pos
	double polynom_coeff[6] 	// +263 polynom COEFFICIENTS
	variable laser_position 		// +311 laser wavenumber for relativ WN
	variable reserved3 			// +319 reserved
	variable new_calib_flag 	// +320 If set to 200, valid label below
	string calib_label			// +321 Calibration label (NULL term'd)
	string expansion 			// +402 Calibration Expansion area
endstructure


static Structure headerend
	char Istring[40]			//3978  special intensity scaling string
	char Spare_6[25]			//4018  
	char SpecType				//4043  spectrometer type (acton, spex, etc.)
	char SpecModel				//4044  spectrometer model (type dependent)
	char PulseBurstUsed		//4045  pulser burst mode on/off
	int32 PulseBurstCount		//4046  pulser triggers per burst
	double ulseBurstPeriod		//4050  pulser burst period (in usec)
	char PulseBracketUsed		//4058  pulser bracket pulsing on/off
	char PulseBracketType		//4059  pulser bracket pulsing type
	double PulseTimeConstFast	//4060  pulser slow exponential time constant (in usec)
	double PulseAmplitudeFast	//4068  pulser fast exponential amplitude constant
	double PulseTimeConstSlow	//4076  pulser slow exponential time constant (in usec)
	double PulseAmplitudeSlow	//4084  pulser slow exponential amplitude constant
	int16 AnalogGain			//4092  analog gain
	int16 AvGainUsed			//4094  avalanche gain was used
	int16 AvGain				//4096  avalanche gain value
	int16 lastvalue				//4098  Always the LAST value in the header
endstructure


function WinspecSpe_check_file(file) 
	variable file
	fsetpos file, 0
	// make sure file size > 4100 (data begins after a 4100-byte header)
	FStatus file
	if (V_logEOF <= 4100)
		fsetpos file, 0
		return -1
	endif
	FSetPos file, 108
	// datatype field in header ONLY can be 0 .. 3, or 5, 6, 8
	variable data_type = read_uint16_le(file)
	fsetpos file, 1992
	variable headerversion = read_flt_le(file)
	fsetpos file, 0
	if(headerversion<2 || headerversion>3)
		return -1
	endif
	if((data_type >= 0 && data_type <= 3) || data_type == 5 || data_type == 6 || data_type == 8)
		return 1
	endif
	return -1
end


function WinspecSpe_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "Princeton Instruments WinSpec"
	importloader.filestr = "*.spe"
	importloader.category = "XRD"
end


function WinspecSpe_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	WinspecSpe_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file

	struct headerstart headstart
	struct spe_calib x_calib
	struct spe_calib y_calib
	struct headerend headend


	FSetPos file, 0
	Fbinread/B=3 file, headstart			//0
	WinspecSpe_read_calib(file, x_calib)	//3000
	WinspecSpe_read_calib(file, y_calib)	//3489
	Fbinread/B=3 file, headend				//3978
	
	//	print headstart
	//	print x_calib
	//	print y_calib
	//	print headend


	string wname = "raw_data"
	Make /O/D/N=(headstart.xdim,headstart.ydim, headstart.NumFrames) $wname /wave=w

	// experiment datatype
	// 0 = 32f (4 bytes) 
	// 1 = 32s (4 bytes) SPE 2.X only
	// 2 = 16s (2 bytes) SPE 2.X only
	// 3 = 16u (2 bytes)
	// 5 = 64f () SPE 2.X only
	// 6 = 8u (1 byte) SPE 2.X only
	// 8 = 32u (4 bytes)
	switch (headstart.datatype)
		case 0:
			fbinread/B=3/F=4 file, w
			break
		case 1: // (SPE 2.X only
			fbinread/B=3/F=3 file, w
			break
		case 2:
			fbinread/B=3/F=2 file, w
			break
		case 3:
			fbinread/U/B=3/F=2 file, w
			break
		case 5:
			fbinread/U/B=3/F=5 file, w
			break
		case 6:
			fbinread/U/B=3/F=1 file, w
			break
		case 8:
			fbinread/U/B=3/F=3 file, w
			break
		default:
			break
	endswitch

	if(headstart.file_header_ver >=3)
		//print headstart.xml_offset
		debugprintf2("XML footer not supported yet (64bit offset), need IgorPro7",0)
	endif

	note w,header
	note w, "Exposure time (sec): "+num2str(headstart.exp_sec)
	note w, "Date: "+cleanupname(headstart.datec,1)
	note w, "Time: "+WinspecSpe_time(headstart.ExperimentTimeLocal)
	note w, "Comment1: "+cleanupname(headstart.Comments0,1)
	note w, "Comment2: "+cleanupname(headstart.Comments1,1)
	note w, "Comment3: "+cleanupname(headstart.Comments2,1)
	note w, "Comment4: "+cleanupname(headstart.Comments3,1)
	note w, "Comment5: "+cleanupname(headstart.Comments4,1)
	note w, "Number of frames: "+num2str(headstart.NumFrames)
	

	// redimension and create scaling waves
	if (headstart.ydim>1) // image(stack) file
		if (headstart.NumFrames == 1) // image
			redimension/N=(headstart.xdim,headstart.ydim) w
		else // 3D image stack
			//redimension/N=(headstart.xdim,headstart.ydim, headstart.NumFrames) w
		endif

		if(x_calib.polynom_order > 6)
			debugprintf2("bad polynom header  xcalib: "+num2str(x_calib.polynom_order),0)
			return -1
		elseif(y_calib.polynom_order > 6)
			debugprintf2("bad polynom header  ycalib: "+num2str(y_calib.polynom_order),0)
			return -1
		endif
	
		variable i=0,j=0,xval=0,yval=0
		if (!x_calib.calib_valid) //use idx as X instead
			SetScale/P  x,0,1,"", w
		elseif (x_calib.polynom_order == 1) // linear
			SetScale/P  x,x_calib.polynom_coeff[0],x_calib.polynom_coeff[1],"", w
		else
			wname+="_x"
			Make /O/R/N=(headstart.xdim)  $wname /wave=xcol
			for (i = 0; i < headstart.xdim; i+=1)
				xval = 0
				for (j = 0; j <= x_calib.polynom_order; j+=1)
					xval += x_calib.polynom_coeff[j] * (i+1)^j//pow(i + 1., double(j))
				endfor
				xcol[i]=xval
			endfor
		endif

		
		if (!y_calib.calib_valid)
			SetScale/P  y,0,1,"", w
		elseif (y_calib.polynom_order == 1) // linear
			SetScale/P  y,y_calib.polynom_coeff[0],y_calib.polynom_coeff[1],"", w
		else
			wname+="_y"
			Make /O/R/N=(headstart.ydim)  $wname /wave=ycol
			for (i = 0; i < headstart.ydim; i+=1)
				yval = 0
				for (j = 0; j <= y_calib.polynom_order; j+=1)
					yval += y_calib.polynom_coeff[j] * (i+1)^j//pow(i + 1., double(j))
				endfor
				ycol[i]=yval
			endfor
		endif
		
	else
		redimension/N=(headstart.xdim) w
		if(x_calib.polynom_order > 6)
			debugprintf2("bad polynom header  xcalib: "+num2str(x_calib.polynom_order),0)
			return -1
		//elseif(y_calib.polynom_order <= 6)
		//	debugprintf2("bad polynom header  ycalib",0)
		//	return -1
		endif

		if (!x_calib.calib_valid) //use idx as X instead
			SetScale/P  x,0,1,"", w
		elseif (x_calib.polynom_order == 1) // linear
			SetScale/P  x,x_calib.polynom_coeff[0],x_calib.polynom_coeff[1],"", w
		else
			wname+="_x"
			Make /O/R/N=(headstart.xdim)  $wname /wave=xcol
			for (i = 0; i < headstart.xdim; i+=1)
				xval = 0
				for (j = 0; j <= x_calib.polynom_order; j+=1)
					xval += x_calib.polynom_coeff[j] * (i+1)^j//pow(i + 1., double(j))
				endfor
				xcol[i]=xval
			endfor
		endif
		
		
	endif
	importloader.success = 1
	loaderend(importloader)
end


static Function/S WinspecSpe_time(timestr) //format HHMMSS (161959)
	string timestr
	string hh, mm, ss
	hh=timestr[0,1]
	mm=timestr[2,3]
	ss=timestr[4,5]
	return hh+":"+mm+":"+ss
End


static function WinspecSpe_read_calib(file, calib)
	variable file
	struct spe_calib &calib
	variable i=0
	// can't read the single structure because of byte alignment issues
	FBinRead/B=3/F=5 file,calib.offset 					// +0 offset for absolute data scaling
	FBinRead/B=3/F=5 file,calib.factor 				// +8 factor for absolute data scaling
	FBinRead/B=3/F=1 file,calib.current_unit 				// +16 selected scaling unit
	FBinRead/B=3/F=1 file,calib.reserved1				// +17 reserved
	calib.strings = mybinread(file, 40) 				// +18 special string for scaling
	calib.reserved2 = mybinread(file, 40) 				// +58 reserved
	FBinRead/B=3/F=1 file,calib.calib_valid			// +98 flag of whether calibration is valid
	FBinRead/B=3/F=1 file,calib.input_unit			// +99 current input units for "calib-value"
	FBinRead/B=3/F=1 file,calib.polynom_unit			// +100 linear UNIT and used  in the "polynom-coeff"
	FBinRead/B=3/F=1 file,calib.polynom_order		// +101 ORDER of calibration POLYNOM
	FBinRead/B=3/F=1 file,calib.calib_count			// +102 valid calibration data pairs
	for(i=0;i<10;i+=1)
		FBinRead/B=3/F=5 file,calib.pixel_position[i]
	endfor
	for(i=0;i<10;i+=1)
		FBinRead/B=3/F=5 file,calib.calib_value[i]
	endfor
	for(i=0;i<6;i+=1)
		FBinRead/B=3/F=5 file,calib.polynom_coeff[i]
	endfor
	FBinRead/B=3/F=5 file,calib.laser_position 		// +311 laser wavenumber for relativ WN
	FBinRead/B=3/F=1 file,calib.reserved3 			// +319 reserved
	FBinRead/U/B=3/F=1 file,calib.new_calib_flag		// +320 If set to 200, valid label below
	calib.calib_label = mybinread(file, 81)			// +321 Calibration label (NULL term'd)
	calib.expansion = mybinread(file, 87) 				// +402 Calibration Expansion area
end
