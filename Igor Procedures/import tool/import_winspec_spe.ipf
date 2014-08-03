// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

// The WinSpec procedure is based on xylib by Marcin Wojdyr:
// https://github.com/wojdyr/xylib (https://github.com/wojdyr/xylib/blob/master/xylib/winspec_spe.cpp)
// and 
// http://www.igorexchange.com/node/2756

// ftp://ftp.princetoninstruments.com/Public/Manuals/Princeton%20Instruments/SPE%203.0%20File%20Format%20Specification.pdf

// no 2D spectra tested yet.... but should work


#ifdef showmenu
Menu "Macros"
	submenu "Import Tool "+importloaderversion
			submenu "XRD"
				"Princeton Instruments WinSpec	*.spe	file... b1", WinspecSpe_load_data() 
			end
	end
end
#endif

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


static constant SPE_HEADER_SIZE = 4100 // fixed binary header size

// datatypes of DATA point in spe_file
static constant SPE_DATA_FLOAT = 0 	// size 4
static constant SPE_DATA_LONG = 1 		// size 4
static constant SPE_DATA_INT = 2 		// size 2
static constant SPE_DATA_UINT = 3 		// size 2


structure header1
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
	float SpecGlueEndWlNm					//82  Starting Wavelength in Nm
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
	char Spare_2[10]						//678  
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
endstructure

structure ROIinfo
	int16  startx	//left x start value.
	int16  endx		//right x value.
	int16  groupx	//amount x is binned/grouped in hw.
	int16  starty	//top y start value.
	int16  endy		//bottom y value.
	int16  groupy	//amount y is binned/grouped in hw.
endstructure // ROIinfoblk[ROIMAX]                   
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


structure header2
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



// Calibration structure in SPE format.
// NOTE: fields that we don't care have been commented out
structure spe_calib
	double offset 				// +0 offset for absolute data scaling
	double factor 				// +8 factor for absolute data scaling
	char current_unit 			// +16 selected scaling unit
	char reserved1 				// +17 reserved
	char strings[40] 			// +18 special string for scaling
	char reserved2[40] 		// +58 reserved
	char calib_valid 			// +98 flag of whether calibration is valid
	char input_unit 			// +99 current input units for "calib-value"
	char polynom_unit 			// +100 linear UNIT and used  in the "polynom-coeff"
	char polynom_order 		// +101 ORDER of calibration POLYNOM
	char calib_count 			// +102 valid calibration data pairs
	double pixel_position[10] 	// +103 pixel pos. of calibration data
	double calib_value[10] 		// +183 calibration VALUE at above pos
	double polynom_coeff[6] 	// +263 polynom COEFFICIENTS
	double laser_position 		// +311 laser wavenumber for relativ WN
	char reserved3 				// +319 reserved
	uchar new_calib_flag 		// +320 If set to 200, valid label below
	char calib_label[81] 		// +321 Calibration label (NULL term'd)
	char expansion[87] 		// +402 Calibration Expansion area
endstructure



