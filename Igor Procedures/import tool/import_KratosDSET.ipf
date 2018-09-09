// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.


static strconstant Gtmpwavename = "tmpwave_"
static strconstant directory = "root:Packages:KratosDSET"

static constant magic_number = 56833 // even Kratos calls it Magic Number

// These are my guesses and may not be correct
static strconstant offsetsname1_flags = "0;1;2;3;8;16;32;144;160"
static strconstant offsetsname1_value = "DATASET;ISS;SIMS;XPS;UPS;Sample_Position;Counter;???;Delay"
static strconstant offsetsname2_flags = "4;6;8;69;73;37;133;4096;4098;4160"
static strconstant offsetsname2_value = "List;change_done;Irregular;Spectrum;Split_Spectrum;Mapping;?? Auto Z;set_file;change_todo;Record_Spectrum"

// #### flags
static strconstant f_technique_names								= "AES;ISS;SIMS;XPS;SEM;SNMS;RGA;TDS;UPS"
static strconstant f_fat_resolution_names						= "Pass energy 5;Pass energy 10;Pass energy 20;Pass energy 40;Pass energy 80;Pass energy 160;Pass energy 320"
static strconstant f_fat_resolution_values						= "5;10;20;40;80;160;320"
static strconstant f_fixed_retard_ratio_names					= "Retard ratio 20/14;Retard ratio 10/11;Retard ratio 5/6;Retard ratio 2/3"
//static strconstant f_fixed_retard_ratio_names_20_10_5_2		= "Retard ratio 20;Retard ratio 10;Retard ratio 5;Retard ratio 2"
//static strconstant f_fixed_retard_ratio_names_14_11_6_3		= "Retard ratio 14;Retard ratio 11;Retard ratio 6;Retard ratio 3"
//static strconstant f_fixed_retard_ratio_values_20_10_5_2		= "20;10;5;2"
//static strconstant f_fixed_retard_ratio_values_14_11_6_3		= "14;11;6;3"
static strconstant f_lens_mode_names							= "Low Magn.;Medium Magn.;High Magn.;Hybrid;Magnetic;Slot-M;Electrostatic"
static strconstant f_hsa_lens_mode_names						= "Hybrid;Magnetic;Slot-M;Electrostatic;AES;UPS;ISS;Low Mag;Medium Mag;High Mag;SA XPS"
static strconstant f_mhsa_lens_mode_names						= "Field of View 1: Survey;Field of View 2: Small Spot;Field of View 3;Field of View 4;Field of View 5"
static strconstant f_fibre_optic_RS232_names					= "Fibre Optic 1;Fibre Optic 2;Fibre Optic 3;Fibre Optic 4"
static strconstant f_xray_manual_psu_options_names			= "Mg;Al;Mono (Al);Ti;Ag;UV"
static strconstant f_xray_manual_psu_source_names			= "Source 1;Source 2;Source 3;Source 4;Source 5"
static strconstant f_hardware_config_option_names			= ""//
//"ESCA Interface Card (IF1);ESCA Interface Card (IF3);ESCA Vision Interface Card;ESCA Xray Gun;ESCA Analyser;ESCA Ion Gun;ESCA Manipulator;VME BVME363 CPU68010;VME BVME370 CPU68030;VME BVME410 Ethernet;VME Kratos 3 Channel Timer Counter;VME Kratos 6 Channel Fibre-Optic Timer Counter;VME Kratos RS232 Fibre-Optic;VME Synoptics Frame-Store;
//VME Synoptics Slow-Scan Generator;VME Kratos Video Multiplexor;VME Imaging Technology Frame-Store;VME Kratos Slow-Scan Generator;VME Kratos Analog Signal Multiplexor;VME Kratos Parallel HT-Rack Interface;VME Kratos Fibre-Optic HT-Rack Interface;VME Kratos Fibre-Optic PSU Interface;VME Kratos Stepper Motor Interface;HT-Rack FAT Control Board;
//HT-Rack FRR Control Board;HT-Rack FAT/FRR Control Board;HT-Rack Lens Single PSU;HT-Rack Lens Double PSU;HT-Rack Mirror HSA Detector/Lens PSU;HT-Rack Analyser PSU;HT-Rack DAC I/O (AES Imaging);HT-Rack XPS Imaging Board MK1;HT-Rack XPS/AES Imaging Board MK2,;HT-Rack Manual Channeltron PSU;HT-Rack Channeltron PSU;HT-Rack Charge Neutraliser;
//Xray Manual PSU (Emission Stabiliser);Xray Spellman PSU;Electron-gun Manual PSU,;Electron-gun Accel PSU;Electron-gun Spellman PSU;Ion-Gun Manual PSU;K4 Vacuum Controller;Hemi-Spherical Analyser;Mirror Hemi-Spherical Analyser;Channeltrons;Channel Plates;Secondary Electron Detector;Camera;Stage;Selected Area Motor;Motorised Iris;Carousel;
//VME Kratos Slow-Scan Generator MK2;NICPU Delay Line Detector;NICPU Analyser HT Unit;NICPU Magnet and Charge Neutraliser Unit;NICPU Motor Control;NICPU X-ray PSU;NICPU Deflection Unit;NICPU Ion Gun PSU;NICPU Processor;NICPU VM-1 Vacuum Controller;NOVA Chamber;NICPU Manual UV Lamp;Electron-gun Kratos FEG;VME Synchronous Serial Interface;Sample Current Imaging;NICPU Stage Manual Control Unit"
static strconstant f_vme_baud_rate_names 						= "4800;9600;19200;38400"
static strconstant f_host_serial_port_names					= "COM1;COM2"
static strconstant f_vme_ethernet_hostname_names				= "sa_inst_0;sa_inst_1;sa_inst_2;sa_inst_3;sa_inst_4;sa_inst_5;sa_inst_6;sa_inst_7;os9"
static strconstant f_config_option_state_names				= "Disabled;Enabled"
static strconstant f_host_slave_config_names					= "Serial Port;Ethernet;Snapper8 Framestore;Passwords;User Logins;Parallel Port;Imagenation Framestore"
static strconstant f_k4_vacuum_config_names					= "Auxiliary Chamber Fitted;Turbo Isolate Value (V1) Fitted;Sample Magazine Fitted;Ion Gauge Fitted To STC;Manipulator Fitted;MHSA Entrance Aperture Motor"
static strconstant f_lens_psu_polarity_names					= "Positive;Negative;Switchable"
static strconstant f_lens_psu_range_limit_names				= "5 kV;6 kV;?;?;3 kV;10 kV"
static strconstant f_lens_double_psu_options_names			= "PSU 1;PSU 2;PSU 3;PSU 4"
static strconstant f_lens_single_psu_options_names				= "PSU 1;PSU 2;PSU 3;PSU 4;PSU 5;PSU 6;PSU 7;PSU 8"
static strconstant f_lens_options_names							= "Magnetic;V 1;V 2a;V 2b;V 3;V 4;V 5;V 6;V 7;V 8;V 9;V 2"
static strconstant f_channeltron_psu_options_names			= "3-Channel (3);2x3-Channel (6);3x3-Channel (9);3-Channel + 5-channel (8);5-channel (5)"
static strconstant f_configuration_section_names				= "Host/Slave Configuration;Instrument Configuration;Operating Configuration"
static strconstant f_esca_xray_anode_option_names				= "Single (Mg);Dual (Mg/Al);Single (Al);Dual and Mono"
static strconstant f_esca_manipulator_option_names			= "Linear Motion Probe;10 Position Carousel;Load Lock Probe"
//static strconstant f_esca_jp_xray_emission_option_names		= "0;10;20;30;40;50"
static strconstant f_esca_jp_xray_emission						= "0;0.01;0.02;0.03;0.04;0.05"
//static strconstant f_esca_jp_xray_accelHT_option_names			= "2;4;6;8;10;12;15"
static strconstant f_esca_jp_xray_accelHT						= "2000;4000;6000;8000;10000;12000;15000"
//static strconstant f_esca_xray_emission_option_names			= "0;5;10;15;20;25;30"
static strconstant f_esca_xray_emission							= "0;0.005;0.01;0.015;0.02;0.025;0.03"
//static strconstant f_esca_xray_accelHT_option_names				= "2;4;6;8;10;12"
static strconstant f_esca_xray_accelHT							= "2000;4000;6000;8000;10000;12000"
static strconstant f_esca_xray_anode_type_names				= "Mg;Al;Mono"
static strconstant f_off_on_switch_names						= "Off;On;Going To Off;Going To On"
//static strconstant f_esca_ion_gun_accelHT_option_names			= "0.5;1.0;1.5;2.0"
static strconstant f_esca_ion_gun_accelHT						= "0.5;1.0;1.5;2.0"
//static strconstant f_esca_ion_gun_emission_option_names		= "10;20;30"
static strconstant f_esca_ion_gun_emission						= "10;20;30"
static strconstant f_esca_calibrate_option_names				= "Never;On Initialisation;Before Experiment;Before Scan"
static strconstant f_esca_resolution_options_names				= "Manual;Two Options;ESCA K1 PEs"
static strconstant f_esca_resolution_names						= "Low;High;Error;Error"
static strconstant f_analyser_option_names						= "?;Mirror HSA;DuPont (ESCA 3X00)"
static strconstant f_neutraliser_state_names					= "Switch Off;Switch On;On For Acquisition;Under Manual Control"
//static strconstant f_detector_timer_counter_config_names		= "3 Detector HSA;5 Detector HSA;8 Detector HSA;8 Detector HSA/MHSA;1 Detector Analyser"
static strconstant f_hardware_control_names					= "Turn Off;Turn On;On For Acquisition;Manual Settings"
static strconstant f_energy_reference_names					= "Mg;Al;K.E.;Ag;He I;He II;Zr;Ti;Al (Mono)"
static strconstant f_energy_reference_values					= "1253.60;1486.61;0;2984.20;21.21;40.80;2042.40;4510;1486.69"
static strconstant f_anode_names 									= "Magnesium;Aluminium;None"
static strconstant f_stage_axes_names 							= "X Axis;Y Axis;Z Axis;Rotation X;Rotation Y;Rotation Z;Gripper;Elevator"
static strconstant f_aperture_sizes_names 						= "3x12 mm;10 mm;2 mm;1 mm;400 µm;150 µm"
static strconstant f_iris_positions_names 						= "3x12 mm;2 mm;1 mm;400 µm;150 µm;10 mm;10 mm;10 mm;Sp. Shield;3x12 mm"
static strconstant xps_energy_scale_names 						= "B. E.;K. E."
static strconstant f_egun_filament_type_names 					= "Thermal LaB6 Filament;Thermal Field Emission"
static strconstant f_egun_parameter_names 						= "Accel HT;Filament;Emission;Extractor Bias;Suppressor Bias;Spot Size Lens;Focus Lens;Alignment X;Alignment Y;Stigmator X;Stigmator Y;Collector Bias;Multiplier Bias;Black Level"
static strconstant f_sed_operating_mode_names					= "Off;SE1;SE2;BS1;BS2"
//static strconstant f_xray_spellman_psu_options_names			= "Mg;Al;Mono (Al);M.F. Mono;UV I;Ag;Zr;Ti;Mono (Ag);UV II"
//static strconstant f_xray_spellman_psu_source_names			= "Source 1;Source 2;Source 3;Source 4;Source 5;Source 6"
static strconstant f_lens_sweep_options_names					= "Sweep Lens;Sweep Analyser"
static strconstant f_xsam_carousel_option_names				= "9 Position Carousel;10 Position Carousel"
static strconstant f_stage_sequence_names						= ""//
//"Load platen from Elevator top level;Unload platen to Elevator top level;Load platen from Elevator middle level;Unload platen to Elevator middle level;Load platen from Elevator bottom level;Unload platen to Elevator bottom level;Go to Platen picture position from INT ref;Go to XPS position from INT ref;Go to Microscope position from INT ref;Go to INT ref from Platen image position;
//Sample Thickness - Unused;Platen image position;XPS analysis position;Microscope position;INT Ref Position;SAC Ref Position - Unused;SAC Zone x Upper Limit - x value only ;SAC Zone x Lower Limit - x value only;SAC Zone y Upper Limit - y value only;SAC Zone y Lower Limit - y value only;SAC Zone z Upper Limit - z value only;SAC Zone z Lower Limit - z value only;
//SEC Zone x Upper Limit - x value only;SEC Zone x Lower Limit - x value only;SEC Zone y Upper Limit - y value only;SEC Zone y Lower Limit - y value only;SEC Zone z Upper Limit - z value only;SEC Zone z Lower Limit - z value only;INT Zone x Upper Limit - x value only;INT Zone x Lower Limit - x value only;INT Zone y Upper Limit - y value only;
//INT Zone y Lower Limit - y value only;INT Zone z Upper Limit - z value only;INT Zone z Lower Limit - z value only;Gripper Open;Gripper Closed;Elevator Level 1 - Read back only;Elevator Level 1 Drop - Read back only;Elevator Level 2 - Read back only;Elevator Level 2 Drop - Read back only;Elevator Level 3 - Read back only;Elevator Level 3 Drop - Read back only;
//Analysis Datum;SAC Datum;Sample load sequence;Sample unload sequence;Go to INT rest position from SAC;Go to INT rest position from SEC;Go to INT rest position from INT;Compu Centric Centre of Rotation;Sample exchange coordinate;Elevator Raised Position;Elevator Lowered Position;Nova stage condition sequence"
static strconstant f_esca_k1_resolution_names					= "PE 8;PE 16;PE 32;PE 80"
static strconstant f_esca_k1_aperture_names					= "Slot 1;Slot 2;Slot 3;Slot 4"
static strconstant f_esca_k1_resolution_values					= "8;16;32;80"
//static strconstant f_esca_k1_resolution_exact_default_values		= "7.875;15.75;31.5;78.75"
static strconstant f_esca_k1_lens_modes_names					= "Small;Macro"
//static strconstant f_nicpu_spectrometer_option_names			= "FRR;ISS;UPS;TOF"
//static strconstant f_nicpu_motor_control_option_names			= "8 Stepper Motors and 2 Linear Motors;8 Stepper Motors;10 Stepper Motors"
//static strconstant f_nicpu_magnet_unit_option_names			= "Mark I"
//static strconstant f_nicpu_xray_psu_anode_materials_names		= "Mg;Al;Mono (Al);M.F. Mono;Ag;Zr;Ti;Mono (Ag)"
//static strconstant f_nicpu_xray_psu_filaments_names			= "Mono 1;Mono 2;Mono 3;Dual 1;Dual 2"
static strconstant f_nicpu_ion_gun_type_names					= "Minibeam 1;Minibeam 2;Minibeam 3;Minibeam 4;Minibeam 5"
static strconstant f_nicpu_ion_gun_filament_names			= "Filament 1;Filament 2"
static strconstant f_nicpu_vacuum_config_names				= ""//
//"MHSA Entrance Aperture Motor;CCG/Ion Gauge Fitted To SEC/STC;Manipulator Fitted;V8 and V9 Fitted;Sputter Shield Control;SAC MAGLEV TMP Fitted;UPS Fitted;NOVA MAGLEV Differential Pump;Ultra External Sample Exchange;NOVA MAGLEV;Ultra Dual Probe Fitted;Ultra Aux Chamber Fitted with STC Ion Gun;Ultra Fast Entry Lock Fitted;Ultra Fast Entry Lock Fitted with MAGLEV TMP;
//Ultra Fast Entry Lock Fitted with TIC Cart Readback;SAC Ion Gun Fitted;NOVA Differential Pump"
static strconstant f_camera_type_names							= "Analogue (requires framestore);PixeLINK FireWire (framestoreless)"
static strconstant f_coarse_image_rotation_names				= "None;90 degrees anticlockwise;180 degrees anticlockwise;270 degrees anticlockwise"
static strconstant f_nicpu_motor_step_mode_names				= "Full Step, High Current;Full Step, Medium Current;Full Step, Low Current;Half Step, High Current;Half Step, Medium High Current;Half Step, Medium Low Current;Half Step, Low Current;Quarter Step, High Current;Quarter Step, Medium High Current;Quarter Step, Medium Low Current;Quarter Step, Low Current"
//static strconstant f_nicpu_motor_holding_current_names		= "None;Low;Medium;High"
static strconstant f_ion_gun_gas_state_names					= "Switch Off;Switch On;As Previous State;Under Manual Control"
static strconstant f_nicpu_xray_psu_version_names			= "49-240;BE5856AA"
//static strconstant f_nicpu_xray_control_unit_version_names	= "BE1319AA;BE1319AB;BE1319AC;BE1319AD"


static structure KratosDsetobject
	wave IDlist
	wave type
	wave /T name
	wave /T strvalue
	wave numvalue
	wave /T units
	wave /T flags
	wave /T nameofdatawave

	variable id
	string objectname
	string header
	string appendtodetector
	string lastID
	string IDchain
endstructure


static structure KratosDsetobjectlist
	wave object_offsets
	wave /T object_name
	wave object_nextlist
	variable maxobjects
	variable currentobject
	variable loaded
	variable startofobjectlist
endstructure


static function KratosDSET_initaddobject(Dsetobject, ID, type, name,  units, flags, nameofdatawave)
	struct KratosDsetobject &Dsetobject; variable ID; variable type; 	string name; string units; string flags; string nameofdatawave
	variable i = DimSize(Dsetobject.IDlist,  0)
	Redimension /N=(i+1) Dsetobject.IDlist, Dsetobject.type, Dsetobject.name, Dsetobject.strvalue, Dsetobject.numvalue, Dsetobject.nameofdatawave, Dsetobject.units, Dsetobject.flags
	Dsetobject.IDlist[i]=ID
	Dsetobject.type[i]=type
	Dsetobject.name[i]=name
	Dsetobject.strvalue[i]=""
	Dsetobject.numvalue[i]=NaN
	Dsetobject.units[i]= units
	Dsetobject.flags[i] = flags
	Dsetobject.nameofdatawave[i]= nameofdatawave
end


static function KratosDSET_IDtopnt(Dsetobject, ID)
	struct KratosDsetobject &Dsetobject; variable ID
	FindValue /V=(ID) Dsetobject.IDlist
	return V_value
end


static function KratosDSET_checkID(file, Dsetobject, ID)
	variable file ; struct KratosDsetobject &Dsetobject ; 	variable ID
	// get the corresponding index in the ID wave
	variable pnt = KratosDSET_IDtopnt(Dsetobject, ID)
	if(pnt!=-1)
		variable type = Dsetobject.type[pnt]
		variable i=0, tmp=0, tmp2=0
		variable num100 = (type-mod(type,100))/100 ; type -= 100*num100
		variable num10 = (type-mod(type,10))/10 ; type -= 10*num10
		variable num1 = (type-mod(type,1))/1
		fstatus file
		string tmps = ""
		sprintf tmps, "%10.0f", (V_filePOS-4) ; Debugprintf2("Reading \""+Dsetobject.name[pnt]+"\" (ID:"+num2str(ID)+") at positition "+tmps+"...",1)
		if( num100 == 0 && num10 == 0)
			if(num1<6 && num1 != 0)
				Fbinread /B=2/F=(num1) file, tmp ; Dsetobject.numvalue[pnt] = tmp
			elseif(num1>=6)
				Dsetobject.strvalue[pnt]=KratosDSET_readstr(file) // only for num1=6, but there are until now no 7, 8, 9
			else
			// do nothing
			endif		
		else // we have to read an array
			Fbinread /U/B=2/F=(num10) file, tmp // num10 should always be 3
			Debugprintf2("Reading "+num2str(tmp)+" values.",1)
			string tmpwavename=directory+":"+Gtmpwavename+Dsetobject.nameofdatawave[pnt]+StringFromList(0, Dsetobject.IDchain  ,";")
			//string tmpwavename=directory+":"+Gtmpwavename+Dsetobject.nameofdatawave[pnt]+Dsetobject.nameofdatawave[KratosDSET_IDtopnt(Dsetobject, str2num(StringFromList(0, Dsetobject.IDchain  ,";")))]
			Make /O/R/N=(tmp) $tmpwavename /wave=tmpwave
			Fbinread /B=2/F=(num1) file, tmpwave
		endif
		// save the last ID which was read
		Dsetobject.lastID = num2str(Dsetobject.IDlist[pnt])
		// in case we should read some flags
		if(strlen(Dsetobject.flags[pnt]) !=0 )
			tmps = StringByKey(num2str(Dsetobject.numvalue[pnt]),Dsetobject.flags[pnt], "=", ";")
			if(strlen(tmps)!=0)
				Dsetobject.strvalue[pnt] = tmps
			else
				Fstatus file
				sprintf tmps, "%10.0f", (V_filePOS-4) ; Debugprintf2("Error in Flags at position "+tmps+", ID: "+num2str(Dsetobject.IDlist[pnt])+" ; Flag = "+num2str(Dsetobject.numvalue[pnt]),0)
				//Debugprintf2("Unknown ID "+num2str(ID)+" at position "+num2str(V_filePOS)+". Please check with kal and add to script! (ID: "+num2str(currentobject+1)+")",0)
			endif
		endif
	else
		// no suitable ID found, will be handled in the calling routine --> check for markers or unknown ID
		return -1
	endif
	return 0
end


static function KratosDSET_resetDsetobject(Dsetobject) // 1298 known objects
	struct KratosDsetobject &Dsetobject

	NewDatafolder /O root:Packages ; NewDatafolder /O $directory
	Make /FREE/O/D/N=(0) IDlist ; wave Dsetobject.IDlist = IDlist
	Make /FREE/O/B/U/N=(0) type ; wave Dsetobject.type = type
	Make /FREE/O/T/N=(0) name ; wave /T Dsetobject.name = name
	Make /FREE/O/T/N=(0) strvalue ; wave /T Dsetobject.strvalue = strvalue
	Make /FREE/O/D/N=(0) numvalue ; wave Dsetobject.numvalue = numvalue
	Make /FREE/O/T/N=(0) units ; 	wave /T Dsetobject.units = units
	Make /FREE/O/T/N=(0) flags ; wave /T Dsetobject.flags = flags
	Make /FREE/O/T/N=(0) nameofdatawave ; wave /T Dsetobject.nameofdatawave = nameofdatawave


	Dsetobject.objectname = ""
	Dsetobject.lastID = ""
	Dsetobject.IDchain = ""
	Dsetobject.id = NAN

