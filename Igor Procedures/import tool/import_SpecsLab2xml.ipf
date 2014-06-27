// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

Menu "Macros"
	submenu "Import Tool "+importloaderversion
			submenu "PES"
				"Load SpecsLab2					*.xml	file... v1.1", SpecsXML_load_data()
			end
	end
end


// some xy exported by SpecsLab2 are interpolated, some are not?
// only FAT is sometimes interpolated, not XAS, FE...

// some waves for saving values
static strconstant countlist				= "countlist"
static strconstant scalinglist				= "scalinglist"
static constant charlimit 				= 14

// meas. modes
static strconstant f_FAT					= "FixedAnalyzerTransmission"
static strconstant f_CIS					= "ConstantInitialState"
static strconstant f_CFS					= "ConstantFinalState"
static strconstant f_DVS					= "DetectorVoltageScan"
static strconstant f_SFAT				= "Snapshot (FAT)"
static strconstant f_FE					= "FixedEnergies"


static structure xmlsequence
	string name
	variable length
	string type_id
	string type_name
	variable terminate
endstructure


static structure xmlstruct
	string name
//	variable length
	string type_id
	string type_name
	variable terminate
endstructure


static structure xmlenum
	string name
	string values
	string type_id
	string type_name
	string val
endstructure


static Structure Detectors
	variable position[255]		// eV
	variable shift[255]			// eV
	variable gain[255]			// -
	variable deadtime[255]		// ns
	variable threshold[255] 	// mV
	variable numdetectors
endstructure


static structure RegionInfo
	string nameforwave
	string folder
	string header
	struct Detectors Detector
	string RegionName
	string AktGroupName
	string analysis_method
	string analyzer_lens
	string detector_dataset
	string detector_dataset_directory
	string analyzer_slit
	string scanmode
	variable scanmode_flags
	variable num_scans
	variable curves_per_scan
	variable values_per_curve
	variable dwell_time
	variable scan_delta
	variable excitation_energy
	variable kinetic_energy
	variable kinetic_energy_base
	variable pass_energy
	variable bias_voltage
	variable detector_voltage
	variable effective_workfunction
	variable mcd_head
	variable mcd_tail
	string analyzer_name
	string source_name
	variable times
	variable numcounts
	string YCurve_name
	variable YCurve_start
	variable Ycurve_delta
	variable Ycurve_curves
	variable Ycurve_length
	string comment
endstructure


static function SpecsXML_resetRegionInfo(myRegionInfo)
	struct RegionInfo &myRegionInfo
	variable i=0
	// DLD can have up to 1000 channels but IgorPro has a limit to arrays of structs
	for(i=0;i<255;i+=1)
		myRegionInfo.Detector.position[i]=0
		myRegionInfo.Detector.gain[i]=0
		myRegionInfo.Detector.shift[i]=0
		myRegionInfo.Detector.deadtime[i]=0
		myRegionInfo.Detector.threshold[i]=0
	endfor
	myRegionInfo.Detector.numdetectors=0
	
	myRegionInfo.nameforwave = ""
	myRegionInfo.RegionName = ""
	myRegionInfo.AktGroupName = ""
	myRegionInfo.analysis_method = ""
	myRegionInfo.analyzer_lens = ""
	myRegionInfo.detector_dataset = ""
	myRegionInfo.detector_dataset_directory = ""
	myRegionInfo.analyzer_slit = ""
	myRegionInfo.scanmode = ""
	myRegionInfo.scanmode_flags = 0
	myRegionInfo.num_scans = 0
	myRegionInfo.curves_per_scan = 0
	myRegionInfo.values_per_curve = 0
	myRegionInfo.dwell_time = 0
	myRegionInfo.scan_delta = 0
	myRegionInfo.excitation_energy = 0
	myRegionInfo.kinetic_energy = 0
	myRegionInfo.kinetic_energy_base = 0
	myRegionInfo.pass_energy = 0
	myRegionInfo.bias_voltage = 0
	myRegionInfo.detector_voltage = 0
	myRegionInfo.effective_workfunction = 0
	myRegionInfo.mcd_head = 0
	myRegionInfo.mcd_tail = 0
	myRegionInfo.analyzer_name = ""
	myRegionInfo.source_name = ""
	myRegionInfo.times = 0
	myRegionInfo.numcounts = 0
	myRegionInfo.YCurve_name = ""
	myRegionInfo.YCurve_start = 0
	myRegionInfo.Ycurve_delta = 0
	myRegionInfo.Ycurve_curves = 0
	myRegionInfo.Ycurve_length = 0

	myRegionInfo.comment = ""
end


static function  /S SpecsXML_getID(str,name)
	string str, name
	variable offset =0
	name+="=\""

	if(strsearch(str, name,0)!=-1)
		offset = strsearch(str, name,0)+strlen(name)
		return str[offset,strsearch(str,"\"",offset)-1]
	endif
	return ""
end


static function  /S SpecsXML_getval(str,names, namee)
	string str, names, namee
	if (strsearch(str,"<string name=\"name\">",0) == 0)
		return str[ strlen(names),strlen(str)-strlen(namee)-1]
	endif
	return ""
end


