// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

static constant timinglist = 0

// some xy exported by SpecsLab2 are interpolated, some are not?
// only FAT is sometimes interpolated, not XAS, FE...

// some waves for saving values
static strconstant countlist				= "countlist"
static strconstant scalinglist				= "scalinglist"
static constant charlimit 				= 14
static strconstant directory = "root:Packages:SpecsLabXML"

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
	wave w_position		// eV
	wave w_shift			// eV
	wave w_gain			// -
	wave w_deadtime		// ns
	wave w_threshold 	// mV
	variable numdetectors
	variable act_det
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
	string appendtodetector
	string remoteinfo_name

	variable linecount
	wave /T filewave
	string filename
endstructure


static function SpecsXML_resetRegionInfo(myRegionInfo)
	struct RegionInfo &myRegionInfo
	NewDatafolder /O root:Packages ; NewDatafolder /O $directory
	string tmps = ""
	tmps = directory+":w_position"; Make /O/D/N=(0) $tmpS; wave myRegionInfo.Detector.w_position = $tmps
	tmps = directory+":w_shift"; Make /O/D/N=(0) $tmpS; wave  myRegionInfo.Detector.w_shift = $tmps
	tmps = directory+":w_gain"; Make /O/D/N=(0) $tmpS; wave  myRegionInfo.Detector.w_gain = $tmps
	tmps = directory+":w_deadtime"; Make /O/D/N=(0) $tmpS; wave  myRegionInfo.Detector.w_deadtime = $tmps
	tmps = directory+":w_threshold"; Make /O/D/N=(0) $tmpS; wave  myRegionInfo.Detector.w_threshold = $tmps
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
	myRegionInfo.remoteinfo_name = ""

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
	
	// save flags in single variables (for speed reasons)	
	variable f_interpolate = str2num(get_flags(f_interpolate))
	variable f_DivDetGain = str2num(get_flags(f_divbygain))
	variable f_CHE = str2num(get_flags(f_includeNDET))
	variable f_DivScans = str2num(get_flags(f_divbyNscans))
	variable f_DivLifeTime = str2num(get_flags(f_divbytime))
	variable f_singlescans = str2num(get_flags(f_includeNscans))
	variable f_DivTF = str2num(get_flags(f_divbyTF))
	variable f_includeTF = str2num(get_flags(f_includeTF))

	// getting max positive detektorshift
	wavestats /M=1 /Q /C=1 myRegionInfo.Detector.w_shift
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
		myRegionInfo.Detector.w_gain = 1
	endif
	// making waves for spectra
 	string detectorname = SpecsXML_checkdblwavename(shortname(cleanname(myRegionInfo.RegionName),charlimit),myRegionInfo.appendtodetector)
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

	variable j=0, k=0, index = 0, tmpr=0, InterpolationsDetektor=0, HauptAnteil=0, tmpstart=0, tmpend=0
	
	for (i=0;i<(myRegionInfo.values_per_curve);i+=1)
		tmpR=0
		for(j=0;j<(myRegionInfo.detector.numdetectors);j+=1)

			strswitch(myRegionInfo.scanmode)
				case f_FAT:
					Index =myregionInfo.mcd_head * myregionInfo.detector.numdetectors + myRegionInfo.detector.numdetectors*(i) + (j) - myRegionInfo.detector.numdetectors*ROUND(myRegionInfo.Detector.w_shift[j]*myRegionInfo.pass_energy/myRegionInfo.scan_delta)
					// in case a new MCD calibration was applied to the spectra it can happen that some detectors are now outside the measurement window (index is out of range)
					// Debugprintf2("Error - Index out of range (0<  x <"+num2str(dimsize(countlist,0))+")"+num2str(index),0)
					// SpecsLab just skips the detectors which are out of range for the corresponding measurement point, but we will rescale the wave later
					if(index<0)
						tmpstart = i+1
						continue
					endif
					if(index>=dimsize(countlist,0))
						tmpend =  i-1
						continue
					endif
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
						Detector[j+(i*myRegionInfo.detector.numdetectors)] += countlist[j+(i*myRegionInfo.detector.numdetectors)][k] * myRegionInfo.Detector.w_gain[j]
				       	if(f_singlescans ==1)
							DetectorCHES[j+(i*myRegionInfo.detector.numdetectors)][k] =  countlist[j+(i*myRegionInfo.detector.numdetectors)][k] * myRegionInfo.Detector.w_gain[j]
						endif
					endfor
					DetectorX[j+(i*myRegionInfo.detector.numdetectors)] = myRegionInfo.kinetic_energy+myRegionInfo.scan_delta*i+myRegionInfo.Detector.w_shift[j]*myRegionInfo.pass_energy
				break 
			endswitch
			
			if(cmpstr(myRegionInfo.scanmode,f_SFAT) != 0)
			
				if(f_interpolate == 1)
					// OMICRON-Methode: Zaehlrate am aktuellen Messpunkt aus den rechts und links davon liegenden Channeltron-Zaehlraten interpolieren
					// Zunaechst mal muss ich ermittel, ob er ab- oder aufgerundet hat, beim bestimmen des Index
					if (abs(mod(myRegionInfo.Detector.w_shift[j]*myRegionInfo.pass_energy/myRegionInfo.scan_delta,1))<0.5)
						// Es wurde abgerundet => ich muss mit einem um eine Schrittweite IM INDEX HOEHER liegenden Datenpunkt interpolieren
						InterpolationsDetektor = -1
						HauptAnteil = 1 - abs(mod(myRegionInfo.Detector.w_shift[j]*myRegionInfo.pass_energy/myRegionInfo.scan_delta,1))
					else
						// Es wurde aufgerundet => ich muss mit einem um eine Schrittweite IM INDEX NIEDRIGER liegenden Datenpunkt interpolieren
						InterpolationsDetektor = 1
						HauptAnteil = abs(mod(myRegionInfo.Detector.w_shift[j]*myRegionInfo.pass_energy/myRegionInfo.scan_delta,1))
					endif
					InterpolationsDetektor = InterpolationsDetektor * SIGN(mod(myRegionInfo.Detector.w_shift[j],1))// Der Detektor-Versatz kann ja positiv oder negativ sein. Bei negativem Versatz muss ich die Richtung umkehren !
					if (InterpolationsDetektor == 0)
						TmpR = TmpR + Countliste_avg[Index]*myRegionInfo.Detector.w_gain[j] // Zaehlraten der Einzelchanneltrons addieren
	 				else
						TmpR = TmpR + HauptAnteil * Countliste_avg[Index]*myRegionInfo.Detector.w_gain[j] // Index zeigt ja immer auf den am naehesten an der Energie liegenden Messpunkt. Von da muss also der Hauptteil (>0,5) kommen
						If((Index + InterpolationsDetektor*myRegionInfo.detector.numdetectors) < 0 || (Index + InterpolationsDetektor*myRegionInfo.detector.numdetectors) > (myRegionInfo.numcounts-1)) //todo ||
							InterpolationsDetektor = 0// Sollte der Datenpunkt ausserhalb der Liste liegen, also nicht mitgemessen worden sein, dass nehme ich einfach den mit Index spezifizierten Punkt zu 100%
						endif
				             	TmpR = TmpR + (1-HauptAnteil) * Countliste_avg[Index+ InterpolationsDetektor*myRegionInfo.detector.numdetectors]*myRegionInfo.Detector.w_gain[j]// Index zeigt ja immer auf den am naehesten an der Energie liegenden Messpunkt. Von da muss also der Hauptteil (>0,5) kommen
 					endif
	  			else
 					// Specs-Methode: nicht interpolieren, sondern die Channeltron-Zaehlrate, die dem aktuellen Messpunkt am naehesten liegt voll dem Messpunkt zuordnen
					TmpR = TmpR + Countliste_avg[Index]*myRegionInfo.Detector.w_gain[j] //Zaehlraten der Einzelchanneltrons addieren
				endif

			       if(f_CHE == 1)
				       // detector shift berücksichtigen ....
					DetectorCHE[i][j]=Countliste_avg[Index] * myRegionInfo.Detector.w_gain[j]
					if(cmpstr(myRegionInfo.scanmode,f_FAT)==0) //time scale
						DetectorCHEY[j]=myRegionInfo.dwell_time*(myRegionInfo.mcd_head+j)
					else // kinetic energy scale
						DetectorCHEY[j]=myRegionInfo.kinetic_energy+myRegionInfo.Detector.w_shift[j]*myRegionInfo.pass_energy
					endif
			       endif
			       
		       	if(f_singlescans ==1)
		       		for(k=0;k<myRegionInfo.num_scans;k+=1)
						DetectorCHES[i][j+(k*myRegionInfo.detector.numdetectors)]=countlist[Index][k]*myRegionInfo.Detector.w_gain[j]
						if(cmpstr(myRegionInfo.scanmode,f_FAT)==0) // time scale
							DetectorCHESY[j+(k*myRegionInfo.detector.numdetectors)]=myRegionInfo.dwell_time*(myRegionInfo.mcd_head+j+k*(dimsize(Countliste_avg,0)/myRegionInfo.detector.numdetectors))
						else // kinetic energy scale
							DetectorCHESY[j+(k*myRegionInfo.detector.numdetectors)]=myRegionInfo.kinetic_energy+myRegionInfo.Detector.w_shift[j]*myRegionInfo.pass_energy
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
		if(str2num(get_flags(f_vsEkin))==0 && cmpstr(myRegionInfo.scanmode,f_SFAT)!=0 && cmpstr(myRegionInfo.scanmode,f_FAT)!=0 &&cmpstr(myRegionInfo.scanmode,f_CFS) != 0)
			if(str2num(get_flags(f_posEbin)) == 0)
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
		if(str2num(get_flags(f_vsEkin))==0 && cmpstr(myRegionInfo.scanmode,f_SFAT)!=0 && cmpstr(myRegionInfo.scanmode,f_FAT)!=0 && cmpstr(myRegionInfo.scanmode,f_CFS) != 0)
			if(str2num(get_flags(f_posEbin)) == 0)
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
		wave DetectorTF = $(detectorname[0,strlen(detectorname)-strlen(myRegionInfo.appendtodetector)-1]+"_transm")
		duplicate /O Detector, DetectordivTF
		DetectordivTF[] /= DetectorTF[p]
 	endif
	
	
	// check if a new calibration was applied and we need to rescale the wave (only the detector for now!!!)
	if(tmpend !=0 || tmpstart !=0)
		// this should only affect FAT
		Debugprintf2("Some detectors were out of range, rescaling wave!",0)
		Duplicate/FREE Detector, Detectortmp
		redimension /N=(tmpend-tmpstart+1) Detector
		SetScale/P  x,DimOffset(Detector, 0)+tmpstart*DimDelta(Detector, 0),DimDelta(Detector, 0),"eV",  Detector
		Detector[] = Detectortmp[tmpstart+p]
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
	Note  savewave,"RemoteInfo name: " + myRegionInfo.remoteinfo_name
	Note  savewave, "Comment: " + myRegionInfo.comment

	variable Unixtime  = myRegionInfo.times+2082844800
	Debugprintf2("Time Of Recording: "+Secs2Date(Unixtime,-2)+" ; "+ Secs2Time(Unixtime,3) + "(UTC) (GMT=UTC+2)",1)
	Note  savewave, "Time Of Recording (UTC): "+Secs2Date(Unixtime,-2)+" ; "+ Secs2Time(Unixtime,3)
	Note  savewave, "Time Of Recording (GMT): "+Secs2Date(Unixtime+60*2*60,-2)+" ; "+ Secs2Time(Unixtime+60*2*60,3)

	if(timinglist)
		string nb = "SpecsLab2XMLResults"
		string nbtext = ""
		sprintf nbtext, "%s\t%s %s\t%s %s\t%d\r", myRegionInfo.RegionName, Secs2Date(Unixtime,-2), Secs2Time(Unixtime,3), Secs2Date(Unixtime+60*2*60,-2), Secs2Time(Unixtime+60*2*60,3), Unixtime
		if (WinType(nb) == 0)
			NewNotebook /N=$nb /F=0
		endif
		// Insert text in notebook
		Notebook $nb, text = nbtext
	endif
	
	if(mode==1)	
		SetScale d, 0,0,"cps", savewave
		strswitch(myRegionInfo.scanmode)
			case f_FAT:
				if(str2num(get_flags(f_vsEkin))==0)
					if(str2num(get_flags(f_posEbin)) == 0)
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
				if(str2num(get_flags(f_vsEkin))==0)
					if(str2num(get_flags(f_posEbin)) == 0)
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
					if(str2num(get_flags(f_vsEkin))==0)
						if(str2num(get_flags(f_posEbin)) == 0)
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
					if(str2num(get_flags(f_vsEkin))==0)
						if(str2num(get_flags(f_posEbin)) == 0)
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