//the following populates the list of DSET objects with ID etc. 
//for commented out objects the datatype is unknown (never had them in my files until now)
//KratosDSET_initaddobject(Dsetobject,/ID/,/datatype/,/"name for note"/,/"unit"/, /"Flags to string"/,/"name of wave"/)
	//	Datatypes:
	//	0: no value
	// 1:	Signed one-byte integer.
	//	2:	Signed 16-bit word; two bytes.
	//	3:	Signed 32-bit word; four bytes.
	//	4:	32-bit IEEE floating point; four bytes.
	//	5:	64-bit IEEE floating point; eight bytes.
	
	// 6: string

	//	33: array of f =3: Signed 32-bit word; four bytes.
	//	34: array of f =4:	32-bit IEEE floating point; four bytes.
	//	35: array of f =5:	64-bit IEEE floating poin; eight bytes.
	
	KratosDSET_initaddobject(Dsetobject,1,3,"Technique","", "0=AES;1=ISS;2=SIMS;3=XPS;4=SEM;5=SNMS;6=RGA;8=UPS","")//AID_technique 0..15?
	KratosDSET_initaddobject(Dsetobject,2,3,"Scan type","","0=Spectrum;1=Irregular;2=Mapping;3=Linescan;4=profile scan;5=Snapshot","")//AID_scan_type
	KratosDSET_initaddobject(Dsetobject,3,5,"Spectrum scan start","eV","","")//AID_spectrum_start
	KratosDSET_initaddobject(Dsetobject,4,5,"Spectrum scan step size","eV","","")//AID_spectrum_step_size
	KratosDSET_initaddobject(Dsetobject,5,6,"Abscissa label","","","")//FID_abscissa_label
	KratosDSET_initaddobject(Dsetobject,6,6,"Abscissa units","","","")//FID_abscissa_units
	KratosDSET_initaddobject(Dsetobject,7,5,"Dwell time","seconds","","")//AID_dwell_time
	KratosDSET_initaddobject(Dsetobject,8,6,"Ordinate label","","","")//FID_ordinate_label
	KratosDSET_initaddobject(Dsetobject,9,6,"Ordinate units","","","")//FID_ordinate_units
	KratosDSET_initaddobject(Dsetobject,10,3,"# ordinate values","","","")//FID_no_abscissa_values
	KratosDSET_initaddobject(Dsetobject,11,35,"Abscissa values","","","abscval")//FID_abscissa_values
	KratosDSET_initaddobject(Dsetobject,12,34,"Ordinate values","","","ordval")//FID_ordinate_values
	KratosDSET_initaddobject(Dsetobject,13,6,"Sample name","","","")//AID_sample_name
	KratosDSET_initaddobject(Dsetobject,14,5,"X-coordinate","millimetres","","")//FID_xcoord
	KratosDSET_initaddobject(Dsetobject,15,5,"Y-coordinate","millimetres","","")//FID_ycoord
	KratosDSET_initaddobject(Dsetobject,16,5,"Z-coordinate","millimetres","","")//FID_zcoord
	KratosDSET_initaddobject(Dsetobject,17,5,"Theta-coordinate","radians","","")//FID_theta_coord
	KratosDSET_initaddobject(Dsetobject,18,5,"Phi-coordinate","radians","","")//FID_phi_coord
	KratosDSET_initaddobject(Dsetobject,20,5,"Cumulative etch time","seconds","","")//FID_total_etch_time
	KratosDSET_initaddobject(Dsetobject,21,6,"Excitation name","","","")//FID_excitation_name
	KratosDSET_initaddobject(Dsetobject,22,5,"Excitation energy","eV","","")//FID_excitation_energy
	KratosDSET_initaddobject(Dsetobject,23,5,"Excitation strength","","","")//FID_excitation_strength
	KratosDSET_initaddobject(Dsetobject,24,3,"Primary ion mass","amu","","")//FID_primary_mass
	KratosDSET_initaddobject(Dsetobject,25,3,"# points per line in map","","","")//AID_coord_n_points_x
	KratosDSET_initaddobject(Dsetobject,26,3,"# lines in map","","","")//AID_coord_n_lines_y
	KratosDSET_initaddobject(Dsetobject,27,3,"Map start x","","","")//FID_map_start_x
	KratosDSET_initaddobject(Dsetobject,28,3,"Map start y","","","")//FID_map_start_y
	KratosDSET_initaddobject(Dsetobject,29,3,"Map end x","","","")//FID_map_end_x
	KratosDSET_initaddobject(Dsetobject,30,3,"Map end y","","","")//FID_map_end_y
	KratosDSET_initaddobject(Dsetobject,31,5,"Etch time","seconds","","")//AID_etch_time
	KratosDSET_initaddobject(Dsetobject,32,33,"Map counts","","","")//FID_map_counts
	KratosDSET_initaddobject(Dsetobject,33,4,"Minimum intensity","","","")//FID_min_intensity
	KratosDSET_initaddobject(Dsetobject,34,4,"Maximum intensity","","","")//FID_max_intensity
	KratosDSET_initaddobject(Dsetobject,35,5,"X step size","millimetres","","")//FID_delta_x
	KratosDSET_initaddobject(Dsetobject,36,5,"Y step size","millimetres","","")//FID_delta_y
	KratosDSET_initaddobject(Dsetobject,37,6,"Acquisition name","","","")//AID_region_name
	KratosDSET_initaddobject(Dsetobject,38,3,"State change type","","0=Etch;1=Position;2=Counter;9=Ion Gun Gas;10=Delay","")//FID_change_of_state
	KratosDSET_initaddobject(Dsetobject,39,5,"Gun current","amps","","")//AID_gun_current
	KratosDSET_initaddobject(Dsetobject,40,5,"Gun voltage","volts","","")//AID_gun_voltage
	//KratosDSET_initaddobject(Dsetobject,41,0,"Analyser mode","","","")//FID_analyser_mode
	KratosDSET_initaddobject(Dsetobject,42,5,"Pass energy","","","")//AID_pass_energy_nominal
	//KratosDSET_initaddobject(Dsetobject,43,0,"Retard ratio","","","")//AID_retard_ratio_nominal
	//KratosDSET_initaddobject(Dsetobject,44,0,"Abscissa end","","","")//FID_abscissa_end
	//KratosDSET_initaddobject(Dsetobject,45,0,"Minimum sweeps","","","")//FID_min_scans
	//KratosDSET_initaddobject(Dsetobject,46,0,"Maximum sweeps","","","")//FID_max_scans
	//KratosDSET_initaddobject(Dsetobject,47,0,"Required counts","","","")//FID_required_counts
	//KratosDSET_initaddobject(Dsetobject,48,0,"Abscissa point","","","")//FID_abscissa_point
	//KratosDSET_initaddobject(Dsetobject,49,0,"S/n ratio","","","")//FID_signal_to_noise
	//KratosDSET_initaddobject(Dsetobject,50,0,"Magnification","","","")//FID_magnification
	KratosDSET_initaddobject(Dsetobject,51,5,"Map energy/mass","","","")//AID_map_energy
	//KratosDSET_initaddobject(Dsetobject,52,0,"First background","","","")//FID_background_1
	//KratosDSET_initaddobject(Dsetobject,53,0,"Second background","","","")//FID_background_2
	//KratosDSET_initaddobject(Dsetobject,54,0,"FAT code","","","")//FID_fat_code
	//KratosDSET_initaddobject(Dsetobject,55,0,"FRR code","","","")//FID_frr_code
	//KratosDSET_initaddobject(Dsetobject,56,0,"Mag code","","","")//FID_mag_code
	//KratosDSET_initaddobject(Dsetobject,57,0,"Excitation code","","","")//FID_excitation_code
	//KratosDSET_initaddobject(Dsetobject,58,0,"Filament","","","")//AID_filament
	KratosDSET_initaddobject(Dsetobject,59,3,"Loop index","","","")//AID_current_counter
	//KratosDSET_initaddobject(Dsetobject,60,0,"Etch table","","","")//FID_etch_table
	KratosDSET_initaddobject(Dsetobject,61,3,"Loop index limit","","","")//AID_counter_limit
	//KratosDSET_initaddobject(Dsetobject,62,0,"Map geometry","","","")//FID_map_geometry
	KratosDSET_initaddobject(Dsetobject,63,5,"Pre-etch delay","","","")//FID_pre_etch_delay
	KratosDSET_initaddobject(Dsetobject,64,5,"Post etch delay","","","")//FID_post_etch_delay
	//KratosDSET_initaddobject(Dsetobject,65,0,"Registration coords","","","")//FID_registration
	//KratosDSET_initaddobject(Dsetobject,66,0,"Multi-point","","","")//FID_multi_point
	//KratosDSET_initaddobject(Dsetobject,67,0,"Control","","","")//FID_control
	//KratosDSET_initaddobject(Dsetobject,68,0,"Detector mask","","","")//FID_detector_mask
	//KratosDSET_initaddobject(Dsetobject,69,0,"Multi-point coords","","","")//FID_multi_point_coords
	//KratosDSET_initaddobject(Dsetobject,70,0,"Analyser x-coord","","","")//FID_analyser_x
	//KratosDSET_initaddobject(Dsetobject,71,0,"Analyser y-coord","","","")//FID_analyser_y
	//KratosDSET_initaddobject(Dsetobject,72,0,"Processing history","","","")//FID_history
	//KratosDSET_initaddobject(Dsetobject,73,0,"Loop start","","","")//FID_loop_start
	//KratosDSET_initaddobject(Dsetobject,74,0,"Loop end","","","")//FID_loop_end
	//KratosDSET_initaddobject(Dsetobject,75,0,"Quantitation regions","","","")//FID_regions
	//KratosDSET_initaddobject(Dsetobject,76,0,"Components","","","")//FID_components
	//KratosDSET_initaddobject(Dsetobject,77,0,"Map energies","","","")//FID_map_energy_array
	//KratosDSET_initaddobject(Dsetobject,78,0,"Related objects","","","")//FID_related_objects
	//KratosDSET_initaddobject(Dsetobject,79,0,"Annotation","","","")//FID_annotation
	//KratosDSET_initaddobject(Dsetobject,80,0,"Abscissa shift","","","")//FID_abscissa_shift
	//KratosDSET_initaddobject(Dsetobject,81,0,"Carousel Increments","","","")//FID_carousel_increments
	//KratosDSET_initaddobject(Dsetobject,82,0,"Electron Gun Mag.","","","")//FID_eg_magnification
	//KratosDSET_initaddobject(Dsetobject,83,0,"Electon gun zoom","","","")//FID_eg_zoom
	//KratosDSET_initaddobject(Dsetobject,84,0,"Full scale deflection","","","")//FID_full_deflection
	//KratosDSET_initaddobject(Dsetobject,85,0,"Manipulator positions","","","")//FID_position_table
	//KratosDSET_initaddobject(Dsetobject,86,0,"Position Type","","","")//FID_position_type
	//KratosDSET_initaddobject(Dsetobject,87,0,"Eucentric Correction","","","")//FID_eucentric_correction
	//KratosDSET_initaddobject(Dsetobject,88,0,"Background objects","","","")//FID_background_objects
	//KratosDSET_initaddobject(Dsetobject,89,0,"Colour array","","","")//FID_colour_array
	//KratosDSET_initaddobject(Dsetobject,90,0,"Map start X","","","")//FID_map_x0
	//KratosDSET_initaddobject(Dsetobject,91,0,"Map end X","","","")//FID_map_x1
	//KratosDSET_initaddobject(Dsetobject,92,0,"Map start Y","","","")//FID_map_y0
	//KratosDSET_initaddobject(Dsetobject,93,0,"Map end Y","","","")//FID_map_y1
	//KratosDSET_initaddobject(Dsetobject,94,0,"Coordinate type","","","")//FID_coord_type
	//KratosDSET_initaddobject(Dsetobject,95,0,"Map scan angle","","","")//FID_map_scan_angle
	//KratosDSET_initaddobject(Dsetobject,96,0,"Process ID',27h,'s","","","")//FID_process_ids
	//KratosDSET_initaddobject(Dsetobject,97,0,"Position Name","","","")//FID_position_name
	//KratosDSET_initaddobject(Dsetobject,98,0,"Position Values","","","")//FID_position_values
	KratosDSET_initaddobject(Dsetobject,99,3,"# Sweeps completed","","","")//AID_n_sweeps_completed
	//KratosDSET_initaddobject(Dsetobject,100,0,"MPA X coordinate","","","")//FID_mp_x
	//KratosDSET_initaddobject(Dsetobject,101,0,"MPA Y coordinate","","","")//FID_mp_y
	//KratosDSET_initaddobject(Dsetobject,102,0,"MPA label","","","")//FID_mp_label
	//KratosDSET_initaddobject(Dsetobject,103,0,"MPA units","","","")//FID_mp_units
	//KratosDSET_initaddobject(Dsetobject,104,0,"MPA coordinate system","","","")//FID_mp_coordtype
	//KratosDSET_initaddobject(Dsetobject,105,0,"MPA parent dataset","","","")//FID_mp_dset
	//KratosDSET_initaddobject(Dsetobject,106,0,"MPA parent object","","","")//FID_mp_pid
	//KratosDSET_initaddobject(Dsetobject,107,0,"MPA position table","","","")//FID_mp_table
	//KratosDSET_initaddobject(Dsetobject,108,0,"Multipoint Information","","","")//FID_multipoint
	//KratosDSET_initaddobject(Dsetobject,109,0,"Peak name","","","")//FID_peak_name
	//KratosDSET_initaddobject(Dsetobject,110,0,"Object Aborted","","","")//FID_aborted
	//KratosDSET_initaddobject(Dsetobject,111,0,"Lower limit","","","")//FID_lower_limit
	//KratosDSET_initaddobject(Dsetobject,112,0,"Upper limit","","","")//FID_upper_limit
	KratosDSET_initaddobject(Dsetobject,113,6,"Instrument name","","","")//AID_instrument
	//KratosDSET_initaddobject(Dsetobject,114,0,"Transmission Function","","","")//FID_transmission_func
	//KratosDSET_initaddobject(Dsetobject,115,0,"Type of Ion Gun","","","")//FID_ion_gun_type
	//KratosDSET_initaddobject(Dsetobject,116,0,"Etch Position ID","","","")//FID_etch_position_id
	//KratosDSET_initaddobject(Dsetobject,117,0,"Pallet Type","","","")//FID_pallet_type
	//KratosDSET_initaddobject(Dsetobject,118,0,"Channels per AMU","","","")//FID_channels_amu
	//KratosDSET_initaddobject(Dsetobject,119,0,"Default Sample Bias","","","")//FID_default_sample_bias
	//KratosDSET_initaddobject(Dsetobject,120,0,"Sample Bias","","","")//FID_sample_bias
	//KratosDSET_initaddobject(Dsetobject,121,0,"Polarity","","","")//FID_polarity
	//KratosDSET_initaddobject(Dsetobject,122,0,"Number Of Frames","","","")//FID_n_frames
	//KratosDSET_initaddobject(Dsetobject,123,0,"Quadrupole DC","","","")//FID_quadrupole_dc
	//KratosDSET_initaddobject(Dsetobject,124,0,"Ion Gun Name","","","")//FID_ion_gun_name
	//KratosDSET_initaddobject(Dsetobject,125,0,"Ion Type","","","")//FID_ion_type
	//KratosDSET_initaddobject(Dsetobject,126,0,"Ion Gun Magnification","","","")//FID_ion_gun_magnification
	//KratosDSET_initaddobject(Dsetobject,127,0,"Ion Gun Zoom","","","")//FID_ion_gun_zoom
	//KratosDSET_initaddobject(Dsetobject,128,0,"Ion Gun Current","","","")//FID_ion_gun_current
	//KratosDSET_initaddobject(Dsetobject,129,0,"Ion Gun Voltage","","","")//FID_ion_gun_voltage
	//KratosDSET_initaddobject(Dsetobject,130,0,"Ion Spot Name","","","")//FID_ion_spot_name
	//KratosDSET_initaddobject(Dsetobject,131,0,"Ion Spot Size","","","")//FID_ion_spot_size
	//KratosDSET_initaddobject(Dsetobject,132,0,"SIMS Neutraliser","","","")//FID_neutraliser
	//KratosDSET_initaddobject(Dsetobject,133,0,"Raster Name","","","")//FID_raster_name
	//KratosDSET_initaddobject(Dsetobject,134,0,"Raster Shift X (%)","","","")//FID_raster_shift_x
	//KratosDSET_initaddobject(Dsetobject,135,0,"Raster Shift Y (%)","","","")//FID_raster_shift_y
	//KratosDSET_initaddobject(Dsetobject,136,0,"Raster Size X (%)","","","")//FID_raster_size_x
	//KratosDSET_initaddobject(Dsetobject,137,0,"Raster Size Y (%)","","","")//FID_raster_size_y
	//KratosDSET_initaddobject(Dsetobject,138,0,"# Pixels In Raster X","","","")//FID_raster_pixels_x
	//KratosDSET_initaddobject(Dsetobject,139,0,"# Pixels In Raster Y","","","")//FID_raster_pixels_y
	//KratosDSET_initaddobject(Dsetobject,140,0,"# Pixels In Border X","","","")//FID_raster_border_x
	//KratosDSET_initaddobject(Dsetobject,141,0,"# Pixels In Border Y","","","")//FID_raster_border_y
	//KratosDSET_initaddobject(Dsetobject,142,0,"Temperatures Cycles","","","")//FID_temperature_table
	//KratosDSET_initaddobject(Dsetobject,143,0,"Temperature","","","")//FID_temperature
	//KratosDSET_initaddobject(Dsetobject,144,0,"Profile Cycles","","","")//FID_profile_cycles
	//KratosDSET_initaddobject(Dsetobject,145,0,"Charge Neut. Current","","","")//FID_charge_neut_current
	//KratosDSET_initaddobject(Dsetobject,146,0,"Charge Neut. Voltage","","","")//FID_charge_neut_voltage
	//KratosDSET_initaddobject(Dsetobject,147,0,"Quadrupole Resolution","","","")//FID_quad_resolution
	//KratosDSET_initaddobject(Dsetobject,148,0,"Ion Gun Number","","","")//FID_ion_gun_number
	//KratosDSET_initaddobject(Dsetobject,149,0,"Operator name","","","")//AID_operator_name
	KratosDSET_initaddobject(Dsetobject,151,6,"Date Acquired","","","")//AID_date_and_time
	//KratosDSET_initaddobject(Dsetobject,152,0,"Probe Gas","","","")//FID_probe_gas
	//KratosDSET_initaddobject(Dsetobject,153,0,"Probe Mass","","","")//FID_probe_mass
	//KratosDSET_initaddobject(Dsetobject,154,0,"Probe Energy","","","")//FID_probe_energy
	//KratosDSET_initaddobject(Dsetobject,155,0,"Scattering Angle","","","")//FID_scatter_angle
	//KratosDSET_initaddobject(Dsetobject,156,0,"Profile Gate Pattern","","","")//FID_gate_pattern
	//KratosDSET_initaddobject(Dsetobject,157,0,"Profiling Gate Number","","","")//FID_gate_number
	//KratosDSET_initaddobject(Dsetobject,158,0,"Next Gate Object No.","","","")//FID_next_gate_object
	//KratosDSET_initaddobject(Dsetobject,159,0,"Profile Energy/Mass","","","")//FID_profile_energy
	//KratosDSET_initaddobject(Dsetobject,160,0,"Intervention Type","","","")//FID_intervention_type
	//KratosDSET_initaddobject(Dsetobject,161,0,"Monitor Signal Ratio","","","")//FID_signal_ratio
	//KratosDSET_initaddobject(Dsetobject,162,0,"Intervention Object","","","")//FID_intervention_objects
	//KratosDSET_initaddobject(Dsetobject,163,0,"Intervention Cycle","","","")//FID_intervention_cycle
	//KratosDSET_initaddobject(Dsetobject,164,0,"Intervention Gate","","","")//FID_intervention_gate
	//KratosDSET_initaddobject(Dsetobject,165,0,"Intervention Nt. Bias","","","")//FID_intervention_nt_bias
	//KratosDSET_initaddobject(Dsetobject,166,0,"Intervention Nt. Emission","","","")//FID_intervention_nt_emission
	//KratosDSET_initaddobject(Dsetobject,167,0,"Intervention Default Bias","","","")//FID_intervention_default_bias
	//KratosDSET_initaddobject(Dsetobject,168,0,"Intervention Sample Bias","","","")//FID_intervention_sample_bias
	//KratosDSET_initaddobject(Dsetobject,169,0,"Points have been edited","","","")//FID_points_edited
	KratosDSET_initaddobject(Dsetobject,170,3,"Processing History","","","")//FID_proc_hist // should be an array (3x)
	//KratosDSET_initaddobject(Dsetobject,171,0,"Sample Magazine Table","","","")//FID_sample_magazine_table
	//KratosDSET_initaddobject(Dsetobject,172,0,"Sample Magazine Index","","","")//FID_sample_magazine_index
	//KratosDSET_initaddobject(Dsetobject,173,0,"Sample Magazine Label","","","")//FID_sample_magazine_label
	//KratosDSET_initaddobject(Dsetobject,174,0,"Start Zalar Rotation","","","")//FID_zalar_rotation_start
	//KratosDSET_initaddobject(Dsetobject,175,0,"Stop Zalar Rotation","","","")//FID_zalar_rotation_stop
	//KratosDSET_initaddobject(Dsetobject,176,0,"Etch Positions","","","")//FID_etch_positions
	//KratosDSET_initaddobject(Dsetobject,177,0,"Fork Positions For Etching","","","")//FID_etch_fork_positions
	//KratosDSET_initaddobject(Dsetobject,178,0,"X-Ray Voltage Code","","","")//FID_xray_voltage_code
	//KratosDSET_initaddobject(Dsetobject,179,0,"X-Ray Current Code","","","")//FID_xray_current_code
	//KratosDSET_initaddobject(Dsetobject,180,0,"Ion Gun Voltage Code","","","")//FID_ion_gun_voltage_code
	//KratosDSET_initaddobject(Dsetobject,181,0,"Ion Gun Current Code","","","")//FID_ion_gun_current_code
	//KratosDSET_initaddobject(Dsetobject,182,0,"Position Index","","","")//FID_position_index
	//KratosDSET_initaddobject(Dsetobject,183,0,"No Licence","","","")//FID_no_licence
	//KratosDSET_initaddobject(Dsetobject,184,0,"Transfer Lens Aperture Index","","","")//FID_analyser_aperture_index
	//KratosDSET_initaddobject(Dsetobject,185,0,"Energy Filter Aperture Index","","","")//FID_mass_analyser_aperture_index
	//KratosDSET_initaddobject(Dsetobject,186,0,"Ion Gun Aperture Index","","","")//FID_ion_gun_aperture_index
	//KratosDSET_initaddobject(Dsetobject,187,0,"Transfer Lens Aperture Name","","","")//FID_analyser_aperture_name
	//KratosDSET_initaddobject(Dsetobject,188,0,"Energy Filter Aperture Name","","","")//FID_mass_analyser_aperture_name
	//KratosDSET_initaddobject(Dsetobject,189,0,"Ion Gun Aperture Name","","","")//FID_ion_gun_aperture_name
	//KratosDSET_initaddobject(Dsetobject,190,0,"Transfer Lens Aperture Position","","","")//FID_analyser_aperture_position
	//KratosDSET_initaddobject(Dsetobject,191,0,"Energy Filter Aperture Position","","","")//FID_mass_analyser_aperture_position
	//KratosDSET_initaddobject(Dsetobject,192,0,"Ion Gun Aperture Position","","","")//FID_ion_gun_aperture_position
	//KratosDSET_initaddobject(Dsetobject,193,0,"Ion Gun Mechanism Index","","","")//FID_ion_gun_aperture_mechanism_index
	//KratosDSET_initaddobject(Dsetobject,194,0,"Profile Depth Calibration","","","")//FID_depth_calibration
	//KratosDSET_initaddobject(Dsetobject,195,0,"Layer End Cycle","","","")//FID_depth_calib_end_cycle
	//KratosDSET_initaddobject(Dsetobject,196,0,"Sputter Rate","","","")//FID_depth_calib_sputter_rate
	//KratosDSET_initaddobject(Dsetobject,197,0,"RSF","","","")//FID_depth_calib_RSF
	//KratosDSET_initaddobject(Dsetobject,198,0,"Dose","","","")//FID_conc_calib_dose
	//KratosDSET_initaddobject(Dsetobject,199,0,"Matrix Species Object Number","","","")//FID_conc_calib_matrix
	//KratosDSET_initaddobject(Dsetobject,200,0,"Known Conc. Cycles","","","")//FID_conc_calib_cycles
	//KratosDSET_initaddobject(Dsetobject,201,0,"Sum for dose start cycles","","","")//FID_conc_calib_start_cycles
	//KratosDSET_initaddobject(Dsetobject,202,0,"Sum for dose end cycles","","","")//FID_conc_calib_end_cycles
	//KratosDSET_initaddobject(Dsetobject,203,0,"Ion Gun Con-focal","","","")//FID_ion_gun_confocal
	//KratosDSET_initaddobject(Dsetobject,204,0,"Direction","","","")//FID_direction
	//KratosDSET_initaddobject(Dsetobject,205,0,"Elevation","","","")//FID_elevation
	//KratosDSET_initaddobject(Dsetobject,206,0,"Orientation","","","")//FID_orientation
	//KratosDSET_initaddobject(Dsetobject,207,0,"Actual Working Distance","","","")//FID_actual_wd
	//KratosDSET_initaddobject(Dsetobject,208,0,"Neutraliser On","","","")//FID_neutraliser_on
	//KratosDSET_initaddobject(Dsetobject,209,0,"Neutraliser Bias Voltage","","","")//FID_neutraliser_bias
	//KratosDSET_initaddobject(Dsetobject,210,0,"Neutraliser Filament Current","","","")//FID_neutraliser_current
	//KratosDSET_initaddobject(Dsetobject,211,0,"Neutraliser Balance Voltage","","","")//FID_neutraliser_balance
	//KratosDSET_initaddobject(Dsetobject,212,0,"Primary Trim Coil Current","","","")//FID_primary_trim
	//KratosDSET_initaddobject(Dsetobject,213,0,"Detector number","","","")//FID_detector_number
	//KratosDSET_initaddobject(Dsetobject,214,0,"Separation ratio","","","")//FID_separation_ratio
	//KratosDSET_initaddobject(Dsetobject,215,0,"# detectors","","","")//FID_no_of_detectors
	KratosDSET_initaddobject(Dsetobject,221,0,"Background to a spectrum","","","BG")//FID_spectrum_background
	KratosDSET_initaddobject(Dsetobject,222,5,"Component Max Height","","","")//FID_comp_height
	KratosDSET_initaddobject(Dsetobject,223,5,"Component Width","","","")//FID_comp_width
	KratosDSET_initaddobject(Dsetobject,224,5,"Component start","","","")//FID_comp_start
	KratosDSET_initaddobject(Dsetobject,225,5,"Component constraint on Max Height","","","")//FID_constr_lower_height
	KratosDSET_initaddobject(Dsetobject,226,5,"Component constraint on Max Height","","","")//FID_constr_upper_height
	KratosDSET_initaddobject(Dsetobject,227,5,"Component constraint on start","","","")//FID_constr_lower_start
	KratosDSET_initaddobject(Dsetobject,228,5,"Component constraint on start","","","")//FID_constr_upper_start
	KratosDSET_initaddobject(Dsetobject,229,5,"Component constraint on width","","","")//FID_constr_lower_width
	KratosDSET_initaddobject(Dsetobject,230,5,"Component constraint on width","","","")//FID_constr_upper_width
	KratosDSET_initaddobject(Dsetobject,231,3,"Line shape model","","","")//FID_comp_model
	KratosDSET_initaddobject(Dsetobject,232,5,"Component list","","","")//FID_component_list
	KratosDSET_initaddobject(Dsetobject,233,0,"Synthetic spectrum","","","")//FID_envelope
	KratosDSET_initaddobject(Dsetobject,234,5,"Component half width in units of width","","","")//FID_comp_half_width
	KratosDSET_initaddobject(Dsetobject,235,3,"Component group index","","","")//FID_comp_group_index
	KratosDSET_initaddobject(Dsetobject,236,3,"Component Group","","","")//FID_component_group
	KratosDSET_initaddobject(Dsetobject,237,33,"Component Group parameter flags","","","")//FID_group_param_flags
	KratosDSET_initaddobject(Dsetobject,238,33,"Dataset Browser Filter","","","DSF")//FID_dataset_filter
	KratosDSET_initaddobject(Dsetobject,239,6,"Name of the Synthetic Component","","","")//FID_comp_name
	//KratosDSET_initaddobject(Dsetobject,240,0,"Name of the Group of Components","","","")//FID_comp_group_name
	KratosDSET_initaddobject(Dsetobject,241,5,"Sensitivity Factor","","","")//FID_sensitivity_factor
	KratosDSET_initaddobject(Dsetobject,242,5,"Atomic Mass for quantification","","","")//FID_atomic_mass
	KratosDSET_initaddobject(Dsetobject,243,35,"Quantification start coordinates","","","RegStart")//FID_region_start
	KratosDSET_initaddobject(Dsetobject,244,35,"Quantification end coordinates","","","RegEnd")//FID_region_end
	KratosDSET_initaddobject(Dsetobject,245,6,"Name of the Model line shape","","","")//FID_comp_model_name
	//KratosDSET_initaddobject(Dsetobject,246,0,"Library Object Envelope","","","")//FID_library_envelope
	KratosDSET_initaddobject(Dsetobject,247,0,"Library General Information","","","")//FID_library_info
	KratosDSET_initaddobject(Dsetobject,248,6,"Name of Element","","","")//FID_element_name
	KratosDSET_initaddobject(Dsetobject,249,6,"Symbol for Element","","","")//FID_element_symbol
	KratosDSET_initaddobject(Dsetobject,250,3,"Atomic Number","","","")//FID_atomic_number
	KratosDSET_initaddobject(Dsetobject,251,5,"Peak Position","","","")//FID_peak_position
	KratosDSET_initaddobject(Dsetobject,252,5,"Percentage Isotope Abundance","","","")//FID_abundance
	KratosDSET_initaddobject(Dsetobject,253,3,"Library Element Filter","","","")//FID_element_filter
	//KratosDSET_initaddobject(Dsetobject,254,0,"Profile Raw Data","","","")//FID_profile_raw_data
	//KratosDSET_initaddobject(Dsetobject,255,0,"Profile Intensity Adjusted Data","","","")//FID_profile_adjusted_data
	//KratosDSET_initaddobject(Dsetobject,256,0,"Profile Calculated Peak Position","","","")//FID_profile_position
	//KratosDSET_initaddobject(Dsetobject,257,0,"Profile Calculated full width half Max","","","")//FID_profile_fwhm
	//KratosDSET_initaddobject(Dsetobject,258,0,"Profile component sensitivity factor","","","")//FID_profile_sensitivity
	//KratosDSET_initaddobject(Dsetobject,259,0,"Profile component atomic mass","","","")//FID_profile_atomic_mass
	//KratosDSET_initaddobject(Dsetobject,260,0,"Format of spectrum profile","","","")//FID_profile_nature
	//KratosDSET_initaddobject(Dsetobject,261,0,"Profile spectrum By .. ","","","")//FID_profile_data_type
	//KratosDSET_initaddobject(Dsetobject,262,0,"Profile spectrum Using .. ","","","")//FID_profile_source
	//KratosDSET_initaddobject(Dsetobject,263,0,"Profile spectrum variable","","","")//FID_profile_state_change_type
	//KratosDSET_initaddobject(Dsetobject,264,0,"Electron Gun Filament Current","","","")//FID_egun_filament
	//KratosDSET_initaddobject(Dsetobject,265,0,"Electron Gun Emission Current","","","")//FID_egun_emission
	//KratosDSET_initaddobject(Dsetobject,266,0,"Electron Gun Spot Size","","","")//FID_egun_spotsize
	//KratosDSET_initaddobject(Dsetobject,267,0,"Electron Gun Focus","","","")//FID_egun_focus
	KratosDSET_initaddobject(Dsetobject,268,3,"Quantification Region List","","","")//FID_region_list
	KratosDSET_initaddobject(Dsetobject,269,5,"Quantification Raw Area","","","")//FID_region_area
	KratosDSET_initaddobject(Dsetobject,270,5,"Quantification Peak Position","","","")//FID_region_peak_position
	KratosDSET_initaddobject(Dsetobject,271,5,"Quantification Peak Half Width","","","")//FID_region_peak_half_width
	KratosDSET_initaddobject(Dsetobject,272,5,"Quantification Peak Maximum","","","")//FID_region_peak_height
	//KratosDSET_initaddobject(Dsetobject,273,0,"Energy Offset (KE) for a group from a component","","","")//FID_reference_component_offset
	//KratosDSET_initaddobject(Dsetobject,274,0,"Reference Component Index ","","","")//FID_reference_component_index
	//KratosDSET_initaddobject(Dsetobject,275,0,"Reference Group Index ","","","")//FID_reference_group_index
	//KratosDSET_initaddobject(Dsetobject,276,0,"Measurement Interval","","","")//FID_log_interval
	//KratosDSET_initaddobject(Dsetobject,277,0,"X-Ray Active State","","","")//FID_log_xray_state
	//KratosDSET_initaddobject(Dsetobject,278,0,"X-Ray Emission Current","","","")//FID_log_xray_em_curr
	//KratosDSET_initaddobject(Dsetobject,279,0,"X-Ray Anode Name","","","")//FID_log_xray_anode_name
	//KratosDSET_initaddobject(Dsetobject,280,0,"X-Ray HT Voltage","","","")//FID_log_xray_ht_volt
	//KratosDSET_initaddobject(Dsetobject,281,0,"X-Ray Filament Current","","","")//FID_log_xray_fil_curr
	//KratosDSET_initaddobject(Dsetobject,282,0,"Channel-Plate Active State","","","")//FID_log_cplate_state
	//KratosDSET_initaddobject(Dsetobject,283,0,"Channel-Plate Voltage","","","")//FID_log_cplate_volt
	//KratosDSET_initaddobject(Dsetobject,284,0,"Max Channel-Plate Voltage","","","")//FID_log_cplate_max_volt
	//KratosDSET_initaddobject(Dsetobject,285,0,"Channeltrons Active State","","","")//FID_log_ctrons_state
	//KratosDSET_initaddobject(Dsetobject,286,0,"Channeltron Voltages","","","")//FID_log_ctrons_volts
	//KratosDSET_initaddobject(Dsetobject,287,0,"Max Channeltron Voltages","","","")//FID_log_ctrons_max_volts
	//KratosDSET_initaddobject(Dsetobject,288,0,"Electron Gun Active State","","","")//FID_log_egun_state
	//KratosDSET_initaddobject(Dsetobject,289,0,"Electron Gun HT Voltage","","","")//FID_log_egun_ht_volt
	//KratosDSET_initaddobject(Dsetobject,290,0,"E-Gun Emission Current","","","")//FID_log_egun_em_curr
	//KratosDSET_initaddobject(Dsetobject,291,0,"E-Gun Filament Current","","","")//FID_log_egun_fil_curr
	//KratosDSET_initaddobject(Dsetobject,292,0,"Ion Gun Active State","","","")//FID_log_igun_state
	//KratosDSET_initaddobject(Dsetobject,293,0,"Ion Gun HT Voltage","","","")//FID_log_igun_ht_volt
	//KratosDSET_initaddobject(Dsetobject,294,0,"Ion Gun Emission Current","","","")//FID_log_igun_em_curr
	//KratosDSET_initaddobject(Dsetobject,295,0,"Service Comment","","","")//FID_log_service_comment
	//KratosDSET_initaddobject(Dsetobject,296,0,"Neutraliser Active State","","","")//FID_log_neut_state
	//KratosDSET_initaddobject(Dsetobject,297,0,"Neutraliser Filament Current","","","")//FID_log_neut_fil_curr
	//KratosDSET_initaddobject(Dsetobject,298,0,"Max Neutraliser Filament Current","","","")//FID_log_neut_max_fil_curr
	//KratosDSET_initaddobject(Dsetobject,299,0,"Accumulated Channeltron Counts","","","")//FID_log_ctrons_counts
	//KratosDSET_initaddobject(Dsetobject,300,0,"Accumulated Counts From ESCA Detector","","","")//FID_log_esca_detector_counts
	//KratosDSET_initaddobject(Dsetobject,301,0,"Current User","","","")//FID_log_user_name
	//KratosDSET_initaddobject(Dsetobject,302,0,"hsa_available","","","")//IID_hsa_available
	//KratosDSET_initaddobject(Dsetobject,303,0,"fat_available","","","")//IID_fat_available
	//KratosDSET_initaddobject(Dsetobject,304,0,"fat_values","","","")//IID_fat_values
	//KratosDSET_initaddobject(Dsetobject,305,0,"frr_available","","","")//IID_frr_available
	//KratosDSET_initaddobject(Dsetobject,306,0,"frr_values","","","")//IID_frr_values
	//KratosDSET_initaddobject(Dsetobject,307,0,"electron_gun_available","","","")//IID_electron_gun_available
	//KratosDSET_initaddobject(Dsetobject,308,0,"can_set_eg_voltage","","","")//IID_can_set_eg_voltage
	//KratosDSET_initaddobject(Dsetobject,309,0,"max_eg_voltage","","","")//IID_max_eg_voltage
	//KratosDSET_initaddobject(Dsetobject,310,0,"can_set_eg_current","","","")//IID_can_set_eg_current
	//KratosDSET_initaddobject(Dsetobject,311,0,"max_eg_current","","","")//IID_max_eg_current
	//KratosDSET_initaddobject(Dsetobject,312,0,"x_rays_available","","","")//IID_x_rays_available
	//KratosDSET_initaddobject(Dsetobject,313,0,"x_ray_source","","","")//IID_x_ray_sources
	//KratosDSET_initaddobject(Dsetobject,314,0,"photon_energies","","","")//IID_photon_energies
	//KratosDSET_initaddobject(Dsetobject,315,0,"can_set_x_ray_current","","","")//IID_can_set_x_ray_current
	//KratosDSET_initaddobject(Dsetobject,316,0,"max_x_ray_current","","","")//IID_max_x_ray_current
	//KratosDSET_initaddobject(Dsetobject,317,0,"can_set_x_ray_voltage","","","")//IID_can_set_x_ray_voltage
	//KratosDSET_initaddobject(Dsetobject,318,0,"max_x_ray_voltage","","","")//IID_max_x_ray_voltage
	//KratosDSET_initaddobject(Dsetobject,319,0,"hsa_magnifications","","","")//IID_hsa_magnifications
	//KratosDSET_initaddobject(Dsetobject,320,0,"control_hosts","","","")//IID_control_hosts
	//KratosDSET_initaddobject(Dsetobject,321,0,"users_can_edit","","","")//IID_users_can_edit
	//KratosDSET_initaddobject(Dsetobject,322,0,"comms_type","","","")//IID_comms_type
	//KratosDSET_initaddobject(Dsetobject,323,0,"no_of_elements","","","")//IID_no_of_elements
	//KratosDSET_initaddobject(Dsetobject,324,0,"no_of_detectors","","","")//IID_no_of_detectors
	//KratosDSET_initaddobject(Dsetobject,325,0,"seperation_ratio","","","")//IID_seperation_ratio
	//KratosDSET_initaddobject(Dsetobject,326,0,"work_function","","","")//IID_work_function
	//KratosDSET_initaddobject(Dsetobject,327,0,"HT_units","","","")//IID_HT_units
	//KratosDSET_initaddobject(Dsetobject,328,0,"element_names","","","")//IID_element_names
	//KratosDSET_initaddobject(Dsetobject,329,0,"element_polarities","","","")//IID_element_polarities
	//KratosDSET_initaddobject(Dsetobject,330,0,"pe_offsets","","","")//IID_pe_offsets
	//KratosDSET_initaddobject(Dsetobject,331,0,"rr_gains","","","")//IID_rr_gains
	//KratosDSET_initaddobject(Dsetobject,332,0,"detector_dead_time","","","")//IID_detector_dead_time
	//KratosDSET_initaddobject(Dsetobject,333,0,"channeltron_settle_time","","","")//IID_channeltron_settle_time
	//KratosDSET_initaddobject(Dsetobject,334,0,"inter_region_delay","","","")//IID_inter_region_delay
	//KratosDSET_initaddobject(Dsetobject,335,0,"anode_change_time","","","")//IID_anode_change_time
	//KratosDSET_initaddobject(Dsetobject,336,0,"channel_settle_time","","","")//IID_channel_settle_time
	//KratosDSET_initaddobject(Dsetobject,337,0,"excitation_code","","","")//IID_excitation_code
	//KratosDSET_initaddobject(Dsetobject,338,0,"vme_host","","","")//IID_vme_host
	//KratosDSET_initaddobject(Dsetobject,339,0,"base_port","","","")//IID_base_port
	//KratosDSET_initaddobject(Dsetobject,340,0,"upper_filament","","","")//IID_upper_filament
	//KratosDSET_initaddobject(Dsetobject,341,0,"lower_filament","","","")//IID_lower_filament
	//KratosDSET_initaddobject(Dsetobject,342,0,"anode_option","","","")//IID_anode_option
	//KratosDSET_initaddobject(Dsetobject,343,0,"max_lens_voltage","","","")//IID_max_lens_voltage
	//KratosDSET_initaddobject(Dsetobject,344,0,"STC chamber","","","")//IID_stc_chamber
	//KratosDSET_initaddobject(Dsetobject,345,0,"SAC chamber","","","")//IID_sac_chamber
	//KratosDSET_initaddobject(Dsetobject,346,0,"25 eV step","","","")//IID_25ev_step
	//KratosDSET_initaddobject(Dsetobject,347,0,"scan type mask","","","")//IID_scan_type_mask
	//KratosDSET_initaddobject(Dsetobject,348,0,"technique mask","","","")//IID_technique_mask
	//KratosDSET_initaddobject(Dsetobject,349,0,"control type mask","","","")//IID_control_type_mask
	//KratosDSET_initaddobject(Dsetobject,350,0,"AES full scale defl.","","","")//IID_aes_fsd
	//KratosDSET_initaddobject(Dsetobject,351,0,"XPS full scale defl.","","","")//IID_xps_fsd
	//KratosDSET_initaddobject(Dsetobject,352,0,"can set EG mag.","","","")//IID_can_set_eg_mag
	//KratosDSET_initaddobject(Dsetobject,353,0,"can set EG zoom","","","")//IID_can_set_eg_zoom
	//KratosDSET_initaddobject(Dsetobject,354,0,"XPS mapping available","","","")//IID_xps_mapping_available
	//KratosDSET_initaddobject(Dsetobject,355,0,"E.G. lower zoom","","","")//IID_lower_zoom
	//KratosDSET_initaddobject(Dsetobject,356,0,"E.G. upper zoom","","","")//IID_upper_zoom
	//KratosDSET_initaddobject(Dsetobject,357,0,"E.G. magnifications","","","")//IID_eg_magnifications
	//KratosDSET_initaddobject(Dsetobject,358,0,"XPS/AES rack","","","")//IID_xps_rack
	//KratosDSET_initaddobject(Dsetobject,359,0,"SIMS rack","","","")//IID_sims_rack
	//KratosDSET_initaddobject(Dsetobject,360,0,"Manipulator available","","","")//IID_manipulator_available
	//KratosDSET_initaddobject(Dsetobject,361,0,"Manipulator Axes","","","")//IID_axes
	//KratosDSET_initaddobject(Dsetobject,362,0,"Manipulator type","","","")//IID_manipulator_type
	//KratosDSET_initaddobject(Dsetobject,363,0,"Manipulator number","","","")//IID_manipulator_number
	//KratosDSET_initaddobject(Dsetobject,364,0,"Nominal E.G. voltage","","","")//IID_nominal_eg_voltage
	//KratosDSET_initaddobject(Dsetobject,365,0,"Nominal E.G. distance","","","")//IID_nominal_eg_distance
	//KratosDSET_initaddobject(Dsetobject,366,0,"E.G. Elevation","","","")//IID_eg_elevation
	//KratosDSET_initaddobject(Dsetobject,367,0,"E.G. Direction","","","")//IID_eg_direction
	//KratosDSET_initaddobject(Dsetobject,368,0,"E.G. Orientation","","","")//IID_eg_orientation
	//KratosDSET_initaddobject(Dsetobject,369,0,"Actual working distance","","","")//IID_actual_eg_distance
	//KratosDSET_initaddobject(Dsetobject,370,0,"XPS magnifications","","","")//IID_xps_magnifications
	//KratosDSET_initaddobject(Dsetobject,371,0,"Analyser Elevation","","","")//IID_lens_elevation
	//KratosDSET_initaddobject(Dsetobject,372,0,"Analyser Direction","","","")//IID_lens_direction
	//KratosDSET_initaddobject(Dsetobject,373,0,"Analyser Orientation","","","")//IID_lens_orientation
	//KratosDSET_initaddobject(Dsetobject,374,0,"E.G. Aspect Ratio","","","")//IID_eg_aspect_ratio
	//KratosDSET_initaddobject(Dsetobject,375,0,"Analyser Aspect Ratio","","","")//IID_lens_aspect_ratio
	//KratosDSET_initaddobject(Dsetobject,376,0,"E.G. Voltage Compensation","","","")//IID_eg_voltage_compensation
	//KratosDSET_initaddobject(Dsetobject,377,0,"Lens Voltage Compensation","","","")//IID_lens_voltage_compensation
	//KratosDSET_initaddobject(Dsetobject,378,0,"Delay for EG position","","","")//IID_eg_position_delay
	//KratosDSET_initaddobject(Dsetobject,379,0,"Delay for Lens position","","","")//IID_lens_position_delay
	//KratosDSET_initaddobject(Dsetobject,380,0,"Analyser slew rate","","","")//IID_decrease_analyser_slew
	//KratosDSET_initaddobject(Dsetobject,381,0,"Analyser settle time","","","")//IID_analyser_settle_time
	//KratosDSET_initaddobject(Dsetobject,382,0,"Connected Host","","","")//IID_connected_host
	//KratosDSET_initaddobject(Dsetobject,383,0,"Axis Type","","","")//IID_axis_type
	//KratosDSET_initaddobject(Dsetobject,384,0,"Axis Step Size","","","")//IID_axis_step
	//KratosDSET_initaddobject(Dsetobject,385,0,"Axis Minimum Speed","","","")//IID_axis_min_speed
	//KratosDSET_initaddobject(Dsetobject,386,0,"Axis Maximum Speed","","","")//IID_axis_max_speed
	//KratosDSET_initaddobject(Dsetobject,387,0,"Axis Creep Speed","","","")//IID_axis_creep_speed
	//KratosDSET_initaddobject(Dsetobject,388,0,"Axis Acceleration","","","")//IID_axis_acceleration
	//KratosDSET_initaddobject(Dsetobject,389,0,"Axis Direction","","","")//IID_axis_direction
	//KratosDSET_initaddobject(Dsetobject,390,0,"Axis Speed Type","","","")//IID_axis_speed_type
	//KratosDSET_initaddobject(Dsetobject,391,0,"Axis Minimum Range","","","")//IID_axis_min_range
	//KratosDSET_initaddobject(Dsetobject,392,0,"Axis Maximum Range","","","")//IID_axis_max_range
	//KratosDSET_initaddobject(Dsetobject,393,0,"Axis Offset","","","")//IID_axis_offset
	//KratosDSET_initaddobject(Dsetobject,394,0,"Axis Move Sequence","","","")//IID_axis_move_sequence
	//KratosDSET_initaddobject(Dsetobject,395,0,"Axis Unit Number","","","")//IID_axis_unit_number
	//KratosDSET_initaddobject(Dsetobject,396,0,"Axis Fixed Position","","","")//IID_axis_fixed_position
	//KratosDSET_initaddobject(Dsetobject,397,0,"Manipulator Code","","","")//IID_manipulator_code
	//KratosDSET_initaddobject(Dsetobject,398,0,"Axis Creep Distance","","","")//IID_axis_creep_distance
	//KratosDSET_initaddobject(Dsetobject,399,0,"Axis Docking Position","","","")//IID_axis_docking_position
	//KratosDSET_initaddobject(Dsetobject,400,0,"Axis micrometer offset","","","")//IID_axis_micrometer_offset
	//KratosDSET_initaddobject(Dsetobject,401,0,"C',27h,'tron power supply unit","","","")//IID_Ctron_ps_unit
	//KratosDSET_initaddobject(Dsetobject,402,0,"Channeltron settings","","","")//IID_Ctron_settings
	//KratosDSET_initaddobject(Dsetobject,403,0,"Axis HS Instrument","","","")//IID_axis_hs
	//KratosDSET_initaddobject(Dsetobject,404,0,"Axis HS Orientations","","","")//IID_axis_hs_orientation
	//KratosDSET_initaddobject(Dsetobject,405,0,"Axis HS F.S.D.s","","","")//IID_axis_hs_fsd
	//KratosDSET_initaddobject(Dsetobject,406,0,"Pallet Type","","","")//IID_pallet_type
	//KratosDSET_initaddobject(Dsetobject,407,0,"Switch Backup","","","")//IID_axis_backoff
	//KratosDSET_initaddobject(Dsetobject,408,0,"Ion guns fitted","","","")//IID_ion_guns
	//KratosDSET_initaddobject(Dsetobject,409,0,"Ion Gun Type","","","")//IID_ion_gun_type
	//KratosDSET_initaddobject(Dsetobject,410,0,"Exchange Position (Locked)","","","")//IID_ex_position_locked
	//KratosDSET_initaddobject(Dsetobject,411,0,"Exchange Position (Unlocked)","","","")//IID_ex_position_unlocked
	//KratosDSET_initaddobject(Dsetobject,412,0,"Etch Position 1","","","")//IID_etch_position_1
	//KratosDSET_initaddobject(Dsetobject,413,0,"Etch Position 2","","","")//IID_etch_position_2
	//KratosDSET_initaddobject(Dsetobject,414,0,"Etch Position 3","","","")//IID_etch_position_3
	//KratosDSET_initaddobject(Dsetobject,415,0,"Etch Position 4","","","")//IID_etch_position_4
	//KratosDSET_initaddobject(Dsetobject,416,0,"Gate Valve Timeout","","","")//IID_gate_valve_timeout
	//KratosDSET_initaddobject(Dsetobject,417,0,"Fork Timeout","","","")//IID_fork_timeout
	//KratosDSET_initaddobject(Dsetobject,418,0,"Ion Types","","","")//IID_ion_gun_ion_type
	//KratosDSET_initaddobject(Dsetobject,419,0,"Can Set Ion Gun Volts","","","")//IID_ion_gun_can_set_voltage
	//KratosDSET_initaddobject(Dsetobject,420,0,"Ion Gun Max. Voltage","","","")//IID_ion_gun_max_voltage
	//KratosDSET_initaddobject(Dsetobject,421,0,"Can Set Ion Gun Amps","","","")//IID_ion_gun_can_set_current
	//KratosDSET_initaddobject(Dsetobject,422,0,"Ion Gun Max. Current","","","")//IID_ion_gun_max_current
	//KratosDSET_initaddobject(Dsetobject,423,0,"Can Set Ion Gun Mag","","","")//IID_ion_gun_can_set_magnification
	//KratosDSET_initaddobject(Dsetobject,424,0,"Can Set Ion Gun Zoom","","","")//IID_ion_gun_can_set_zoom
	//KratosDSET_initaddobject(Dsetobject,425,0,"Ion Gun Lower Zoom","","","")//IID_ion_gun_lower_zoom
	//KratosDSET_initaddobject(Dsetobject,426,0,"Ion Gun Upper Zoom","","","")//IID_ion_gun_upper_zoom
	//KratosDSET_initaddobject(Dsetobject,427,0,"Ion Gun Working Distance","","","")//IID_ion_gun_working_distance
	//KratosDSET_initaddobject(Dsetobject,428,0,"Ion Gun Elevation","","","")//IID_ion_gun_elevation
	//KratosDSET_initaddobject(Dsetobject,429,0,"Ion Gun Direction","","","")//IID_ion_gun_direction
	//KratosDSET_initaddobject(Dsetobject,430,0,"Ion Gun Orientation","","","")//IID_ion_gun_orientation
	//KratosDSET_initaddobject(Dsetobject,431,0,"Ion Gun Aspect Ratio","","","")//IID_ion_gun_aspect_ratio
	//KratosDSET_initaddobject(Dsetobject,432,0,"Ion Gun Nominal Voltage","","","")//IID_ion_gun_nominal_voltage
	//KratosDSET_initaddobject(Dsetobject,433,0,"Ion Gun Nominal Working Distance","","","")//IID_ion_gun_nominal_working_distance
	//KratosDSET_initaddobject(Dsetobject,434,0,"Ion Gun Spot Size Table","","","")//IID_ion_gun_spot_sizes
	//KratosDSET_initaddobject(Dsetobject,435,0,"Ion Spot Name","","","")//IID_ion_spot_name
	//KratosDSET_initaddobject(Dsetobject,436,0,"Ion Spot Size","","","")//IID_ion_spot_size
	//KratosDSET_initaddobject(Dsetobject,437,0,"Ion Gun Seting 1","","","")//IID_ion_setting_1
	//KratosDSET_initaddobject(Dsetobject,438,0,"Ion Gun Seting 2","","","")//IID_ion_setting_2
	//KratosDSET_initaddobject(Dsetobject,439,0,"Ion Gun Seting 3","","","")//IID_ion_setting_3
	//KratosDSET_initaddobject(Dsetobject,440,0,"Mass Analyser Type","","","")//IID_mass_analyser_type
	//KratosDSET_initaddobject(Dsetobject,441,0,"Maximum Mass (AMU)","","","")//IID_sims_maximum_mass
	//KratosDSET_initaddobject(Dsetobject,442,0,"Standby Mass (AMU)","","","")//IID_sims_standby_mass
	//KratosDSET_initaddobject(Dsetobject,443,0,"Mass Analyser Settle Time","","","")//IID_sims_mass_settle_time
	//KratosDSET_initaddobject(Dsetobject,444,0,"SIMS Energy Filter","","","")//IID_sims_energy_filter
	//KratosDSET_initaddobject(Dsetobject,445,0,"Minimum Temperature","","","")//IID_minimum_temperature
	//KratosDSET_initaddobject(Dsetobject,446,0,"Maximum Temperature","","","")//IID_maximum_temperature
	//KratosDSET_initaddobject(Dsetobject,447,0,"Standby Temperature","","","")//IID_standby_temperature
	//KratosDSET_initaddobject(Dsetobject,448,0,"Min. Temp. Increment","","","")//IID_minimum_temperature_increment
	//KratosDSET_initaddobject(Dsetobject,449,0,"Institute ID","","","")//IID_institute_id
	//KratosDSET_initaddobject(Dsetobject,450,0,"Instrument Type","","","")//IID_instrument_id
	//KratosDSET_initaddobject(Dsetobject,451,0,"SIMS Default Rasters","","","")//IID_rasters
	//KratosDSET_initaddobject(Dsetobject,452,0,"Minimum Dwell Time","","","")//IID_raster_minimum_dwell
	//KratosDSET_initaddobject(Dsetobject,453,0,"Raster Name","","","")//IID_raster_name
	//KratosDSET_initaddobject(Dsetobject,454,0,"# Raster Pixels","","","")//IID_raster_n_pixels
	//KratosDSET_initaddobject(Dsetobject,455,0,"# Border Pixels","","","")//IID_raster_n_border
	//KratosDSET_initaddobject(Dsetobject,456,0,"SIMS Master DAC Table","","","")//IID_sims_master_table
	//KratosDSET_initaddobject(Dsetobject,457,0,"DAC I.D. Number","","","")//IID_dac_id
	//KratosDSET_initaddobject(Dsetobject,458,0,"Master DAC Class","","","")//IID_master_dac_class
	//KratosDSET_initaddobject(Dsetobject,459,0,"Master DAC Processor","","","")//IID_master_proc_type
	//KratosDSET_initaddobject(Dsetobject,460,0,"Master DAC Offset","","","")//IID_master_dac_offset
	//KratosDSET_initaddobject(Dsetobject,461,0,"Master Minimum DAC","","","")//IID_master_min_dac
	//KratosDSET_initaddobject(Dsetobject,462,0,"Master Maximum DAC","","","")//IID_master_max_dac
	//KratosDSET_initaddobject(Dsetobject,463,0,"Master Minimum Value","","","")//IID_master_min_value
	//KratosDSET_initaddobject(Dsetobject,464,0,"Master Maximum Value","","","")//IID_master_max_value
	//KratosDSET_initaddobject(Dsetobject,465,0,"Master Units","","","")//IID_master_units
	//KratosDSET_initaddobject(Dsetobject,466,0,"+VE SIMS Alias Table","","","")//IID_pos_sims_alias_table
	//KratosDSET_initaddobject(Dsetobject,467,0,"-VE SIMS Alias Table","","","")//IID_neg_sims_alias_table
	//KratosDSET_initaddobject(Dsetobject,468,0,"SNMS Alias Table","","","")//IID_snms_alias_table
	//KratosDSET_initaddobject(Dsetobject,469,0,"RGA Alias Table","","","")//IID_rga_alias_table
	//KratosDSET_initaddobject(Dsetobject,470,0,"TDS Alias Table","","","")//IID_tds_alias_table
	//KratosDSET_initaddobject(Dsetobject,471,0,"Alias Minimum Value","","","")//IID_alias_min_value
	//KratosDSET_initaddobject(Dsetobject,472,0,"Alias Maximum Value","","","")//IID_alias_max_value
	//KratosDSET_initaddobject(Dsetobject,473,0,"Alias Step Size","","","")//IID_alias_step_size
	//KratosDSET_initaddobject(Dsetobject,474,0,"Alias Actual Value","","","")//IID_alias_actual_value
	//KratosDSET_initaddobject(Dsetobject,475,0,"Alias Standby Value","","","")//IID_alias_standby
	//KratosDSET_initaddobject(Dsetobject,476,0,"Ion Gun Usage","","","")//IID_ion_gun_use
	//KratosDSET_initaddobject(Dsetobject,477,0,"Mag. Entry Name","","","")//IID_mag_entry_name
	//KratosDSET_initaddobject(Dsetobject,478,0,"Mag. Entry F.S.D.","","","")//IID_mag_entry_fsd
	//KratosDSET_initaddobject(Dsetobject,479,0,"Mag. Entry Units","","","")//IID_mag_entry_units
	//KratosDSET_initaddobject(Dsetobject,480,0,"Ion Gun Magnifications","","","")//IID_ion_gun_magnifications
	//KratosDSET_initaddobject(Dsetobject,481,0,"Ion Gun Name","","","")//IID_ion_gun_name
	//KratosDSET_initaddobject(Dsetobject,482,0,"Ion Gun Number","","","")//IID_ion_gun_number
	//KratosDSET_initaddobject(Dsetobject,483,0,"Master DAC # Bits","","","")//IID_master_n_bits
	//KratosDSET_initaddobject(Dsetobject,484,0,"SIMS Maps Min. Dwell","","","")//IID_sims_map_min_dwell
	//KratosDSET_initaddobject(Dsetobject,485,0,"SIMS H.V. Switch Delay","","","")//IID_sims_switch_delay
	//KratosDSET_initaddobject(Dsetobject,486,0,"X Ray Ramp Time","","","")//IID_x_ray_ramp_time
	//KratosDSET_initaddobject(Dsetobject,487,0,"Standby Energy","","","")//IID_standby_energy
	//KratosDSET_initaddobject(Dsetobject,488,0,"Ion Scattering Angle","","","")//IID_ion_gun_scatter_angle
	//KratosDSET_initaddobject(Dsetobject,489,0,"Minimum Ion Energy","","","")//IID_ion_gun_min_energy
	//KratosDSET_initaddobject(Dsetobject,490,0,"Maximum Ion Energy","","","")//IID_ion_gun_max_energy
	//KratosDSET_initaddobject(Dsetobject,491,0,"Ion Masses","","","")//IID_ion_gun_ion_masses
	//KratosDSET_initaddobject(Dsetobject,492,0,"Gate Paterns","","","")//IID_gate_patterns
	//KratosDSET_initaddobject(Dsetobject,493,0,"Gate Pattern Name","","","")//IID_gate_pattern_name
	//KratosDSET_initaddobject(Dsetobject,494,0,"Gate Definitions","","","")//IID_gates
	//KratosDSET_initaddobject(Dsetobject,495,0,"Gate Name","","","")//IID_gate_name
	//KratosDSET_initaddobject(Dsetobject,496,0,"Gate X Pixels","","","")//IID_gate_pixels_x
	//KratosDSET_initaddobject(Dsetobject,497,0,"Gate Y Pixels","","","")//IID_gate_pixels_y
	//KratosDSET_initaddobject(Dsetobject,498,0,"Increasing Energy Slew Rate","","","")//IID_increase_analyser_slew
	//KratosDSET_initaddobject(Dsetobject,499,0,"To Standby After Each Sweep","","","")//IID_standby_after_sweep
	//KratosDSET_initaddobject(Dsetobject,500,0,"Default Raster Shift X","","","")//IID_default_raster_shift_x
	//KratosDSET_initaddobject(Dsetobject,501,0,"Default Raster Shift Y","","","")//IID_default_raster_shift_y
	//KratosDSET_initaddobject(Dsetobject,502,0,"Manip. Controller Type","","","")//IID_manipulator_controller
	//KratosDSET_initaddobject(Dsetobject,503,0,"Manipulator Interface Card","","","")//IID_manipulator_card
	//KratosDSET_initaddobject(Dsetobject,504,0,"Axis Microswitches","","","")//IID_axis_switches
	//KratosDSET_initaddobject(Dsetobject,505,0,"Axis Motor Number","","","")//IID_axis_motor_number
	//KratosDSET_initaddobject(Dsetobject,506,0,"Elec. Gun Scan Pt. Distance","","","")//IID_eg_scan_point_distance
	//KratosDSET_initaddobject(Dsetobject,507,0,"Ion Gun Scan Pt. Distance","","","")//IID_ion_gun_scan_point_distance
	//KratosDSET_initaddobject(Dsetobject,508,0,"VME Serial Ports","","","")//IID_serial_ports
	//KratosDSET_initaddobject(Dsetobject,509,0,"Serial Port Name","","","")//IID_serial_device_name
	//KratosDSET_initaddobject(Dsetobject,510,0,"Serial Port Baud Rate","","","")//IID_serial_baud_rate
	//KratosDSET_initaddobject(Dsetobject,511,0,"Serial Port Parity","","","")//IID_serial_parity
	//KratosDSET_initaddobject(Dsetobject,512,0,"Serial Port Bits/Char","","","")//IID_serial_bits_per_char
	//KratosDSET_initaddobject(Dsetobject,513,0,"Serial Port Stop Bits","","","")//IID_serial_stop_bits
	//KratosDSET_initaddobject(Dsetobject,514,0,"Serial Port End Timeout","","","")//IID_serial_end_timeout
	//KratosDSET_initaddobject(Dsetobject,515,0,"Serial Port Termination Chars","","","")//IID_serial_termination
	//KratosDSET_initaddobject(Dsetobject,516,0,"Vacuum Controller Type","","","")//IID_vacuum_controller_type
	//KratosDSET_initaddobject(Dsetobject,517,0,"Vacuum System Options","","","")//IID_vacuum_system_options
	//KratosDSET_initaddobject(Dsetobject,518,0,"Magazine Max. Samples","","","")//IID_magazine_max_samples
	//KratosDSET_initaddobject(Dsetobject,519,0,"Scorpion K4 Port Index","","","")//IID_scorpion_k4_port
	//KratosDSET_initaddobject(Dsetobject,520,0,"Manipulator Move Sequences","","","")//IID_move_sequences
	//KratosDSET_initaddobject(Dsetobject,521,0,"Move Sequence Name","","","")//IID_sequence_name
	//KratosDSET_initaddobject(Dsetobject,522,0,"Move Sequence Number","","","")//IID_sequence_number
	//KratosDSET_initaddobject(Dsetobject,523,0,"Move Sequence Positions","","","")//IID_sequence_positions
	//KratosDSET_initaddobject(Dsetobject,524,0,"Pallet Size","","","")//IID_pallet_size
	//KratosDSET_initaddobject(Dsetobject,525,0,"Pallet Type Detection","","","")//IID_pallet_type_detection
	//KratosDSET_initaddobject(Dsetobject,526,0,"Mirror Type Detection","","","")//IID_mirror_detection
	//KratosDSET_initaddobject(Dsetobject,527,0,"X-Ray Shutter Detection","","","")//IID_xray_shutter_detection
	//KratosDSET_initaddobject(Dsetobject,528,0,"# Transfer Angles","","","")//IID_ntransfer_angles
	//KratosDSET_initaddobject(Dsetobject,529,0,"Transfer Angles","","","")//IID_transfer_angles
	//KratosDSET_initaddobject(Dsetobject,530,0,"Fork Type","","","")//IID_fork_type
	//KratosDSET_initaddobject(Dsetobject,531,0,"Fork Number","","","")//IID_fork_number
	//KratosDSET_initaddobject(Dsetobject,532,0,"Fork Code","","","")//IID_fork_code
	//KratosDSET_initaddobject(Dsetobject,533,0,"Fork Card","","","")//IID_fork_card
	//KratosDSET_initaddobject(Dsetobject,534,0,"Fork Exchange Position","","","")//IID_fork_exchange_position
	//KratosDSET_initaddobject(Dsetobject,535,0,"Fork Load Position","","","")//IID_fork_load_position
	//KratosDSET_initaddobject(Dsetobject,536,0,"Fork Minimum Etch Position","","","")//IID_fork_min_etch
	//KratosDSET_initaddobject(Dsetobject,537,0,"Fork Maximum Etch Position","","","")//IID_fork_max_etch
	//KratosDSET_initaddobject(Dsetobject,538,0,"Fork Axes","","","")//IID_fork_axes
	//KratosDSET_initaddobject(Dsetobject,539,0,"Ion Gun X Offset","","","")//IID_ion_gun_xoffset
	//KratosDSET_initaddobject(Dsetobject,540,0,"Ion Gun Y Offset","","","")//IID_ion_gun_yoffset
	//KratosDSET_initaddobject(Dsetobject,541,0,"Ion Gun Theta Offset","","","")//IID_ion_gun_theta_offset
	//KratosDSET_initaddobject(Dsetobject,542,0,"Zalar Rotation Allowed","","","")//IID_axis_zalar_rotation
	//KratosDSET_initaddobject(Dsetobject,543,0,"Seconfs Per Rotation","","","")//IID_axis_zalar_rate
	//KratosDSET_initaddobject(Dsetobject,544,0,"XPS Serial Baud Rate","","","")//IID_xps_serial_comms_speed
	//KratosDSET_initaddobject(Dsetobject,545,0,"SIMS Serial Baud Rate","","","")//IID_sims_serial_comms_speed
	//KratosDSET_initaddobject(Dsetobject,546,0,"Shimadzu ESCA Manipulator Positions","","","")//IID_manipulator_npositions
	//KratosDSET_initaddobject(Dsetobject,547,0,"Shimadzu Anode Currents","","","")//IID_shimadzu_anode_currents
	//KratosDSET_initaddobject(Dsetobject,548,0,"Shimadzu Anode Voltages","","","")//IID_shimadzu_anode_voltages
	//KratosDSET_initaddobject(Dsetobject,549,0,"Shimadzu Ion Gun Currents","","","")//IID_ion_gun_shimadzu_currents
	//KratosDSET_initaddobject(Dsetobject,550,0,"Shimadzu Ion Gun Voltages","","","")//IID_ion_gun_shimadzu_voltages
	//KratosDSET_initaddobject(Dsetobject,551,0,"Analyser Calibration","","","")//IID_calibrate_analyser
	//KratosDSET_initaddobject(Dsetobject,552,0,"Calibration Max. Error","","","")//IID_calibrate_max_error
	//KratosDSET_initaddobject(Dsetobject,553,0,"Analyser Minimum DAC","","","")//IID_analyser_min_dac
	//KratosDSET_initaddobject(Dsetobject,554,0,"Analyser Maximum DAC","","","")//IID_analyser_max_dac
	//KratosDSET_initaddobject(Dsetobject,555,0,"Analyser Minimum Value","","","")//IID_analyser_min_value
	//KratosDSET_initaddobject(Dsetobject,556,0,"Analyser Maximum Value","","","")//IID_analyser_max_value
	//KratosDSET_initaddobject(Dsetobject,557,0,"Aperture Mechanisms","","","")//IID_aperture_mechanisms
	//KratosDSET_initaddobject(Dsetobject,558,0,"Aperture Mechanism Name","","","")//IID_aperture_mechanism_name
	//KratosDSET_initaddobject(Dsetobject,559,0,"Transfer Lens Aperture Index","","","")//IID_analyser_aperture_index
	//KratosDSET_initaddobject(Dsetobject,560,0,"Energy Filter Aperture Index","","","")//IID_mass_analyser_aperture_index
	//KratosDSET_initaddobject(Dsetobject,561,0,"Ion Gun Aperture Index","","","")//IID_ion_gun_aperture_index
	//KratosDSET_initaddobject(Dsetobject,562,0,"Axis Slow Manual Speed","","","")//IID_axis_slow_manual_speed
	//KratosDSET_initaddobject(Dsetobject,563,0,"Axis Fast Manual Speed","","","")//IID_axis_fast_manual_speed
	//KratosDSET_initaddobject(Dsetobject,564,0,"Ion Gun Con-focal","","","")//IID_ion_gun_confocal
	//KratosDSET_initaddobject(Dsetobject,565,0,"Nominal Pass Energies","","","")//IID_nominal_pass_energies
	//KratosDSET_initaddobject(Dsetobject,566,0,"Exact Pass Energies","","","")//IID_exact_pass_energies
	//KratosDSET_initaddobject(Dsetobject,567,0,"Nominal Retard Ratios","","","")//IID_nominal_retard_ratios
	//KratosDSET_initaddobject(Dsetobject,568,0,"Exact Retard Ratios","","","")//IID_exact_retard_ratios
	//KratosDSET_initaddobject(Dsetobject,569,0,"PE gains (25meV step size)","","","")//IID_pe_gains_25
	//KratosDSET_initaddobject(Dsetobject,570,0,"PE offsets (25meV step size)","","","")//IID_pe_offsets_25
	//KratosDSET_initaddobject(Dsetobject,571,0,"RR gains (25meV step size)","","","")//IID_rr_gains_25
	//KratosDSET_initaddobject(Dsetobject,572,0,"RR offsets (25meV step size)","","","")//IID_rr_offsets_25
	//KratosDSET_initaddobject(Dsetobject,573,0,"PE gains (50meV step size)","","","")//IID_pe_gains_50
	//KratosDSET_initaddobject(Dsetobject,574,0,"PE offsets (50meV step size)","","","")//IID_pe_offsets_50
	//KratosDSET_initaddobject(Dsetobject,575,0,"RR gains (50meV step size)","","","")//IID_rr_gains_50
	//KratosDSET_initaddobject(Dsetobject,576,0,"RR offsets (50meV step size)","","","")//IID_rr_offsets_50
	//KratosDSET_initaddobject(Dsetobject,577,0,"PE gains (100meV step size)","","","")//IID_pe_gains_100
	//KratosDSET_initaddobject(Dsetobject,578,0,"PE offsets (100meV step size)","","","")//IID_pe_offsets_100
	//KratosDSET_initaddobject(Dsetobject,579,0,"RR gains (100meV step size)","","","")//IID_rr_gains_100
	//KratosDSET_initaddobject(Dsetobject,580,0,"RR offsets (100meV step size)","","","")//IID_rr_offsets_100
	//KratosDSET_initaddobject(Dsetobject,581,0,"C',27h,'tron power supply fitted","","","")//IID_Ctron_ps_fitted
	//KratosDSET_initaddobject(Dsetobject,582,0,"Backlash","","","")//IID_axis_backlash
	//KratosDSET_initaddobject(Dsetobject,583,0,"Axis may move with others","","","")//IID_axis_simul_movement
	//KratosDSET_initaddobject(Dsetobject,584,0,"Flap valve safe distance","","","")//IID_axis_flap_valve_dist
	//KratosDSET_initaddobject(Dsetobject,585,0,"E Gun Control Mechanism","","","")//IID_eg_computer_controlled
	//KratosDSET_initaddobject(Dsetobject,586,0,"E Gun Serial Port Name","","","")//IID_eg_serial_port_name
	//KratosDSET_initaddobject(Dsetobject,587,0,"Charge Neutraliser Type","","","")//IID_neutraliser_type
	//KratosDSET_initaddobject(Dsetobject,588,0,"Minimum Voltages","","","")//IID_neutraliser_mins
	//KratosDSET_initaddobject(Dsetobject,589,0,"Maximum Voltages","","","")//IID_neutraliser_maxs
	//KratosDSET_initaddobject(Dsetobject,590,0,"Neutraliser DAC bits","","","")//IID_neutraliser_dac_bits
	//KratosDSET_initaddobject(Dsetobject,591,0,"Neutraliser Voltage Limits","","","")//IID_neutraliser_limits
	//KratosDSET_initaddobject(Dsetobject,592,0,"Camera Control Mechanism","","","")//IID_camera_source_controlled
	//KratosDSET_initaddobject(Dsetobject,593,0,"Number of Cameras","","","")//IID_number_of_cameras
	//KratosDSET_initaddobject(Dsetobject,594,0,"Image capture available","","","")//IID_frame_store_available
	//KratosDSET_initaddobject(Dsetobject,595,0,"Scan Correction Mode","","","")//IID_hs_scan_correction_mode
	//KratosDSET_initaddobject(Dsetobject,596,0,"HS Scan Rotation","","","")//IID_hs_scan_rotation
	//KratosDSET_initaddobject(Dsetobject,597,0,"Axis HS scan x-offset","","","")//IID_hs_x_offset_factor
	//KratosDSET_initaddobject(Dsetobject,598,0,"Axis HS scan y-offset","","","")//IID_hs_y_offset_factor
	//KratosDSET_initaddobject(Dsetobject,599,0,"Electron Gun PSU type","","","")//IID_eg_psu_type
	KratosDSET_initaddobject(Dsetobject,2001,3,"Process identifier","","","")//PID_process
	KratosDSET_initaddobject(Dsetobject,2003,5,"Gaussian width","","","")//PID_gauss_width
	KratosDSET_initaddobject(Dsetobject,2004,3,"Smooth type","","","")//PID_smooth_type
	KratosDSET_initaddobject(Dsetobject,2005,3,"Derivative","","","")//PID_deriv
	KratosDSET_initaddobject(Dsetobject,2006,3,"No. Points","","","")//PID_npoints
	KratosDSET_initaddobject(Dsetobject,2007,3,"Polynomial Degree","","","")//PID_poly_degree
	//KratosDSET_initaddobject(Dsetobject,2008,0,"Direction of Integration","","","")//PID_integrate_direction
	//KratosDSET_initaddobject(Dsetobject,2009,0,"Deconvolution width","","","")//PID_deconvolute_width
	//KratosDSET_initaddobject(Dsetobject,2010,0,"Maximum iterations","","","")//PID_max_iterations
	//KratosDSET_initaddobject(Dsetobject,2011,0,"Tolerance","","","")//PID_tolerance
	//KratosDSET_initaddobject(Dsetobject,2012,0,"Deconvolution method","","","")//PID_deconv_method
	//KratosDSET_initaddobject(Dsetobject,2013,0,"Kernel size","","","")//PID_kernel_size
	//KratosDSET_initaddobject(Dsetobject,2014,0,"Kernel coefficients","","","")//PID_kernel_coeffs
	//KratosDSET_initaddobject(Dsetobject,2015,0,"Suppress -ve values","","","")//PID_suppress_negatives
	//KratosDSET_initaddobject(Dsetobject,2016,0,"Histogram threshold","","","")//PID_threshold
	//KratosDSET_initaddobject(Dsetobject,2017,0,"Histogram mass region","","","")//PID_mass_region
	//KratosDSET_initaddobject(Dsetobject,2018,0,"Linear correction factor","","","")//PID_linear_factor
	//KratosDSET_initaddobject(Dsetobject,2019,0,"Quadratic correction factor","","","")//PID_square_factor
	//KratosDSET_initaddobject(Dsetobject,2020,0,"X-ray correction side","","","")//PID_side
	//KratosDSET_initaddobject(Dsetobject,2021,0,"Shift regions with spectrum","","","")//PID_shift_regions
	//KratosDSET_initaddobject(Dsetobject,2022,0,"Calculation operator","","","")//PID_operator
	//KratosDSET_initaddobject(Dsetobject,2023,0,"Second Operand Type","","","")//PID_operand2_type
	//KratosDSET_initaddobject(Dsetobject,2024,0,"Constant operand","","","")//PID_constant_operand
	//KratosDSET_initaddobject(Dsetobject,2025,0,"Data operand","","","")//PID_data_operand
	//KratosDSET_initaddobject(Dsetobject,2026,0,"Operand 1st Dimension","","","")//PID_operand_dim1
	//KratosDSET_initaddobject(Dsetobject,2027,0,"Operand 2nd Dimension","","","")//PID_operand_dim2
	//KratosDSET_initaddobject(Dsetobject,2028,0,"Operand Abscissa start","","","")//PID_abscissa_start
	//KratosDSET_initaddobject(Dsetobject,2029,0,"Operand Abscissa increment","","","")//PID_abscissa_inc
	//KratosDSET_initaddobject(Dsetobject,2030,0,"Overwrite original","","","")//PID_overwrite
	//KratosDSET_initaddobject(Dsetobject,2031,0,"Sample Bias","","","")//PID_sample_bias
	//KratosDSET_initaddobject(Dsetobject,2032,0,"Sample to Pixel Transform","","","")//PID_image_xy_to_ij
	//KratosDSET_initaddobject(Dsetobject,2033,0,"New Object Name","","","")//PID_new_object_name
	//KratosDSET_initaddobject(Dsetobject,2034,0,"Direction","","","")//PID_new_direction
	//KratosDSET_initaddobject(Dsetobject,2035,0,"Elevation","","","")//PID_new_elevation
	//KratosDSET_initaddobject(Dsetobject,2036,0,"Orientation","","","")//PID_new_orientation
	//KratosDSET_initaddobject(Dsetobject,2037,0,"Actual Working Distance","","","")//PID_new_actual_wd
	//KratosDSET_initaddobject(Dsetobject,2038,0,"Full Scale Deflection","","","")//PID_new_fsd
	//KratosDSET_initaddobject(Dsetobject,2039,0,"Abscissa Values","","","")//PID_abscissa_values
	//KratosDSET_initaddobject(Dsetobject,2040,0,"Processing Abscissa Shift","","","")//PID_abscissa_shift
	KratosDSET_initaddobject(Dsetobject,2041,3,"Background type for spectra","","1=F_LINEAR;2=F_SHIRLEY","")//PID_background_type
	//KratosDSET_initaddobject(Dsetobject,2042,0,"Background start coordinates","","","")//PID_background_start
	//KratosDSET_initaddobject(Dsetobject,2043,0,"Background end coordinates","","","")//PID_background_end
	//KratosDSET_initaddobject(Dsetobject,2044,0,"Background Limit Option Type","","","")//PID_background_limit
	KratosDSET_initaddobject(Dsetobject,2045,3,"Number of bins to average","","","")//PID_bin_to_average
	//KratosDSET_initaddobject(Dsetobject,2046,0,"Start of the component","","","")//PID_comp_start
	//KratosDSET_initaddobject(Dsetobject,2047,0,"Full Width of the component","","","")//PID_comp_width
	//KratosDSET_initaddobject(Dsetobject,2048,0,"Full Height of the component","","","")//PID_comp_height
	//KratosDSET_initaddobject(Dsetobject,2049,0,"Name of the Model line shape","","","")//PID_comp_model_name
	//KratosDSET_initaddobject(Dsetobject,2050,0,"Component Group parameter flags","","","")//PID_group_param_flags
	//KratosDSET_initaddobject(Dsetobject,2051,0,"Start of the component","","","")//PID_comp_start_lower
	//KratosDSET_initaddobject(Dsetobject,2052,0,"Full Width of the component","","","")//PID_comp_width_lower
	//KratosDSET_initaddobject(Dsetobject,2053,0,"Full Height of the component","","","")//PID_comp_height_lower
	//KratosDSET_initaddobject(Dsetobject,2054,0,"Start of the component","","","")//PID_comp_start_upper
	//KratosDSET_initaddobject(Dsetobject,2055,0,"Full Width of the component","","","")//PID_comp_width_upper
	//KratosDSET_initaddobject(Dsetobject,2056,0,"Full Height of the component","","","")//PID_comp_height_upper
	//KratosDSET_initaddobject(Dsetobject,2057,0,"Optimisation Strategy","","","")//PID_autofit_strategy
	//KratosDSET_initaddobject(Dsetobject,2058,0,"Optimisation termination Tolerace","","","")//PID_autofit_tolerance
	//KratosDSET_initaddobject(Dsetobject,2059,0,"Optimisation number of iterations","","","")//PID_autofit_iterations
	//KratosDSET_initaddobject(Dsetobject,2060,0,"Name of the Synthetic Component","","","")//PID_comp_name
	//KratosDSET_initaddobject(Dsetobject,2061,0,"Name of the Group of Components","","","")//PID_comp_group_name
	//KratosDSET_initaddobject(Dsetobject,2062,0,"Sensitivity Factor","","","")//PID_sensitivity_factor
	//KratosDSET_initaddobject(Dsetobject,2063,0,"Atomic Mass for quantification","","","")//PID_atomic_mass
	//KratosDSET_initaddobject(Dsetobject,2064,0,"Quantifcation start coordinates","","","")//PID_region_start
	//KratosDSET_initaddobject(Dsetobject,2065,0,"Quantifcation end coordinates","","","")//PID_region_end
	//KratosDSET_initaddobject(Dsetobject,2066,0,"Component Model data source","","","")//PID_model_data_source
	//KratosDSET_initaddobject(Dsetobject,2067,0,"Data bin associated with annotation","","","")//PID_annotation_bin
	//KratosDSET_initaddobject(Dsetobject,2068,0,"Annotation x offset from data index","","","")//PID_annotation_x_offset
	//KratosDSET_initaddobject(Dsetobject,2069,0,"Annotation y offset from data index","","","")//PID_annotation_y_offset
	KratosDSET_initaddobject(Dsetobject,2070,6,"Annotation text string","","","")//PID_annotation_string
	KratosDSET_initaddobject(Dsetobject,2071,3,"Annotation type","","","")//PID_annotation_type
	KratosDSET_initaddobject(Dsetobject,2072,35,"Arrow start offset from data bin","","","")//PID_arrow_start
	KratosDSET_initaddobject(Dsetobject,2073,35,"Arrow end offset from data bin","","","")//PID_arrow_end
	//KratosDSET_initaddobject(Dsetobject,2074,0,"Axis range","","","")//PID_axis_range
	KratosDSET_initaddobject(Dsetobject,2075,3,"Object List containing annotation","","","")//PID_annotation_list // not in KAL file
	//KratosDSET_initaddobject(Dsetobject,2076,0,"Data edit x value","","","")//PID_data_edit_x
	//KratosDSET_initaddobject(Dsetobject,2077,0,"Data edit y value","","","")//PID_data_edit_y
	//KratosDSET_initaddobject(Dsetobject,2078,0,"Dataset comment","","","")//PID_dataset_comment
	KratosDSET_initaddobject(Dsetobject,3000,3,"Discrete detector flag","","","")//AID_discrete_detector
	KratosDSET_initaddobject(Dsetobject,3001,5,"start x coord","","","")//AID_coord_start_x
	KratosDSET_initaddobject(Dsetobject,3002,5,"start y coord","","","")//AID_coord_start_y
	KratosDSET_initaddobject(Dsetobject,3003,5,"step size x coord","","","")//AID_coord_step_size_x
	KratosDSET_initaddobject(Dsetobject,3004,5,"step size y coord","","","")//AID_coord_step_size_y
	KratosDSET_initaddobject(Dsetobject,3005,5,"Full Scale Deflection X","mm","","")//AID_coord_fsd_x
	KratosDSET_initaddobject(Dsetobject,3006,5,"Full Scale Deflection Y","mm","","")//AID_coord_fsd_y
	KratosDSET_initaddobject(Dsetobject,3009,3,"Real time display data index","","","")//AID_acquired_rtd_raw_index
	KratosDSET_initaddobject(Dsetobject,3010,3,"Table Of State Change Objects","","","")//AID_state_change_table
	KratosDSET_initaddobject(Dsetobject,3011,3,"Energy/line scan # steps","","","")//AID_scan_n_steps
	KratosDSET_initaddobject(Dsetobject,3012,3,"# Sweeps required","","","")//AID_n_sweeps_required
	KratosDSET_initaddobject(Dsetobject,3013,33,"Enabled detectors","","","detlist")//AID_en_detector_list
	KratosDSET_initaddobject(Dsetobject,3014,3,"Acquisition spec active","","","")//AID_acq_spec_active
	KratosDSET_initaddobject(Dsetobject,3015,3,"KE/line scan or map spec","","","")//AID_acquisition_specs
	KratosDSET_initaddobject(Dsetobject,3016,3,"Save data flag","","","")//AID_save_data_flag
	KratosDSET_initaddobject(Dsetobject,3017,3,"Sum sweeps flag","","","")//AID_sum_sweeps_flag
	KratosDSET_initaddobject(Dsetobject,3018,0,"Miscellaneous data","","","miscD")//AID_misc_items
	//KratosDSET_initaddobject(Dsetobject,3019,0,"Acquired data","","","")//AID_acquired_data
	KratosDSET_initaddobject(Dsetobject,3020,6,"Destination dataset name","","","")//AID_destination_dataset
	//KratosDSET_initaddobject(Dsetobject,3021,0,"Lens mode","","","")//AID_lens_mode
	//KratosDSET_initaddobject(Dsetobject,3023,0,"Dummy field 3023","","","")//AID_dummy_3023
	KratosDSET_initaddobject(Dsetobject,3024,3,"Acquisition Specification Flag","","","")//AID_acquisition_specification
	KratosDSET_initaddobject(Dsetobject,3025,3,"Flow chart goto start","","","")//AID_goto_start
	//KratosDSET_initaddobject(Dsetobject,3026,0,"Position name","","","")//AID_position_name
	KratosDSET_initaddobject(Dsetobject,3030,3,"Object display type","","0=DISPLAY_TYPE_DATASET_NAME;1=DISPLAY_TYPE_SCAN;2=DISPLAY_TYPE_STATE_CHANGE","")//AID_object_display_type
	//KratosDSET_initaddobject(Dsetobject,3031,0,"Acquired raw data","","","")//AID_acquired_raw_data
	//KratosDSET_initaddobject(Dsetobject,3032,0,"Index into raw data","","","")//AID_acquired_raw_index
	//KratosDSET_initaddobject(Dsetobject,3033,0,"Final Etch time","","","")//AID_final_etch_time
	KratosDSET_initaddobject(Dsetobject,3035,3,"Number of Etch Cycles","","","")//AID_no_etch_cycles
	KratosDSET_initaddobject(Dsetobject,3036,3,"Etch Ramp Enabled","","","")//AID_etch_ramp_enabled
	//KratosDSET_initaddobject(Dsetobject,3037,0,"ESCA 3X00 Xray Anode Type","","","")//AID_esca3X00_xray_gun_anode
	//KratosDSET_initaddobject(Dsetobject,3038,0,"ESCA 3400 Xray Emission","","","")//AID_esca3400_xray_gun_emission
	//KratosDSET_initaddobject(Dsetobject,3039,0,"ESCA 3400 Xray Accel HT","","","")//AID_esca3400_xray_gun_accelHT
	KratosDSET_initaddobject(Dsetobject,3040,3,"On Off State of Hardware","","0=F_SWITCH_OFF;1=F_SWITCH_ON","")//AID_on_off_switch
	//KratosDSET_initaddobject(Dsetobject,3041,0,"ESCA 3X00 Ion Gun Emission","","","")//AID_esca3X00_ion_gun_emission
	//KratosDSET_initaddobject(Dsetobject,3042,0,"ESCA 3X00 Ion Gun Accel HT","","","")//AID_esca3X00_ion_gun_accelHT
	//KratosDSET_initaddobject(Dsetobject,3043,0,"Samples Positions Active","","","")//AID_esca_manipulator_samples_enabled
	//KratosDSET_initaddobject(Dsetobject,3044,0,"Sample Positions Number","","","")//AID_esca_manipulator_position
	KratosDSET_initaddobject(Dsetobject,3045,3,"Type Of Analyser","","0=HEMISPHERICAL;1=Mirror HEMISPHERICAL","")//AID_analyser_type
	KratosDSET_initaddobject(Dsetobject,3046,3,"Analyser Scan Mode","","0=FAT;1=FRR","")//AID_analyser_scan_mode
	KratosDSET_initaddobject(Dsetobject,3047,3,"Analyser Pass Energy","","0=5 eV;1=10 eV;2=20 eV;3=40 eV;4=80 eV;5=160 eV;6=320 eV","")//AID_pass_energy
	//KratosDSET_initaddobject(Dsetobject,3048,0,"Analyser retard_ratio","","","")//AID_retard_ratio
	KratosDSET_initaddobject(Dsetobject,3049,3,"HSA Lens Mode","","0=Hybrid;1=Magenetic;2=Slot-M;3=Electrostatic;4=AES;5=UPS;6=ISS;7=Low Mag;8=Medium Mag;9=High Mag;10=SA XPS","")//AID_hsa_lens_mode
	KratosDSET_initaddobject(Dsetobject,3050,3,"MHSA Lens Mode","","0=F_MHSA_LOW_MAGN;1=F_MHSA_MEDIUM_MAGN;2=F_MHSA_HIGH_MAGN","")//AID_mhsa_lens_mode
	//KratosDSET_initaddobject(Dsetobject,3051,0,"Xray Gun current","","","")//AID_manual_xray_gun_current
	//KratosDSET_initaddobject(Dsetobject,3052,0,"Xray Gun voltage","","","")//AID_manual_xray_gun_voltage
	//KratosDSET_initaddobject(Dsetobject,3053,0,"Xray Gun Anode","","","")//AID_manual_xray_gun_anode
	//KratosDSET_initaddobject(Dsetobject,3054,0,"Xray Gun Source","","","")//AID_manual_xray_gun_source
	//KratosDSET_initaddobject(Dsetobject,3055,0,"ESCA Sample name","","","")//AID_esca_manipulator_sample_name
	KratosDSET_initaddobject(Dsetobject,3056,5,"Raster Zoom Factor","","","")//AID_raster_zoom
	KratosDSET_initaddobject(Dsetobject,3057,5,"Raster X Offset Factor","","","")//AID_raster_x_offset
	KratosDSET_initaddobject(Dsetobject,3058,5,"Raster Y Offset Factor","","","")//AID_raster_y_offset
	KratosDSET_initaddobject(Dsetobject,3059,5,"Raster Kinetic Compensation Factor","","","")//AID_raster_ke_factor
	KratosDSET_initaddobject(Dsetobject,3060,5,"Raster X Scale Factor","","","")//AID_raster_x_scale
	KratosDSET_initaddobject(Dsetobject,3061,5,"Raster Y Scale Factor","","","")//AID_raster_y_scale
	KratosDSET_initaddobject(Dsetobject,3062,5,"Raster Rotation Angle","Rads","","")//AID_raster_rotation
	KratosDSET_initaddobject(Dsetobject,3063,5,"Raster Shear Angle","Rads","","")//AID_raster_shear
	KratosDSET_initaddobject(Dsetobject,3064,5,"Xray Gun Settle time","seconds","","")//AID_xray_gun_settle_time
	KratosDSET_initaddobject(Dsetobject,3065,5,"Charge Neutraliser Charge Balance","","","")//AID_neutraliser_charge_balance
	KratosDSET_initaddobject(Dsetobject,3066,5,"Charge Neutraliser Filament Current","","","")//AID_neutraliser_filament_current
	KratosDSET_initaddobject(Dsetobject,3067,5,"Charge Neutraliser Filament Bias","","","")//AID_neutraliser_filament_bias
	KratosDSET_initaddobject(Dsetobject,3068,5,"Magnet Lens Trim Coil","","","")//AID_neutraliser_trim_coil
	KratosDSET_initaddobject(Dsetobject,3069,5,"Magnet Lens Deguass","","","")//AID_neutraliser_deguass
	KratosDSET_initaddobject(Dsetobject,3070,3,"Neutraliser Switch State","","1=F_NEUTRALISER_LEAVE_ON;3=F_NEUTRALISER_MANUAL_SETTINGS","")//AID_neutraliser_state
	KratosDSET_initaddobject(Dsetobject,3071,3,"Hardware Control State","","","")//AID_hardware_control
	//KratosDSET_initaddobject(Dsetobject,3072,0,"Analyser Energy","","","")//AID_analyser_energy
	KratosDSET_initaddobject(Dsetobject,3073,3,"Tuning Mode Flag","","","")//AID_tune_mode_active
	KratosDSET_initaddobject(Dsetobject,3074,5,"Reference Energy","","","")//AID_tune_reference_energy
	KratosDSET_initaddobject(Dsetobject,3075,5,"Max - Min Counts at Reference Energy","","","")//AID_tune_max_to_min_intensity
	KratosDSET_initaddobject(Dsetobject,3076,5,"Half-Width at Reference Energy","","","")//AID_tune_half_width
	KratosDSET_initaddobject(Dsetobject,3077,5,"Peak Area at Reference Energy","","","")//AID_tune_peak_area
	KratosDSET_initaddobject(Dsetobject,3078,5,"Intensity at Reference Energy","","","")//AID_tune_intensity
	//KratosDSET_initaddobject(Dsetobject,3079,0,"Actual Etch Time Performed","","","")//AID_actual_etch_time
	KratosDSET_initaddobject(Dsetobject,3080,3,"Xray Reference Energy","","0=1253.6;1=1486.61;2=0.0;3=2984.2;4=21.21;5=40.80;6=2042.4;7=4510;8=1486.69","")//AID_xray_energy_reference
	//offset: 107028
	//static strconstant f_energy_reference_names					= "Mg;Al;K.E.;Ag;He I;He II;Zr;Ti;Al (Mono)"
	//offset: 47000
	//static strconstant f_energy_reference_values					= "1253.60;1486.61;0;2984.20;21.21;40.80;2042.40;4510;1486.69"
	// in dump_dataset.exe
	//	66 66 66 66 66 96 93 40	-->	1253.6	(offset 46956)
	//	3D 0A D7 A3 70 3A 97 40	-->	1486.61	(offset 46984)
	//	00 00 00 00 00 00 00 00	-->	0.0	(offset 46992)
	//	66 66 66 66 66 50 A7 40	-->	2984.2	(offset 47000)
	//	F6 28 5C 8F C2 35 35 40	-->	21.21	(offset 47008)
	//	66 66 66 66 66 66 44 40	-->	40.80	(offset 47016)
	//	9A 99 99 99 99 E9 9F 40	-->	2042.4	(offset 47024)
	//	00 00 00 00 00 9E B1 40	-->	4510.0	(offset 47032)
	//	F6 28 5C 8F C2 3A 97 40	-->	1486.69	(offset 47040)
	KratosDSET_initaddobject(Dsetobject,3081,3,"OBJECT identification tag","","","")//AID_object_tag
	KratosDSET_initaddobject(Dsetobject,3082,3,"Map acquire sequence","","3=F_DO_1ST_LINE_OF_ALL_MAPS_BEFORE_2ND_LINE_OF_1ST_MAP","")//AID_acquire_sequence
	KratosDSET_initaddobject(Dsetobject,3083,3,"# lines of map completed","","","")//AID_map_lines_completed
	//KratosDSET_initaddobject(Dsetobject,3084,0,"stream info and data","","","")//AID_stream_data
	//KratosDSET_initaddobject(Dsetobject,3085,0,"data stream number","","","")//AID_stream_number
	//KratosDSET_initaddobject(Dsetobject,3086,0,"next line # to be started","","","")//AID_map_prov_next_line
	KratosDSET_initaddobject(Dsetobject,3087,6,"Stage Position Name","","","")//AID_stage_position_name
	KratosDSET_initaddobject(Dsetobject,3088,5,"Stage X Position","m","","")//AID_stage_x_position
	KratosDSET_initaddobject(Dsetobject,3089,5,"Stage Y Position","m","","")//AID_stage_y_position
	KratosDSET_initaddobject(Dsetobject,3090,5,"Stage Z Position","m","","")//AID_stage_z_position
	KratosDSET_initaddobject(Dsetobject,3091,5,"Stage X Rotation","","","")//AID_stage_x_rotation
	KratosDSET_initaddobject(Dsetobject,3092,5,"Stage Y Rotation","","","")//AID_stage_y_rotation
	KratosDSET_initaddobject(Dsetobject,3093,5,"Stage Z Rotation","","","")//AID_stage_z_rotation
	KratosDSET_initaddobject(Dsetobject,3094,6,"Motor Name","","","")//AID_motor_name
	KratosDSET_initaddobject(Dsetobject,3095,5,"Motor Position","m","","")//AID_motor_position
	KratosDSET_initaddobject(Dsetobject,3096,3,"pixel square per point","","","")//AID_image_point_size
	KratosDSET_initaddobject(Dsetobject,3097,3,"Map type","","0=F_MAP_SCANNED;1=F_MAP_STIGMATIC","")//AID_map_type
	KratosDSET_initaddobject(Dsetobject,3098,3,"Stage Position Table","","","")//AID_stage_position_table
	//KratosDSET_initaddobject(Dsetobject,3099,0,"Stage Manual Button State","","","")//AID_stage_button_state
	KratosDSET_initaddobject(Dsetobject,3100,6,"Motor Position Name","","","")//AID_motor_position_name
	KratosDSET_initaddobject(Dsetobject,3101,3,"Selected Area Aperture","","0=F_APERTURE_3by12;1=F_APERTURE_10mm;2=F_APERTURE_2mm;3=F_APERTURE_1mm;4=F_APERTURE_400um;5=F_APERTURE_150um;6=F_NO_APERTURE_SIZES","")//AID_selected_area_aperture
	KratosDSET_initaddobject(Dsetobject,3102,3,"Active Analyser Type","","0=HEMISPHERICAL;1=MIRROR HEMISPHERICAL","")//AID_active_analyser_type
	KratosDSET_initaddobject(Dsetobject,3103,3,"Manually Acquired Data Saved","","","")//AID_iman_current_image_flag
	KratosDSET_initaddobject(Dsetobject,3104,3,"Detector used to set analyser energy map/linescan","","","")//AID_key_detector_number
	KratosDSET_initaddobject(Dsetobject,3105,5,"Analyser Energy for required energy at key detector","","","")//AID_anaylser_energy
	KratosDSET_initaddobject(Dsetobject,3106,5,"Stigmatic Image Shift X","","","")//AID_stigmatic_image_shift_x
	KratosDSET_initaddobject(Dsetobject,3107,5,"Stigmatic Image Shift Y","","","")//AID_stigmatic_image_shift_y
	//KratosDSET_initaddobject(Dsetobject,3108,0,"Institute name","","","")//AID_institute_name
	//KratosDSET_initaddobject(Dsetobject,3109,0,"Sample Batch name","","","")//AID_sample_batch_name
	//KratosDSET_initaddobject(Dsetobject,3110,0,"Destination report file name","","","")//AID_destination_report
	//KratosDSET_initaddobject(Dsetobject,3111,0,"Run time processing operations","","","")//AID_report_processing
	KratosDSET_initaddobject(Dsetobject,3112,5,"Work function","","","")//AID_work_function
	KratosDSET_initaddobject(Dsetobject,3113,6,"Chemical symbol or formula","","","")//AID_species_label
	KratosDSET_initaddobject(Dsetobject,3114,6,"Transition or charge state","","","")//AID_transition_or_charge_state
	//KratosDSET_initaddobject(Dsetobject,3115,0,"Xray Gun power","","","")//AID_manual_xray_gun_power
	//KratosDSET_initaddobject(Dsetobject,3116,0,"Print at Run time flag","","","")//AID_print_report
	KratosDSET_initaddobject(Dsetobject,3117,3,"XPS Energy Scale","","0=F_BINDING_ENERGY;1=F_KINETIC_ENERGY","")//AID_xps_energy_scale
	//KratosDSET_initaddobject(Dsetobject,3118,0,"Electron Gun Beam Voltage","","","")//AID_electron_gun_beam_voltage
	//KratosDSET_initaddobject(Dsetobject,3119,0,"Electron Gun Filament Current","","","")//AID_electron_gun_filament_current
	//KratosDSET_initaddobject(Dsetobject,3120,0,"Electron Gun Emission Current","","","")//AID_electron_gun_emission_current
	//KratosDSET_initaddobject(Dsetobject,3121,0,"Electron Gun Extractor Voltage","","","")//AID_electron_gun_extractor_voltage
	//KratosDSET_initaddobject(Dsetobject,3122,0,"Electron Gun Suppressor Voltage","","","")//AID_electron_gun_suppressor_voltage
	//KratosDSET_initaddobject(Dsetobject,3123,0,"Electron Gun Spot Size Lens","","","")//AID_electron_gun_spot_size
	//KratosDSET_initaddobject(Dsetobject,3124,0,"Electron Gun Focus Lens","","","")//AID_electron_gun_focus
	//KratosDSET_initaddobject(Dsetobject,3125,0,"Electron Gun X alignment","","","")//AID_electron_gun_align_x
	//KratosDSET_initaddobject(Dsetobject,3126,0,"Electron Gun Y alignment","","","")//AID_electron_gun_align_y
	//KratosDSET_initaddobject(Dsetobject,3127,0,"Electron Gun X Stigmator","","","")//AID_electron_gun_stig_x
	//KratosDSET_initaddobject(Dsetobject,3128,0,"Electron Gun Y Stigmator","","","")//AID_electron_gun_stig_y
	//KratosDSET_initaddobject(Dsetobject,3129,0,"On Off State of Electron Gun","","","")//AID_egun_switch_state
	//KratosDSET_initaddobject(Dsetobject,3130,0,"On Off State of SED","","","")//AID_SED_switch_state
	//KratosDSET_initaddobject(Dsetobject,3131,0,"SED Collector bias","","","")//AID_SED_collector_bias
	//KratosDSET_initaddobject(Dsetobject,3132,0,"SED Multiplier bias","","","")//AID_SED_multiplier_bias
	//KratosDSET_initaddobject(Dsetobject,3133,0,"SED Black Level","","","")//AID_SED_black_level
	//KratosDSET_initaddobject(Dsetobject,3134,0,"Input Channel to framestore","","","")//AID_sem_input_channel
	//KratosDSET_initaddobject(Dsetobject,3135,0,"Output for scan ramps","","","")//AID_sem_ramp_output
	//KratosDSET_initaddobject(Dsetobject,3136,0,"SEM Pixel Dwell-time","","","")//AID_sem_dwell_time
	//KratosDSET_initaddobject(Dsetobject,3137,0,"SEM Raster only flag","","","")//AID_sem_raster_only
	//KratosDSET_initaddobject(Dsetobject,3138,0,"SEM Raster Size","","","")//AID_sem_raster_size
	//KratosDSET_initaddobject(Dsetobject,3139,0,"SEM Raster X offset","","","")//AID_sem_raster_x_offset
	//KratosDSET_initaddobject(Dsetobject,3140,0,"SEM Raster Y offset","","","")//AID_sem_raster_y_offset
	//KratosDSET_initaddobject(Dsetobject,3141,0,"Start Spellman E.Gun Extractor Current Readback","","","")//AID_ss_egun_extractor_current
	KratosDSET_initaddobject(Dsetobject,3142,3,"Start Spellman X.Gun active anode","","2=F_SS_ANODE_STD_MONO","")//AID_ss_xgun_active_anode
	KratosDSET_initaddobject(Dsetobject,3143,5,"Start Spellman X.Gun emission","A","","")//AID_ss_xgun_emission_current
	KratosDSET_initaddobject(Dsetobject,3144,5,"Start Spellman X.Gun Anode HT","V","","")//AID_ss_xgun_anode_voltage
	//KratosDSET_initaddobject(Dsetobject,3145,0,"Start Spellman U.V. Strike HT","","","")//AID_ss_uv_strike_ht
	//KratosDSET_initaddobject(Dsetobject,3146,0,"Start Spellman U.V. Discharge Current","","","")//AID_ss_uv_discharge_current
	//KratosDSET_initaddobject(Dsetobject,3147,0,"Start Spellman X.Gun Mono Bias","","","")//AID_ss_xgun_mono_bias
	//KratosDSET_initaddobject(Dsetobject,3148,0,"Start Spellman X.Gun filament Limit","","","")//AID_ss_xgun_filament_limit
	KratosDSET_initaddobject(Dsetobject,3149,3,"Start Spellman X.Gun Energy Reference","","0=F_REFER_TO_XRAY_MG;1=F_REFER_TO_XRAY_AL;2=F_REFER_TO_NONE;3=F_REFER_TO_XRAY_AG;4=F_REFER_TO_UV_HE_I;5=F_REFER_TO_UV_HE_II;6=F_REFER_TO_XRAY_ZR;7=F_REFER_TO_XRAY_TI;8=F_REFER_TO_XRAY_MONO_AL;9=F_NO_ENERGY_REFERENCES","")//AID_ss_xgun_energy_ref
	//KratosDSET_initaddobject(Dsetobject,3150,0,"X.Gun filament Degas first time","","","")//AID_ss_xgun_degas_first_time
	//KratosDSET_initaddobject(Dsetobject,3151,0,"X.Gun filament Degas second time","","","")//AID_ss_xgun_degas_second_time
	//KratosDSET_initaddobject(Dsetobject,3152,0,"X.Gun filament Degas first current","","","")//AID_ss_xgun_degas_first_current
	//KratosDSET_initaddobject(Dsetobject,3153,0,"X.Gun filament Degas second current","","","")//AID_ss_xgun_degas_second_current
	//KratosDSET_initaddobject(Dsetobject,3154,0,"Electron Gun Scan Parameters","","","")//AID_egun_scan_parameters
	//KratosDSET_initaddobject(Dsetobject,3155,0,"Operating Accel. HT (V)","","","")//AID_egun_op_accel_ht_volts
	//KratosDSET_initaddobject(Dsetobject,3156,0,"Operating Spot Size","","","")//AID_egun_op_spot_size
	//KratosDSET_initaddobject(Dsetobject,3157,0,"Operating Emission Current","","","")//AID_egun_op_emission
	//KratosDSET_initaddobject(Dsetobject,3158,0,"Operating Extactor Current","","","")//AID_egun_op_extractor_current
	//KratosDSET_initaddobject(Dsetobject,3159,0,"Electron Gun Filament Type","","","")//AID_egun_filament_type
	//KratosDSET_initaddobject(Dsetobject,3160,0,"Lens Sweep OBJECT","","","")//AID_lens_sweep_object
	//KratosDSET_initaddobject(Dsetobject,3161,0,"Lens Sweep Option","","","")//AID_lens_sweep_option
	//KratosDSET_initaddobject(Dsetobject,3162,0,"Lens Sweep Row","","","")//AID_lens_sweep_row
	//KratosDSET_initaddobject(Dsetobject,3163,0,"Lens Sweep Row","","","")//AID_lens_sweep_active
	//KratosDSET_initaddobject(Dsetobject,3164,0,"Lens Sweep Counter","","","")//AID_lens_sweep_counter
	//KratosDSET_initaddobject(Dsetobject,3165,0,"Lens Sweep Initialise","","","")//AID_lens_sweep_initialise
	//KratosDSET_initaddobject(Dsetobject,3166,0,"Lens Sweep abscissa","","","")//AID_lens_sweep_abscissa
	KratosDSET_initaddobject(Dsetobject,3167,3,"Selected Area Iris Index","","","")//AID_iris_position_index
	KratosDSET_initaddobject(Dsetobject,3168,3,"X.Gun Energy Reference","","","")//AID_manual_xgun_energy_ref
	//KratosDSET_initaddobject(Dsetobject,3169,0,"ESCA 3200 Xray Emission","","","")//AID_esca3200_xray_gun_emission
	//KratosDSET_initaddobject(Dsetobject,3170,0,"ESCA 3200 Xray Accel HT","","","")//AID_esca3200_xray_gun_accelHT
	//KratosDSET_initaddobject(Dsetobject,3171,0,"ESCA 3X00 Resolution","","","")//AID_esca3X00_analyser_resolution
	//KratosDSET_initaddobject(Dsetobject,3172,0,"Samples Positions Active","","","")//AID_xsam_carousel_samples_enabled
	KratosDSET_initaddobject(Dsetobject,3173,3,"Sample Positions Number","","","")//AID_xsam_carousel_position
	//KratosDSET_initaddobject(Dsetobject,3174,0,"XSAM Sample name","","","")//AID_xsam_carousel_sample_name
	//KratosDSET_initaddobject(Dsetobject,3175,0,"Analyser operation suppress flag","","","")//AID_dont_mess_with_analyser
	//KratosDSET_initaddobject(Dsetobject,3176,0,"Samples Position Active","","","")//AID_sample_bar_samples_enabled
	//KratosDSET_initaddobject(Dsetobject,3177,0,"Sample Position Number","","","")//AID_sample_bar_position
	//KratosDSET_initaddobject(Dsetobject,3178,0,"Sample name","","","")//AID_sample_bar_sample_name
	KratosDSET_initaddobject(Dsetobject,3179,5,"Sample Bias","","","")//AID_sample_bias
	KratosDSET_initaddobject(Dsetobject,3180,3,"Start Spellman X.Gun Source","","2=F_SS_XRAY_PSU_SOURCE_3","")//AID_ss_xgun_active_source
	KratosDSET_initaddobject(Dsetobject,3181,6,"Region Comment","","","")//AID_region_comment
	//KratosDSET_initaddobject(Dsetobject,3182,0,"Magnet Scale Factor","","","")//AID_magnet_scale_factor
	//KratosDSET_initaddobject(Dsetobject,3183,0,"Magnet Scale Factor Enabled","","","")//AID_magnet_scale_factor_enabled
	//KratosDSET_initaddobject(Dsetobject,3184,0,"ESCAK1 Aperture name","","","")//AID_escak1_analyser_aperture_name
	//KratosDSET_initaddobject(Dsetobject,3185,0,"ESCAK1 Lens Mode Name","","","")//AID_escak1_analyser_lens_mode_name
	//KratosDSET_initaddobject(Dsetobject,3186,0,"ESCAK1 Lens Mode","","","")//AID_escak1_analyser_lens_mode
	//KratosDSET_initaddobject(Dsetobject,3187,0,"ESCAK1 Aperture","","","")//AID_escak1_analyser_aperture
	KratosDSET_initaddobject(Dsetobject,3188,5,"Stage Gripper","","","")//AID_stage_gripper
	KratosDSET_initaddobject(Dsetobject,3189,5,"Stage Elevator","","","")//AID_stage_elevator
	KratosDSET_initaddobject(Dsetobject,3190,3,"NICPU X-ray Gun Filament","","0=F_NICPU_XRAY_PSU_FILAMENT_MONO_1;1=F_NICPU_XRAY_PSU_FILAMENT_MONO_2;3=F_NICPU_XRAY_PSU_FILAMENT_DUAL_1","")//AID_nicpu_xgun_active_filament
	KratosDSET_initaddobject(Dsetobject,3191,3,"NICPU X-ray Gun Active Anode Material","","0=F_NICPU_XRAY_ANODE_MAGNESIUM;2=F_NICPU_XRAY_ANODE_STD_MONO;7=F_NICPU_XRAY_ANODE_AG_MONO","")//AID_nicpu_xgun_active_anode_material
	KratosDSET_initaddobject(Dsetobject,3192,5,"NICPU X-ray Gun Emission Current","A","","")//AID_nicpu_xgun_emission_current
	KratosDSET_initaddobject(Dsetobject,3193,5,"NICPU X-ray Gun Anode HT Voltage","V","","")//AID_nicpu_xgun_ht_voltage
	KratosDSET_initaddobject(Dsetobject,3194,5,"NICPU X-ray Gun Focus Voltage","V","","")//AID_nicpu_xgun_focus_voltage
	KratosDSET_initaddobject(Dsetobject,3195,5,"NICPU X-ray Gun Filament Current Limit","A","","")//AID_nicpu_xgun_filament_current_limit
	KratosDSET_initaddobject(Dsetobject,3196,5,"NICPU X-ray gun filament degas first time","s","","")//AID_nicpu_xgun_degas_first_time
	KratosDSET_initaddobject(Dsetobject,3197,5,"NICPU X-ray gun filament degas second time","s","","")//AID_nicpu_xgun_degas_second_time
	KratosDSET_initaddobject(Dsetobject,3198,5,"NICPU X-ray gun filament degas first current","A","","")//AID_nicpu_xgun_degas_first_current
	KratosDSET_initaddobject(Dsetobject,3200,5,"NICPU X-ray gun filament degas second current","A","","")//AID_nicpu_xgun_degas_second_current
	KratosDSET_initaddobject(Dsetobject,3201,5,"Magnet Lens Trim Coil 2","","","")//AID_neutraliser_trim_coil_2
	KratosDSET_initaddobject(Dsetobject,3202,5,"Magnet Lens Trim Coil 3","","","")//AID_neutraliser_trim_coil_3
	KratosDSET_initaddobject(Dsetobject,3203,5,"NICPU Ion Gun PSU beam_ht","V","","")//AID_nicpu_igun_beam_ht
	KratosDSET_initaddobject(Dsetobject,3204,5,"NICPU Ion Gun PSU LMIG Beam HT","V","","")//AID_nicpu_igun_LMIG_beam_ht
	KratosDSET_initaddobject(Dsetobject,3205,5,"NICPU Ion Gun PSU Float Voltage","V","","")//AID_nicpu_igun_float_voltage
	KratosDSET_initaddobject(Dsetobject,3206,5,"NICPU Ion Gun PSU LMIG Filament Current","A","","")//AID_nicpu_igun_LMIG_filament_current
	KratosDSET_initaddobject(Dsetobject,3207,5,"NICPU Ion Gun PSU LMIG Beam Current","A","","")//AID_nicpu_igun_LMIG_beam_current
	KratosDSET_initaddobject(Dsetobject,3208,5,"NICPU Ion Gun PSU grid_voltage","V","","")//AID_nicpu_igun_grid_voltage
	KratosDSET_initaddobject(Dsetobject,3209,5,"NICPU Ion Gun PSU Filament Current Limit","A","","")//AID_nicpu_igun_filament_current_limit
	KratosDSET_initaddobject(Dsetobject,3210,5,"NICPU Ion Gun PSU Emission Current","A","","")//AID_nicpu_igun_emission_current
	KratosDSET_initaddobject(Dsetobject,3211,5,"NICPU Ion Gun PSU Extractor Voltage","V","","")//AID_nicpu_igun_extractor_voltage
	KratosDSET_initaddobject(Dsetobject,3212,5,"NICPU Ion Gun PSU Extractor Current","A","","")//AID_nicpu_igun_extractor_current
	KratosDSET_initaddobject(Dsetobject,3213,5,"NICPU Ion Gun PSU Alignment X","V","","")//AID_nicpu_igun_alignment_x_voltage
	KratosDSET_initaddobject(Dsetobject,3214,5,"NICPU Ion Gun PSU Alignment Y","V","","")//AID_nicpu_igun_alignment_y_voltage
	KratosDSET_initaddobject(Dsetobject,3215,5,"NICPU Ion Gun PSU Condenser Voltage","V","","")//AID_nicpu_igun_condenser_voltage
	KratosDSET_initaddobject(Dsetobject,3216,5,"NICPU Ion Gun PSU Focus Voltage","V","","")//AID_nicpu_igun_focus_voltage
	KratosDSET_initaddobject(Dsetobject,3217,3,"NICPU Ion Gun PSU filament","","0=F_NICPU_ION_GUN_FILAMENT_1","")//AID_nicpu_igun_filament
	KratosDSET_initaddobject(Dsetobject,3218,3,"NICPU Ion Gun PSU HT Tracking On","","","")//AID_nicpu_igun_ht_tracking_on
	KratosDSET_initaddobject(Dsetobject,3219,5,"NICPU Ion Gun PSU Raster Offset X","V","","")//AID_nicpu_igun_raster_offset_x_voltage
	KratosDSET_initaddobject(Dsetobject,3220,5,"NICPU Ion Gun PSU Raster Offset Y","V","","")//AID_nicpu_igun_raster_offset_y_voltage
	KratosDSET_initaddobject(Dsetobject,3221,5,"NICPU Ion Gun PSU Raster Scale X","V","","")//AID_nicpu_igun_raster_scale_x_voltage
	KratosDSET_initaddobject(Dsetobject,3222,5,"NICPU Ion Gun PSU Raster Scale Y","V","","")//AID_nicpu_igun_raster_scale_x_voltage
	KratosDSET_initaddobject(Dsetobject,3223,3,"NICPU Analyser Number Detectors","","","")//AID_nicpu_analyser_number_detectors
	KratosDSET_initaddobject(Dsetobject,3224,3,"NICPU X.Gun Energy Reference","","0=F_REFER_TO_XRAY_MG;1=F_REFER_TO_XRAY_AL;2=F_REFER_TO_NONE;3=F_REFER_TO_XRAY_AG;4=F_REFER_TO_UV_HE_I;5=F_REFER_TO_UV_HE_II;6=F_REFER_TO_XRAY_ZR;7=F_REFER_TO_XRAY_TI;8=F_REFER_TO_XRAY_MONO_AL;9=F_NO_ENERGY_REFERENCES","")//AID_nicpu_xgun_energy_ref
	KratosDSET_initaddobject(Dsetobject,3225,5,"NICPU Imager integration time","","","")//AID_image_integration_time
	KratosDSET_initaddobject(Dsetobject,3226,5,"NICPU Ion Gun filament Degas first time","","","")//AID_nicpu_igun_degas_first_time
	KratosDSET_initaddobject(Dsetobject,3227,5,"NICPU Ion Gun filament Degas second time","","","")//AID_nicpu_igun_degas_second_time
	KratosDSET_initaddobject(Dsetobject,3228,5,"NICPU Ion Gun filament Degas first current","","","")//AID_nicpu_igun_degas_first_current
	KratosDSET_initaddobject(Dsetobject,3229,5,"NICPU Ion Gun filament Degas second current","","","")//AID_nicpu_igun_degas_second_current
	KratosDSET_initaddobject(Dsetobject,3230,5,"NICPU Ion Gun PSU Raster Size","mm","","")//AID_nicpu_igun_raster_size
	KratosDSET_initaddobject(Dsetobject,3231,5,"NICPU Ion Gun PSU Beam Current","","","")//AID_nicpu_igun_beam_current
	KratosDSET_initaddobject(Dsetobject,3232,5,"Position of image centre wrt sample holder centre x","","","")//AID_image_centre_wrt_sample_holder_x
	KratosDSET_initaddobject(Dsetobject,3233,5,"Position of image centre wrt sample holder centre y","","","")//AID_image_centre_wrt_sample_holder_y
	KratosDSET_initaddobject(Dsetobject,3234,0,"Scan Sweep OBJECT","","","SWO")//AID_scan_sweep_object
	//KratosDSET_initaddobject(Dsetobject,3235,0,"Scan Sweep Option","","","")//AID_scan_sweep_option
	KratosDSET_initaddobject(Dsetobject,3236,3,"Scan Sweep Row","","","")//AID_scan_sweep_row
	KratosDSET_initaddobject(Dsetobject,3237,3,"Scan Sweep Row","","","")//AID_scan_sweep_active
	KratosDSET_initaddobject(Dsetobject,3238,3,"Scan Sweep Counter","","","")//AID_scan_sweep_counter
	KratosDSET_initaddobject(Dsetobject,3239,3,"Scan Sweep Initialise","","","")//AID_scan_sweep_initialise
	KratosDSET_initaddobject(Dsetobject,3240,5,"Lens Sweep abscissa","","","")//AID_scan_sweep_abscissa
	KratosDSET_initaddobject(Dsetobject,3241,3,"Lens Sweep ordinate acquire","","","")//AID_scan_sweep_ordinate_needed
	KratosDSET_initaddobject(Dsetobject,3242,3,"Selected ordinate in Profile scan","","","")//AID_scan_sweep_quant_ordinate_type
	KratosDSET_initaddobject(Dsetobject,3244,3,"Origin of platen","","","")//AID_platen_level
	KratosDSET_initaddobject(Dsetobject,3245,3,"Type of platen","","","")//AID_platen_type
	KratosDSET_initaddobject(Dsetobject,3246,5,"NICPU X-ray Gun Water Flow Rate Limit","A","","")//AID_nicpu_xgun_water_flow_rate_limit
	KratosDSET_initaddobject(Dsetobject,3247,5,"NICPU X-ray Gun Suppressor or Bias Voltage","V","","")//AID_nicpu_xgun_suppressor_bias_voltage
	KratosDSET_initaddobject(Dsetobject,3248,3,"NOVA sputter shield control bit (0 for no, 1 for yes)","","","")//AID_enable_sputter_shield
	KratosDSET_initaddobject(Dsetobject,3249,5,"Position of image centre wrt sample holder centre z","","","")//AID_image_centre_wrt_sample_holder_z
	KratosDSET_initaddobject(Dsetobject,3250,3,"Auto Z coordinate","","","")//AID_auto_z_this_coordinate
	KratosDSET_initaddobject(Dsetobject,3251,3,"NICPU Ion Gun Enable Azimuthal Rotation","","","")//AID_nicpu_igun_enable_azimuthal_rotation
	KratosDSET_initaddobject(Dsetobject,3252,5,"Electron Gun Filament Voltage","V","","")//AID_electron_gun_filament_voltage
	KratosDSET_initaddobject(Dsetobject,3253,5,"Electron Gun Float Voltage","V","","")//AID_electron_gun_float_voltage
	KratosDSET_initaddobject(Dsetobject,3254,3,"Auto Z ordinate","","","")//AID_ordinate_choice_for_auto_z
	KratosDSET_initaddobject(Dsetobject,3255,5,"Z Step size (mm) for auto z","","","")//AID_delta_z_auto_z
	KratosDSET_initaddobject(Dsetobject,3256,3,"Number of steps in auto z","","","")//AID_n_delta_z
	KratosDSET_initaddobject(Dsetobject,3257,3,"Marker to indicate auto z has been performed 1 for yes 0 for no","","","")//AID_auto_z_done
	KratosDSET_initaddobject(Dsetobject,3258,5,"Marker to request a fine scan after the main scan","","","")//AID_fine_auto_z
	KratosDSET_initaddobject(Dsetobject,3259,5,"Optimum z position","m","","")//AID_auto_z_max_position
	KratosDSET_initaddobject(Dsetobject,3260,3,"Ordinate value at optimum z position","","","")//AID_auto_z_max_position_ordinate_value
	KratosDSET_initaddobject(Dsetobject,3261,3,"This an index to a row in either position tables","","","")//AID_position_table_row
	KratosDSET_initaddobject(Dsetobject,3262,3,"This is an index which identifies a position table","","","")//AID_position_table_id
	KratosDSET_initaddobject(Dsetobject,3263,3,"Index to Scan used for auto z","","","")//AID_auto_z_scan_choice
	KratosDSET_initaddobject(Dsetobject,3264,5,"Width of region in spectra scan","eV","","")//AID_last_scan_width
	KratosDSET_initaddobject(Dsetobject,3265,3,"Energy/line scan # steps","","","")//AID_last_scan_n_steps
	KratosDSET_initaddobject(Dsetobject,3266,5,"Spectrum scan step size","eV","","")//AID_last_spectrum_step_size
	KratosDSET_initaddobject(Dsetobject,3267,5,"Dwell/sweep time","seconds","","")//AID_last_dwell_time
	KratosDSET_initaddobject(Dsetobject,3268,5,"Dwell/sweep time","seconds","","")//AID_snapshot_last_dwell_time
	KratosDSET_initaddobject(Dsetobject,3269,3,"The point of viewed when acquisition is in progress","","","")//AID_POV_id
	//KratosDSET_initaddobject(Dsetobject,3269,0,"This Id',27h,'s a camera as either SAC or SEC","","","")//AID_Nova_camera_id
	KratosDSET_initaddobject(Dsetobject,3272,5,"degree of spherical correction","","","")//AID_spherical_correction_value
	KratosDSET_initaddobject(Dsetobject,3273,3,"Ion Gun Gas State","","","")//AID_nicpu_igun_gas_state
	KratosDSET_initaddobject(Dsetobject,3275,5,"NICPU X-ray Gun Leakage Current Trip High","mA","","")//AID_nicpu_xgun_leakage_current_trip_high
	KratosDSET_initaddobject(Dsetobject,3276,5,"NICPU X-ray Gun Leakage Current Trip Low","mA","","")//AID_nicpu_xgun_leakage_current_trip_low
	KratosDSET_initaddobject(Dsetobject,3277,5,"NICPU X-ray Gun Deionise Delay","seconds","","")//AID_nicpu_xgun_deionise_delay
	KratosDSET_initaddobject(Dsetobject,3278,5,"NICPU Ion Gun Standby Delay Time","seconds","","")//AID_nicpu_igun_standby_time
	KratosDSET_initaddobject(Dsetobject,3279,5,"State Change Delay Time","seconds","","")//AID_state_change_delay
	KratosDSET_initaddobject(Dsetobject,3280,3,"Index used to id flow chart object originated from","","","")//AID_flow_chart_index
	KratosDSET_initaddobject(Dsetobject,3281,3,"Index used to id object in flow diagram","","","")//AID_object_in_flow_chart_index
	KratosDSET_initaddobject(Dsetobject,3282,6,"Descriptor for aperture size used in acquisition","","","")//AID_aperture_size_name
	KratosDSET_initaddobject(Dsetobject,3283,6,"Descriptor for iris position used in acquisition","","","")//AID_iris_position_name
	KratosDSET_initaddobject(Dsetobject,3284,3,"Number of images in X direction (image stitching)","","","")//AID_image_count_x
	KratosDSET_initaddobject(Dsetobject,3285,3,"Number of images in Y direction (image stitching)","","","")//AID_image_count_y
	KratosDSET_initaddobject(Dsetobject,3286,3,"Sample exchange needed","","","")//AID_external_exchange
	KratosDSET_initaddobject(Dsetobject,3287,3,"This is an index that denotes the part of vision that created any' given stage position","","","")//AID_position_source
	//KratosDSET_initaddobject(Dsetobject,3288,0,"TIFF file name","","","")//AID_tiff_file_name
	//KratosDSET_initaddobject(Dsetobject,3289,0,"Scan direction","","","")//AID_scan_direction
	KratosDSET_initaddobject(Dsetobject,3290,6,"Vision Software Version","","","")//AID_vision_software_version
	// comment from Neal Fairley:
	//
	// You should be aware of one thing about the dset files which is why I don't convert them ... 
	// the format in not static between releases of Vision and a minor alteration in the dset parameters
	// may move data around within the binary file. I am sure you can just check your conversion code
	// against the version of Vision you are using each time a new upgrade to Vision is released ...
	// MMRC:	5177 b4901 NICPU: 70 296 b296
	// JCAP:	6432 b6303 NICPU: 72 492 b492
	KratosDSET_initaddobject(Dsetobject,3323,6,"Sample holder name","","","")//AID_sh_name
	KratosDSET_initaddobject(Dsetobject,3324,6,"Export datset file name","","","")//AID_export_file_name
	KratosDSET_initaddobject(Dsetobject,5000,6,"Instrument name","","","")//CID_instrument_name
	//KratosDSET_initaddobject(Dsetobject,3292,0,"Techniques Available","","","")//CID_techniques_available
	//KratosDSET_initaddobject(Dsetobject,3293,0,"Instrument interface type","","","")//CID_intrument_interface
	//KratosDSET_initaddobject(Dsetobject,3294,0,"II processor","","","")//CID_es_processor
	//KratosDSET_initaddobject(Dsetobject,3295,0,"II comms interface","","","")//CID_es_comms_interface
	//KratosDSET_initaddobject(Dsetobject,3296,0,"II port name","","","")//CID_es_port_name
	//KratosDSET_initaddobject(Dsetobject,3297,0,"II serial speed","","","")//CID_es_serial_port_speed
	//KratosDSET_initaddobject(Dsetobject,3298,0,"Excitation sources","","","")//CID_excitation_source_array
	KratosDSET_initaddobject(Dsetobject,5022,3,"Excitation technique","","","")//CID_excitation_technique
	KratosDSET_initaddobject(Dsetobject,5030,3,"Xray excitation code","","","")//CID_xray_excitation_code
	KratosDSET_initaddobject(Dsetobject,5031,4,"Xray photon energy","","","")//CID_xray_photon_energy
	KratosDSET_initaddobject(Dsetobject,5032,3,"Xray gun voltage control flag","","","")//CID_xray_gun_voltage_control_flag
	KratosDSET_initaddobject(Dsetobject,5033,3,"Xray gun current control flag","","","")//CID_xray_gun_current_control_flag
	//KratosDSET_initaddobject(Dsetobject,3304,0,"Xray anode type","","","")//CID_xray_anode_type
	KratosDSET_initaddobject(Dsetobject,5040,3,"Electron Gun excitation code","","","")//CID_egun_excitation_code
	KratosDSET_initaddobject(Dsetobject,5041,3,"Electron Gun gun voltage control flag","","","")//CID_egun_gun_voltage_control_flag
	KratosDSET_initaddobject(Dsetobject,5042,3,"Electron Gun gun current control flag","","","")//CID_egun_gun_current_control_flag
	//KratosDSET_initaddobject(Dsetobject,3308,0,"Lens array","","","")//CID_lens_array
	KratosDSET_initaddobject(Dsetobject,5101,6,"Lens name","","","")//CID_lens_name
	//KratosDSET_initaddobject(Dsetobject,3310,0,"Lens unit number","","","")//CID_lens_unit_number
	//KratosDSET_initaddobject(Dsetobject,3311,0,"Lens polarity","","","")//CID_lens_polarity
	KratosDSET_initaddobject(Dsetobject,5104,4,"Lens max voltage","V","","")//CID_lens_max_voltage
	KratosDSET_initaddobject(Dsetobject,5105,3,"Lens Information array","","","")//CID_lens_information_array
	KratosDSET_initaddobject(Dsetobject,5106,3,"Lens Mode array","","","")//CID_lens_mode_array
	//KratosDSET_initaddobject(Dsetobject,5107,0,"Lens Mode","","","")//CID_lens_mode
	KratosDSET_initaddobject(Dsetobject,5108,3,"Lens Resolution Array","eV","","")//CID_lens_resolution_array
	KratosDSET_initaddobject(Dsetobject,5109,4,"Lens Energy offset","","","")//CID_lens_energy_offset
	KratosDSET_initaddobject(Dsetobject,5110,3,"Lens unit functions","","","")//CID_lens_unit_functions
	KratosDSET_initaddobject(Dsetobject,5111,35,"Lens Function Analyser Energy","","","")//CID_lens_analyser_energy
	KratosDSET_initaddobject(Dsetobject,5112,35,"Lens Function Voltage","","","")//CID_lens_voltage
	KratosDSET_initaddobject(Dsetobject,5126,33,"Analyser Resolutions FAT Flag","","","")//CID_analyser_resolution_fat_flags
	KratosDSET_initaddobject(Dsetobject,5127,35,"Analyser Resolutions Value","","","")//CID_analyser_resolution_exact_values
	KratosDSET_initaddobject(Dsetobject,5128,35,"Analyser Resolutions Offset","","","")//CID_analyser_resolution_offsets
	KratosDSET_initaddobject(Dsetobject,5129,35,"Analyser Resolutions Gain","","","")//CID_analyser_resolution_gains
	KratosDSET_initaddobject(Dsetobject,5130,5,"Analyser work function","","","")//CID_analyser_work_function
	KratosDSET_initaddobject(Dsetobject,5150,3,"# detectors","","","")//CID_n_detectors
	KratosDSET_initaddobject(Dsetobject,5151,4,"Detectors separation ratio","V","","")//CID_detector_separation_ratio
	KratosDSET_initaddobject(Dsetobject,5152,34,"Detectors channeltron voltages","","","")//CID_detector_channeltron_voltages
	KratosDSET_initaddobject(Dsetobject,5500,3,"Configuration Option Toggle State","","0=F_CONFIG_OPTION_DISABLED;1=F_CONFIG_OPTION_ENABLED","")//CID_config_option_state
	KratosDSET_initaddobject(Dsetobject,5501,3,"Configuration VME baud rate","","3=F_VME_38400_BAUD","")//CID_vme_baud_rate
	KratosDSET_initaddobject(Dsetobject,5502,3,"Configuration Host Serial Port","","0=F_HOST_SERIAL_PORT_A","")//CID_host_serial_port
	//KratosDSET_initaddobject(Dsetobject,5503,0,"Configuration VME hostname","","","")//CID_vme_ethernet_hostname
	KratosDSET_initaddobject(Dsetobject,5504,3,"Configuration Host/Slave Comms","","","")//CID_config_host_slave
	KratosDSET_initaddobject(Dsetobject,5505,6,"Configuration Option Name","","","")//CID_option_name
	KratosDSET_initaddobject(Dsetobject,5506,3,"Configuration Instrument","","","")//CID_config_instrument
	KratosDSET_initaddobject(Dsetobject,5507,33,"K4 Vacuum Options","","","")//CID_k4_config_options
	KratosDSET_initaddobject(Dsetobject,5508,3,"K4 Vacuum Fibre OpticSerial Port","","","")//CID_k4_serial_port
	KratosDSET_initaddobject(Dsetobject,5510,3,"Lens Single PSU Options","","","")//CID_lens_single_psu_array
	KratosDSET_initaddobject(Dsetobject,5511,3,"Lens first name","","","")//CID_lens_first_name
	KratosDSET_initaddobject(Dsetobject,5512,3,"Lens PSU unit number","","","")//CID_lens_psu_unit_number
	KratosDSET_initaddobject(Dsetobject,5513,3,"Lens PSU polarity","","","")//CID_lens_psu_polarity
	KratosDSET_initaddobject(Dsetobject,5514,4,"Lens PSU range limit","","","")//CID_lens_psu_range_limit
	//KratosDSET_initaddobject(Dsetobject,5515,0,"Lens Magnification Options","","","")//CID_lens_magnifications
	KratosDSET_initaddobject(Dsetobject,5516,3,"No. Fibre-Optic Timer/Counters","","","")//CID_No_optical_timer_counters
	KratosDSET_initaddobject(Dsetobject,5517,3,"FAT Pass Energy Options","","","")//CID_fat_pass_energy_options
	KratosDSET_initaddobject(Dsetobject,5518,5,"Exact Pass Energy","","","")//CID_exact_pass_energy
	KratosDSET_initaddobject(Dsetobject,5519,5,"Pass Energy 25meV Offset","","","")//CID_pass_energy_25_offset
	KratosDSET_initaddobject(Dsetobject,5520,5,"Pass Energy 25meV Gain","","","")//CID_pass_energy_25_gain
	KratosDSET_initaddobject(Dsetobject,5521,5,"Pass Energy 50meV Offset","","","")//CID_pass_energy_50_offset
	KratosDSET_initaddobject(Dsetobject,5522,5,"Pass Energy 50meV Gain","","","")//CID_pass_energy_50_gain
	KratosDSET_initaddobject(Dsetobject,5523,5,"Pass Energy 100meV Offset","","","")//CID_pass_energy_100_offset
	KratosDSET_initaddobject(Dsetobject,5524,5,"Pass Energy 100meV Gain","","","")//CID_pass_energy_100_gain
	KratosDSET_initaddobject(Dsetobject,5525,3,"Retard Ratio Options","","","")//CID_frr_options
	KratosDSET_initaddobject(Dsetobject,5526,5,"Exact Retard Ratio","","","")//CID_exact_retard_ratio
	KratosDSET_initaddobject(Dsetobject,5527,5,"Retard Ratio 25meV Offset","","","")//CID_retard_ratio_25_offset
	KratosDSET_initaddobject(Dsetobject,5528,5,"Retard Ratio 25meV Gain","","","")//CID_retard_ratio_25_gain
	KratosDSET_initaddobject(Dsetobject,5529,5,"Retard Ratio 50meV Offset","","","")//CID_retard_ratio_50_offset
	KratosDSET_initaddobject(Dsetobject,5530,5,"Retard Ratio 50meV Gain","","","")//CID_retard_ratio_50_gain
	KratosDSET_initaddobject(Dsetobject,5531,5,"Retard Ratio 100meV Offset","","","")//CID_retard_ratio_100_offset
	KratosDSET_initaddobject(Dsetobject,5532,5,"Retard Ratio 100meV Gain","","","")//CID_retard_ratio_100_gain
	KratosDSET_initaddobject(Dsetobject,5533,5,"Work function","eV","","")//CID_work_function
	KratosDSET_initaddobject(Dsetobject,5534,5,"HSA decrease Slew-rate","","","")//CID_hsa_decrease_slew_rate
	KratosDSET_initaddobject(Dsetobject,5535,5,"HSA increase Slew-rate","","","")//CID_hsa_increase_slew_rate
	KratosDSET_initaddobject(Dsetobject,5536,5,"HSA channel Settle-Time","s","","")//CID_hsa_channel_settle_time
	KratosDSET_initaddobject(Dsetobject,5537,3,"HSA 25 meV DAC enabled","","","")//CID_hsa_25meV_steps_enabled
	KratosDSET_initaddobject(Dsetobject,5538,3,"Channeltrons PSU Options","","","")//CID_channeltron_psu_options
	KratosDSET_initaddobject(Dsetobject,5539,35,"Channeltron PSU Limit","V","","")//CID_channeltron_psu_limit
	KratosDSET_initaddobject(Dsetobject,5540,35,"Channeltron PSU Values","V","","")//CID_channeltron_psu_value
	KratosDSET_initaddobject(Dsetobject,5542,3,"Manual Xray PSU Options","","","")//CID_manual_xray_psu_options
	KratosDSET_initaddobject(Dsetobject,5543,3,"Manual PSU Anode","","","")//CID_manual_xray_psu_anode
	KratosDSET_initaddobject(Dsetobject,5544,3,"Manual Xray PSU Fibre Optic Serial Port","","","")//CID_manual_xray_PSU_serial_port
	KratosDSET_initaddobject(Dsetobject,5545,5,"Manual Xray PSU Ramp-Time","","","")//CID_manual_xray_PSU_ramp_time
	KratosDSET_initaddobject(Dsetobject,5546,5,"HSA Detectors separation ratio","","","")//CID_hsa_detector_separation_ratio
	KratosDSET_initaddobject(Dsetobject,5547,5,"HSA Standby Energy","","","")//CID_hsa_standby_energy
	KratosDSET_initaddobject(Dsetobject,5548,3,"No. HSA Channeltron Detectors","","","")//CID_number_of_channeltrons
	KratosDSET_initaddobject(Dsetobject,5549,5,"Channeltron Settle-Time","s","","")//CID_channeltron_settle_time
	KratosDSET_initaddobject(Dsetobject,5550,5,"Channeltron Standby Voltage","V","","")//CID_channeltron_standby_voltage
	KratosDSET_initaddobject(Dsetobject,5551,5,"Channeltron Dead-Time","s","","")//CID_channeltron_dead_time
	KratosDSET_initaddobject(Dsetobject,5562,5,"ESCA decrease Slew-rate","","","")//CID_esca_decrease_slew_rate
	KratosDSET_initaddobject(Dsetobject,5563,5,"ESCA increase Slew-rate","","","")//CID_esca_increase_slew_rate
	KratosDSET_initaddobject(Dsetobject,5564,5,"ESCA channel Settle-Time","s","","")//CID_esca_channel_settle_time
	KratosDSET_initaddobject(Dsetobject,5565,5,"ESCA Standby Energy","eV","","")//CID_esca_standby_energy
	KratosDSET_initaddobject(Dsetobject,5566,5,"ESCA Scan DAC Gain","","","")//CID_esca_scan_dac_gain
	KratosDSET_initaddobject(Dsetobject,5567,5,"ESCA Scan DAC Offset","","","")//CID_esca_scan_dac_offset
	KratosDSET_initaddobject(Dsetobject,5568,3,"ESCA Xray Anode Option","","0=F_ESCA_SINGLE_MG_ANODE","")//CID_esca_xray_anode
	KratosDSET_initaddobject(Dsetobject,5569,3,"ESCA Manipulator Option","","1=F_ESCA_10_POSITION_PROBE","")//CID_esca_manipulator_option
	KratosDSET_initaddobject(Dsetobject,5570,3,"HSA Lens Magnification Options","","","")//CID_hsa_lens_magnifications
	//KratosDSET_initaddobject(Dsetobject,5571,3,"HSA Lens Magnification Options","","","")//CID_hsa_lens_magn_option
	KratosDSET_initaddobject(Dsetobject,5572,3,"MHSA Lens Magnification Options","","","")//CID_mhsa_lens_magnifications
	//KratosDSET_initaddobject(Dsetobject,5573,3,"MHSA Lens Magnification Options","","","")//CID_mhsa_lens_magnoption
	KratosDSET_initaddobject(Dsetobject,5574,3,"Lens Magnification Scanning Enabled","","","")//CID_lens_scanning_enabled
	KratosDSET_initaddobject(Dsetobject,5575,5,"Lens Magnification Full-Scale-Deflection","","","")//CID_lens_magn_fsd
	KratosDSET_initaddobject(Dsetobject,5576,3,"Analyser Operating State Data","","","")//CID_analyser_operating_states
	KratosDSET_initaddobject(Dsetobject,5577,3,"Analyser Scan Mode","","","")//CID_analyser_scan_mode
	//KratosDSET_initaddobject(Dsetobject,5578,0,"Acquisition Parameters","","","")//CID_acquisition_parameters
	KratosDSET_initaddobject(Dsetobject,5579,3,"Lens Double PSU Options","","","")//CID_lens_double_psu_array
	KratosDSET_initaddobject(Dsetobject,5580,3,"Lens second name","","","")//CID_lens_second_name
	KratosDSET_initaddobject(Dsetobject,5581,3,"Channeltron Instrument Config","","","")//CID_channeltron_config
	KratosDSET_initaddobject(Dsetobject,5582,5,"Channel-Plate PSU Limit","V","","")//CID_channelplate_psu_limit
	KratosDSET_initaddobject(Dsetobject,5583,5,"Channel-Plate PSU Values","V","","")//CID_channelplate_psu_value
	KratosDSET_initaddobject(Dsetobject,5584,5,"Channel-Plate PSU Standby","V","","")//CID_channelplate_standby
	KratosDSET_initaddobject(Dsetobject,5585,5,"Channel-Plate PSU Settle-Time","s","","")//CID_channelplate_settle_time
	KratosDSET_initaddobject(Dsetobject,5586,5,"ESCA Xray PSU Settle-Time","s","","")//CID_esca_xray_settle_time	
	KratosDSET_initaddobject(Dsetobject,5587,0,"Transmission Function Object (ke,t)","","","TFO")//CID_transmission_function
	KratosDSET_initaddobject(Dsetobject,5588,3,"Number of Limit Switches","","","")//CID_motor_no_limit_switches
	KratosDSET_initaddobject(Dsetobject,5589,3,"Number of Calibration Switches","","","")//CID_motor_no_calib_switches
	KratosDSET_initaddobject(Dsetobject,5590,5,"Negative-Limit Distance from origin","","","")//CID_motor_negative_limit
	KratosDSET_initaddobject(Dsetobject,5591,5,"Positive-Limit Distancefrom origin","","","")//CID_motor_positive_limit
	KratosDSET_initaddobject(Dsetobject,5592,3,"Number of Steps Per Unit for Motor Axis","","","")//CID_motor_steps_per_unit
	KratosDSET_initaddobject(Dsetobject,5593,3,"Motor Set Number","","","")//CID_motor_group_number
	KratosDSET_initaddobject(Dsetobject,5594,3,"Hardware motor number","","","")//CID_motor_hardware_motor_number
	KratosDSET_initaddobject(Dsetobject,5595,3,"Motor Reverse Direction Flag","","","")//CID_motor_reverse_direction
	KratosDSET_initaddobject(Dsetobject,5596,5,"Motor Start Speed","","","")//CID_motor_start_speed
	KratosDSET_initaddobject(Dsetobject,5597,5,"Motor Final Speed","","","")//CID_motor_final_speed
	KratosDSET_initaddobject(Dsetobject,5598,5,"Motor Acceleration","","","")//CID_motor_acceleration
	KratosDSET_initaddobject(Dsetobject,5599,5,"Motor Manual Slow Speed","","","")//CID_motor_manual_slow_speed
	KratosDSET_initaddobject(Dsetobject,5600,5,"Motor Manual Fast Speed","","","")//CID_motor_manual_fast_speed
	KratosDSET_initaddobject(Dsetobject,5601,5,"Motor Creep Speed","","","")//CID_motor_creep_speed
	KratosDSET_initaddobject(Dsetobject,5602,5,"Motor Creep Distance","","","")//CID_motor_creep_distance
	KratosDSET_initaddobject(Dsetobject,5603,5,"Motor Backlash","","","")//CID_motor_backlash
	KratosDSET_initaddobject(Dsetobject,5604,5,"Motor Calibration Switch Position","","","")//CID_motor_calib_switch_position
	KratosDSET_initaddobject(Dsetobject,5605,5,"Motor Calibration Switch Backoff","","","")//CID_motor_calib_switch_backoff
	KratosDSET_initaddobject(Dsetobject,5606,3,"Motor Move With Motor Set Allowed","","","")//CID_motor_move_with_motor_set_allowed
	KratosDSET_initaddobject(Dsetobject,5607,3,"Motor Calibration Sequence Number","","","")//CID_motor_calibration_sequence_number
	KratosDSET_initaddobject(Dsetobject,5608,3,"Stage Axes","","","")//CID_stage_axes
	//KratosDSET_initaddobject(Dsetobject,5609,0,"Aperture Motors","","","")//CID_aperture_motors
	KratosDSET_initaddobject(Dsetobject,5610,3,"Motor Position Table","","","")//CID_motor_position_table
	KratosDSET_initaddobject(Dsetobject,5611,5,"MHSA Lens Magnification Full-Scale-Deflection","","","")//CID_lens_mhsa_magn_fsd
	KratosDSET_initaddobject(Dsetobject,5612,5,"X Shift between scanned and parallel images","","","")//CID_stigmatic_shift_x
	KratosDSET_initaddobject(Dsetobject,5613,5,"Y Shift between scanned and parallel images","","","")//CID_stigmatic_shift_y
	KratosDSET_initaddobject(Dsetobject,5614,5,"XPS framestore black-level [0,1]","","","")//CID_iman_framestore_black_level
	KratosDSET_initaddobject(Dsetobject,5615,35,"Transmission Function Kinetic Energy","","","trans_ke")//CID_transmission_ke
	KratosDSET_initaddobject(Dsetobject,5616,35,"Transmission Function Value","","","trans_val")//CID_transmission_value
	//KratosDSET_initaddobject(Dsetobject,5617,0,"ESCA sample information","","","")//CID_esca_sample_info
	KratosDSET_initaddobject(Dsetobject,5618,0,"XPS Neutraliser Default Settings","","","")//CID_xps_neutraliser_default_settings
	//KratosDSET_initaddobject(Dsetobject,5619,0,"Electron Gun Operating Settings","","","")//CID_electron_gun_operating_settings
	KratosDSET_initaddobject(Dsetobject,5620,35,"Electron Gun Beam Voltage Limits","","","")//CID_electron_gun_beam_voltage
	KratosDSET_initaddobject(Dsetobject,5621,35,"Electron Gun Filament Current Limits","","","")//CID_electron_gun_filament_current
	KratosDSET_initaddobject(Dsetobject,5622,35,"Electron Gun Emission Current Limits","","","")//CID_electron_gun_emission_current
	KratosDSET_initaddobject(Dsetobject,5623,35,"Electron Gun Extractor Voltage Limits","","","")//CID_electron_gun_extractor_voltage
	KratosDSET_initaddobject(Dsetobject,5624,35,"Electron Gun Suppressor Voltage Limits","","","")//CID_electron_gun_suppressor_voltage
	KratosDSET_initaddobject(Dsetobject,5625,35,"Electron Gun Spot Size Lens Limits","","","")//CID_electron_gun_spot_size
	KratosDSET_initaddobject(Dsetobject,5626,35,"Electron Gun Focus Lens Limits","","","")//CID_electron_gun_focus
	KratosDSET_initaddobject(Dsetobject,5627,35,"Electron Gun Alignment Limits","","","")//CID_electron_gun_alignment
	KratosDSET_initaddobject(Dsetobject,5628,35,"Electron Gun Stigmator Limits","","","")//CID_electron_gun_stigmator
	KratosDSET_initaddobject(Dsetobject,5629,35,"SED Collector bias Limits","","","")//CID_SED_collector_bias
	KratosDSET_initaddobject(Dsetobject,5630,35,"SED Multiplier bias Limits","","","")//CID_SED_multiplier_bias
	KratosDSET_initaddobject(Dsetobject,5631,35,"SED Black Level Limits","","","")//CID_SED_black_level
	KratosDSET_initaddobject(Dsetobject,5632,3,"Electron Gun Type","","","")//CID_electron_gun_type
	//KratosDSET_initaddobject(Dsetobject,5633,0,"SED Operating Modes","","","")//CID_sed_operating_modes
	//KratosDSET_initaddobject(Dsetobject,5634,0,"Slow-scan Geometry List","","","")//CID_slowscan_geometry
	KratosDSET_initaddobject(Dsetobject,5635,5,"Slow-scan Full scan deflection","","","")//CID_slowscan_fsd
	KratosDSET_initaddobject(Dsetobject,5636,3,"Accel EGUN PSU Fibre Optic Serial Port","","","")//CID_egun_accel_PSU_serial_port
	KratosDSET_initaddobject(Dsetobject,5637,3,"Start Spellman Xray PSU Options","","","")//CID_spellman_xray_psu_options
	KratosDSET_initaddobject(Dsetobject,5638,5,"Start Spellman Xray PSU bias Limit","","","")//CID_spellman_xray_psu_mono_bias_limit
	KratosDSET_initaddobject(Dsetobject,5639,3,"ISS Bipolar relays enabled","","","")//CID_iss_bipolar_relays_enabled
	KratosDSET_initaddobject(Dsetobject,5640,3,"Number of VME motor control cards","","","")//CID_no_vme_motor_controllers
	KratosDSET_initaddobject(Dsetobject,5641,3,"VME motor control card number","","","")//CID_vme_motor_controller
	//KratosDSET_initaddobject(Dsetobject,5642,0,"ESCA Scan DAC Gain","","","")//CID_esca_res_dac_gain
	//KratosDSET_initaddobject(Dsetobject,5643,0,"ESCA Scan DAC Offset","","","")//CID_esca_res_dac_offset
	KratosDSET_initaddobject(Dsetobject,5644,3,"ESCA Resolution Option","","0=F_ESCA_ONE_RESOLUTION","")//CID_esca_resolution_option
	KratosDSET_initaddobject(Dsetobject,5645,3,"ESCA Calibrate Analyser","","0=F_ESCA_CALIBRATE_NEVER","")//CID_esca_calibrate_analyser
	KratosDSET_initaddobject(Dsetobject,5646,3,"XSAM Carousel Option","","","")//CID_xsam_carousel_option
	KratosDSET_initaddobject(Dsetobject,5647,5,"Energy offset for mirror analyser","","","")//CID_mhsa_image_energy_offset
	//KratosDSET_initaddobject(Dsetobject,5648,0,"XSAM Carousel sample information","","","")//CID_xsam_carousel_sample_info
	//KratosDSET_initaddobject(Dsetobject,5649,0,"Sample Bar sample information","","","")//CID_sample_bar_sample_info
	KratosDSET_initaddobject(Dsetobject,5650,3,"Stage Sequences of Moves","","","")//CID_stage_sequences
	KratosDSET_initaddobject(Dsetobject,5651,6,"Stage Sequence name","","","")//CID_stage_sequence_name
	//KratosDSET_initaddobject(Dsetobject,5652,0,"Stage Sequence enabled","","","")//CID_stage_sequence_enabled
	KratosDSET_initaddobject(Dsetobject,5653,3,"Motor Valve Interlock Flag","","","")//CID_motor_valve_interlock
	KratosDSET_initaddobject(Dsetobject,5654,5,"Motor Valve Distance","","","")//CID_motor_valve_distance
	KratosDSET_initaddobject(Dsetobject,5655,3,"ESCA Xray Max Accel HT","","0=F_ESCA_JP_XRAY_ACCELHT_2","")//CID_esca_xray_maxHT_code
	KratosDSET_initaddobject(Dsetobject,5656,6,"Engineer Mode Password","","","")//CID_engineer_mode_password
	//KratosDSET_initaddobject(Dsetobject,5657,0,"Engineer Mode Password Length","","","")//CID_engineer_mode_password_length
	KratosDSET_initaddobject(Dsetobject,5658,5,"Sample Bias","","","")//CID_sample_bias
	KratosDSET_initaddobject(Dsetobject,5659,3,"Sample bias Switch Fitted","","","")//CID_sample_bias_switch_fitted
	KratosDSET_initaddobject(Dsetobject,5660,3,"Divide by 10 Box Fitted","","","")//CID_divide_by_10_fitted
	KratosDSET_initaddobject(Dsetobject,5661,35,"Camera FSDs X","mm","","")//CID_camera_fsd_x
	KratosDSET_initaddobject(Dsetobject,5662,35,"Not Used (but has been used)","","","")//CID_camera_2_fsd
	KratosDSET_initaddobject(Dsetobject,5663,3,"Camera options","","","")//CID_camera_options
	KratosDSET_initaddobject(Dsetobject,5664,35,"Rotation axis for v1","","","")//CID_rotation_axis_v1
	KratosDSET_initaddobject(Dsetobject,5665,35,"Rotation axis for v2","","","")//CID_rotation_axis_v2
	KratosDSET_initaddobject(Dsetobject,5666,3,"Registered Users","","","")//CID_user_list
	KratosDSET_initaddobject(Dsetobject,5667,6,"User Name","","","")//CID_user_name
	KratosDSET_initaddobject(Dsetobject,5668,6,"User Password","","","")//CID_user_password
	KratosDSET_initaddobject(Dsetobject,5669,6,"STD Aperture Name for ESCA K1","","","")//CID_escak1_aperture_name_std
	KratosDSET_initaddobject(Dsetobject,5670,6,"1000um Aperture Name for ESCA K1","","","")//CID_escak1_aperture_name_1000um
	KratosDSET_initaddobject(Dsetobject,5671,6,"200um Aperture Name for ESCA K1","","","")//CID_escak1_aperture_name_200um
	KratosDSET_initaddobject(Dsetobject,5672,6,"100um Aperture Name for ESCA K1","","","")//CID_escak1_aperture_name_100um
	KratosDSET_initaddobject(Dsetobject,5673,3,"Polarity of Hardware Bit 15 SML_OR_MCR","","","")//CID_escak1_control_15
	KratosDSET_initaddobject(Dsetobject,5674,3,"Polarity of Hardware Bit 16 MIRR_ERR","","","")//CID_escak1_control_16
	KratosDSET_initaddobject(Dsetobject,5675,3,"Polarity of Hardware Bit 19 HV_OFF","","","")//CID_escak1_control_19
	KratosDSET_initaddobject(Dsetobject,5676,3,"Delay Line Detector Imaging","","","")//CID_nicpu_detector_imaging
	KratosDSET_initaddobject(Dsetobject,5677,3,"NICPU Motor Control Unit Option","","","")//CID_nicpu_motor_control_option
	KratosDSET_initaddobject(Dsetobject,5678,3,"NICPU Analyser FRR Option","","","")//CID_nicpu_analyser_frr
	KratosDSET_initaddobject(Dsetobject,5679,3,"NICPU Analyser ISS Option","","","")//CID_nicpu_analyser_iss
	KratosDSET_initaddobject(Dsetobject,5680,3,"NICPU Analyser UPS Option","","","")//CID_nicpu_analyser_ups
	KratosDSET_initaddobject(Dsetobject,5681,3,"NICPU Analyser TOF Option","","","")//CID_nicpu_analyser_tof
	KratosDSET_initaddobject(Dsetobject,5682,3,"NICPU Magnet Unit Option","","","")//CID_nicpu_magnet_unit_option
	KratosDSET_initaddobject(Dsetobject,5683,5,"NICPU Analyser Standby Energy","eV","","")//CID_nicpu_standby_energy
	KratosDSET_initaddobject(Dsetobject,5684,5,"NICPU Analyser Maximum Energy","eV","","")//CID_nicpu_max_energy
	KratosDSET_initaddobject(Dsetobject,5685,3,"Motor Half Step Flag","","","")//CID_motor_half_step
	KratosDSET_initaddobject(Dsetobject,5686,3,"Motor Winding Phase Reversed Flag","","","")//CID_motor_winding_phase_reversed
	KratosDSET_initaddobject(Dsetobject,5687,3,"NICPU Xray PSU Filaments","","","")//CID_nicpu_xray_psu_filaments
	KratosDSET_initaddobject(Dsetobject,5688,5,"NICPU Xray PSU focus Limit","V","","")//CID_nicpu_xray_psu_focus_voltage_limit
	KratosDSET_initaddobject(Dsetobject,5689,3,"NICPU Xray PSU Anode Material","","","")//CID_nicpu_xray_psu_anode_material
	KratosDSET_initaddobject(Dsetobject,5690,5,"NICPU Ion Gun PSU Condenser Max","","","")//CID_nicpu_ion_gun_psu_condenser_max
	KratosDSET_initaddobject(Dsetobject,5691,5,"NICPU Ion Gun PSU Condenser Min","","","")//CID_nicpu_ion_gun_psu_condenser_min
	KratosDSET_initaddobject(Dsetobject,5692,5,"NICPU Ion Gun PSU Objective Max","","","")//CID_nicpu_ion_gun_psu_objective_max
	KratosDSET_initaddobject(Dsetobject,5693,5,"NICPU Ion Gun PSU Objective Min","","","")//CID_nicpu_ion_gun_psu_objective_min
	KratosDSET_initaddobject(Dsetobject,5694,3,"NICPU Ion Gun Type","","","")//CID_nicpu_ion_gun_type
	KratosDSET_initaddobject(Dsetobject,5695,3,"NICPU Ion Gun PSU Operating Settings","","","")//CID_nicpu_igun_operating_settings
	KratosDSET_initaddobject(Dsetobject,5696,3,"NICPU XRay Gun PSU Focus Settings","","","")//CID_nicpu_xray_psu_spot_settings
	KratosDSET_initaddobject(Dsetobject,5697,5,"NICPU Ion Gun PSU Filament Current Limit","A","","")//CID_nicpu_igun_filament_current_limit
	KratosDSET_initaddobject(Dsetobject,5698,5,"NICPU Delay Line Detector Rotation","Rads","","")//CID_nicpu_detector_rotation
	KratosDSET_initaddobject(Dsetobject,5699,5,"NICPU Delay Line Detector X Shear","Rads","","")//CID_nicpu_detector_x_shear
	KratosDSET_initaddobject(Dsetobject,5700,5,"NICPU Delay Line Detector Y Shear","Rads","","")//CID_nicpu_detector_y_shear
	KratosDSET_initaddobject(Dsetobject,5701,5,"NICPU Delay Line Detector X Offset","","","")//CID_nicpu_detector_x_offset
	KratosDSET_initaddobject(Dsetobject,5702,5,"NICPU Delay Line Detector Y Offset","","","")//CID_nicpu_detector_y_offset
	KratosDSET_initaddobject(Dsetobject,5703,5,"NICPU Delay Line Detector X Compression","","","")//CID_nicpu_detector_x_compression
	KratosDSET_initaddobject(Dsetobject,5704,5,"NICPU Delay Line Detector Y Compression","","","")//CID_nicpu_detector_y_compression
	KratosDSET_initaddobject(Dsetobject,5705,35,"Camera Centre","","","")//CID_camera_centre
	KratosDSET_initaddobject(Dsetobject,5706,3,"NICPU Vacuum Serial Port","","","")//CID_nicpu_serial_port
	KratosDSET_initaddobject(Dsetobject,5707,3,"NOVA Platen Control Option","","","")//CID_nova_platen_control
	//KratosDSET_initaddobject(Dsetobject,5708,0,"NOVA Platen Zone Limits","","","")//CID_nova_platen_zone_limits
	//KratosDSET_initaddobject(Dsetobject,5709,0,"NOVA Platen Zone Lower Limit","","","")//CID_nova_platen_zone_lower_limit
	//KratosDSET_initaddobject(Dsetobject,5710,0,"NOVA Platen Zone Upper Limit","","","")//CID_nova_platen_zone_upper_limit
	//KratosDSET_initaddobject(Dsetobject,5711,0,"Nova Platen Reference coordintates","","","")//CID_nova_platen_ref_coordinates
	KratosDSET_initaddobject(Dsetobject,5712,3,"Delay line detector variant","","","")//CID_dld_detector_PSU_variant
	//KratosDSET_initaddobject(Dsetobject,5713,0,"NOVA Platen SAC Position","","","")//CID_nova_platen_sac_position
	//KratosDSET_initaddobject(Dsetobject,5714,0,"NOVA Platen XPS Position","","","")//CID_nova_platen_xps_position
	//KratosDSET_initaddobject(Dsetobject,5715,0,"NOVA Platen SEC Camera Position","","","")//CID_nova_platen_sec_camera_position
	KratosDSET_initaddobject(Dsetobject,5716,3,"NICPU number of enabled detectors","","","")//CID_nicpu_number_of_enabled_detectors
	KratosDSET_initaddobject(Dsetobject,5717,33,"Current Platen Configuration","","","")//CID_nova_platen_current_state
	KratosDSET_initaddobject(Dsetobject,5718,33,"NICPU Vacuum Options","","","")//CID_nicpu_vacuum_config_options
	KratosDSET_initaddobject(Dsetobject,5719,3,"NICPU Vacuum Chamber Style","","","")//CID_nicpu_vacuum_chamber_style
	KratosDSET_initaddobject(Dsetobject,5720,34,"NICPU configuration data (private to NICPU)","","","")//CID_nicpu_private_info //check
	KratosDSET_initaddobject(Dsetobject,5721,3,"NICPU Xray psu instrument type","","","")//CID_nicpu_xray_psu_instrument
	KratosDSET_initaddobject(Dsetobject,5722,3,"Camera Type","","","")//CID_camera_type
	KratosDSET_initaddobject(Dsetobject,5723,6,"PixeLINK Camera Serial Number","","","")//CID_pixelink_camera_serial_number
	KratosDSET_initaddobject(Dsetobject,5724,4,"Coarse Image Rotation","","","")//CID_coarse_image_rotation
	KratosDSET_initaddobject(Dsetobject,5725,3,"Mirror Image","","","")//CID_mirror_image
	KratosDSET_initaddobject(Dsetobject,5726,3,"Nova gripper unload level","","","")//CID_nova_gripper_unload_level
	KratosDSET_initaddobject(Dsetobject,5727,3,"Nova elevator level 1 content","","","")//CID_nova_elevator_level_1_content
	KratosDSET_initaddobject(Dsetobject,5728,3,"Nova elevator level 2 content","","","")//CID_nova_elevator_level_2_content
	KratosDSET_initaddobject(Dsetobject,5729,3,"Nova elevator level 3 content","","","")//CID_nova_elevator_level_3_content
	KratosDSET_initaddobject(Dsetobject,5730,3,"Nova gripper content","","","")//CID_nova_gripper_content
	KratosDSET_initaddobject(Dsetobject,5731,4,"PixeLINK exposure time","s","","")//CID_pixelink_exposure_time
	//KratosDSET_initaddobject(Dsetobject,5732,0,"Array of acquisition settings: This should include analyser, Xray' PSU and energy region information","","","")//CID_acquisition_lookup_table
	KratosDSET_initaddobject(Dsetobject,5733,5,"Analyser HT Decay Time Constant","","","")//CID_hsa_ht_decay_time
	KratosDSET_initaddobject(Dsetobject,5734,3,"NICPU Motor Step Mode","","","")//CID_nicpu_motor_step_mode
	KratosDSET_initaddobject(Dsetobject,5735,3,"NICPU Motor Holding Current","","","")//CID_nicpu_motor_holding_current
	KratosDSET_initaddobject(Dsetobject,5736,3,"NICPU VM1 PLD Number","","","")//CID_nicpu_pld_option
	KratosDSET_initaddobject(Dsetobject,5737,3,"DLD (NICPU) active","","","")//CID_DLD_signal_conditioning_PCB
	KratosDSET_initaddobject(Dsetobject,5738,4,"Image stitching","","","")//CID_image_stitching
	KratosDSET_initaddobject(Dsetobject,5745,6,"VME IP address or hostname","","","")//CID_vme_ethernet_address
	KratosDSET_initaddobject(Dsetobject,5746,3,"Fine Image Rotation Enabled","","","")//CID_fine_rotation
	KratosDSET_initaddobject(Dsetobject,5747,4,"Fine Image Rotation Angle","degrees","","")//CID_fine_rotation_angle
	KratosDSET_initaddobject(Dsetobject,5748,35,"Camera FSDs Y","mm","","")//CID_camera_fsd_y
	KratosDSET_initaddobject(Dsetobject,5749,3,"5 Position Manual Zoom Lens Fitted","","","")//CID_5_position_manual_zoom_lens
	KratosDSET_initaddobject(Dsetobject,5750,3,"Index into Camera FSDs X/Y of FSD currently applicable","","","")//CID_camera_fsd_index
	KratosDSET_initaddobject(Dsetobject,5751,3,"Trim coil 3 illumination","","","")//CID_trim_coil_3_illumination
	KratosDSET_initaddobject(Dsetobject,5752,5,"Trim coil 3 max illumination current","A","","")//CID_trim_coil_3_max_illumination_current
	KratosDSET_initaddobject(Dsetobject,5753,5,"NICPU XRay HT Ramp Step Time","s","","")//CID_nicpu_xray_ht_ramp_step_time
	KratosDSET_initaddobject(Dsetobject,5754,4,"PixeLINK gamma","","","")//CID_pixelink_gamma
	KratosDSET_initaddobject(Dsetobject,5755,3,"Autofocus","","","")//CID_autofocus
	KratosDSET_initaddobject(Dsetobject,5756,5,"Autofocus range","m","","")//CID_autofocus_range
	KratosDSET_initaddobject(Dsetobject,5757,5,"Autofocus accuracy","m","","")//CID_autofocus_accuracy
	//KratosDSET_initaddobject(Dsetobject,5758,0,"Autofocus move x & y with z","","","")//CID_autofocus_move_xy_with_z
	KratosDSET_initaddobject(Dsetobject,5759,5,"Autofocus dx/dz","","","")//CID_autofocus_xz_gradient
	KratosDSET_initaddobject(Dsetobject,5760,5,"Autofocus dy/dz","","","")//CID_autofocus_yz_gradient
	KratosDSET_initaddobject(Dsetobject,5761,3,"Trim coil 2 illumination","","","")//CID_trim_coil_2_illumination
	KratosDSET_initaddobject(Dsetobject,5762,5,"Trim coil 2 max illumination current","A","","")//CID_trim_coil_2_max_illumination_current
	KratosDSET_initaddobject(Dsetobject,5763,3,"PixeLINK v3 red gain","","","")//CID_pixelink_v3_red_gain
	KratosDSET_initaddobject(Dsetobject,5764,3,"PixeLINK v3 green gain","","","")//CID_pixelink_v3_green_gain
	KratosDSET_initaddobject(Dsetobject,5765,3,"PixeLINK v3 blue gain","","","")//CID_pixelink_v3_blue_gain
	KratosDSET_initaddobject(Dsetobject,5766,34,"NICPU XPS imaging pixel weights","","","")//CID_nicpu_xps_imaging_pixel_weights
	KratosDSET_initaddobject(Dsetobject,5767,0,"NICPU XPS imaging flat field calibration object","","","")//CID_nicpu_xps_imaging_flat_field_calibration_object
	KratosDSET_initaddobject(Dsetobject,5768,3,"DLD Detector PSU PCB Option","","","")//CID_dld_detector_psu_pcb_option
	KratosDSET_initaddobject(Dsetobject,5769,3,"AES down scanning","","","")//CID_aes_down_scanning
	KratosDSET_initaddobject(Dsetobject,5770,3,"NICPU Xray PSU Version","","","")//CID_nicpu_xray_psu_version
	KratosDSET_initaddobject(Dsetobject,5771,5,"NICPU XRay HV PSU emission current software limit","A","","")//CID_nicpu_xray_emission_current_software_limit
	KratosDSET_initaddobject(Dsetobject,5772,3,"NICPU Xray Control Unit Version","","","")//CID_nicpu_xray_control_unit_version
	KratosDSET_initaddobject(Dsetobject,33885409,6,"ALIAS","","","")//ALIAS
	KratosDSET_initaddobject(Dsetobject,33885410,6,"ALIAS","","","")//ALIAS
	KratosDSET_initaddobject(Dsetobject,538971360,3,"NICPU Ion Gun PSU PAH Gun Mode","","","")//AID_nicpu_igun_pah_gun_mode
	KratosDSET_initaddobject(Dsetobject,538971367,3,"NICPU Ion Gun PSU PAH Action On Completion","","","")//AID_nicpu_igun_pah_action_on_completion
	KratosDSET_initaddobject(Dsetobject,538971370,3,"Index into the last sample holder file","","","")//AID_next_sh_index
	KratosDSET_initaddobject(Dsetobject,538971373,3,"Data file index	","","","")//AID_file_index
	KratosDSET_initaddobject(Dsetobject,538971374,3,"Type of experiment contained in AID_sample_holder_acquisition_list","","","")//AID_experiment_type
	KratosDSET_initaddobject(Dsetobject,538971377,3,"Index of sample holder in gripper","","","")//AID_sh_at_analysis
	KratosDSET_initaddobject(Dsetobject,538971379,3,"Index into images dataset","","","")//AID_sh_image_ref
	KratosDSET_initaddobject(Dsetobject,538971381,3,"This indexes identifies the exact sample holder","","","")//AID_sample_holder_index
	KratosDSET_initaddobject(Dsetobject,538971382,3,"Stage frame of reference","","","")//AID_stage_FOV
	KratosDSET_initaddobject(Dsetobject,538971383,3,"This value depicts an item locked state. A value of zero always denotes an unlocked state","","","")//AID_lock_state
	KratosDSET_initaddobject(Dsetobject,538971384,3,"Used to show last file index used to save uncalibrated data","","","")//AID_free_space_file_index
	KratosDSET_initaddobject(Dsetobject,538971395,3,"Number of Tilt Increments","","","")//AID_n_tilt_increments
	KratosDSET_initaddobject(Dsetobject,538971397,3,"Unique experiment index for any given sample holder","","","")//AID_experiment_index
	KratosDSET_initaddobject(Dsetobject,538971401,3,"0 for not, anything else for is","","","")//AID_enabled
	KratosDSET_initaddobject(Dsetobject,538971403,3,"Unique experiment index for any collection in a sample holder","","","")//AID_experiment_collection_index
	KratosDSET_initaddobject(Dsetobject,538971405,3,"counts the number of experiments in the queue","","","")//AID_queue_counter
	KratosDSET_initaddobject(Dsetobject,538971406,3,"Cluster Size","","","")//AID_nicpu_igun_mb6_cluster_size
	KratosDSET_initaddobject(Dsetobject,538973839,3,"NICPU PAH Ion Gun Manually Differentially Pumped","","","")//CID_nicpu_pah_manually_diff_pumped
	KratosDSET_initaddobject(Dsetobject,538973841,3,"NICPU Elevator Controlled by Theta Z Buttons","","","")//CID_nicpu_elevator_controlled_by_theta_z
	//KratosDSET_initaddobject(Dsetobject,538973842,0,"VCU gauge resolution","","","")//CID_VCU_gauge_resolution
	//KratosDSET_initaddobject(Dsetobject,538973846,0,"Number of elevator levels","","","")//CID_n_elevator_levels
	KratosDSET_initaddobject(Dsetobject,542117083,5,"NICPU Ion Gun PSU PAH Wien Voltage","","","")//AID_nicpu_igun_pah_wien_voltage
	KratosDSET_initaddobject(Dsetobject,542117084,5,"NICPU Ion Gun PSU PAH Beam Bend Voltage","","","")//AID_nicpu_igun_pah_beam_bend_voltage
	KratosDSET_initaddobject(Dsetobject,542117085,5,"NICPU Ion Gun PSU PAH Oven Temperature","","","")//AID_nicpu_igun_pah_oven_temperature
	KratosDSET_initaddobject(Dsetobject,542117087,5,"NICPU Ion Gun PSU PAH Oven Ramp Rate","","","")//AID_nicpu_igun_pah_oven_ramp_rate
	KratosDSET_initaddobject(Dsetobject,542117089,5,"Start Spellman X.Gun Anode HT Voltage Limit","V","","")//AID_ss_xgun_anode_ht_voltage_limit
	KratosDSET_initaddobject(Dsetobject,542117090,5,"NICPU X-Ray Gun Anode HT Voltage Limit","V","","")//AID_nicpu_xgun_anode_ht_voltage_limit
	KratosDSET_initaddobject(Dsetobject,542117091,5,"NICPU Ion Gun PSU PAH Beam Monitor Current","","","")//AID_nicpu_igun_pah_beam_monitor_current
	KratosDSET_initaddobject(Dsetobject,542117092,5,"NICPU Ion Gun PSU PAH Emission Current Hold Time","seconds","","")//AID_nicpu_igun_pah_warm_up_emission_hold_time
	KratosDSET_initaddobject(Dsetobject,542117093,5,"NICPU Ion Gun PSU PAH Temperature Hold Time","seconds","","")//AID_nicpu_igun_pah_warm_up_temperature_hold_time
	KratosDSET_initaddobject(Dsetobject,542117094,5,"NICPU Ion Gun PSU PAH Cool Down Time","seconds","","")//AID_nicpu_igun_pah_cool_down_time
	KratosDSET_initaddobject(Dsetobject,542117124,5,"Size of each Tilt Increment	degree","","","")//AID_tilt_increment_size
	KratosDSET_initaddobject(Dsetobject,542117130,5,"Estimate of sample thickness in m","","","")//AID_sample_thickness
	KratosDSET_initaddobject(Dsetobject,542119565,5,"NICPU PAH Ion Gun Oven Temperature Limit","","","")//CID_nicpu_pah_oven_temp_limit
	KratosDSET_initaddobject(Dsetobject,542119572,5,"NICPU Minibeam 6 Gas Mass","","","")//CID_nicpu_igun_mb6_gas_mass
	KratosDSET_initaddobject(Dsetobject,542119573,5,"NICPU Minibeam 6 Magnetic Field","","","")//CID_nicpu_igun_mb6_magnetic_field
	//KratosDSET_initaddobject(Dsetobject,548408559,0,"Object that contains the experiment","","","")//AID_experiment_object
	//KratosDSET_initaddobject(Dsetobject,548408582,0,"Object contain info needed to create (x,y) repeat positions","","","")//AID_xy_repeat_data
	//KratosDSET_initaddobject(Dsetobject,548408583,0,"Object contain info needed to create angle resolved angles","","","")//AID_arxps_data
	//KratosDSET_initaddobject(Dsetobject,548408584,0,"Object contain info needed to create stack z heights","","","")//AID_z_stack_data
	//KratosDSET_initaddobject(Dsetobject,805309680,0,"Experiemt name","","","")//AID_experiment_name
	//KratosDSET_initaddobject(Dsetobject,807406824,0,"Unused","","","")//AID_sample_holder_file_index
	//KratosDSET_initaddobject(Dsetobject,807406825,0,"Indicies of holders loaded in Instrument","","","")//AID_sh_look_up_array
	//KratosDSET_initaddobject(Dsetobject,807406834,0,"Indicies showing contents of each holder location","","","")//AID_sh_content_look_up
	//KratosDSET_initaddobject(Dsetobject,807406841,0,"List of removed sample holder id's to date for instrument","","","")//AID_used_sh_list
	//KratosDSET_initaddobject(Dsetobject,816844011,0,"An array of experiments to be performed in FIFO order","","","")//AID_experiment_list
	//KratosDSET_initaddobject(Dsetobject,816844012,0,"An experiment done at a given, locked, stage position","","","")//AID_experiment
	//KratosDSET_initaddobject(Dsetobject,816844020,0,"Images meta data","","","")//AID_images_meta
	//KratosDSET_initaddobject(Dsetobject,816844026,0,"Each item in the array gives to details of a defined platen","","","")//AID_sh_look_up_details
	//KratosDSET_initaddobject(Dsetobject,816844044,0,"Experiment Queue","","","")//AID_experiment_queue
	KratosDSET_initaddobject(Dsetobject,816846478,3,"NICPU PAH Ion Gun PSU PAH Mode Operating Settings","","","")//CID_nicpu_pah_igun_pah_mode_operating_settings
	KratosDSET_initaddobject(Dsetobject,816846480,3,"NICPU PAH Ion Gun PSU Argon Mode Operating Settings","","","")//CID_nicpu_pah_igun_ar_mode_operating_settings
	KratosDSET_initaddobject(Dsetobject,816846483,3,"NICPU Minibeam 6 Ion Gun PSU Operating Settings","","","")//CID_nicpu_igun_MB6_mode_operating_settings