static function SpecsXML_savedetector(myRegionInfo)
	struct RegionInfo &myRegionInfo
	
	// getting counts and scaling list
	wave /Z countlist = $countlist
	wave /Z scalinglist = $scalinglist
	if(WaveExists( countlist) == 0 && WaveExists(scalinglist) == 0)
		Debugprintf2("	... empty region",0)
		killwaves countlist
		killwaves scalinglist
		return 0
	endif
	
	// adding up the single scans in a new counlist
	Make /FREE/O/D/N=(dimsize(countlist,0)) Countliste_avg = 0
	variable i=0
	for(i=0;i<myRegionInfo.num_scans;i+=1)
		Countliste_avg[]+= countlist[p][i]
	endfor

	
	// saving gain etc. in single waves
	// todo: save them already in waves when read (will also avoid the limit of 255 detectors in structs
	Make /FREE/O/D/N=(myRegionInfo.detector.numdetectors) DetGainList = 0
	Make /FREE/O/D/N=(myRegionInfo.detector.numdetectors) DetShiftList = 0
	DetGainList[] = myRegionInfo.detector.gain[p]
	DetShiftList[] = myRegionInfo.detector.shift[p]
	
	// save flags in single variables (for speed reasons)	
	variable f_interpolate = str2num(get_flags("interpolieren"))
	variable f_DivDetGain = str2num(get_flags("DivDetectorGain"))
	variable f_CHE = str2num(get_flags("ChanneltronEinzeln"))
	variable f_DivScans = str2num(get_flags("CB_DivScans"))
	variable f_DivLifeTime = str2num(get_flags("CB_DivLifeTime"))
	variable f_singlescans = str2num(get_flags("singlescans"))
	variable f_DivTF = str2num(get_flags("f_DivTF"))
	variable f_includeTF = str2num(get_flags("includetransmission"))

	// getting max positive detektorshift
	wavestats /M=1 /Q /C=1 DetShiftList
	variable GetMaxPositiveDetektorShift = V_max

	// check for flags and set temporary lists and variables accordingly so we dont need to check for flags every time
	variable tmp_dwell_time = myRegionInfo.dwell_time
	if(f_DivLifeTime == 0)
		tmp_dwell_time = 1
	endif
	variable tmp_num_scans = myRegionInfo.num_scans 
	if(f_DivScans == 0)
		tmp_num_scans = 1
	endif   
	if(f_DivDetGain == 0 && cmpstr(myRegionInfo.scanmode,f_SFAT) != 0) 
		// we need the DetGain for the SFAT mode
		DetGainList = 1
	endif
	// making waves for spectra
 	string detectorname = SpecsXML_checkdblwavename(shortname(cleanname(myRegionInfo.RegionName),charlimit),"_Detector")
	variable t_valx = myRegionInfo.values_per_curve
	if(cmpstr(myRegionInfo.scanmode,f_SFAT)==0)
		t_valx *= myRegionInfo.detector.numdetectors
	 	Make /O/R/N=(t_valx) $detectorname+"_X" /wave=DetectorX
	endif
 	Make /O/R/N=(t_valx) $detectorname /wave=Detector = 0
       if(f_CHE  == 1 && cmpstr(myRegionInfo.scanmode,f_SFAT)!=0)
	 	Make /O/R/N=(t_valx,myRegionInfo.detector.numdetectors) $detectorname+"CHE" /wave=DetectorCHE = 0
	 	Make /O/R/N=(myRegionInfo.detector.numdetectors) $detectorname+"CHEY" /wave=DetectorCHEY = 0
	endif
	if(f_singlescans==1  && cmpstr(myRegionInfo.scanmode,f_SFAT)!=0)
		Make /O/R/N=(t_valx,myRegionInfo.detector.numdetectors*myRegionInfo.num_scans) $detectorname+"CHES" /wave=DetectorCHES = 0
		Make /O/R/N=(myRegionInfo.detector.numdetectors*myRegionInfo.num_scans) $detectorname+"CHESY" /wave=DetectorCHESY = 0
	elseif(f_singlescans==1  && cmpstr(myRegionInfo.scanmode,f_SFAT)==0)
		Make /O/R/N=(t_valx,myRegionInfo.num_scans) $detectorname+"CHES" /wave=DetectorCHES = 0
		Make /O/R/N=(myRegionInfo.num_scans) $detectorname+"CHESY" /wave=DetectorCHESY = 0
		DetectorCHESY[] = p*myRegionInfo.dwell_time
	endif

	variable j=0, k=0, index = 0, tmpr=0, InterpolationsDetektor=0, HauptAnteil=0
	
	for (i=0;i<(myRegionInfo.values_per_curve);i+=1)
		tmpR=0
		for(j=0;j<(myRegionInfo.detector.numdetectors);j+=1)

			strswitch(myRegionInfo.scanmode)
				case f_FAT:
					Index =myregionInfo.mcd_head * myregionInfo.detector.numdetectors + myRegionInfo.detector.numdetectors*(i) + (j) - myRegionInfo.detector.numdetectors*ROUND(DetShiftList[j]*myRegionInfo.pass_energy/myRegionInfo.scan_delta)
				break
				case f_FE:
					Index = myRegionInfo.detector.numdetectors*(i) + (j)  // Hier einfach die Detektoren aufsummieren, da sie hintereinander in der Counts-Liste stehen und auch so zusammen gehoeren !
				break
				case f_CFS:
					Index = myRegionInfo.detector.numdetectors*(i) + (j) //  Hier einfach die Detektoren aufsummieren, da sie hintereinander in der Counts-Liste stehen und auch so zusammen gehoeren !
				break
				case f_CIS:
					Index = myRegionInfo.detector.numdetectors*(i) + (j) // Hier einfach die Detektoren aufsummieren, da sie hintereinander in der Counts-Liste stehen und auch so zusammen gehoeren !
				break
				case f_DVS:
					Index = myRegionInfo.detector.numdetectors*(i) + (j) // Hier einfach die Detektoren aufsummieren, da sie hintereinander in der Counts-Liste stehen und auch so zusammen gehoeren !
				break 
				case f_SFAT:
					// we NEED to multiply by gain!!!
		       		for(k=0;k<myRegionInfo.num_scans;k+=1)
						Detector[j+(i*myRegionInfo.detector.numdetectors)] += countlist[j+(i*myRegionInfo.detector.numdetectors)][k] * DetGainList[j]
				       	if(f_singlescans ==1)
							DetectorCHES[j+(i*myRegionInfo.detector.numdetectors)][k] =  countlist[j+(i*myRegionInfo.detector.numdetectors)][k] * DetGainList[j]
						endif
					endfor
					DetectorX[j+(i*myRegionInfo.detector.numdetectors)] = myRegionInfo.kinetic_energy+myRegionInfo.scan_delta*i+DetShiftList[j]*myRegionInfo.pass_energy
				break 
			endswitch
			
			if(cmpstr(myRegionInfo.scanmode,f_SFAT) != 0)
			
				if(f_interpolate == 1)
					// OMICRON-Methode: Zaehlrate am aktuellen Messpunkt aus den rechts und links davon liegenden Channeltron-Zaehlraten interpolieren
					// Zunaechst mal muss ich ermittel, ob er ab- oder aufgerundet hat, beim bestimmen des Index
					if (abs(mod(DetShiftList[j]*myRegionInfo.pass_energy/myRegionInfo.scan_delta,1))<0.5)
						// Es wurde abgerundet => ich muss mit einem um eine Schrittweite IM INDEX HOEHER liegenden Datenpunkt interpolieren
						InterpolationsDetektor = -1
						HauptAnteil = 1 - abs(mod(DetShiftList[j]*myRegionInfo.pass_energy/myRegionInfo.scan_delta,1))
					else
						// Es wurde aufgerundet => ich muss mit einem um eine Schrittweite IM INDEX NIEDRIGER liegenden Datenpunkt interpolieren
						InterpolationsDetektor = 1
						HauptAnteil = abs(mod(DetShiftList[j]*myRegionInfo.pass_energy/myRegionInfo.scan_delta,1))
					endif
					InterpolationsDetektor = InterpolationsDetektor * SIGN(mod(DetShiftList[j],1))// Der Detektor-Versatz kann ja positiv oder negativ sein. Bei negativem Versatz muss ich die Richtung umkehren !
					if (InterpolationsDetektor == 0)
						TmpR = TmpR + Countliste_avg[Index]*DetGainList[j] // Zaehlraten der Einzelchanneltrons addieren
	 				else
						TmpR = TmpR + HauptAnteil * Countliste_avg[Index]*DetGainList[j] // Index zeigt ja immer auf den am naehesten an der Energie liegenden Messpunkt. Von da muss also der Hauptteil (>0,5) kommen
						If((Index + InterpolationsDetektor*myRegionInfo.detector.numdetectors) < 0 || (Index + InterpolationsDetektor*myRegionInfo.detector.numdetectors) > (myRegionInfo.numcounts-1)) //todo ||
							InterpolationsDetektor = 0// Sollte der Datenpunkt ausserhalb der Liste liegen, also nicht mitgemessen worden sein, dass nehme ich einfach den mit Index spezifizierten Punkt zu 100%
						endif
				             	TmpR = TmpR + (1-HauptAnteil) * Countliste_avg[Index+ InterpolationsDetektor*myRegionInfo.detector.numdetectors]*DetGainList[j]// Index zeigt ja immer auf den am naehesten an der Energie liegenden Messpunkt. Von da muss also der Hauptteil (>0,5) kommen
 					endif
	  			else
 					// Specs-Methode: nicht interpolieren, sondern die Channeltron-Zaehlrate, die dem aktuellen Messpunkt am naehesten liegt voll dem Messpunkt zuordnen
					TmpR = TmpR + Countliste_avg[Index]*DetGainList[j] //Zaehlraten der Einzelchanneltrons addieren
				endif

			       if(f_CHE == 1)
				       // detector shift berücksichtigen ....
					DetectorCHE[i][j]=Countliste_avg[Index] * DetGainList[j]
					if(cmpstr(myRegionInfo.scanmode,f_FAT)==0) //time scale
						DetectorCHEY[j]=myRegionInfo.dwell_time*(myRegionInfo.mcd_head+j)
					else // kinetic energy scale
						DetectorCHEY[j]=myRegionInfo.kinetic_energy+DetShiftList[j]*myRegionInfo.pass_energy
					endif
			       endif
			       
		       	if(f_singlescans ==1)
		       		for(k=0;k<myRegionInfo.num_scans;k+=1)
						DetectorCHES[i][j+(k*myRegionInfo.detector.numdetectors)]=countlist[Index][k]*DetGainList[j]
						if(cmpstr(myRegionInfo.scanmode,f_FAT)==0) // time scale
							DetectorCHESY[j+(k*myRegionInfo.detector.numdetectors)]=myRegionInfo.dwell_time*(myRegionInfo.mcd_head+j+k*(dimsize(Countliste_avg,0)/myRegionInfo.detector.numdetectors))
						else // kinetic energy scale
							DetectorCHESY[j+(k*myRegionInfo.detector.numdetectors)]=myRegionInfo.kinetic_energy+DetShiftList[j]*myRegionInfo.pass_energy
						endif
					endfor
				endif
		
		       endif

		endfor
		
		if(cmpstr(myRegionInfo.scanmode,f_SFAT) != 0)
			Detector[i] = tmpr
		endif

	endfor

	// cps conversion if desired && save spectra and add notes
     	Detector /= tmp_num_scans
     	Detector /= tmp_dwell_time
	SpecsXML_savewave(Detector, myRegionInfo, 1)
	if(cmpstr(myRegionInfo.scanmode,f_SFAT)==0)
		SpecsXML_savewave(DetectorX, myRegionInfo, 1)
	endif
	// single channeltrons
       if(f_CHE  == 1&& cmpstr(myRegionInfo.scanmode,f_SFAT)!=0)
		DetectorCHE /= tmp_num_scans
		DetectorCHE /= tmp_dwell_time
		SpecsXML_savewave(DetectorCHE, myRegionInfo, 1)
		// quote: "The 1D wave has to be 1 point longer than the corresponding dimension of the 2D wave, because the boundaries of the pixels are taken into account."
		// Y-wave scaling
		redimension /N=(dimsize(DetectorCHEY,0)+1) DetectorCHEY
		DetectorCHEY[dimsize(DetectorCHEY,0)-1] =  2*DetectorCHEY[dimsize(DetectorCHEY,0)-2]-DetectorCHEY[dimsize(DetectorCHEY,0)-3]
		if(str2num(get_flags("vskineticenergy"))==0 && cmpstr(myRegionInfo.scanmode,f_SFAT)!=0 && cmpstr(myRegionInfo.scanmode,f_FAT)!=0 &&cmpstr(myRegionInfo.scanmode,f_CFS) != 0)
			if(str2num(get_flags("posbinde")) == 0)
				DetectorCHEY -= myRegionInfo.excitation_energy
			else
				DetectorCHEY = myRegionInfo.excitation_energy - DetectorCHEY
			endif
		endif
		SpecsXML_savewave(DetectorCHEY, myRegionInfo, 1)
	endif
	// single scans
      	if(f_singlescans==1)
		DetectorCHES /= tmp_num_scans
		DetectorCHES /= tmp_dwell_time
		SpecsXML_savewave(DetectorCHES, myRegionInfo, 1)
		// quote: "The 1D wave has to be 1 point longer than the corresponding dimension of the 2D wave, because the boundaries of the pixels are taken into account."
		// Y-wave scaling
		redimension /N=(dimsize(DetectorCHESY,0)+1) DetectorCHESY
		DetectorCHESY[dimsize(DetectorCHESY,0)-1] =  2*DetectorCHESY[dimsize(DetectorCHESY,0)-2]-DetectorCHESY[dimsize(DetectorCHESY,0)-3]
		if(str2num(get_flags("vskineticenergy"))==0 && cmpstr(myRegionInfo.scanmode,f_SFAT)!=0 && cmpstr(myRegionInfo.scanmode,f_FAT)!=0 && cmpstr(myRegionInfo.scanmode,f_CFS) != 0)
			if(str2num(get_flags("posbinde")) == 0)
				DetectorCHESY -= myRegionInfo.excitation_energy
			else
				DetectorCHESY = myRegionInfo.excitation_energy - DetectorCHESY
			endif
		endif
		SpecsXML_savewave(DetectorCHESY, myRegionInfo, 1)
	endif
	
	// divide Detector by Transmission Function	
 	if( f_DivTF && f_includeTF)
		Make /O/R/N=(0) $detectorname+"divTF" /wave=DetectordivTF = 0
		wave DetectorTF = $(detectorname[0,strlen(detectorname)-10]+"_transm")
		duplicate /O Detector, DetectordivTF
		DetectordivTF[] /= DetectorTF[p]
 	endif
	
	// delete tmp waves
	killwaves countlist
	killwaves scalinglist