static function SpecsXML_readstructsafterseq(givenstruct, savewave, savepos, myRegionInfo, length, name)
	struct xmlstruct &givenstruct
	//wave /Z &savewave // IgorPro 8 has an issue with this
	wave /Z savewave
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
		tmps = myRegionInfo.filewave[myRegionInfo.linecount]; myRegionInfo.linecount +=1
		SpecsXML_getstruct(tmps, givenstruct, name)
		strswitch(givenstruct.type_name)
			case "Detector":
				myRegionInfo.Detector.act_det = i
				break
		endswitch
		if(SpecsXML_readstruct(givenstruct, savewave, j, myRegionInfo) == -1)
			return -1
		endif
	endfor
	myRegionInfo.linecount +=1 //</sequence>
	return 0
end


static function /S SpecsXML_checktype(givenstruct, givenseq, givenenum, savewave, savepos, myRegionInfo, str)
	struct xmlstruct &givenstruct
	struct xmlsequence &givenseq
	struct xmlenum &givenenum
	//wave /Z &savewave // IgorPro 8 has an issue with this
	wave /Z savewave
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
			if(SpecsXML_readsq(givenseq, savewave, savepos, myRegionInfo) == -1)
				return "-1"
			endif
			return ""
		elseIf (strsearch(str,"<struct",0) == 0)
			SpecsXML_getstruct(str, givenstruct, "structstruct")
			if(SpecsXML_readstruct(givenstruct, savewave, savepos, myRegionInfo) == -1)
				return "-1"
			endif
			return ""
		elseIf (strsearch(str,"<enum",0) == 0)
			SpecsXML_getenum(str, givenenum)
			return ""
		elseIf (strsearch(str,"/>",0) !=  -1)
			return ""
		endif
		return str