end


static function KratosDSET_addnotestr(waves, name, str)
	wave waves
	string name
	string str
	if(strlen(str)>0)
		note waves, name+str
	endif
end


static function KratosDSET_addnotenum(waves, name, num)
	wave waves
	string name
	variable num
	string tmps = ""
	sprintf tmps, "%f", num
	if(numtype(num)==0)
		note waves, name+tmps
	endif
end


static function KratosDSET_setnote(Dsetobject, data)
	struct KratosDsetobject &Dsetobject; wave data
	// creates notes from Dsetobject and saves it to wave "data"
	KratosDSET_addnotestr(data, "", Dsetobject.header)
	variable i=0
	for(i=0;i<dimsize(Dsetobject.IDlist,0);i+=1)
		if(Dsetobject.type[i]>9) // arrays of data and not notes
		elseif(Dsetobject.type[i]==6) // this is a string note
			KratosDSET_addnotestr(data, Dsetobject.name[i]+": ", cleanupname(Dsetobject.strvalue[i],0))
		else // numbers with units
			if(strlen(Dsetobject.strvalue[i])!=0) // number was a flag and its string value is now in strvalue
				if(strlen(Dsetobject.units[i]) !=0) // units exits
					KratosDSET_addnotestr(data, Dsetobject.name[i]+" ["+Dsetobject.units[i]+"]: ", Dsetobject.strvalue[i])
				else
					KratosDSET_addnotestr(data, Dsetobject.name[i]+": ", Dsetobject.strvalue[i])
				endif
			else // number is a real value and not a flag
				if(strlen(Dsetobject.units[i]) !=0) // units exits
					KratosDSET_addnotenum(data, Dsetobject.name[i]+" ["+Dsetobject.units[i]+"]: ", Dsetobject.numvalue[i])
				else
					KratosDSET_addnotenum(data, Dsetobject.name[i]+": ", Dsetobject.numvalue[i])
				endif
			endif
		endif
	endfor