end


static function SpecsXML_savewave(savewave, myRegionInfo, mode)
	wave savewave
	struct RegionInfo &myRegionInfo
	variable mode


	Note savewave, ""+myRegionInfo.header
	Note savewave, "Region Name: "+myRegionInfo.RegionName
	Note savewave, "Scans: " + num2str(myRegionInfo.num_scans)
	//	Note  savewave, "Curve: " + num2str(curve)
	//	Note  savewave, "Channel: " + num2str(channel)
	Note  savewave,"Method: " + myRegionInfo.analysis_method
	Note  savewave,"Analyzer: " + myRegionInfo.Analyzer_Name
	Note  savewave,"Analyzer Lens: " + myRegionInfo.analyzer_lens
	Note  savewave,"Analyzer Slit: " + myRegionInfo.analyzer_slit
	Note  savewave,"Scan Mode: " + myRegionInfo.scanmode
	Note  savewave,"Dwell time: " + num2str(myRegionInfo.dwell_time)+"s"
	Note  savewave,"Excitation energy: " + num2str(myRegionInfo.excitation_energy)+"eV"
	Note  savewave,"Kinetic energy: " + num2str(myRegionInfo.kinetic_energy)+"eV"
	Note  savewave,"Kinetic energy base: " + num2str(myRegionInfo.kinetic_energy_base)+"eV"
	Note  savewave,"Pass energy: " + num2str(myRegionInfo.pass_energy)+"eV"
	Note  savewave,"Bias Voltage: " + num2str(myRegionInfo.bias_voltage)
	Note  savewave,"Detector Voltage: " + num2str(myRegionInfo.detector_voltage)
	Note  savewave,"Effective Workfunction: " + num2str(myRegionInfo.effective_workfunction)
	Note  savewave,"Source: " + myRegionInfo.Source_name
	//	Note  savewave,"Remote: " + remote
	//	Note  savewave,"RemoteInfo: " + remoteInfo				
	Note  savewave, "Comment: " + myRegionInfo.comment

	variable Unixtime  = myRegionInfo.times+2082844800
	Debugprintf2("Time Of Recording: "+Secs2Date(Unixtime,-2)+" ; "+ Secs2Time(Unixtime,3) + "(UTC) (GMT=UTC+2)",1)
	Note  savewave, "Time Of Recording (UTC): "+Secs2Date(Unixtime,-2)+" ; "+ Secs2Time(Unixtime,3)
	Note  savewave, "Time Of Recording (GMT): "+Secs2Date(Unixtime+60*2*60,-2)+" ; "+ Secs2Time(Unixtime+60*2*60,3)

	
	if(mode==1)	
		SetScale d, 0,0,"cps", savewave
		strswitch(myRegionInfo.scanmode)
			case f_FAT:
				if(str2num(get_flags("vskineticenergy"))==0)
					if(str2num(get_flags("posbinde")) == 0)
						SetScale/P  x,myRegionInfo.kinetic_energy-myRegionInfo.excitation_energy,myRegionInfo.scan_delta,"eV",  savewave
					else
						SetScale/P  x,-myRegionInfo.kinetic_energy+myRegionInfo.excitation_energy,-myRegionInfo.scan_delta,"eV",  savewave
					endif
					Note  savewave, "x-axis: bindingy energy"
					Note  savewave, "y-axis: intensity"
				else
					SetScale/P  x,myRegionInfo.kinetic_energy,myRegionInfo.scan_delta,"eV",  savewave
					Note  savewave, "x-axis: kinetic energy"
					Note  savewave, "y-axis: intensity"
				endif				
			break
			case f_FE:
				SetScale/P  x,0,myRegionInfo.dwell_time,"s",  savewave
				Note  savewave, "x-axis: time"
				Note  savewave, "y-axis: intensity"
			break
			case f_CFS:
				SetScale/P  x,myRegionInfo.excitation_energy,myRegionInfo.scan_delta,"eV",  savewave
				Note  savewave, "x-axis: photon energy"
				Note  savewave, "y-axis: intensity"
			break
			case f_CIS:
				SetScale/P  x,myRegionInfo.excitation_energy,myRegionInfo.scan_delta,"eV",  savewave
				Note  savewave, "x-axis: photon energy"
				Note  savewave, "y-axis: intensity"
			break
			case f_DVS:
				SetScale/P  x,myRegionInfo.detector_voltage,myRegionInfo.scan_delta,"V",  savewave
				Note  savewave, "x-axis: detector voltage"
				Note  savewave, "y-axis: intensity"
			break 
			case f_SFAT:
				if(str2num(get_flags("vskineticenergy"))==0)
					if(str2num(get_flags("posbinde")) == 0)
						SetScale/P  x,myRegionInfo.kinetic_energy-myRegionInfo.excitation_energy,myRegionInfo.scan_delta,"eV",  savewave
					else
						SetScale/P  x,-myRegionInfo.kinetic_energy+myRegionInfo.excitation_energy,-myRegionInfo.scan_delta,"eV",  savewave
					endif
					Note  savewave, "x-axis: bindingy energy"
					Note  savewave, "y-axis: intensity"
				else
					SetScale/P  x,myRegionInfo.kinetic_energy,myRegionInfo.scan_delta,"eV",  savewave
					Note  savewave, "x-axis: kinetic energy"
					Note  savewave, "y-axis: intensity"
				endif				
			break
		endswitch
		if(dimsize(savewave,1)>0)
			strswitch(myRegionInfo.scanmode)
				case f_FAT:
					SetScale/P  y,0,myRegionInfo.dwell_time,"s",  savewave
				break
				case f_FE:
					// each channel measures differnt finial state --> SFAT, todo
					SetScale/P  y,0,1,"eV",  savewave
				break
				case f_CFS:
					// each channel measures differnt finial state --> SFAT, todo
					SetScale/P  y,0,1,"eV",  savewave
				break
				case f_CIS:
					// each channel measures differnt inital state --> SFAT, todo
					SetScale/P  y,0,1,"eV",  savewave
				break
				case f_DVS:
					// each channel measures differnt finial state --> SFAT, todo
					SetScale/P  y,0,1,"eV",  savewave
				break
				case f_SFAT:
					// each channel measures differnt finial state --> SFAT, todo
					SetScale/P  y,0,1,"eV",  savewave
				break
			endswitch
		endif
	endif	
	
	if(mode==2) // data and ADC curves
		if(	myRegionInfo.Ycurve_length - myRegionInfo.mcd_tail - myRegionInfo.mcd_head  == myRegionInfo.values_per_curve)
			myRegionInfo.YCurve_start += myRegionInfo.YCurve_delta * myRegionInfo.mcd_head
			variable i=0
			for(i=0;i<myRegionInfo.values_per_curve;i+=1)
				 savewave[i] =  savewave[i+myRegionInfo.mcd_head]
			endfor
			redimension /N=(myRegionInfo.values_per_curve) savewave

			SetScale d, 0,0,"cps", savewave
			strswitch(myRegionInfo.scanmode)
				case f_FAT:
					if(str2num(get_flags("vskineticenergy"))==0)
						if(str2num(get_flags("posbinde")) == 0)
							SetScale/P  x,myRegionInfo.YCurve_start-myRegionInfo.excitation_energy,myRegionInfo.YCurve_delta,"eV", savewave
						else
							SetScale/P  x,-myRegionInfo.YCurve_start+myRegionInfo.excitation_energy,-myRegionInfo.YCurve_delta,"eV", savewave
						endif
						Note savewave, "x-axis: binding energy"
						Note savewave, "y-axis: intensity"
					else
						SetScale/P  x,myRegionInfo.YCurve_start,myRegionInfo.YCurve_delta,"eV",  savewave
						Note  savewave, "x-axis: kinetic energy"
						Note  savewave, "y-axis: intensity"
					endif				
					break
				case f_FE:
					SetScale/P  x,myRegionInfo.YCurve_start,myRegionInfo.YCurve_delta,"s", savewave
					Note savewave, "x-axis: time"
					Note savewave, "y-axis: intensity"
					break
				case f_CFS:
					SetScale/P  x,myRegionInfo.YCurve_start,myRegionInfo.YCurve_delta,"eV", savewave
					Note savewave, "x-axis: photon energy"
					Note savewave, "y-axis: intensity"
					break
				case f_CIS:
					SetScale/P  x,myRegionInfo.YCurve_start,myRegionInfo.YCurve_delta,"eV", savewave
					Note savewave, "x-axis: photon energy"
					Note savewave, "y-axis: intensity"
					break
				case f_DVS:
					SetScale/P  x,myRegionInfo.YCurve_start,myRegionInfo.YCurve_delta,"V", savewave
					Note savewave, "x-axis: detector voltage"
					Note savewave, "y-axis: intensity"
					break 
				case f_SFAT:
					if(str2num(get_flags("vskineticenergy"))==0)
						if(str2num(get_flags("posbinde")) == 0)
							SetScale/P  x,myRegionInfo.YCurve_start-myRegionInfo.excitation_energy,myRegionInfo.YCurve_delta,"eV", savewave
						else
							SetScale/P  x,-myRegionInfo.YCurve_start+myRegionInfo.excitation_energy,myRegionInfo.YCurve_delta,"eV", savewave
						endif
						Note savewave, "x-axis: binding energy"
						Note savewave, "y-axis: intensity"
					else
						SetScale/P  x,myRegionInfo.YCurve_start,myRegionInfo.YCurve_delta,"eV",  savewave
						Note  savewave, "x-axis: kinetic energy"
						Note  savewave, "y-axis: intensity"
					endif				
					break
			endswitch
		else
			SetScale/P  x,myRegionInfo.YCurve_start,myRegionInfo.YCurve_delta,"", savewave
		endif
	endif
