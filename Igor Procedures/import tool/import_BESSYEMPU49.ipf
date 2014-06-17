// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=1		// Use modern global access method.

// EMP data file as for the U49/2-PGM2 at BESSYII

Menu "Macros"
	submenu "Import Tool "+importloaderversion
		submenu "PES"
			"Load Bessy EMP U49				*.dat	file... beta", BessyEMPU49_load_data()
		end
	end
end


static structure keyval
	string key
	string val
endstructure


static structure empheader
	string Comment
	string Probe
	string CfgTyp
	string Fileform
	string myDate
	string Program
	string Version
	string MeasTyp
	variable Analys
	variable Scans
	variable Points
	variable MonSta
	variable MonEnd
	variable AnaSta
	variable AnaEnd
	variable AnaRange
	variable AnaMin
	variable DacSta
	variable DacEnd
	variable DeltaE
	string MonName
	variable MonType
	string MonUnit
	variable MonSpeed
	variable MonRewind
	variable MonSweep
	variable IdPos
	variable IdMode
	variable LiveTime
	variable DeadTime
	variable MeasTime
	variable ScanTime
	string ScanCtrl
	variable DelayVal
	string SecMeas
	string XMonFile
	string XAnaFile
	string P_TakeUp
	string ChanOrder
	string Devices
	string myDisplay
	string Arithm
	variable spectra
endstructure


static function /S BessyEMPU49_getparams(str, keyval)
	string str
	struct keyval &keyval
	keyval.key = ""
	keyval.val = ""
	if(strsearch(str,":",0)!=-1)
		keyval.key = 	stripstrfirstlastspaces(str[0,strsearch(str,":",0)-1])
		keyval.val = stripstrfirstlastspaces(str[strsearch(str,":",0)+1, inf])
	elseif(strlen(str)!=0)
		keyval.key = str
	endif
end


function BessyEMPU49_check_file(file)
	variable file
	fsetpos file, 0
	string tmps = stripstrfirstlastspaces(mycleanupstr(myreadline(file)))
	if(strsearch(tmps, "Comment",0)!=0)
		fsetpos file, 0
		return -1
	endif
	tmps = stripstrfirstlastspaces(mycleanupstr(myreadline(file)))
	if(strsearch(tmps, "Probe",0)!=0)
		fsetpos file, 0
		return -1
	endif
	tmps = stripstrfirstlastspaces(mycleanupstr(myreadline(file)))
	if(strsearch(tmps, "FileName",0)!=0 && strsearch(tmps, "CfgTyp",0)!=0)
		fsetpos file, 0
		return -1
	endif
	tmps = stripstrfirstlastspaces(mycleanupstr(myreadline(file)))
	if(strsearch(tmps, "Fileform",0)!=0)
		fsetpos file, 0
		return -1
	endif
	tmps = stripstrfirstlastspaces(mycleanupstr(myreadline(file)))
	if(strsearch(tmps, "Date",0)!=0)
		fsetpos file, 0
		return -1
	endif
	tmps = stripstrfirstlastspaces(mycleanupstr(myreadline(file)))
	if(strsearch(tmps, "Program",0)!=0 && strsearch(tmps, "EMP",0) ==-1)
		fsetpos file, 0
		return -1
	endif
	tmps = stripstrfirstlastspaces(mycleanupstr(myreadline(file)))
	if(strsearch(tmps, "Version",0)!=0)
		fsetpos file, 0
		return -1
	endif
	fsetpos file, 0	
	return 1
end


function BessyEMPU49_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "BESSYII EMP"
	importloader.filestr = "*.dat"
	importloader.category = "PES;XAS"
end