end


static function /S KratosDSET_readstr(file)
	variable file
	variable num
	variable i=0
	string tmps=""
	Fbinread /U/B=2/F=3 file, num 	// how many chars
	for(i=0;i<num;i+=1)
		mybinreadBE(file, 3)			// skip first three chars (empty)
		tmps+= mybinreadBE(file, 1)	// read char
	endfor
	return tmps
end


static function KratosDSET_savewave(wavetosave, namewave, Dsetobject, scaleflag)
	wave wavetosave; string namewave; struct KratosDsetobject &Dsetobject; variable scaleflag
	
	string tmps=""
	Make /O/R/N=(1)  $namewave /wave=savewave
	duplicate /O wavetosave, savewave
	if(scaleflag==0) // normal spectrum
		if(strsearch(Dsetobject.strvalue[KratosDSET_IDtopnt(Dsetobject, 5)],"Kinetic Energy",0)==0)	
			tmps=Dsetobject.strvalue[KratosDSET_IDtopnt(Dsetobject, 6)]
			if(str2num(get_flags(f_posEbin)) == 0)
				SetScale/P  x,-str2num(Dsetobject.strvalue[KratosDSET_IDtopnt(Dsetobject, 3080)])+Dsetobject.numvalue[KratosDSET_IDtopnt(Dsetobject, 3)],Dsetobject.numvalue[KratosDSET_IDtopnt(Dsetobject, 4)], tmps, savewave
			else
				SetScale/P  x,str2num(Dsetobject.strvalue[KratosDSET_IDtopnt(Dsetobject, 3080)])-Dsetobject.numvalue[KratosDSET_IDtopnt(Dsetobject, 3)],-Dsetobject.numvalue[KratosDSET_IDtopnt(Dsetobject, 4)], tmps, savewave
			endif
		else
			//????
			tmps=Dsetobject.strvalue[KratosDSET_IDtopnt(Dsetobject, 6)]
			SetScale/P  x,Dsetobject.numvalue[KratosDSET_IDtopnt(Dsetobject, 3)],Dsetobject.numvalue[KratosDSET_IDtopnt(Dsetobject, 4)], tmps, savewave
		endif
		// normalize countrate
		if(str2num(get_flags(f_divbyNscans))==1)
			savewave/=(Dsetobject.numvalue[KratosDSET_IDtopnt(Dsetobject, 99)])
		endif
		
		if(str2num(get_flags(f_divbytime))==1)
			savewave/=(Dsetobject.numvalue[KratosDSET_IDtopnt(Dsetobject, 7)])
		endif
	elseif(scaleflag==2) // mapping image
		variable points = Dsetobject.numvalue[KratosDSET_IDtopnt(Dsetobject, 25)]
		make/FREE/O/D /N=(Dsetobject.numvalue[KratosDSET_IDtopnt(Dsetobject, 25)],Dsetobject.numvalue[KratosDSET_IDtopnt(Dsetobject, 26)]) imagetemp
		imagetemp[][]=savewave[q*points+p]
		duplicate /O imagetemp, savewave
		tmps=Dsetobject.strvalue[KratosDSET_IDtopnt(Dsetobject, 6)]
		SetScale/P  x,Dsetobject.numvalue[KratosDSET_IDtopnt(Dsetobject, 3001)], Dsetobject.numvalue[KratosDSET_IDtopnt(Dsetobject, 3003)], tmps, savewave
		SetScale/P  y,Dsetobject.numvalue[KratosDSET_IDtopnt(Dsetobject, 3002)], Dsetobject.numvalue[KratosDSET_IDtopnt(Dsetobject, 3004)], tmps, savewave
	endif
	KratosDSET_setnote(Dsetobject, savewave)
	return 0