end


static function /S SpecsXML_checkdblwavename(strs, stre)
	string strs, stre
	string tempname = strs+stre
	if(WaveExists($tempname))
		variable i=0
		do
			i+=1
			tempname = strs+"_"+num2str(i)+stre
		while(WaveExists($tempname))
	endif
	return tempname
end


static function SpecsXML_readstructsafterseq(file, givenstruct, savewave, savepos, myRegionInfo, length, name)
	variable file
	struct xmlstruct &givenstruct
	wave /Z &savewave
	variable &savepos
	struct RegionInfo &myRegionInfo
	variable length
	string name
	if(length==-1)
		length = 1
	endif
	
	variable i, j
	string tmps
	for(i=0;i<length;i+=1)
		j=i
		FReadLine file, tmps
		SpecsXML_getstruct(tmps, givenstruct, name)
		SpecsXML_readstruct(file, givenstruct, savewave, j, myRegionInfo)
	endfor
	FReadLine file, tmps //</sequence>
	return 0
end


static function /S SpecsXML_checktype(file, givenstruct, givenseq, givenenum, savewave, savepos, myRegionInfo, str)
	variable file
	struct xmlstruct &givenstruct
	struct xmlsequence &givenseq
	struct xmlenum &givenenum
	wave /Z &savewave
	variable &savepos
	struct RegionInfo &myRegionInfo
	string str

		If (strsearch(str,"</struct>",0) == 0)
			//if(strsearch(givenstruct.type_name,"RegionData",0)==0)
			//	SpecsXML_savedetector(myRegionInfo)
			//	SpecsXML_resetRegionInfo(myRegionInfo)
			//endif
			return "12"
		elseIf (strsearch(str,"<sequence",0) == 0)
			SpecsXML_getsq(str, givenseq)
			SpecsXML_readsq(file, givenseq, savewave, savepos, myRegionInfo)
			return ""
		elseIf (strsearch(str,"<struct",0) == 0)
			SpecsXML_getstruct(str, givenstruct, "structstruct")
			SpecsXML_readstruct(file, givenstruct, savewave, savepos, myRegionInfo)
			return ""
		elseIf (strsearch(str,"<enum",0) == 0)
			SpecsXML_getenum(str, givenenum)	
			return ""
		elseIf (strsearch(str,"/>",0) !=  -1)
			return ""
		endif
		return str