end




static function SpecsXML_readparamstruct(givenstruct, savewave, savepos, myRegionInfo, str)
	struct xmlstruct &givenstruct
	//wave /Z &savewave // IgorPro 8 has an issue with this
	wave /Z savewave
	variable &savepos
	struct RegionInfo &myRegionInfo
	string str
	string tmps
	
	struct xmlsequence myseq
	struct xmlenum myenum

	
	
	tmps = myRegionInfo.filewave[myRegionInfo.linecount]; myRegionInfo.linecount +=1 // <any name="value">
	if(strsearch(tmps,"/>",0) !=  -1)
		return 0	
	endif

	do 
		tmps = mycleanupstr(myRegionInfo.filewave[myRegionInfo.linecount]); myRegionInfo.linecount +=1
		If (strlen(tmps)==0)
			return -1
		elseIf (strsearch(tmps,"</any>",0) == 0)
			return 0
		endif
		tmps = SpecsXML_checktype(givenstruct, myseq, myenum, savewave, savepos, myRegionInfo, tmps)
		if(strlen(tmps) != 0)
			if(cmpstr(tmps, "-1")==0)
				return -1
			endif
			strswitch(stringfromlist(1,str))
				case "Current [nA]":
					//SpecsXML_getvariable("double", tmps, myRegionInfo)
					break
				case "Energy [eV]":
					//SpecsXML_getvariable("double", tmps, myRegionInfo)
					break
				case "Anode":