end


static function KratosDSET_saveobject(Dsetobject)
	struct KratosDsetobject &Dsetobject
	string tmps=Gtmpwavename+Dsetobject.nameofdatawave[KratosDSET_IDtopnt(Dsetobject, 12)]
	variable len=16	
	Dsetobject.objectname=cleanupname(Dsetobject.objectname,0)
	Debugprintf2("...exporting: "+Dsetobject.objectname,0)
	String savedDataFolder = GetDataFolder(1)
	SetDataFolder directory
	string tmpwavelist = WaveList(Gtmpwavename+"*", ";", "")
	string tmpwave = ""
	variable i=0
	for(i=0;i<ItemsInList(tmpwavelist,";");i+=1)
		tmpwave = StringFromList(i,tmpwavelist,";")
		SetDataFolder directory
		wave twave = $tmpwave
		SetDataFolder savedDataFolder
		if(cmpstr(tmps,tmpwave,1)==0) // detector (12 - ordwave) or something else
			if(Dsetobject.numvalue[KratosDSET_IDtopnt(Dsetobject, 2)]==2) // F_mapping
				KratosDSET_savewave(twave, shortname(Dsetobject.objectname, len)+"_"+num2str(Dsetobject.id)+dsetobject.appendtodetector, Dsetobject, 2)
			else // normal 1D spectra
				KratosDSET_savewave(twave, shortname(Dsetobject.objectname, len)+"_"+num2str(Dsetobject.id)+dsetobject.appendtodetector, Dsetobject, 0)
			endif
		else
			if(str2num(get_flags(f_onlyDET))==0)
				KratosDSET_savewave(twave, shortname(Dsetobject.objectname, len)+"_"+num2str(Dsetobject.id)+"_"+ReplaceString(Gtmpwavename,tmpwave,""), Dsetobject, -1)
			endif
			//Debugprintf2("Data wave "+tmpwave+" not known! Just killing it!",0)
		endif
		killwaves twave
	endfor