Structure header3
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
	// datatype field in header ONLY can be 0 .. 3
	variable data_type = read_uint16_le(file)
	fsetpos file, 1992
	variable headerversion = read_flt_le(file)
	fsetpos file, 0
	if(headerversion<2 || headerversion>3)
		return -1
	endif
	if (data_type < 0 || data_type > 3)
		return -1
	endif
	return 1
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

	struct header1 head1
	struct  ROIinfo ROI1
	struct  ROIinfo ROI2
	struct  ROIinfo ROI3
	struct  ROIinfo ROI4
	struct  ROIinfo ROI5
	struct  ROIinfo ROI6
	struct  ROIinfo ROI7
	struct  ROIinfo ROI8
	struct  ROIinfo ROI9
	struct  ROIinfo ROI10
	struct header2 head2
	struct spe_calib x_calib
	struct spe_calib y_calib
	struct header3 head3


	FSetPos file, 0
	Fbinread/B=3 file, head1	//0
	Fbinread/B=3 file, ROI1	//1512
	Fbinread/B=3 file, ROI2	//1524
	Fbinread/B=3 file, ROI3	//1536
	Fbinread/B=3 file, ROI4	//1548
	Fbinread/B=3 file, ROI5	//1560
	Fbinread/B=3 file, ROI6	//1572
	Fbinread/B=3 file, ROI7	//1584
	Fbinread/B=3 file, ROI8	//1596
	Fbinread/B=3 file, ROI9	//1608
	Fbinread/B=3 file, ROI10	//1620
	Fbinread/B=3 file, head2	//1632
	variable fileoff=3000
	FSetPos file, fileoff //should be correct as 1446 + 4 + 1550 = 3000 and 3263-263=3000
	Fbinread/B=3 file, x_calib //read_calib(file, x_calib) //3000
	Fbinread/B=3 file, y_calib //read_calib(file, y_calib) //3489
	Fbinread/B=3 file, head3 //3978

	
	Debugprintf2("##################",1)
	Debugprintf2("xdim: "+num2str(head1.xdim),1)
	Debugprintf2("ydim: "+num2str(head1.ydim),1)
	Debugprintf2("Number of frames: "+num2str(head1.NumFrames),1)
	Debugprintf2("Exposure time (sec): "+num2str(head1.exp_sec),1)
	Debugprintf2("Data type: "+num2str(head1.datatype),1) //+108
	Debugprintf2("Comment1: "+head1.Comments0,1)
	Debugprintf2("Comment2: "+head1.Comments1,1)
	Debugprintf2("Comment3: "+head1.Comments2,1)
	Debugprintf2("Comment4: "+head1.Comments3,1)
	Debugprintf2("Comment5: "+head1.Comments4,1)
	Debugprintf2("Time: "+head1.ExperimentTimeLocal,1)
	Debugprintf2("Date: "+head1.datec,1)


	//x calibration start + fix some erros (offset 3000)

	Debugprintf2("offset for absolute data scaling x: "+num2str(x_calib.offset),1)
	Debugprintf2("factor for absolute data scaling x: "+num2str(x_calib.factor),1)
	Debugprintf2("selected scaling unit x: "+num2str(x_calib.current_unit),1)
	Debugprintf2("reserved1 x: "+num2str(x_calib.reserved1),1)
	//Debugprintf2("special string for scaling x: "+num2str(x_calib. strings[40]),1)
	//Debugprintf2("reserved2 x: "+num2str(x_calib.reserved2[40]),1)
	Debugprintf2("flag of whether calibration is valid x: "+num2str(x_calib.calib_valid),1)
	Debugprintf2("current input units for 'calib-value' x: "+num2str(x_calib.input_unit),1)
	Debugprintf2("linear UNIT and used  in the 'polynom-coeff' x: "+num2str(x_calib.polynom_unit),1)
	Debugprintf2("ORDER of calibration POLYNOM x: "+num2str(x_calib.polynom_order),1)
	Debugprintf2("valid calibration data pairs x: "+num2str(x_calib.calib_count),1)
	fileoff=3103
	FSetPos file, fileoff+0*8; FBinRead/B=3/F=5 file,x_calib.pixel_position[0]
	FSetPos file, fileoff+1*8; FBinRead/B=3/F=5 file,x_calib.pixel_position[1]
	FSetPos file, fileoff+2*8; FBinRead/B=3/F=5 file,x_calib.pixel_position[2]
	FSetPos file, fileoff+3*8; FBinRead/B=3/F=5 file,x_calib.pixel_position[3]
	FSetPos file, fileoff+4*8; FBinRead/B=3/F=5 file,x_calib.pixel_position[4]
	FSetPos file, fileoff+5*8; FBinRead/B=3/F=5 file,x_calib.pixel_position[5]
	FSetPos file, fileoff+6*8; FBinRead/B=3/F=5 file,x_calib.pixel_position[6]
	FSetPos file, fileoff+7*8; FBinRead/B=3/F=5 file,x_calib.pixel_position[7]
	FSetPos file, fileoff+8*8; FBinRead/B=3/F=5 file,x_calib.pixel_position[8]
	FSetPos file, fileoff+9*8; FBinRead/B=3/F=5 file,x_calib.pixel_position[9]
	Debugprintf2("pixel pos. of calibration data 0 x: "+num2str(x_calib.pixel_position[0]),1)
	Debugprintf2("pixel pos. of calibration data 1 x: "+num2str(x_calib.pixel_position[1]),1)
	Debugprintf2("pixel pos. of calibration data 2 x: "+num2str(x_calib.pixel_position[2]),1)
	Debugprintf2("pixel pos. of calibration data 3 x: "+num2str(x_calib.pixel_position[3]),1)
	Debugprintf2("pixel pos. of calibration data 4 x: "+num2str(x_calib.pixel_position[4]),1)
	Debugprintf2("pixel pos. of calibration data 5 x: "+num2str(x_calib.pixel_position[5]),1)
	Debugprintf2("pixel pos. of calibration data 6 x: "+num2str(x_calib.pixel_position[6]),1)
	Debugprintf2("pixel pos. of calibration data 7 x: "+num2str(x_calib.pixel_position[7]),1)
	Debugprintf2("pixel pos. of calibration data 8 x: "+num2str(x_calib.pixel_position[8]),1)
	Debugprintf2("pixel pos. of calibration data 9 x: "+num2str(x_calib.pixel_position[9]),1)
	fileoff=3183
	FSetPos file, fileoff+0*8; FBinRead/B=3/F=5 file,x_calib.calib_value[0]
	FSetPos file, fileoff+1*8; FBinRead/B=3/F=5 file,x_calib.calib_value[1]
	FSetPos file, fileoff+2*8; FBinRead/B=3/F=5 file,x_calib.calib_value[2]
	FSetPos file, fileoff+3*8; FBinRead/B=3/F=5 file,x_calib.calib_value[3]
	FSetPos file, fileoff+4*8; FBinRead/B=3/F=5 file,x_calib.calib_value[4]
	FSetPos file, fileoff+5*8; FBinRead/B=3/F=5 file,x_calib.calib_value[5]
	FSetPos file, fileoff+6*8; FBinRead/B=3/F=5 file,x_calib.calib_value[6]
	FSetPos file, fileoff+7*8; FBinRead/B=3/F=5 file,x_calib.calib_value[7]
	FSetPos file, fileoff+8*8; FBinRead/B=3/F=5 file,x_calib.calib_value[8]
	FSetPos file, fileoff+9*8; FBinRead/B=3/F=5 file,x_calib.calib_value[9]
	Debugprintf2("calibration VALUE at above pos 0 x: "+num2str(x_calib.calib_value[0]),1)
	Debugprintf2("calibration VALUE at above pos 1 x: "+num2str(x_calib.calib_value[1]),1)
	Debugprintf2("calibration VALUE at above pos 2 x: "+num2str(x_calib.calib_value[2]),1)
	Debugprintf2("calibration VALUE at above pos 3 x: "+num2str(x_calib.calib_value[3]),1)
	Debugprintf2("calibration VALUE at above pos 4 x: "+num2str(x_calib.calib_value[4]),1)
	Debugprintf2("calibration VALUE at above pos 5 x: "+num2str(x_calib.calib_value[5]),1)
	Debugprintf2("calibration VALUE at above pos 6 x: "+num2str(x_calib.calib_value[6]),1)
	Debugprintf2("calibration VALUE at above pos 7 x: "+num2str(x_calib.calib_value[7]),1)
	Debugprintf2("calibration VALUE at above pos 8 x: "+num2str(x_calib.calib_value[8]),1)
	Debugprintf2("calibration VALUE at above pos 9 x: "+num2str(x_calib.calib_value[9]),1)
	fileoff=3263
	FSetPos file, fileoff+0*8; FBinRead/B=3/F=5 file,x_calib.polynom_coeff[0] //scalefactor0
	FSetPos file, fileoff+1*8; FBinRead/B=3/F=5 file,x_calib.polynom_coeff[1]//scalefactor1
	FSetPos file, fileoff+2*8; FBinRead/B=3/F=5 file,x_calib.polynom_coeff[2] //scalefactor2
	FSetPos file, fileoff+3*8; FBinRead/B=3/F=5 file,x_calib.polynom_coeff[3] //scalefactor3
	FSetPos file, fileoff+4*8; FBinRead/B=3/F=5 file,x_calib.polynom_coeff[4] //scalefactor4
	FSetPos file, fileoff+5*8; FBinRead/B=3/F=5 file,x_calib.polynom_coeff[5] //scalefactor5
	Debugprintf2("polynom COEFFICIENTS 0 x: "+num2str(x_calib.polynom_coeff[0]),1)
	Debugprintf2("polynom COEFFICIENTS 1 x: "+num2str(x_calib.polynom_coeff[1]),1)
	Debugprintf2("polynom COEFFICIENTS 2 x: "+num2str(x_calib.polynom_coeff[2]),1)
	Debugprintf2("polynom COEFFICIENTS 3 x: "+num2str(x_calib.polynom_coeff[3]),1)
	Debugprintf2("polynom COEFFICIENTS 4 x: "+num2str(x_calib.polynom_coeff[4]),1)
	Debugprintf2("polynom COEFFICIENTS 5 x: "+num2str(x_calib.polynom_coeff[5]),1)
	Debugprintf2("laser wavenumber for relativ WN x: "+num2str(x_calib.laser_position),1)
	Debugprintf2("reserved3 x: "+num2str(x_calib.reserved3),1)
	Debugprintf2("If set to 200, valid label below x: "+num2str(x_calib. new_calib_flag),1)
	//Debugprintf2("Calibration label (NULL term'd) x: "+num2str(x_calib.calib_label[81]),1)
	//Debugprintf2("Calibration Expansion area x: "+num2str(x_calib.expansion[87]),1)

	//y calibration start + fix some erros (offset 3490) or  3489 ??

	Debugprintf2("offset for absolute data scaling y: "+num2str(y_calib.offset),1)
	Debugprintf2("factor for absolute data scaling y: "+num2str(y_calib.factor),1)
	Debugprintf2("selected scaling unit y: "+num2str(y_calib.current_unit),1)
	Debugprintf2("reserved1 y: "+num2str(y_calib.reserved1),1)
	//Debugprintf2("special string for scaling y: "+num2str(y_calib. strings[40]),1)
	//Debugprintf2("reserved2 y: "+num2str(y_calib.reserved2[40]),1)
	Debugprintf2("flag of whether calibration is valid y: "+num2str(y_calib.calib_valid),1)
	Debugprintf2("current input units for 'calib-value' y: "+num2str(y_calib.input_unit),1)
	Debugprintf2("linear UNIT and used  in the 'polynom-coeff' y: "+num2str(y_calib.polynom_unit),1)
	Debugprintf2("ORDER of calibration POLYNOM y: "+num2str(y_calib.polynom_order),1)
	Debugprintf2("valid calibration data pairs y: "+num2str(y_calib.calib_count),1)
	fileoff=3592
	FSetPos file, fileoff+0*8; FBinRead/B=3/F=5 file,y_calib.pixel_position[0]
	FSetPos file, fileoff+1*8; FBinRead/B=3/F=5 file,y_calib.pixel_position[1]
	FSetPos file, fileoff+2*8; FBinRead/B=3/F=5 file,y_calib.pixel_position[2]
	FSetPos file, fileoff+3*8; FBinRead/B=3/F=5 file,y_calib.pixel_position[3]
	FSetPos file, fileoff+4*8; FBinRead/B=3/F=5 file,y_calib.pixel_position[4]
	FSetPos file, fileoff+5*8; FBinRead/B=3/F=5 file,y_calib.pixel_position[5]
	FSetPos file, fileoff+6*8; FBinRead/B=3/F=5 file,y_calib.pixel_position[6]
	FSetPos file, fileoff+7*8; FBinRead/B=3/F=5 file,y_calib.pixel_position[7]
	FSetPos file, fileoff+8*8; FBinRead/B=3/F=5 file,y_calib.pixel_position[8]
	FSetPos file, fileoff+9*8; FBinRead/B=3/F=5 file,y_calib.pixel_position[9]
	Debugprintf2("pixel pos. of calibration data 0 y: "+num2str(y_calib.pixel_position[0]),1)
	Debugprintf2("pixel pos. of calibration data 1 y: "+num2str(y_calib.pixel_position[1]),1)
	Debugprintf2("pixel pos. of calibration data 2 y: "+num2str(y_calib.pixel_position[2]),1)
	Debugprintf2("pixel pos. of calibration data 3 y: "+num2str(y_calib.pixel_position[3]),1)
	Debugprintf2("pixel pos. of calibration data 4 y: "+num2str(y_calib.pixel_position[4]),1)
	Debugprintf2("pixel pos. of calibration data 5 y: "+num2str(y_calib.pixel_position[5]),1)
	Debugprintf2("pixel pos. of calibration data 6 y: "+num2str(y_calib.pixel_position[6]),1)
	Debugprintf2("pixel pos. of calibration data 7 y: "+num2str(y_calib.pixel_position[7]),1)
	Debugprintf2("pixel pos. of calibration data 8 y: "+num2str(y_calib.pixel_position[8]),1)
	Debugprintf2("pixel pos. of calibration data 9 y: "+num2str(y_calib.pixel_position[9]),1)
	fileoff=3672
	FSetPos file, fileoff+0*8; FBinRead/B=3/F=5 file,y_calib.calib_value[0]
	FSetPos file, fileoff+1*8; FBinRead/B=3/F=5 file,y_calib.calib_value[1]
	FSetPos file, fileoff+2*8; FBinRead/B=3/F=5 file,y_calib.calib_value[2]
	FSetPos file, fileoff+3*8; FBinRead/B=3/F=5 file,y_calib.calib_value[3]
	FSetPos file, fileoff+4*8; FBinRead/B=3/F=5 file,y_calib.calib_value[4]
	FSetPos file, fileoff+5*8; FBinRead/B=3/F=5 file,y_calib.calib_value[5]
	FSetPos file, fileoff+6*8; FBinRead/B=3/F=5 file,y_calib.calib_value[6]
	FSetPos file, fileoff+7*8; FBinRead/B=3/F=5 file,y_calib.calib_value[7]
	FSetPos file, fileoff+8*8; FBinRead/B=3/F=5 file,y_calib.calib_value[8]
	FSetPos file, fileoff+9*8; FBinRead/B=3/F=5 file,y_calib.calib_value[9]
	Debugprintf2("calibration VALUE at above pos 0 y: "+num2str(y_calib.calib_value[0]),1)
	Debugprintf2("calibration VALUE at above pos 1 y: "+num2str(y_calib.calib_value[1]),1)
	Debugprintf2("calibration VALUE at above pos 2 y: "+num2str(y_calib.calib_value[2]),1)
	Debugprintf2("calibration VALUE at above pos 3 y: "+num2str(y_calib.calib_value[3]),1)
	Debugprintf2("calibration VALUE at above pos 4 y: "+num2str(y_calib.calib_value[4]),1)
	Debugprintf2("calibration VALUE at above pos 5 y: "+num2str(y_calib.calib_value[5]),1)
	Debugprintf2("calibration VALUE at above pos 6 y: "+num2str(y_calib.calib_value[6]),1)
	Debugprintf2("calibration VALUE at above pos 7 y: "+num2str(y_calib.calib_value[7]),1)
	Debugprintf2("calibration VALUE at above pos 8 y: "+num2str(y_calib.calib_value[8]),1)
	Debugprintf2("calibration VALUE at above pos 9 y: "+num2str(y_calib.calib_value[9]),1)
	fileoff=3752
	FSetPos file, fileoff+0*8; FBinRead/B=3/F=5 file,y_calib.polynom_coeff[0] //scalefactor0
	FSetPos file, fileoff+1*8; FBinRead/B=3/F=5 file,y_calib.polynom_coeff[1]//scalefactor1
	FSetPos file, fileoff+2*8; FBinRead/B=3/F=5 file,y_calib.polynom_coeff[2] //scalefactor2
	FSetPos file, fileoff+3*8; FBinRead/B=3/F=5 file,y_calib.polynom_coeff[3] //scalefactor3
	FSetPos file, fileoff+4*8; FBinRead/B=3/F=5 file,y_calib.polynom_coeff[4] //scalefactor4
	FSetPos file, fileoff+5*8; FBinRead/B=3/F=5 file,y_calib.polynom_coeff[5] //scalefactor5
	Debugprintf2("polynom COEFFICIENTS 0 y: "+num2str(y_calib.polynom_coeff[0]),1)
	Debugprintf2("polynom COEFFICIENTS 1 y: "+num2str(y_calib.polynom_coeff[1]),1)
	Debugprintf2("polynom COEFFICIENTS 2 y: "+num2str(y_calib.polynom_coeff[2]),1)
	Debugprintf2("polynom COEFFICIENTS 3 y: "+num2str(y_calib.polynom_coeff[3]),1)
	Debugprintf2("polynom COEFFICIENTS 4 y: "+num2str(y_calib.polynom_coeff[4]),1)
	Debugprintf2("polynom COEFFICIENTS 5 y: "+num2str(y_calib.polynom_coeff[5]),1)

	Debugprintf2("laser wavenumber for relativ WN y: "+num2str(y_calib.laser_position),1)
	Debugprintf2("reserved3 y: "+num2str(y_calib.reserved3),1)
	Debugprintf2("If set to 200, valid label below y: "+num2str(y_calib. new_calib_flag),1)
	//Debugprintf2("Calibration label (NULL term'd) y: "+num2str(y_calib.calib_label[81]),1)
	//Debugprintf2("Calibration Expansion area y: "+num2str(y_calib.expansion[87]),1)


	//Step & Glue parameters
	Variable glue, offset, scalefactor, final
	FSetPos file, 76; FBinRead/B=3/F=2 file,glue //glue flag
	Debugprintf2("Glue flag: "+num2str(glue),1)
	FSetPos file, 78; FBinRead/B=3/F=4 file,offset //offset
	Debugprintf2("offset: "+num2str(offset),1)
	FSetPos file, 82; FBinRead/B=3/F=4 file,final //final wavelength
	Debugprintf2("final wavelength: "+num2str(final),1)
	FSetPos file, 90; FBinRead/B=3/F=4 file,scalefactor //scalefactor
	Debugprintf2("scalefactor: "+num2str(scalefactor),1)
	//Grating parameters
	Variable center, xpix, grooves
	FSetPos file, 72; FBinRead/B=3/F=4 file,center //offset
	Debugprintf2("center: "+num2str(center),1)
	FSetPos file, 6; FBinRead/B=3/F=2 file,xpix //scalefactor
	Debugprintf2("xpix: "+num2str(xpix),1)
	FSetPos file, 650; FBinRead/B=3/F=4 file,grooves //scalefactor
	Debugprintf2("grooves: "+num2str(grooves),1)

	Fstatus file
	
	//Setscale
	//if (glue==1)
	//	Setscale/P x, offset*1E-9, scalefactor*1E-9, "m", WStemp0
	//else
	//	if(polyx==2)
	//		String Calibx = wname + "_x"
	//		Make/D/O/N = (xpix) $calibx = scalex0 + scalex1*(p+1) + scalex2*(p+1)^2
	//	else
	//		Print "Special Calibration - scale not made: polynomial order", polyx
	//	endif
	//endif
	
	//print (head1.datatype)
	switch (head1.datatype)
		case SPE_DATA_FLOAT:
			GBLoadWave/O/Q/B=3/S=4100/T={2,4}/U=(head1.xdim*head1.ydim*head1.NumFrames)/W=(1)/N=WStemp (S_path+S_filename)
		break
		case SPE_DATA_LONG:
			GBLoadWave/O/Q/B=3/S=4100/T={32,4}/U=(head1.xdim*head1.ydim*head1.NumFrames)/W=(1)/N=WStemp (S_path+S_filename)
		break
		case SPE_DATA_INT:
			GBLoadWave/O/Q/B=3/S=4100/T={16+64,4}/U=(head1.xdim*head1.ydim*head1.NumFrames)/W=(1)/N=WStemp (S_path+S_filename)				
		break
		case SPE_DATA_UINT:
			GBLoadWave/O/Q/B=3/S=4100/T={16+64,4}/U=(head1.xdim*head1.ydim*head1.NumFrames)/W=(1)/N=WStemp (S_path+S_filename)
		break
		default:
		break
	endswitch


	string wname = "raw_data"
	//Rename loaded wave to cleaned-up filename
	rename WStemp0, $wname
	//Duplicate/O WStemp0, $wname
	WAVE w = $wname
	//KillWaves/Z WStemp0
	note w,header
	note w, "Exposure time (sec): "+num2str(head1.exp_sec)
	note w, "Date: "+cleanupname(head1.datec,1)
	note w, "Time: "+WinspecSpe_time(head1.ExperimentTimeLocal)
	note w, "Comment1: "+cleanupname(head1.Comments0,1)
	note w, "Comment2: "+cleanupname(head1.Comments1,1)
	note w, "Comment3: "+cleanupname(head1.Comments2,1)
	note w, "Comment4: "+cleanupname(head1.Comments3,1)
	note w, "Comment5: "+cleanupname(head1.Comments4,1)
	note w, "Number of frames: "+num2str(head1.NumFrames)
	

	// redimension and create scaling waves
	if (head1.ydim>1) // image(stack) file
		if (head1.NumFrames == 1) // image
			redimension/N=(head1.xdim,head1.ydim) w
		else // 3D image stack
			redimension/N=(head1.xdim,head1.ydim, head1.NumFrames) w
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
			Make /O/R/N=(head1.xdim)  $wname /wave=xcol
			for (i = 0; i < head1.xdim; i+=1)
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
			Make /O/R/N=(head1.ydim)  $wname /wave=ycol
			for (i = 0; i < head1.ydim; i+=1)
				yval = 0
				for (j = 0; j <= y_calib.polynom_order; j+=1)
					yval += y_calib.polynom_coeff[j] * (i+1)^j//pow(i + 1., double(j))
				endfor
				ycol[i]=yval
			endfor
		endif
		
	else

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
			Make /O/R/N=(head1.xdim)  $wname /wave=xcol
			for (i = 0; i < head1.xdim; i+=1)
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