////					SpecsXML_getbetween(file)
					break
				case "Power [W]":
					//SpecsXML_getvariable("double", tmps, myRegionInfo)
					break
				case "Voltage [kV]":
					//SpecsXML_getvariable("double", tmps, myRegionInfo)
					break
				case "Angle [deg]":
					//SpecsXML_getvariable("double", tmps, myRegionInfo)
					break
				case "Wavelength set timeout [ms]":
					//SpecsXML_getvariable("long", tmps, myRegionInfo)
					break
				case "Wavelength set delay [ms]":
					//SpecsXML_getvariable("double", tmps, myRegionInfo)
					break
				case "Energy correction slope":
					//SpecsXML_getvariable("double", tmps, myRegionInfo)
					break
				case "Energy correction intercept":
					//SpecsXML_getvariable("double", tmps, myRegionInfo)
					break
				case "Use intensity scaling":
					//SpecsXML_getvariable("boolean", tmps, myRegionInfo)
					break
				case "ADC channel number":
					//SpecsXML_getvariable("ulong", tmps, myRegionInfo)
					break
				case "ADC input scaling":
					//SpecsXML_getvariable("double", tmps, myRegionInfo)
					break
				case "Scaling":
					//SpecsXML_getvariable("double", tmps, myRegionInfo)
					break
				case "Use wait on threshold":
					//SpecsXML_getvariable("boolean", tmps, myRegionInfo)
					break
				case "Threshold value":
					//SpecsXML_getvariable("double", tmps, myRegionInfo)
					break
				case "ADC threshold channel number":
					//SpecsXML_getvariable("ulong", tmps, myRegionInfo)
					break
				case "ADC threshold input scaling":
					//SpecsXML_getvariable("double", tmps, myRegionInfo)
					break
				case "Threshold timeout [ms]":
					//SpecsXML_getvariable("long", tmps, myRegionInfo)
					break
				case "Offset":
					//SpecsXML_getvariable("double", tmps, myRegionInfo)
					break
				case "Style":
					//SpecsXML_getvariable("string", tmps, myRegionInfo)
					break
				case "Color":
					//SpecsXML_getvariable("ulong", tmps, myRegionInfo)
					break
				case "Interpolation":
					//SpecsXML_getvariable("boolean", tmps, myRegionInfo)
					break
				case "File":
					//SpecsXML_getvariable("string", tmps, myRegionInfo)
					break
				case "Group":
					//SpecsXML_getvariable("string", tmps, myRegionInfo)
					break
				case "First of group":
					//SpecsXML_getvariable("boolean", tmps, myRegionInfo)
					break
				case "Comment":
					myRegionInfo.comment = SpecsXML_getvariable("string", tmps, myRegionInfo)
					break
				case "Logfile":
					//SpecsXML_getvariable("string", tmps, myRegionInfo)
					break
				case "ADC channel 1 active":
					//SpecsXML_getvariable("boolean", tmps, myRegionInfo)
					break			
				case "    channel 1 name":
					//SpecsXML_getvariable("string", tmps, myRegionInfo)
					break
				case "    channel 1 input scaling":
					//SpecsXML_getvariable("double", tmps, myRegionInfo)
					break
				case "ADC channel 2 active":
					//SpecsXML_getvariable("boolean", tmps, myRegionInfo)
					break			
				case "    channel 2 name":
					//SpecsXML_getvariable("string", tmps, myRegionInfo)
					break
				case "    channel 2 input scaling":
					//SpecsXML_getvariable("double", tmps, myRegionInfo)
					break
				case "ADC channel 3 active":
					//SpecsXML_getvariable("boolean", tmps, myRegionInfo)
					break			
				case "    channel 3 name":
					//SpecsXML_getvariable("string", tmps, myRegionInfo)
					break
				case "    channel 3 input scaling":
					//SpecsXML_getvariable("double", tmps, myRegionInfo)
					break
				case "ADC channel 4 active":
					//SpecsXML_getvariable("boolean", tmps, myRegionInfo)
					break			
				case "    channel 4 name":
					//SpecsXML_getvariable("string", tmps, myRegionInfo)
					break
				case "    channel 4 input scaling":
					//SpecsXML_getvariable("double", tmps, myRegionInfo)
					break
				case "ADC channel 5 active":
					//SpecsXML_getvariable("boolean", tmps, myRegionInfo)
					break			
				case "    channel 5 name":
					//SpecsXML_getvariable("string", tmps, myRegionInfo)
					break
				case "    channel 5 input scaling":
					//SpecsXML_getvariable("double", tmps, myRegionInfo)
					break
				case "ADC channel 6 active":
					//SpecsXML_getvariable("boolean", tmps, myRegionInfo)
					break			
				case "    channel 6 name":
					//SpecsXML_getvariable("string", tmps, myRegionInfo)
					break
				case "    channel 6 input scaling":
					//SpecsXML_getvariable("double", tmps, myRegionInfo)
					break
				case "ADC channel 7 active":
					//SpecsXML_getvariable("boolean", tmps, myRegionInfo)
					break			
				case "    channel 7 name":
					//SpecsXML_getvariable("string", tmps, myRegionInfo)
					break
				case "    channel 7 input scaling":
					//SpecsXML_getvariable("double", tmps, myRegionInfo)
					break
				case "ADC channel 8 active":
					//SpecsXML_getvariable("boolean", tmps, myRegionInfo)
					break			
				case "    channel 8 name":
					//SpecsXML_getvariable("string", tmps, myRegionInfo)
					break
				case "    channel 8 input scaling":
					//SpecsXML_getvariable("double", tmps, myRegionInfo)
					break
				case "End of acquisition":