function BessyEMPU49_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	BessyEMPU49_load_data_info(importloader)
	 if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	variable file = importloader.file
	string header = importloader.header
	
	string tmps
	struct keyval keyval
	struct empheader empheader
	variable run = 1
	
	// read ascii header
	do
		BessyEMPU49_getparams(mycleanupstr(myreadline(file)), keyval)
		strswitch(keyval.key)
			case "BEGIN":
				run = 0
				break
			case "Comment":
				empheader.Comment = keyval.val
				break
			case "Probe":
				empheader.Probe = keyval.val
				break
			case "CfgTyp":
				empheader.CfgTyp = keyval.val
				break
			case "Fileform":
				empheader.Fileform = keyval.val
				break
			case "Date":
				empheader.myDate = keyval.val
				break
			case "Program":
				empheader.Program = keyval.val
				break
			case "Version":
				empheader.Version = keyval.val
				break
			case "MeasTyp":
				empheader.MeasTyp = keyval.val
				break
			case "Analys.":
				empheader.Analys = str2num(keyval.val)
				break
			case "Scans":
				empheader.Scans = str2num(keyval.val)
				break
			case "Points":
				empheader.Points = str2num(keyval.val)
				break
			case "MonSta":
				empheader.MonSta = str2num(keyval.val)
				break
			case "MonEnd":
				empheader.MonEnd = str2num(keyval.val)
				break
			case "AnaSta":
				empheader.AnaSta = str2num(keyval.val)
				break
			case "AnaEnd":
				empheader.AnaEnd = str2num(keyval.val)
				break
			case "AnaRange":
				empheader.AnaRange = str2num(keyval.val)
				break
			case "AnaMin":
				empheader.AnaMin = str2num(keyval.val)
				break
			case "DacSta":
				empheader.DacSta = str2num(keyval.val)
				break
			case "DacEnd":
				empheader.DacEnd =str2num( keyval.val)
				break
			case "DeltaE":
				empheader.DeltaE = str2num(keyval.val)
				break
			case "MonName":
				empheader.MonName = keyval.val
				break
			case "MonType":
				empheader.MonType = str2num(keyval.val)
				break
			case "MonUnit":
				empheader.MonUnit = keyval.val
				break
			case "MonSpeed":
				empheader.MonSpeed = str2num(keyval.val)
				break
			case "MonRewind":
				empheader.MonRewind = str2num(keyval.val)
				break
			case "MonSweep":
				empheader.MonSweep = str2num(keyval.val)
				break
			case "IdPos":
				empheader.IdPos = str2num(keyval.val)
				break
			case "IdMode":
				empheader.IdMode = str2num(keyval.val)
				break
			case "LiveTime":
				empheader.LiveTime = str2num(keyval.val)
				break
			case "DeadTime":
				empheader.DeadTime = str2num(keyval.val)
				break
			case "MeasTime":
				empheader.MeasTime = str2num(keyval.val)
				break
			case "ScanTime":
				empheader.ScanTime = str2num(keyval.val)
				break
			case "ScanCtrl":
				empheader.ScanCtrl = keyval.val
				break
			case "DelayVal":
				empheader.DelayVal = str2num(keyval.val)
				break
			case "SecMeas":
				empheader.SecMeas = keyval.val
				break
			case "XMonFile":
				empheader.XMonFile = keyval.val
				break
			case "XAnaFile":
				empheader.XAnaFile = keyval.val
				break
			case "P_TakeUp":
				empheader.P_TakeUp = keyval.val
				break
			case "ChanOrder":
				empheader.ChanOrder = keyval.val
				empheader.spectra = ItemsInList(keyval.val,",")
				break
			case "Devices":
				empheader.Devices = keyval.val
				break
			case "Display":
				empheader.myDisplay = keyval.val
				break
			case "Arithm.":
				empheader.Arithm = keyval.val
				break
			case "DATAVALUE":
				BessyEMPU49_getparams(mycleanupstr(myreadline(file)), keyval)
				strswitch(keyval.key)
					case "BEGIN":
						run = 0
						break
					default:
						run = 0
						Debugprintf2("Error!",0)
						loaderend(importloader)
						return -1
						break
				endswitch
				break
			default:
				break
		endswitch
		fstatus file
	while(V_logEOF>V_filePOS && run == 1)

	//if(empheader.spectra>0)
	//else
	//	Debugprintf2("No Spectra!",0)
	//	loaderend(impname,1,file, dfSave)
	//	return -1
	//endif

	tmps = "energy" ; Make /O/D/N=(empheader.points)  $tmps /wave=xcol
	tmps = "spectra" ; Make /O/D/N=(empheader.points,empheader.spectra)  $tmps /wave=ycols

	variable i=0, j=0
	for(i=0;i<empheader.Points;i+=1)
		tmps= splitintolist(mycleanupstr(myreadline(file))," ")
		Redimension/N=(-1,ItemsInList(tmps,"_")-1) ycols
		//if( ItemsInList(tmps,"_")!=empheader.spectra+1)
		//	Debugprintf2("Error in data line!",0)
		//	loaderend(impname,1,file, dfSave)
		//	return -1		
		//endif	
		xcol[i]=str2num(StringFromList(0,tmps,"_"))
		for(j=0;j<(ItemsInList(tmps,"_")-1);j+=1)
			ycols[i][j]=str2num(StringFromList(j+1,tmps,"_"))
		endfor
	endfor
	//print cleanup_(myreadline(file)) // should be END
	
	// save notes to wave
	note ycols, header


	// check for equally spaced energy scale
	if(checkEnergyScale(xcol, 1E-6)==1)
		SetScale/P  x,xcol[0],(xcol[1]-xcol[0]),"eV", ycols
		killwaves xcol
	else
		SetScale/I  x,empheader.MonSta,empheader.MonEnd,"eV", ycols
	endif
	splitmatrix(ycols, "0")
	importloader.success = 1
	loaderend(importloader)
end