end




static function SpecsXML_readparamstruct(file, givenstruct, savewave, savepos, myRegionInfo, str)
	variable file
	struct xmlstruct &givenstruct
	wave /Z &savewave
	variable &savepos
	struct RegionInfo &myRegionInfo
	string str
	string tmps
	
	struct xmlsequence myseq
	struct xmlenum myenum
	string param

	
	
	FReadLine file, tmps // <any name="value">
	if(strsearch(tmps,"/>",0) !=  -1)
		return 0	
	endif

	do 
		FReadLine file, tmps
		tmps = mycleanupstr(tmps)
		If (strlen(tmps)==0)
			return 0
		elseIf (strsearch(tmps,"</any>",0) == 0)
			//just skipping anatyhing between right now
			return 0
		endif
		tmps = SpecsXML_checktype(file, givenstruct, myseq, myenum, savewave, savepos, myRegionInfo, tmps)
		if(strlen(tmps) != 0)
			param = stringfromlist(1,str)
#if 0
			strswitch(param)
				case "Current [nA]":
					str2num(SpecsXML_getvariable(file, "double"))
					break
				case "Energy [eV]":
					str2num(SpecsXML_getvariable(file, "double"))
					break
				case "Source":
					FReadLine file, tmps
					SpecsXML_getenum(tmps, myenum)	
					break
				case "Threshold [mV]":
					myregionInfo.Detector.threshold[savepos] = str2num(SpecsXML_getvariable(file, "double"))
					break
				case "Deadtime [ns]":
					myregionInfo.Detector.deadtime[savepos] = str2num(SpecsXML_getvariable(file, "double"))
					break
				case "Excitation range (min max step)":
					SpecsXML_getvariable(file, "string")
					break
				case "Wavelength set timeout [ms]":
					str2num(SpecsXML_getvariable(file, "long"))
					break
				case "Wavelength set delay [ms]":
					str2num(SpecsXML_getvariable(file, "double"))
					break
				case "Energy correction slope":
					str2num(SpecsXML_getvariable(file, "double"))
					break
				case "Energy correction intercept":
					str2num(SpecsXML_getvariable(file, "double"))
					break
				case "Use intensity scaling":
					str2num(SpecsXML_getvariable(file, "boolean"))
					break
				case "ADC channel number":
					str2num(SpecsXML_getvariable(file, "ulong"))
					break
				case "ADC input scaling":
					str2num(SpecsXML_getvariable(file, "double"))
					break
				case "Scaling":
					str2num(SpecsXML_getvariable(file, "double"))
					break
				case "Use wait on threshold":
					str2num(SpecsXML_getvariable(file, "boolean"))
					break
				case "Threshold value":
					str2num(SpecsXML_getvariable(file, "double"))
					break
				case "ADC threshold channel number":
					str2num(SpecsXML_getvariable(file, "ulong"))
					break
				case "ADC threshold input scaling":
					str2num(SpecsXML_getvariable(file, "double"))
					break
				case "Threshold timeout [ms]":
					str2num(SpecsXML_getvariable(file, "long"))
					break
				case "Offset":
					str2num(SpecsXML_getvariable(file, "double"))
					break
				case "Style":
					SpecsXML_getvariable(file, "string")
					break
				case "Color":
					str2num(SpecsXML_getvariable(file, "ulong"))
					break
				case "Interpolation":
					str2num(SpecsXML_getvariable(file, "boolean"))
					break
				case "File":
					SpecsXML_getvariable(file, "string")
					break
				case "Group":
					SpecsXML_getvariable(file, "string")
					break
				case "First of group":
					str2num(SpecsXML_getvariable(file, "boolean"))
					break
				case "Comment":
					//print "Comment: ", SpecsXML_getvariable(file, "string")
					myRegionInfo.comment = SpecsXML_getvariable(file, "string")
					break
				case "Logfile":
					SpecsXML_getvariable(file, "string")
					break
				case "ADC channel 1 active":
					str2num(SpecsXML_getvariable(file, "boolean"))
					break			
				case "    channel 1 name":
					SpecsXML_getvariable(file, "string")
					break
				case "    channel 1 input scaling":
					str2num(SpecsXML_getvariable(file, "double"))
					break
				case "ADC channel 2 active":
					str2num(SpecsXML_getvariable(file, "boolean"))
					break			
				case "    channel 2 name":
					SpecsXML_getvariable(file, "string")
					break
				case "    channel 2 input scaling":
					str2num(SpecsXML_getvariable(file, "double"))
					break
				case "ADC channel 3 active":
					str2num(SpecsXML_getvariable(file, "boolean"))
					break			
				case "    channel 3 name":
					SpecsXML_getvariable(file, "string")
					break
				case "    channel 3 input scaling":
					str2num(SpecsXML_getvariable(file, "double"))
					break
				case "ADC channel 4 active":
					str2num(SpecsXML_getvariable(file, "boolean"))
					break			
				case "    channel 4 name":
					SpecsXML_getvariable(file, "string")
					break
				case "    channel 4 input scaling":
					str2num(SpecsXML_getvariable(file, "double"))
					break
				case "ADC channel 5 active":
					str2num(SpecsXML_getvariable(file, "boolean"))
					break			
				case "    channel 5 name":
					SpecsXML_getvariable(file, "string")
					break
				case "    channel 5 input scaling":
					str2num(SpecsXML_getvariable(file, "double"))
					break
				case "ADC channel 6 active":
					str2num(SpecsXML_getvariable(file, "boolean"))
					break			
				case "    channel 6 name":
					SpecsXML_getvariable(file, "string")
					break
				case "    channel 6 input scaling":
					str2num(SpecsXML_getvariable(file, "double"))
					break
				case "ADC channel 7 active":
					str2num(SpecsXML_getvariable(file, "boolean"))
					break			
				case "    channel 7 name":
					SpecsXML_getvariable(file, "string")
					break
				case "    channel 7 input scaling":
					str2num(SpecsXML_getvariable(file, "double"))
					break
				case "ADC channel 8 active":
					str2num(SpecsXML_getvariable(file, "boolean"))
					break			
				case "    channel 8 name":
					SpecsXML_getvariable(file, "string")
					break
				case "    channel 8 input scaling":
					str2num(SpecsXML_getvariable(file, "double"))
					break
				case "Anode":
					SpecsXML_getbetween(file)
					break
				case "Power [W]":
					str2num(SpecsXML_getvariable(file, "double"))
					break
				case "Voltage [kV]":
					str2num(SpecsXML_getvariable(file, "double"))
					break
				case "Angle [deg]":
					str2num(SpecsXML_getvariable(file, "double"))
					break
				case "End of acquisition":
					SpecsXML_getbetween(file)
					break
				case "Background Method":
					SpecsXML_getbetween(file) //eigentlich enum
					break
				case "FWHM":
					//SpecsXML_readparamstruct(file, mystruct, savewave, savepos, myRegionInfo)
					break
				case "Counts":
					//SpecsXML_readparamstruct(file, mystruct, savewave, savepos, myRegionInfo)
					break
				case "Count-BG":
					//SpecsXML_readparamstruct(file, mystruct, savewave, savepos, myRegionInfo)
					break
				case "Rate":
					//SpecsXML_readparamstruct(file, mystruct, savewave, savepos, myRegionInfo)
					break
				case "Rate-BG":
					//SpecsXML_readparamstruct(file, mystruct, savewave, savepos, myRegionInfo)
					break
				case "Area":
					//SpecsXML_readparamstruct(file, mystruct, savewave, savepos, myRegionInfo)
					//str2num(SpecsXML_getvariable(file, "double"))
					break
				case "PktLeft":
					//SpecsXML_readparamstruct(file, mystruct, savewave, savepos, myRegionInfo)
					break
				case "PktRight":
					//SpecsXML_readparamstruct(file, mystruct, savewave, savepos, myRegionInfo)
					break
				case "Asymmetry":
				
					break
				case "FWHM-Annotation":
					break
				default:
					Debugprintf2("Unknown paramerer!: "+param,0)
					break
			endswitch