end


static function KratosDSET_getmarkers(file, markercount, nextlist, blockend,Dsetobject)
	variable file; variable &markercount // counter for the markers, for -1 the end of the object block is reached
	wave nextlist; variable blockend; struct KratosDsetobject &Dsetobject
	// one NULL was already read before calling this routine, so we only have to check the max 4 next bytes
	// 3 x NULL --> beginning of new object
	// 2 x NULL --> end of object
	Fstatus file
	variable oldposition = V_filePOS
	variable t1=-1, t2=-1, t3=-1, t4=-1, tmp=0
	FindValue /V=(V_filePOS) nextlist
	if((blockend-oldposition)<0) // end of block --> no markers
		return -1
	elseif((blockend-oldposition)==0 || V_logEOF==V_filePOS+1*4)					// only a } possible
		Fbinread /U/B=2/F=3 file, t1
	elseif((blockend-oldposition)==1*4)												 // a { is not possible
		Fbinread /U/B=2/F=3 file, t1
		Fbinread /U/B=2/F=3 file, t2
		//t1=-1 // or not???
	elseif((blockend-oldposition)==2*4 || V_logEOF==V_filePOS+3*4 || V_value != -1) // a }} is possible
		Fbinread /U/B=2/F=3 file, t1
		Fbinread /U/B=2/F=3 file, t2
		Fbinread /U/B=2/F=3 file, t3
	else
		Fbinread /U/B=2/F=3 file, t1
		Fbinread /U/B=2/F=3 file, t2
		Fbinread /U/B=2/F=3 file, t3
		Fbinread /U/B=2/F=3 file, t4
	endif

	if(t1==0 && t2==0 && t3 == 0 && t4 ==0)	//}{
		Debugprintf2("}{ at pos: "+num2str(oldposition-4),1)
		markercount+=0
		Dsetobject.IDchain = RemoveListItem(0, Dsetobject.IDchain)
		Dsetobject.IDchain = AddListItem(Dsetobject.lastID, Dsetobject.IDchain, ";", 0)
		return 1
	elseif(t1==0 && t2==0 && t3 == 0)			// }}
		Fsetpos file, oldposition+12
		Debugprintf2("}} at pos: "+num2str(oldposition-4),1)
		markercount-=2
		Dsetobject.IDchain = RemoveListItem(0, Dsetobject.IDchain)
		Dsetobject.IDchain = RemoveListItem(0, Dsetobject.IDchain)
		return 1
	elseif(t1==0 && t2==0)						// {
		Fsetpos file, oldposition+8
		Debugprintf2("{ at pos: "+num2str(oldposition-4),1)
		markercount+=1
		Dsetobject.IDchain = AddListItem(Dsetobject.lastID, Dsetobject.IDchain, ";", 0)
		return 1
	elseif(t1==0)									// }
		Fsetpos file, oldposition+4
		Debugprintf2("} at pos: "+num2str(oldposition-4),1)
		Dsetobject.IDchain = RemoveListItem(0, Dsetobject.IDchain)
		markercount-=1
		return 1
	else
		Fsetpos file, oldposition
		return -1
	endif
