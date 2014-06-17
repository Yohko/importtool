// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

Menu "Macros"
	submenu "Import Tool "+importloaderversion
			submenu "PES"
				"Load SpecsLab2					*.xy		file... v1.3", SpecslabXY_load_data()
			end
	end
end



// ###################### SpecsLab XY ########################

// based on procudure from SPECS:
// copyright 2006-2007 by SPECS GmbH , Berlin, Germany
// Import Filter for xy files produced by SpecsLab2


static Function SpecslabXY_grepDataTitle(str)
		string str

		NVAR cycle=root:constants47110815:cycle, curve=root:constants47110815:curve, scan=root:constants47110815:scan, channel=root:constants47110815:channel
		variable numRead, tmpcycle, tmpcurve, tmpscan, tmpchannel
		string out
		
		Debugprintf2("grepDataTitle: "+str+"\r",1)
		sscanf str, "# Cycle: %d, Curve: %d, Scan: %d, Channel: %d", tmpcycle, tmpcurve, tmpscan, tmpchannel
		numRead = V_flag
		
		switch(numRead)
			case 4:
				channel=tmpchannel
			case 3:
				scan=tmpscan
			case 2:
				curve=tmpcurve
				cycle=tmpcycle
			break // this is for all cases above
			default:
			break
		endswitch

		sprintf out "Cycles=%d, Curves=%d, Scans=%d\r", tmpcycle, tmpcurve, tmpscan
		Debugprintf2("grepDataTitle is " + out + " , and num is "+num2str(numRead)+"\r",1)
		Debugprintf2("V_flag is"+num2str(numRead)+"\r",1)

		return numRead
end

static Function/S SpecslabXY_grepLine(str)
		string str
		
		variable posdp,posspace, length
		SVAR option = root:constants47110815:option
		
		Debugprintf2("line to examine is "+str+"\r",1)
		length=strlen(str)
		posdp = strsearch(str,":",0)
		posspace = strsearch(str," ",0)
		
		if( posspace == -1)
			option=""
			return ""
		endif
		
		if( posdp == -1) // needed to support multiline comments
			option = str[posspace,length-1]
		else	
			option = str[posdp+1,length-1]
		endif
		
		option = SpecslabXY_stripwhitespace(option)
		str = str[posspace+1,posdp]
		Debugprintf2("Type is "+str+"\r",1)
		Debugprintf2("Option is "+option+"\r",1)
		return str
end


static Function/S SpecslabXY_stripwhitespace(str)
		string str
		
		variable i=0,j=0, length=strlen(str)
		Debugprintf2("before is "+str,1)
		for( i=0 ; i< length; i+=1)
			if(cmpstr(str[i]," ") != 0 && cmpstr(str[i],"\t") != 0)
				break
			endif
		endfor
		
		for( j=length-1 ; j != 0; j-=1)
			if(cmpstr(str[j]," ") != 0 && cmpstr(str[i],"\t") != 0)
				break
			endif
		endfor	
		
		
		str=str[i,j]
		Debugprintf2("after is "+str,1)
		return str
		
end


static Function SpecslabXY_isDataLine(str)
		string str
		string sx, sy
		
		variable tmpx, tmpy, valRead, ret=1
	 	NVAR xval=root:constants47110815:xval, yval=root:constants47110815:yval
		
		sscanf str, "%f \t%f", tmpx, tmpy
		valRead = V_flag
		if(valRead != 2)
			sscanf str, "%f\t%f", tmpx, tmpy
			valRead = V_flag
			if(valRead != 2)
				ret =  0
			endif
		endif
		sscanf str, "%s\t%s", sx, sy
		tmpx = str2num(sx)
		tmpy=str2num(sy)
		
		if (valRead == 1)
			Debugprintf2("MALFORMED DATA: "+str ,0)
			return 0
		endif
		
		if (ret == 0)
			return 0
		endif
		
		xval = tmpx
		yval = tmpy
		
		Debugprintf2("Found data line containing: "+num2str(xval) + " " + num2str(yval)+"\r",1)
		return 1
end


static Function/S SpecslabXY_removeTrailingCR(str)
		string str
		
		if(cmpstr(str[strlen(str)-1],"\r") == 0)
			str = str[0,strlen(str)-2]
		endif
		return str
end


function SpecslabXY_check_file(file)
	variable file
	fsetpos file, 0
	string tmps = read_line_trim(file) 
	if(strsearch(tmps,"# Created by:        SpecsLab2, Version 2.",0) != 0)
		fsetpos file, 0
		return -1
	endif
	fsetpos file, 0
	return 1
end


function SpecslabXY_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "SpecsLab2 XY"
	importloader.filestr = "*.xy"
	importloader.category = "PES"
end