//					SpecsXML_getbetween(file)
					break
//				case "Background Method": // enum
//					break
				case "Excitation range (min max step)":
					//SpecsXML_getvariable("string", tmps, myRegionInfo)
					break
//				case "FWHM": // --> Double-E struct
//					break
//				case "Counts": // --> Double-E struct
//					break
//				case "Count-BG": // --> Double-E struct
//					break
//				case "Rate": // --> Double-E struct
//					break
//				case "Rate-BG": // --> Double-E struct
//					break
//				case "Area": // --> Double-E struct
//					break
//				case "PktLeft": // --> Point struct
//					break
//				case "PktRight": // --> Point struct
//					break
//				case "Asymmetry": // --> Double-E struct
//					break
//				case "FWHM-Annotation": // --> Point struct
//					break
//				case "Source": // enum
//					break
				case "Threshold [mV]":
					myregionInfo.Detector.w_threshold[myRegionInfo.Detector.act_det] = str2num(SpecsXML_getvariable("double", tmps, myRegionInfo))
					break
				case "Deadtime [ns]":
					myregionInfo.Detector.w_deadtime[myRegionInfo.Detector.act_det] = str2num(SpecsXML_getvariable("double", tmps, myRegionInfo))
					break
				default:
					Debugprintf2("Unknown paramerer!: "+stringfromlist(1,str),0)
					break
			endswitch
		endif
	while(myRegionInfo.linecount<dimsize(myRegionInfo.filewave,0))

	return 0
end