end


static function KratosDSET_read_object_list(file, Dsetobjectlist)
	variable file; struct KratosDsetobjectlist &Dsetobjectlist

	// initialize Dsetobjectlist
	Make /FREE /O/D/N=(Dsetobjectlist.maxobjects,4) object_offsets ; wave Dsetobjectlist.object_offsets = object_offsets
	Make /FREE /O/T/N=(Dsetobjectlist.maxobjects,3) object_name ; wave /T Dsetobjectlist.object_name = object_name
	Make /FREE /O/D/N=(ceil(Dsetobjectlist.maxobjects/64)) object_nextlist ; wave Dsetobjectlist.object_nextlist = object_nextlist
	Dsetobjectlist.object_offsets = 0
	Dsetobjectlist.object_nextlist = 0
	Dsetobjectlist.object_name = ""
	Dsetobjectlist.loaded = 0

	variable nextoffsetblock = 1
	variable i = 0
	do 
		Fbinread /U/B=2/F=3 file, nextoffsetblock // absolute offset to next offsetblock
		string tmps= ""
		sprintf tmps, "%08.0f", nextoffsetblock ; Debugprintf2("Next offset block at: "+tmps,1)
		if(nextoffsetblock!=0)
			Dsetobjectlist.object_nextlist[i]=nextoffsetblock
		else
			Dsetobjectlist.object_nextlist[i]=-1 // just in case 
		endif
		i+=1
		KratosDSET_read_object_list_s(file, Dsetobjectlist)
		Dsetobjectlist.loaded += 64
		if(nextoffsetblock!=0)
			Fsetpos file, nextoffsetblock
		else
			//???? break
		endif
	while(nextoffsetblock != 0)