Function SpecslabXY_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	SpecslabXY_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file


		string folder = GetDataFolder(1)
		string tmps=""

		variable j, n_wave =1
		variable startx,  stepx, num, scanNum,  datacounter = 0, aquedist, numLinesLoaded=0, cycleheader, cnt=0,line=0, cmtLine
		
		variable numPoints=100 
		variable eps=1e-6 // used in checkEnergyScale(...) to determine if two adjacent energy intervals are equal
		string suffix=".new" // string to append to an already existing folders/waves
		string str, type ="????", group="", spectrum="",  oldgroup="", tmp=""
		string method="", lens="", slit="", analyzer="", mode="", curvesPerScan="", valuesPerCurve="",dwellTime="", excEnergy="", passEnergy="", biasVoltage=""
		string detVoltage="", effWorkfunction="", source="", numberOfScan="", kinEnergy="", remote="", comment="", region="", energy="",headerComment="", remoteInfo=""
		
		NewDataFolder/o/s root:constants47110815

		tmpS = "xw" ; Make /O/D/N=(0) $tmpS ; wave xw = $tmpS
		tmpS = "yw" ; Make /O/D/N=(0) $tmpS ; wave yw = $tmpS

		
		variable/G cycle, scan, curve, channel, xval, yval
		string/G option=""
		
		do
				FReadLine file, str
				line+=1
				if(strlen(str) == 0) // hit EOF
					break
				endif
				
				str = SpecslabXY_stripwhitespace(str)
				str = SpecslabXY_removetrailingCR(str)
				
				if(SpecslabXY_isDataLine(str))
					if(numLinesLoaded == 0) // new block begins
					
						if(cmpstr(group,"") != 0 && cmpstr(oldgroup,group) != 0) // new group
							oldgroup = group
							tmps=folder+group
							NewDataFolder/s $tmps
						endif
						
						if( cmpstr(region,"") == 0 )// take save default name
							datacounter+=1
							spectrum = "data" + num2str(datacounter) 
						else
							spectrum = region
						endif
						
						if( cycle > 0)
							spectrum += "Cy" + num2str(cycle)
						endif

						if( str2num(numberOfScan) > 1 && cycleHeader  >= 3 ) // we have separate data for each scan
							spectrum += "Sc" + num2str(scan)
						endif
						
						if (str2num(curvesPerScan) > 1)
							spectrum += "Cu" + num2str(curve)
						endif
						
						if ( cycleHeader == 4) // separate data for each channel
							spectrum += "Ch" + num2str(channel)
						endif
						
						if(WaveExists($spectrum)) // we want  to never overwrite spectra
							cnt=0
							spectrum += suffix
							do
								tmp = spectrum + num2str(cnt)
								cnt+=1
							while(WaveExists($tmp))
							spectrum = tmp
						endif						
						
						if( strlen(spectrum) >= 27 )
							datacounter +=1
							if( cmpstr(headerComment,"" ) == 0 )
								comment = "original name was " + spectrum	
							else
								comment = headerComment + "\r" + "original name was " + spectrum
							endif
							Debugprintf2("Spectrum name shortend due to Igor Pro limitations",0)
							Debugprintf2("from: "+ spectrum,0)
							spectrum = "data " + num2str(datacounter)
							Debugprintf2("to: "+spectrum,0)
						endif
							energy =  "En_" + spectrum
											
						make /D/N=(numPoints) $energy, $spectrum
						Wave xw = $energy
						Wave yw = $spectrum
						
					elseif (numLinesLoaded >= numPoints)
						numPoints *= 2
						Redimension/N=(numPoints) xw, yw		
					endif
					
					xw[numLinesLoaded]=xval
					yw[numLinesLoaded]=yval
					numLinesLoaded+=1
				else
					if(numLinesLoaded != 0)
						Redimension/N=(numLinesLoaded) xw, yw 
						aquedist = checkEnergyScale(xw, eps)//SpecslabXY_checkEnergyScale(xw,numLinesLoaded,eps)
						numLinesLoaded=0
										
						if(aquedist == 1)
							Debugprintf2(method,1)
							strswitch(mode)
								case "FixedAnalyzerTransmission":
									startx = xw[0]-str2num(excEnergy)
									stepx = xw[1] - xw[0]
									if(str2num(get_flags("posbinde")) == 0)
										SetScale/P  x,startx,stepx,"eV", yw
									else
										SetScale/P  x,-startx,-stepx,"eV", yw
									endif
									KillWaves xw
								break
								case "FixedEnergies":
									startx = 0
									stepx =str2num( dwellTime)//xw[1] - xw[0]
									SetScale/P  x,startx,stepx,"s", yw
									KillWaves xw
								break
								case "ConstantFinalState":
									startx = str2num(excEnergy)
									stepx = xw[1] - xw[0]
									SetScale/P  x,startx,stepx,"eV", yw
									KillWaves xw
								break
								case "ConstantInitialState":
									startx = str2num(excEnergy)
									stepx = xw[1] - xw[0]
									SetScale/P  x,startx,stepx,"eV", yw
									KillWaves xw
								break
								case "DetectorVoltageScan":
									startx = xw[0]
									stepx = xw[1] - xw[0]
									SetScale/P  x,startx,stepx,"V", yw
									KillWaves xw
								break
								case "Snapshot (FAT)":
									startx = xw[0]-str2num(excEnergy)
									stepx = xw[1] - xw[0]
									if(str2num(get_flags("posbinde")) == 0)
										SetScale/P  x,startx,stepx,"eV", yw
									else
										SetScale/P  x,-startx,-stepx,"eV", yw
									endif
									KillWaves xw
								break
								default:
									startx = xw[0]
									stepx = xw[1] - xw[0]
									SetScale/P  x,startx,stepx,"eV", yw
									KillWaves xw
								break
							endswitch
						endif

						strswitch(mode)
							case "FixedAnalyzerTransmission":
								Note yw, "x-axis: bindinge energy"
								Note yw, "y-axis: intensity"
							break
							case "FixedEnergies":
								Note yw, "x-axis: time"
								Note yw, "y-axis: intensity"
							break
							case "ConstantFinalState":
								Note yw, "x-axis: photon energy"
								Note yw, "y-axis: intensity"
							break
							case "ConstantInitialState":
								Note yw, "x-axis: photon energy"
								Note yw, "y-axis: intensity"
							break
							case "DetectorVoltageScan":
								Note yw, "x-axis: detector voltage"
								Note yw, "y-axis: intensity"
							break
							case "Snapshot (FAT)":
								Note yw, "x-axis: bindinge energy"
								Note yw, "y-axis: intensity"
							break
							default:
								Note yw, "x-axis: default"
								Note yw, "y-axis: intensity"
							break
						endswitch

						SetScale d, 0,0,"cps", yw
						Note yw, header
						Note yw, "Cycle:" + num2str(cycle)
						Note yw, "Scans:" + num2str(scan)
						Note yw, "Curve:" + num2str(curve)
						Note yw, "Channel:" + num2str(channel)
						Note yw, "Number of Scans:" + numberOfScan
						Note yw, "Curves/Scan:" + curvesPerScan
						Note yw, "Values/Curve:" + valuesPerCurve
						Note yw,"Method:" + method
						Note yw,"Analyzer:" + analyzer
						Note yw,"Analyzer Lens:" + lens
						Note yw,"Analyzer Slit:" + slit
						Note yw,"Scan Mode:" + mode
						Note yw,"Dwell time:" + dwellTime
						Note yw,"Excitation energy:" + excEnergy
						Note yw,"Kinetic energy:" + kinEnergy
						Note yw,"Pass energy:" + passEnergy
						Note yw,"Bias Voltage:" + biasVoltage
						Note yw,"Detector Voltage:" + detVoltage
						Note yw,"Effective Workfunction:" + effWorkfunction
						Note yw,"Source:" + source
						Note yw,"Remote:" + remote
						Note yw,"RemoteInfo:" + remoteInfo				
						Note yw, "Comment:" + comment
					
						//wavestats/Q  yw
						Debugprintf2("... exporting spectrum: "+spectrum,0)
						n_wave  += 1	
				endif
				
				num = SpecslabXY_grepDataTitle(str)
				if( num >= 2 )
					cycleheader = num
					continue
				endif
				
				str = SpecslabXY_grepLine(str)
				strswitch(str)
					case "Group:":
						group=cleanname(option)
					break
					case "Region:":
						region = cleanname(option)
					break
					case "Anylsis Method:":
						method = option
					break
					case "Analysis Method:":
						method = option
					break
					case "Analyzer:":
						analyzer = option
					break
					case "Analyzer Lens:":
						lens = option
					break
					case "Analyzer Slit:":
						slit = option
					break
					case "Scan Mode:":
						mode = option
					break
					case "Number of Scans:":
						numberOfScan = option
					break
					case "Curves/Scan:":
						curvesPerScan = option
					break
					case "Values/Curve:":
						valuesPerCurve= option
					break
					case "Dwell Time:":
						dwelltime = option
					break
					case "Excitation Energy:":
						excEnergy = option
					break
					case "Kinetic Energy:":
						kinEnergy = option
					break
					case "Pass Energy:":
						passEnergy = option
					break
					case "Bias Voltage:":
						biasVoltage = option
					break
					case "Detector Voltage:":
						detVoltage = option
					break
					case "Eff. Workfunction:":
						effWorkfunction = option
					break
					case "Source:":
						source = option
					break
					case "RemoteInfo:":
						remoteInfo = option
					break
					case "Remote:":
						remote = option
					break
					case "Comment:":
						cmtLine = line
						headerComment = option
					break
					default:
						if( ( cmtLine + 1 ) == line && cmpstr(option,"") != 0 )
							cmtLine +=1
							headerComment  = headerComment + "\r" + option
						else
							cmtLine=-1
						endif
					break
				endswitch
			endif
			Fstatus file
		while(V_logEOF>V_filePOS)
	SpecslabXY_CleanUp()
	importloader.success = 1
	loaderend(importloader)
end

static Function SpecslabXY_CleanUp()
	KillDataFolder root:constants47110815
End 

// ###################### SpecsLab XY END ######################