static function SpecsXML_readsq(seq, savewave, savepos, myRegionInfo)
	struct xmlsequence &seq
	//wave /Z &savewave // IgorPro 8 has an issue with this
	wave /Z savewave
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
			if(SpecsXML_readstructsafterseq(mystruct, savewave, savepos, myRegionInfo, seq.length, seq.type_name) == -1)
				return -1
			endif
			break
			
		case "RegionDataSeq":
			if(SpecsXML_readstructsafterseq(mystruct, savewave, savepos, myRegionInfo, seq.length, seq.type_name) == -1)
				return -1
			endif
			break
			
		case "ExcitationSeq":
			if(SpecsXML_readstructsafterseq(mystruct, savewave, savepos, myRegionInfo, seq.length, seq.type_name) == -1)
				return -1
			endif
			break
	
		case "DetectorSeq":
			myRegionInfo.Detector.numdetectors = seq.length
			redimension /N=(myRegionInfo.Detector.numdetectors) myRegionInfo.Detector.w_position; myRegionInfo.Detector.w_position = 0
			redimension /N=(myRegionInfo.Detector.numdetectors) myRegionInfo.Detector.w_shift; myRegionInfo.Detector.w_shift = 0
			redimension /N=(myRegionInfo.Detector.numdetectors) myRegionInfo.Detector.w_gain; myRegionInfo.Detector.w_gain = 0
			redimension /N=(myRegionInfo.Detector.numdetectors) myRegionInfo.Detector.w_deadtime; myRegionInfo.Detector.w_deadtime = 0
			redimension /N=(myRegionInfo.Detector.numdetectors) myRegionInfo.Detector.w_threshold; myRegionInfo.Detector.w_threshold = 0
			if(SpecsXML_readstructsafterseq(mystruct, savewave, savepos, myRegionInfo, seq.length, seq.type_name) == -1)
				return -1
			endif
			break
			
		case "PointSeq":
			if(SpecsXML_readstructsafterseq(mystruct, savewave, savepos, myRegionInfo, seq.length, seq.type_name) == -1)
				return -1
			endif
			break
			
		case "DoubleSeq":
			if(seq.length==-1)
				myRegionInfo.linecount +=2 // <double> //</sequence>
				break
			endif			
			strswitch(seq.name)
				case "data":
					savepos = 0
					myRegionInfo.Ycurve_length = seq.length
					Make /O/R/N=(seq.length,savepos) doubleseqwave
					myRegionInfo.linecount +=1 // <double>
					SpecsXML_counts(doubleseqwave, savepos, seq.length, myRegionInfo)
					myRegionInfo.linecount +=2 // <double> //</sequence>
					tmps2 = SpecsXML_checkdblwavename(shortname(cleanname(myRegionInfo.RegionName),charlimit), "_"+cleanname(myRegionInfo.YCurve_name))
					duplicate doubleseqwave, $tmps2
					killwaves doubleseqwave
					if(str2num(get_flags(f_includeADC))==1 && str2num(get_flags(f_onlyDET))==0)	
						SpecsXML_savewave($tmps2, myRegionInfo, 2)
					else
						killwaves $tmps2
					endif
					break
				case "scaling_factors":
					redimension /N=(seq.length, -1) $scalinglist
					myRegionInfo.linecount +=1 // <double>
					SpecsXML_counts($scalinglist, savepos, seq.length, myRegionInfo)
					myRegionInfo.linecount +=2 // <double> //</sequence>
					break
				case "transmission":
					savepos = 0
					Make /O/R/N=(seq.length,savepos) doubleseqwave
					myRegionInfo.linecount +=1 // <double>
					SpecsXML_counts(doubleseqwave, savepos, seq.length, myRegionInfo)
					myRegionInfo.linecount +=2 // <double> //</sequence>
					tmps2 = SpecsXML_checkdblwavename(shortname(cleanname(myRegionInfo.RegionName),charlimit), "_transm")
					duplicate doubleseqwave, $tmps2
					killwaves doubleseqwave
					if(str2num(get_flags(f_includeTF))==1 && str2num(get_flags(f_onlyDET))==0)
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
				myRegionInfo.linecount +=2 // </ulong> // </sequence>
				break
			endif
		
			myRegionInfo.numcounts = seq.length
			redimension /N=(seq.length, -1) $countlist
			
			myRegionInfo.linecount +=1 // <ulong type_id="IDL:specs.de/SurfaceAnalysis/Counts:1.0" type_name="Counts">
			SpecsXML_counts($countlist, savepos, seq.length, myRegionInfo)
			myRegionInfo.linecount +=2 // </ulong> // </sequence>
			break
			
		case "ScanSeq":
			if(seq.length==-1)
				seq.length = 1
			else
				Make /O/R/N=(1,seq.length) $countlist
				Make /O/R/N=(1,seq.length) $scalinglist
			endif
			savepos = -1
			if(SpecsXML_readstructsafterseq(mystruct, savewave, savepos, myRegionInfo, seq.length, seq.type_name)==-1)
				return -1
			endif
			break
			
		case "ParameterSeq":
			if(SpecsXML_readstructsafterseq(mystruct, savewave, savepos, myRegionInfo, seq.length, seq.type_name) == -1)
				return -1
			endif
			break
			
		case "StringSeq":
			if(seq.length==-1)
				seq.length = 1
			endif
			for(i=0;i<seq.length;i+=1)
				tmps2 = myRegionInfo.filewave[myRegionInfo.linecount]; myRegionInfo.linecount +=1
				SpecsXML_getvariable("string", tmps2, myRegionInfo)
			endfor
			myRegionInfo.linecount +=1 //</sequence>
			break
			
		case "CycleSeq":
			if(SpecsXML_readstructsafterseq(mystruct, savewave, savepos, myRegionInfo, seq.length, seq.type_name) == -1)
				return -1
			endif
			break
			
		case "YCurveSeq":
			if(SpecsXML_readstructsafterseq(mystruct, savewave, savepos, myRegionInfo, seq.length, seq.type_name) == -1)
				return -1
			endif
			break
			
		case "XYCurveSeq":
			if(SpecsXML_readstructsafterseq(mystruct, savewave, savepos, myRegionInfo, seq.length, seq.type_name) == -1)
				return -1
			endif
			break

		case "CompactCycleSeq":
			if(SpecsXML_readstructsafterseq(mystruct, savewave, savepos, myRegionInfo, seq.length, seq.type_name) == -1)
				return -1
			endif
			break
		
		default:
			Debugprintf2("Unknown sequence: "+seq.type_name,0)
			return -1	
			break
	endswitch
	return 0