#endif
		endif
		Fstatus file
	while (V_logEOF>V_filePOS)  	

	return 0
end



static function SpecsXML_readsq(file, seq, savewave, savepos, myRegionInfo)
	variable file
	struct xmlsequence &seq
	wave /Z &savewave
	variable &savepos
	struct RegionInfo &myRegionInfo
	
	struct xmlsequence myseq
	struct xmlstruct mystruct
	struct xmlenum myenum

	string tmps = "", tmps2=""
	variable i=0, tmpd=0, j=0
	
	
	if(seq.length==0 && seq.terminate == -1)
		seq.length = -1 // there is one empty empty struct etc. follwoing 
	elseif(seq.length==0)
		return 0 //there is no </sequence>
	endif
	
	strswitch(seq.type_name)
		case "RegionGroupSeq":
			SpecsXML_readstructsafterseq(file, mystruct, savewave, savepos, myRegionInfo, seq.length, seq.type_name)
			break
			
		case "RegionDataSeq":
			SpecsXML_readstructsafterseq(file, mystruct, savewave, savepos, myRegionInfo, seq.length, seq.type_name)
			break
			
		case "ExcitationSeq":
			SpecsXML_readstructsafterseq(file, mystruct, savewave, savepos, myRegionInfo, seq.length, seq.type_name)
			break
	
		case "DetectorSeq":
			myRegionInfo.Detector.numdetectors = seq.length
			SpecsXML_readstructsafterseq(file, mystruct, savewave, savepos, myRegionInfo, seq.length, seq.type_name)
			break
			
		case "PointSeq":
			SpecsXML_readstructsafterseq(file, mystruct, savewave, savepos, myRegionInfo, seq.length, seq.type_name)
			break
			
		case "DoubleSeq":
			if(seq.length==-1)
				FReadLine file, tmps // <double>
				FReadLine file, tmps //</sequence>
				break
			endif			
			strswitch(seq.name)
				case "data":
					savepos = 0
					myRegionInfo.Ycurve_length = seq.length
					Make /O/R/N=(seq.length,savepos) doubleseqwave
					FReadLine file, tmps // <double>
					SpecsXML_counts(file, doubleseqwave, savepos, seq.length)
					FReadLine file, tmps // </double>
					FReadLine file, tmps //</sequence>
					tmps2 = SpecsXML_checkdblwavename(shortname(cleanname(myRegionInfo.RegionName),charlimit), "_"+cleanname(myRegionInfo.YCurve_name))
					duplicate doubleseqwave, $tmps2
					killwaves doubleseqwave
					if(str2num(get_flags("includeADC"))==1 && str2num(get_flags("justdetector"))==0)	
						SpecsXML_savewave($tmps2, myRegionInfo, 2)
					else
						killwaves $tmps2
					endif
					break
				case "scaling_factors":
					redimension /N=(seq.length, -1) $scalinglist
					FReadLine file, tmps // <double>
					SpecsXML_counts(file, $scalinglist, savepos, seq.length)
					FReadLine file, tmps // <double>
					FReadLine file, tmps //</sequence>
					break
				case "transmission":
					savepos = 0
					Make /O/R/N=(seq.length,savepos) doubleseqwave
					FReadLine file, tmps // <double>
					SpecsXML_counts(file, doubleseqwave, savepos, seq.length)
					FReadLine file, tmps // </double>
					FReadLine file, tmps //</sequence>
					tmps2 = SpecsXML_checkdblwavename(shortname(cleanname(myRegionInfo.RegionName),charlimit), "_transm")
					duplicate doubleseqwave, $tmps2
					killwaves doubleseqwave
					if(str2num(get_flags("includetransmission"))==1 && str2num(get_flags("justdetector"))==0)
						SpecsXML_savewave($tmps2, myRegionInfo, 3)
					else
						killwaves $tmps2
					endif
					break
				default:
					Debugprintf2("Unknown DoubleSeq!!!",0)
					duplicate /O doubleseqwave, savewave
					break
			endswitch		
			break

		case "CountsSeq":
			if(seq.length==-1)
				FReadLine file, tmps // </ulong>
				FReadLine file, tmps // </sequence>
				break
			endif
		
			myRegionInfo.numcounts = seq.length
			redimension /N=(seq.length, -1) $countlist
			
			FReadLine file, tmps // <ulong type_id="IDL:specs.de/SurfaceAnalysis/Counts:1.0" type_name="Counts">
			SpecsXML_counts(file, $countlist, savepos, seq.length)
			FReadLine file, tmps // </ulong>
			FReadLine file, tmps // </sequence>
			break
			
		case "ScanSeq":
			if(seq.length==-1)
				seq.length = 1
			else
				Make /O/R/N=(1,seq.length) $countlist
				Make /O/R/N=(1,seq.length) $scalinglist
			endif
			savepos = -1
			SpecsXML_readstructsafterseq(file, mystruct, savewave, savepos, myRegionInfo, seq.length, seq.type_name)
			break
			
		case "ParameterSeq":
			SpecsXML_readstructsafterseq(file, mystruct, savewave, savepos, myRegionInfo, seq.length, seq.type_name)
			break
			
		case "StringSeq":
			if(seq.length==-1)
				seq.length = 1
			endif
			for(i=0;i<seq.length;i+=1)
				SpecsXML_getvariable(file, "string")
			endfor
			FReadLine file, tmps //</sequence>
			break
			
		case "CycleSeq":
			SpecsXML_readstructsafterseq(file, mystruct, savewave, savepos, myRegionInfo, seq.length, seq.type_name)
			break
			
		case "YCurveSeq":
			SpecsXML_readstructsafterseq(file, mystruct, savewave, savepos, myRegionInfo, seq.length, seq.type_name)
			break
			
		case "XYCurveSeq":
			SpecsXML_readstructsafterseq(file, mystruct, savewave, savepos, myRegionInfo, seq.length, seq.type_name)
			break

		case "CompactCycleSeq":
			SpecsXML_readstructsafterseq(file, mystruct, savewave, savepos, myRegionInfo, seq.length, seq.type_name)
			break
		
		
		default:
				Debugprintf2("Unknown sequence: "+seq.type_name,0)
			break
	endswitch
	return 0
end