end


static function KratosDSET_read_object_list_s(file, Dsetobjectlist)
	variable file; struct KratosDsetobjectlist &Dsetobjectlist

	variable tmp=0, i=0, j=0
	string tmps=""
	i=Dsetobjectlist.loaded
	do
		Fbinread /U/B=2/F=2 file, tmp ;  Dsetobjectlist.object_offsets[i][2]=tmp
		Fbinread /U/B=2/F=2 file, tmp ;  Dsetobjectlist.object_offsets[i][3]=tmp
		tmp = WhichListItem(num2str(Dsetobjectlist.object_offsets[i][2]), offsetsname1_flags)
		if(tmp!=-1)
			Dsetobjectlist.object_name[i][1]=StringFromList(tmp,offsetsname1_value)
			Debugprintf2("1: "+StringFromList(tmp,offsetsname1_value)+", "+num2str(Dsetobjectlist.object_offsets[i][2]),1)
		else
			Fstatus file
			Debugprintf2("Unknown offsetparam #1 "+num2str(Dsetobjectlist.object_offsets[i][2])+" at position "+num2str(V_filePOS)+". Please check with kal and add to script! (ID: "+num2str(i+1)+")",1)
			Dsetobjectlist.object_name[i][1]="UNKNOWN"
		endif
		tmp = WhichListItem(num2str(Dsetobjectlist.object_offsets[i][3]), offsetsname2_flags)
		if(tmp!=-1)
			Dsetobjectlist.object_name[i][2]=StringFromList(tmp,offsetsname2_value)
			Debugprintf2("2: "+StringFromList(tmp,offsetsname2_value)+", "+num2str(Dsetobjectlist.object_offsets[i][3]),1)
		else
			Fstatus file
			Debugprintf2("Unknown offsetparam #2 "+num2str(Dsetobjectlist.object_offsets[i][2])+" at position "+num2str(V_filePOS)+". Please check with kal and add to script! (ID: "+num2str(i+1)+")",1)
			Dsetobjectlist.object_name[i][2]="UNKNOWN"
		endif
		Debugprintf2("Object Flags: "+Dsetobjectlist.object_name[i][1]+" ("+num2str(Dsetobjectlist.object_offsets[i][2])+"), "+Dsetobjectlist.object_name[i][2]+" ("+num2str(Dsetobjectlist.object_offsets[i][3])+")",1)
		
		// now the name of the Block
		tmps=""
		for(j=0;j<4*4;j+=1)
			tmps+=mybinreadBE(file,1) //name of object
		endfor
		Dsetobjectlist.object_name[i][0]=tmps
		Fbinread /U/B=2/F=3 file, tmp ; Dsetobjectlist.object_offsets[i][0]=tmp		// absolute offset of block
		Fbinread /U/B=2/F=3 file, tmp; Dsetobjectlist.object_offsets[i][1]=tmp		// and again
		if(Dsetobjectlist.object_offsets[i][0]!=Dsetobjectlist.object_offsets[i][1])
			Fstatus file
			sprintf tmps, "Position %08.0f ( %08.0f and %08.0f )", V_filePOS, (Dsetobjectlist.object_offsets[i][0]), (Dsetobjectlist.object_offsets[i][1]) ; Debugprintf2("Object "+num2str(i+1)+" is split into two parts: "+Dsetobjectlist.object_name[i][0],1)
		endif
		Debugprintf2(num2str(i+1)+"; "+num2str(Dsetobjectlist.object_offsets[i][0])+" ; "+num2str(Dsetobjectlist.object_offsets[i][1])+" ; "+num2str(Dsetobjectlist.object_offsets[i][2])+" ; "+num2str(Dsetobjectlist.object_offsets[i][3])+" ; "+Dsetobjectlist.object_name[i],1)
		fstatus file
		i+=1
	while (V_logEOF>V_filePOS && i< Dsetobjectlist.loaded +64 && i < Dsetobjectlist.maxobjects)  
end


static function KratosDSET_readblock(file, Dsetobject, Dsetobjectlist)
	variable file; struct KratosDsetobject &Dsetobject; struct KratosDsetobjectlist &Dsetobjectlist
	variable ID = 0, markercount=0, blocklength = 0
	variable lastmarkerpos = -1
	string tmps=""
	Fstatus file
	variable offlast=V_filePOS//variable offlast=offsets[currentobject][0]
	if(Dsetobjectlist.object_offsets[Dsetobjectlist.currentobject][0]!=offlast)
		if(Dsetobjectlist.object_offsets[Dsetobjectlist.currentobject][1]!=offlast)
			Debugprintf2("Error in object offsets!!!!",0)
			return -1
		endif
	endif
	Debugprintf2("New block begins (ID: "+num2str(Dsetobjectlist.currentobject+1)+")",1)
	// read a 4byte uint which contains an object-ID or the ID of the next object block
	Fbinread /U/B=2/F=3 file, blocklength		// first line contains the length of the block
	Fbinread /U/B=2/F=3 file, Dsetobject.id	// second line of the block contains the block-id
	Dsetobject.objectname = Dsetobjectlist.object_name[Dsetobjectlist.currentobject]
	if(Dsetobject.id !=Dsetobjectlist.currentobject+1)
		Debugprintf2("ID and block number are different: "+num2str(Dsetobjectlist.currentobject+1)+" <> "+num2str(Dsetobject.id),0)
		return -1
	endif
	mybinreadBE(file,2*4) // now two empty words (2*4 bytes) should follow ( somehow a "{" )
	Debugprintf2("Number of next spectrum: "+num2str(Dsetobject.id),1)
	Debugprintf2("Size of next Block in bytes: "+num2str(blocklength),1)
	sprintf tmps, "%08.0f", offlast ; Debugprintf2("Current Pos in bytes: "+tmps,1)
	do
		// read object ID
		Fbinread /U/B=2/F=3 file, ID 
		if(KratosDSET_checkID(file, Dsetobject, ID)!=0)
				// check if this is a marker in case ID==0, otherwise unknown ID or a wrong datatype in one ID
				Fstatus file
				if(ID==0) // maybe a marker
					if(KratosDSET_getmarkers(file, markercount, Dsetobjectlist.object_nextlist, blocklength+offlast,Dsetobject)!=1)
						fstatus file
						if(lastmarkerpos != V_filePOS-4)
							// found no markers
							sprintf tmps, "%10.0f", (V_filePOS-4) ; Debugprintf2("Unknown value at position1: "+tmps+" ; Value: "+num2str(ID)+" ; ID: "+num2str(Dsetobjectlist.currentobject+1),0)
							break
						else
							// maybe some unaccounted marker?, need to rewrite the complete maker detection routine
							sprintf tmps, "%10.0f", (V_filePOS-4) ; Debugprintf2("Unaccounted marker at position1: "+tmps,1)
						endif
					else
						// found markers
						fstatus file
						lastmarkerpos = V_filePOS
					endif
					//print Dsetobject.IDchain
				else
					//printf "%10.0f", ID
					sprintf tmps, "%10.0f", (V_filePOS-4) ; Debugprintf2("Unknown value at position2: "+tmps+" ; Value: "+num2str(ID)+" ; ID: "+num2str(Dsetobjectlist.currentobject+1),0)
				endif
		endif
		Fstatus file
		if(offlast+blocklength<=V_filePOS  && markercount <0)
			if(markercount < -1)
				Debugprintf2("Possible error in markercount: "+num2str(markercount),0)
			endif
			// reached end of block
			break
		endif
	while (V_logEOF>V_filePOS)
	return 0
end


static function /S KratosDSET_readcomment(file,endpos)
	variable file; variable endpos
	string comment = ""
	variable tmp = 0
	do
	 	FBinRead/f=1/u file, tmp
	 	if(tmp!=0)
			Fstatus file
			fsetpos file , V_filepos-1
			comment += mybinreadBE(file, 1)
	 	endif
		Fstatus file
	while(V_filepos<endpos)
	return comment
end


static function KratosDSET_cleanup()
	String savedDataFolder = GetDataFolder(1)
	SetDataFolder directory
	string tmpwavelist = WaveList("*", ";", "")
	variable i=0
	for(i=0;i<ItemsInList(tmpwavelist,";");i+=1)
		killwaves $(StringFromList(i,tmpwavelist,";"))
	endfor
	SetDataFolder savedDataFolder
end


static function KratosDSET_read_header(file, Dsetobjectlist)
	variable file; struct KratosDsetobjectlist &Dsetobjectlist

	variable tmp, majorrelease, magicnumber, commentend, offsetdynamic1, offsetdynamic0len, offsetcomments
	string tmps = ""
	// reading header
	Fbinread /U/B=2/F=3 file, magicnumber 					// 1st line - magic number (56833)
	Fbinread /U/B=2/F=3 file, majorrelease 					// 2nd line - major release number (2) -  possible the major release number of the Vision software
	Fbinread /U/B=2/F=3 file, offsetcomments					// 3rd line - random number; comments ???
	Fbinread /U/B=2/F=3 file, commentend						// 4th line - offset to a dynamic offset for offsetblocks
	Fbinread /U/B=2/F=3 file, Dsetobjectlist.startofobjectlist	// 5th line - offset to a first object list block (1036)
	Fbinread /U/B=2/F=3 file, Dsetobjectlist.maxobjects		// 6th line - number of actual number of blocks (max offsets; how many offsets (objectblocks) do we actually have)

	if(majorrelease!=2 || magicnumber!=magic_number || Dsetobjectlist.maxobjects==0)
		//Debugprintf2("Major release 2 expected; got "+num2str(majorrelease),0)
		//Debugprintf2("Wrong magic number!!",0)
		Debugprintf2("No objects to read or wrong header!",0)
		return -1
	endif

	//comments to folllow??? // using offset2 which seems to give evidence of comment chars
	for(tmp=0;tmp<(offsetcomments-(Dsetobjectlist.maxobjects));tmp+=1)
		variable tmp2=0
		Fbinread /U/B=2/F=1 file, tmp2
		Debugprintf2("Number?: "+num2str(tmp2)+"#",1)
		//Debugprintf2("Comment?: "+mybinreadBE(file,1)+"#",0)
	endfor
	// here comes the real comment (does it always start at 360 ???)
	Debugprintf2("Comment: #"+ KratosDSET_readcomment(file, commentend)+"#",0)
	
	// jump to the very first offsetblock
	Fsetpos file, commentend
	Fbinread /U/B=2/F=3 file, offsetdynamic1		// two times the offset where Vision will add new offsets??? + offset4(12)???
	Fbinread /U/B=2/F=3 file, tmp

	if(offsetdynamic1!=tmp)
		Debugprintf2("Offsets differ: "+num2str(offsetdynamic1)+" <> "+num2str(tmp),0)
	elseif(offsetdynamic1!=1024)
		sprintf tmps, "%08.0f", offsetdynamic1 ; Debugprintf2("Check what this offset could be (+12?):  "+tmps,0) // does it somehow correspond to the fileend --> where to add the next offsetsblock???? (12 --> length of 1024 block --> 3*4 bytes --> double offset and length)
	endif
	Fbinread /U/B=2/F=3 file, offsetdynamic0len // offset0+offset4 ==offset = 1024+12==1036
	if(commentend+offsetdynamic0len!=Dsetobjectlist.startofobjectlist)
		Debugprintf2("Something is different here: "+num2str(commentend)+" + "+num2str(offsetdynamic0len)+" <> "+num2str(Dsetobjectlist.startofobjectlist),0)
	endif

	//print "Take a deeper look!!! This is not yet finsished!!!!" // did I include this somewhere else already????
	//Fsetpos file, offsetdynamic1
	//KratosDSET_read_object_list2nd(file)
end


function KratosDSET_check_file(file)
	variable file
	fsetpos file, 0
	variable majorrelease, magicnumber, offsetdynamic0, offsetcomments, startofobjectlist, maxobjects
	// reading header
	Fbinread /U/B=2/F=3 file, magicnumber 					// 1st line - magic number (56833)
	Fbinread /U/B=2/F=3 file, majorrelease 					// 2nd line - major release number (2) -  possible the major release number of the Vision software
	Fbinread /U/B=2/F=3 file, offsetcomments					// 3rd line - random number; comments ???
	Fbinread /U/B=2/F=3 file, offsetdynamic0					// 4th line - offset to a dynamic offset for offsetblocks
	Fbinread /U/B=2/F=3 file, startofobjectlist					// 5th line - offset to a first object list block (1036)
	Fbinread /U/B=2/F=3 file, maxobjects						// 6th line - number of actual number of blocks (max offsets; how many offsets (objectblocks) do we actually have)
	if(majorrelease!=2 || magicnumber!=magic_number || startofobjectlist!=1036)//Dsetobjectlist.maxobjects==0)
		fsetpos file, 0
		return -1
	endif
	fsetpos file, 0
	return 1
end


function KratosDSET_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "Kratos Vision DSET"
	importloader.filestr = "*.dset"
	importloader.category = "PES"
end

// 4byte unsingned int in big-endian (because of sunos --> Sparc)
function KratosDSET_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	KratosDSET_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file

	string tmps = ""

	//print KratosDSET_check_checksum(file)

	struct KratosDsetobject Dsetobject
	struct KratosDsetobjectlist Dsetobjectlist
	KratosDSET_resetDsetobject(Dsetobject)
	Dsetobject.header= header


	Dsetobject.appendtodetector = "_detector"
	if(str2num(get_flags(f_askforEXT)))
		tmps = Dsetobject.appendtodetector
		prompt tmps, "What string to append to detector spectra?"
		doprompt "Import flags!", tmps
		if(V_flag==1)
			Debugprintf2("Cancel import!",0)
			loaderend(importloader)
			return -1
		endif
		Dsetobject.appendtodetector = tmps
	endif

	// read file header
	if(KratosDSET_read_header(file, Dsetobjectlist)==-1)
		Debugprintf2("No blocks to import!",0)
		loaderend(importloader)
		return -1
	endif	
	
	// jump to first offsetblock and get read offsetblocks
	Fsetpos file, Dsetobjectlist.startofobjectlist // from 5th 4byte block at the beginning of file
	KratosDSET_read_object_list(file, Dsetobjectlist)

	// goto first object block and start reading the objects
	Dsetobjectlist.currentobject = 0
	Fsetpos file, Dsetobjectlist.object_offsets[Dsetobjectlist.currentobject][0]
	do
		// read object block
		if(KratosDSET_readblock(file, Dsetobject, Dsetobjectlist)==-1)
			break
		endif
		// in some cases an object is split into two parts
		if(Dsetobjectlist.object_offsets[Dsetobjectlist.currentobject][0]!=Dsetobjectlist.object_offsets[Dsetobjectlist.currentobject][1])
			Debugprintf2("Reading second part of Object with ID: "+num2str(Dsetobjectlist.currentobject+1),1)
			Fsetpos file, Dsetobjectlist.object_offsets[Dsetobjectlist.currentobject][1]
			if(KratosDSET_readblock(file, Dsetobject, Dsetobjectlist)==-1)
				break
			endif
		endif
		// save the data
		KratosDSET_saveobject(Dsetobject)			// save data and
		KratosDSET_resetDsetobject(Dsetobject)	// clean structure for next block
		// goto next object block position
		if(Dsetobjectlist.currentobject<Dsetobjectlist.maxobjects - 1 && Dsetobjectlist.object_offsets[Dsetobjectlist.currentobject+1][0]!=0)
			// just go to beginning next block
			Dsetobjectlist.currentobject+=1
			fsetpos file, Dsetobjectlist.object_offsets[Dsetobjectlist.currentobject][0]
			// and continue
		else
			// last block was read
			Fstatus file
			sprintf tmps, "%08.0f", V_filePOS ;  Debugprintf2("Reached end of file at position: "+tmps,0)
			break
		endif
		Fstatus file
	while (V_logEOF>V_filePOS)  
	
	// remove temporary waves
	KratosDSET_cleanup()
	// more cleanup
	importloader.success = 1
	loaderend(importloader)
end