end


static function SpecsXML_readstruct(givenstruct, savewave, savepos, myRegionInfo)
	struct xmlstruct &givenstruct
	//wave /Z &savewave // IgorPro 8 has an issue with this
	wave /Z savewave // IgorPro 8 has an issue with this
	variable &savepos
	struct RegionInfo &myRegionInfo
	struct xmlsequence myseq
	struct xmlstruct mystruct
	struct xmlenum myenum

	string tmps = ""

	do
		tmps = mycleanupstr(myRegionInfo.filewave[myRegionInfo.linecount]); myRegionInfo.linecount +=1
		If (strlen(tmps)==0)
			return 0
		elseIf (strsearch(tmps,"</struct>",0) == 0)
			if(strsearch(givenstruct.type_name,"RegionData",0)==0)
				// in this case it is end of region and we need to save the data
				if(SpecsXML_savedetector(myRegionInfo) == -1)
					return -1
				endif
				SpecsXML_resetRegionInfo(myRegionInfo)
			endif
			return 0
		endif

		tmps = SpecsXML_checktype(mystruct, myseq, myenum, savewave, savepos, myRegionInfo, tmps)
		if(strlen(tmps) == 0)
			continue
		endif
		if(cmpstr(tmps, "-1")==0)
			return -1
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
						myRegionInfo.Detector.w_position[myRegionInfo.Detector.act_det] = str2num(stringfromlist(1,tmps))
						break
					case "shift":
						myRegionInfo.Detector.w_shift[myRegionInfo.Detector.act_det] = str2num(stringfromlist(1,tmps))
						break
					case "gain":
						myRegionInfo.Detector.w_gain[myRegionInfo.Detector.act_det] = str2num(stringfromlist(1,tmps))
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
							AktGroupName += get_flags(f_suffix)
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
						//str2num(stringfromlist(1,tmps))
						break
					case "error":
						//str2num(stringfromlist(1,tmps))
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
						myRegionInfo.remoteinfo_name  = stringfromlist(1,tmps)
						break
					default:
						Debugprintf2("Unknown RemoteInfostruct element: "+tmps,0)
						break
				endswitch
				break	
			
			case "Parameter":
				SpecsXML_readparamstruct(mystruct, savewave, savepos, myRegionInfo, tmps)
				break
			default:
				Debugprintf2("Unknown struct: "+givenstruct.type_name,0)
				break
		endswitch

	while(myRegionInfo.linecount<dimsize(myRegionInfo.filewave,0))
	return 0
end


static function /S SpecsXML_getbetween(myRegionInfo)
	struct RegionInfo &myRegionInfo
	string tmps = myRegionInfo.filewave[myRegionInfo.linecount]; myRegionInfo.linecount +=1
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