static function SpecsXML_readstruct(file, givenstruct, savewave, savepos, myRegionInfo)
	variable file
	struct xmlstruct &givenstruct
	wave /Z &savewave
	variable &savepos
	struct RegionInfo &myRegionInfo
	struct xmlsequence myseq
	struct xmlstruct mystruct
	struct xmlenum myenum

	string tmps = ""

	do
		FReadLine file, tmps
		tmps = mycleanupstr(tmps)
		If (strlen(tmps)==0)
			return 0
		elseIf (strsearch(tmps,"</struct>",0) == 0)
			if(strsearch(givenstruct.type_name,"RegionData",0)==0)
				// in this case it is end of region and we need to save the data
				SpecsXML_savedetector(myRegionInfo)
				SpecsXML_resetRegionInfo(myRegionInfo)
			endif
			return 0
		endif

		tmps = SpecsXML_checktype(file, mystruct, myseq, myenum, savewave, savepos, myRegionInfo, tmps)
		if(strlen(tmps) == 0)
			continue
		endif
		
		tmps=SpecsXML_gettypename(tmps)
		strswitch(givenstruct.type_name)
			case "Excitation":
				strswitch(stringfromlist(0,tmps))
					case "energy":
						break
					case "lorentz_width":
						break
					case "gauss_width":
						break
					case "intensity":
						break
					default:
						Debugprintf2("Unknown Excitationstruct element: "+tmps,0)
						break	
				endswitch
				break
			
			case "ScanData":
				strswitch(stringfromlist(0,tmps))
					default:
						Debugprintf2("Unknown Scandatastruct element: "+tmps,0)
						break	
				endswitch
				break
				
			case "XYCurve":
				strswitch(stringfromlist(0,tmps))
					case "name":
						break
					case "curves":
						break
					default:
						Debugprintf2("Unknown XYCurvestruct element: "+tmps,0)
						break	
				endswitch
				break
		
			case "Detector":
				strswitch(stringfromlist(0,tmps))
					case "position":
						myregionInfo.Detector.position[savepos] = str2num(stringfromlist(1,tmps))
						break
					case "shift":
						myregionInfo.Detector.shift[savepos] = str2num(stringfromlist(1,tmps))
						break
					case "gain":
						myregionInfo.Detector.gain[savepos] = str2num(stringfromlist(1,tmps))
						break
					default:
						Debugprintf2("Unknown Detectorstruct element: "+tmps,0)
						break	
				endswitch
				break
			
			case "RegionGroup":
				strswitch(stringfromlist(0,tmps))
					case "name":
						string AktGroupName=stringfromlist(1,tmps)
						myRegionInfo.AktGroupName = AktGroupName
						Debugprintf2("... exporting RegionGroup: "+AktGroupName,0)
						AktGroupName = cleanname(AktGroupName)
						string newAktGroupName = myRegionInfo.folder+AktGroupName
						SetDataFolder $(myRegionInfo.folder)
						if(DataFolderExists(newAktGroupName))
							AktGroupName += get_flags("suffix")
							variable i=0
							do
								i+=1
								newAktGroupName = AktGroupName+num2str(i)
							while(DataFolderExists(newAktGroupName))
							AktGroupName += num2str(i)
						endif
						NewDataFolder/s $(AktGroupName)
						break
					default:
						Debugprintf2("Unknown RegionGroupstruct element: "+tmps,0)
						break				
				endswitch
				break
		
			case "RegionData":
				strswitch(stringfromlist(0,tmps))
					case "name":
						myRegionInfo.RegionName = stringfromlist(1,tmps)
						Debugprintf2("... exporting spectrum: "+myRegionInfo.RegionName,0)
						break			
					case "mcd_head":
						myRegionInfo.mcd_head = str2num(stringfromlist(1,tmps))
						break					
					case "mcd_tail":
						myRegionInfo.mcd_tail = str2num(stringfromlist(1,tmps))
						break				
				endswitch
				break
			
			case "RegionDef":
				strswitch(stringfromlist(0,tmps))
					case "analysis_method":
						myRegionInfo.analysis_method=stringfromlist(1,tmps)
						break
					case "analyzer_lens":
						myRegionInfo.analyzer_lens=stringfromlist(1,tmps)
						break
					case "analyzer_slit":
						myRegionInfo.analyzer_slit=stringfromlist(1,tmps)
						break
					case "num_scans":
						myRegionInfo.num_scans =  str2num(stringfromlist(1,tmps))
						break
					case "curves_per_scan":
						myRegionInfo.curves_per_scan =  str2num(stringfromlist(1,tmps))
						break
					case "values_per_curve":
						myRegionInfo.values_per_curve = str2num(stringfromlist(1,tmps))
						break
					case "dwell_time":
						myRegionInfo.dwell_time = str2num(stringfromlist(1,tmps))
						break
					case "scan_delta":
						myRegionInfo.scan_delta = str2num(stringfromlist(1,tmps))
						break
					case "excitation_energy":
						myRegionInfo.excitation_energy = str2num(stringfromlist(1,tmps))
						break
					case "kinetic_energy":
						myRegionInfo.kinetic_energy = str2num(stringfromlist(1,tmps))
						break
					case "kinetic_energy_base":
						myRegionInfo.kinetic_energy_base = str2num(stringfromlist(1,tmps))
						break
					case "pass_energy":
						myRegionInfo.pass_energy = str2num(stringfromlist(1,tmps))
						break
					case "bias_voltage":
						myRegionInfo.bias_voltage = str2num(stringfromlist(1,tmps))
						break
					case "detector_voltage":
						myRegionInfo.detector_voltage = str2num(stringfromlist(1,tmps))
						break
					case "effective_workfunction":
						myRegionInfo.effective_workfunction = str2num(stringfromlist(1,tmps))
						break
					case "detector_dataset":
						break
					case "detector_dataset_directory":
						break
					default:
						Debugprintf2("Unknown RegionDefstruct element: "+tmps,0)
						break
				endswitch
				break
				
			case "Double_E":
				strswitch(stringfromlist(0,tmps))
					case "value":
						break
					case "error":
						break
					default:
						Debugprintf2("Unknown Double_Estruct element: "+tmps,0)
						break
				endswitch
				
				break
		
			case "ScanMode":
				strswitch(stringfromlist(0,tmps))
					case "name":
						myRegionInfo.ScanMode = stringfromlist(1,tmps)
						break
					case "flags":
						myRegionInfo.ScanMode_flags = str2num(stringfromlist(1,tmps))
						break
					default:
						Debugprintf2("Unknown Scanmodestruct element: "+tmps,0)
						break
				endswitch
				break
				
			case "AnalyzerInfo":
				strswitch(stringfromlist(0,tmps))
					case "name":
						myRegionInfo.Analyzer_Name = stringfromlist(1,tmps)
						break
					default:
						Debugprintf2("Unknown AnalyzerInfostruct element: "+tmps,0)
						//print tmps2
						break
				endswitch
				break
				
			case "Point":
				strswitch(stringfromlist(0,tmps))
					case "name":
						break
					case "x":
						break
					case "y":
						break
					default:
						Debugprintf2("Unknown Pointstruct element: "+tmps,0)
						break
				endswitch
				break
				
			case "YCurve":
				strswitch(stringfromlist(0,tmps))
					case "name":
						myRegionInfo.YCurve_name = stringfromlist(1,tmps)
						break
					case "start":
						myRegionInfo.YCurve_start = str2num(stringfromlist(1,tmps))
						break
					case "delta":
						myRegionInfo.YCurve_delta = str2num(stringfromlist(1,tmps))
						break
					case "curves":
						myRegionInfo.YCurve_curves = str2num(stringfromlist(1,tmps))
						break
					default:
						Debugprintf2("Unknown YCurvestruct element: "+tmps,0)
						break
				endswitch
				break
		
			case "Cycle":
				strswitch(stringfromlist(0,tmps))
					case "time":
						myRegionInfo.times = str2num(stringfromlist(1,tmps))
						break
					default:
						Debugprintf2("Unknown Cyclestruct element: "+tmps,0)
						break
				endswitch	
				break
				
			case "SourceInfo":
				strswitch(stringfromlist(0,tmps))
					case "name":
						myRegionInfo.Source_name  = stringfromlist(1,tmps)
						break
					case "intensity_scaling":
						break
					default:
						Debugprintf2("Unknown SourceInfostruct element: "+tmps,0)
						//print tmps2
						break
				endswitch
				break
				
			case "Annotation":
				strswitch(stringfromlist(0,tmps))
					case "macro":
						break
					default:
						Debugprintf2("Unknown Annotationstruct element: "+tmps,0)
						break
				endswitch
				break
			
			
			case "RemoteInfo":
				strswitch(stringfromlist(0,tmps))
					case "name":
						//myRegionInfo.Source_name  = stringfromlist(1,tmps)
						break
					default:
						Debugprintf2("Unknown RemoteInfostruct element: "+tmps,0)
						break
				endswitch
				break	
			
			case "Parameter":
				SpecsXML_readparamstruct(file, mystruct, savewave, savepos, myRegionInfo, tmps)
				break
			default:
				Debugprintf2("Unknown struct: "+givenstruct.type_name,0)
				break
		endswitch

		Fstatus file
	while (V_logEOF>V_filePOS)  
	return 0