static function /S SpecsXML_getvariable(what, str, myRegionInfo)
	string what
	string str
	struct RegionInfo &myRegionInfo
	string returnstr=""
	if(strsearch(str, "<"+what+"/>",0)==0)
		return ""
	endif
	if(strsearch(str, "</"+what+">",0)==-1) // multiline comment for strings or value arrays
		Debugprintf2("multiline parameter!!!: "+str,1)
		returnstr+=str[ strlen("<"+what+">"),inf]
		do
			str = myRegionInfo.filewave[myRegionInfo.linecount]; myRegionInfo.linecount +=1
			if(strsearch(str, "</"+what+">",0)>=0)
				returnstr+=";"+str[0,strlen(str)-strlen("</"+what+">")-1]
				break
			else
				returnstr+=";"+str
			endif
		while(myRegionInfo.linecount<dimsize(myRegionInfo.filewave,0))
	else
		if(strsearch(str, "</"+what+">",0)>0)
			returnstr = str[ strlen("<"+what+">"),strlen(str)-strlen("</"+what+">")-1]
		else
			returnstr= ""
		endif
	endif
	return returnstr
end


static function SpecsXML_counts(savewave, savepos, length, myRegionInfo)
	//wave &savewave // IgorPro 8 has an issue with this
	wave savewave
	variable &savepos
	variable length
	struct RegionInfo &myRegionInfo
	savewave[][savepos]= str2num(myRegionInfo.filewave[myRegionInfo.linecount+p])
	myRegionInfo.linecount += length
	return 0
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
	string tmps = ""
	FReadLine file, tmps
	if(strsearch(tmps,"<?xml version=\"1.0\"?>",0) != 0)
		fsetpos file, 0
		return -1
	endif
	FReadLine file, tmps
	if(strsearch(tmps,"<!-- CORBA XML document created by XMLSerializer",0) != 0)
		fsetpos file, 0
		return -1
	endif
	FReadLine file, tmps
	if(strsearch(tmps,"<!DOCTYPE any [",0) != 0)
		fsetpos file, 0
		return -1
	endif
	// now check for beginning of data
	for(i=0;i<50;i+=1) // maybe increase the number
		FReadLine file, tmps
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
	string appendtodetector = "_detector"
	if(str2num(get_flags(f_askforEXT)))
		tmps = appendtodetector
		prompt tmps, "What string to append to detector spectra?"
		doprompt "Import flags!", tmps
		if(V_flag==1)
			Debugprintf2("Cancel import!",0)
			loaderend(importloader)
			return -1
		endif
		appendtodetector = tmps
	endif

	variable n= StartMSTimer
	
	struct xmlsequence seq
	struct RegionInfo myRegionInfo
	SpecsXML_resetRegionInfo(myRegionInfo)
	variable tmpd = -1
	myRegionInfo.folder=GetDataFolder(1)
	myRegionInfo.header= header
	myRegionInfo.appendtodetector = appendtodetector
	myRegionInfo.linecount = 0
	fstatus file
	myRegionInfo.filename = S_fileName
	
	// load complete file into a text wave for faster processing
	LoadWave/Q/J/V={"", "", 0, 0}/K=2/A=$("file") (S_path+S_fileName)
	if(V_flag !=1)
		loaderend(importloader)
		return -1
	endif
	wave /T myRegionInfo.filewave = $(StringFromList(0, S_waveNames))
	string wavetokill = GetDataFolder(1)+StringFromList(0, S_waveNames)

	if(timinglist)
		string nb = "SpecsLab2XMLResults"
		string nbtext =myRegionInfo.filename+"\r"
		nbtext +="Region Name\tUTC\tGMT\tUnixtime\r"
		if (WinType(nb) == 0)
			NewNotebook /N=$nb /F=0
		endif
		// Insert text in notebook
		Notebook $nb, text = nbtext
	endif

	do
		tmps = mycleanupstr(myRegionInfo.filewave[myRegionInfo.linecount]); myRegionInfo.linecount +=1
		If (strlen(tmps)==0)
			loaderend(importloader)
			return -1
		endif
		If(strsearch(tmps,"<any version=\"1.6\">",0) == 0 || strsearch(tmps,"<any version=\"1.3\">",0) == 0 )
			break
		endif  
	while(myRegionInfo.linecount<dimsize(myRegionInfo.filewave,0))

	do
		tmps = mycleanupstr(myRegionInfo.filewave[myRegionInfo.linecount]); myRegionInfo.linecount +=1
		If (strlen(tmps)==0)
			loaderend(importloader)
			return -1
		endif
		SpecsXML_getsq(tmps, seq)
		strswitch(seq.type_name)
			case "RegionGroupSeq":
				if(SpecsXML_readsq(seq, $(""), tmpd, myRegionInfo) == -1)
					loaderend(importloader)
					return -1
				endif
				break
			default:
				if(strsearch(tmps, "</any>",0)==0)
					Debugprintf2("Probably end of file!",0)
					break
				endif
				Debugprintf2("unknown sequence",0)
				loaderend(importloader)
				return -1
				break
		endswitch
	while(myRegionInfo.linecount<dimsize(myRegionInfo.filewave,0))
	killwaves $wavetokill
	print "Load time: ",StopMSTimer(n)/1E6
	importloader.success = 1
	loaderend(importloader)
end