end


static function /S SpecsXML_getbetween(file)
	variable file
	string tmps
	FReadLine file, tmps
	tmps=mycleanupstr(tmps)
	return tmps[strsearch(tmps, ">",0)+1,strsearch(tmps,"<",strsearch(tmps, ">",0)+1)-1]	
end
 
 
static function /S SpecsXML_gettypename(str)
	string str
	string type = ""
	string val = ""
	type = SpecsXML_getID(str,"name")
	if(strsearch(str, "/>",0)!=-1)
		val = ""
	else
		val = str[strsearch(str, ">",0)+1,strsearch(str,"<",strsearch(str, ">",0)+1)-1]
	endif
	return type+";"+val
end


static function /S SpecsXML_getvariable(file, what)
	variable file
	string what
	string tmps, returnstr=""
	FReadLine file, tmps
	tmps=mycleanupstr(tmps)
	if(strsearch(tmps, "<"+what+"/>",0)==0)
		return ""
	endif
	if(strsearch(tmps, "</"+what+">",0)==-1) // multiline comment for strings or value arrays
		Debugprintf2("multiline parameter!!!: "+tmps,0)
		returnstr+=TmpS[ strlen("<"+what+">"),inf]
		do
			FReadLine file, tmps
			if(strsearch(tmps, "</"+what+">",0)>=0)
				returnstr+=";"+tmps[0,strlen(TmpS)-strlen("</"+what+">")-1]
				break
			else
				returnstr+=";"+tmps
			endif
			Fstatus file
		while (V_logEOF>V_filePOS)  
	else
		if(strsearch(tmps, "</"+what+">",0)>0)
			returnstr = TmpS[ strlen("<"+what+">"),strlen(TmpS)-strlen("</"+what+">")-1]
		else
			returnstr= ""
		endif
	endif
	return returnstr
end


static function SpecsXML_counts(file, savewave, savepos, length)
	variable file
	wave &savewave
	variable &savepos
	variable length
	variable i=0, tmpd=0
	string tmps
	for(i=0;i<length;i+=1)
			FReadLine file, tmps
			savewave[i][savepos]= str2num(mycleanupstr(tmps))
	endfor
end


static function SpecsXML_getstruct(str, mystruct, str2)
	string str
	struct xmlstruct &mystruct
	string str2
	mystruct.name 			= SpecsXML_getID(str,"name")
	mystruct.type_id		= SpecsXML_getID(str,"type_id")
	mystruct.type_name 	= SpecsXML_getID(str,"type_name")
	if(strlen(mystruct.type_name)==0)
		Debugprintf2("Line to separate: "+str,0)
		Debugprintf2("Seq/Struct before: "+str2,0)
	endif
	
	return 0
end


static function SpecsXML_getenum(str, myenum)
	string str
	struct xmlenum &myenum
	myenum.name 			= SpecsXML_getID(str,"name")
	myenum.values			= SpecsXML_getID(str,"values")
	myenum.type_id		= SpecsXML_getID(str,"type_id")
	myenum.type_name 	= SpecsXML_getID(str,"type_name")
	myenum.val = str[strsearch(str, ">",0)+1,strsearch(str,"<",strsearch(str, ">",0)+1)-1]	
	return 0
end


static function SpecsXML_getsq(str, seq)
	string str
	struct xmlsequence &seq
	seq.name	= SpecsXML_getID(str,"name")
	seq.length	= str2num(SpecsXML_getID(str,"length"))
	seq.type_id		= SpecsXML_getID(str,"type_id")
	seq.type_name	= SpecsXML_getID(str,"type_name")
	seq.terminate = strsearch(str,"/>",0)
	return 0
end


function SpecsXML_check_file(file)
	variable file
	fsetpos file, 0
	variable i=0
	string tmps = mycleanupstr(myreadline(file))
	if(strsearch(tmps,"<?xml version=\"1.0\"?>",0) != 0)
		fsetpos file, 0
		return -1
	endif
	tmps = mycleanupstr(myreadline(file))
	if(strsearch(tmps,"<!-- CORBA XML document created by XMLSerializer",0) != 0)
		fsetpos file, 0
		return -1
	endif
	tmps = mycleanupstr(myreadline(file))
	if(strsearch(tmps,"<!DOCTYPE any [",0) != 0)
		fsetpos file, 0
		return -1
	endif
	// now check for beginning of data
	for(i=0;i<50;i+=1) // maybe increase the number
		tmps = mycleanupstr(myreadline(file))
		If (strlen(tmps)==0)
			fsetpos file, 0
			return -1
		endif
		If(strsearch(tmps,"<any version=\"1.6\">",0) == 0 || strsearch(tmps,"<any version=\"1.3\">",0) == 0 )
			fsetpos file, 0
			return 1
		endif  
		fstatus file
		if(V_logEOF<=V_filePOS)
			fsetpos file, 0
			return -1
		endif
	endfor	
	fsetpos file, 0
	return -1
end


function SpecsXML_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "SpecsLab2 XML"
	importloader.filestr = "*.xml"
	importloader.category = "PES"
end


function SpecsXML_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	SpecsXML_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file

	string tmps= ""

	do
		FReadLine file, tmps
		tmps = mycleanupstr(tmps)
		If (strlen(tmps)==0)
			return 0
		endif
		If(strsearch(tmps,"<any version=\"1.6\">",0) == 0 || strsearch(tmps,"<any version=\"1.3\">",0) == 0 )
			break
		endif  
		Fstatus file
	while (V_logEOF>V_filePOS)  
	struct xmlsequence seq
	struct RegionInfo myRegionInfo
	SpecsXML_resetRegionInfo(myRegionInfo)
	variable tmpd = -1//, i=0
	myRegionInfo.folder=GetDataFolder(1)
	myRegionInfo.header= header
	do
		FReadLine file, tmps
		tmps = mycleanupstr(tmps)
		If (strlen(tmps)==0)
			return 0
		endif
		SpecsXML_getsq(tmps, seq)
		strswitch(seq.type_name)
			case "RegionGroupSeq":
				SpecsXML_readsq(file, seq, $(""), tmpd, myRegionInfo)
				break
			default:
				if(strsearch(tmps, "</any>",0)==0)
					Debugprintf2("Probably end of file!",0)
					break
				endif
				Debugprintf2("unknown sequence",0)
				//print tmps
				return -1
				break
		endswitch

		Fstatus file
	while (V_logEOF>V_filePOS)  

	importloader.success = 1
	loaderend(importloader)
end