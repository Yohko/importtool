// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

// not tested yet because of missing data file!!

Menu "Macros"
	submenu "Import Tool "+importloaderversion
			submenu "PES"
				"Load SpecsLab1					*.exp	file... alpha", Specslabexp_load_data()
			end
	end
end

// ###################### SpecsLab I *.exp ########################

static Structure SpecsLabexpinfo
	string header
	variable region
	variable active
	variable start
	variable step
	variable stop
	variable scans
	variable dwell
	variable x_shift
	variable x_gain
	variable wf
	variable visible
	variable depth
	variable data
	string method
	string source
	string mytag
	string analyser
	string mydate
	string sourcedata
	string analyserdata
endstructure


function Specslabexp_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "SpecsLab1"
	importloader.filestr = "*.exp"
	importloader.category = "PES"
end


function Specslabexp_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	Specslabexp_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file
	
	string tmps="", key="", val=""

	struct SpecsLabexpinfo expinfo
	expinfo.header=header
	variable groupc=0
	
	do
		Freadline file, tmps
		If (strlen(tmps)==0)
			return 0
		endif
		tmps=mycleanupstr(tmps)
		
		if(strsearch(tmps,"#",0)==0)
			continue
		endif
		if(strsearch(tmps,":",0)!=-1 && itemsinlist(tmps,":") == 2)
			key=stripstrfirstlastspaces(StringFromList(0,tmps,":"))
			val=stripstrfirstlastspaces(StringFromList(1,tmps,":"))
		else
			key=tmps
			val=""
		endif	
		strswitch(key)
			case "region":
				Debugprintf2("Begin of region block!",0)
				expinfo.region = str2num(val)
				break
			case "method":
				expinfo.method=val
				break
			case "active":
				expinfo.active = str2num(val)
				break
			case "range":
				val=splitintolist(val," ")
				expinfo.start=str2num(StringFromList(0,val,"_"))
				expinfo.stop=str2num(StringFromList(1,val,"_"))
				expinfo.step=str2num(StringFromList(2,val,"_"))
				break
			case "scans":
				expinfo.scans=str2num(val)
				break
			case "dwell":
				expinfo.dwell=str2num(val)
				break
			case "x_shift":
				expinfo.x_shift=str2num(val)
				break
			case "x_gain":
				expinfo.x_gain=str2num(val)
				break
			case "work_function":
				expinfo.wf=str2num(val)
				break
			case "Source":
				expinfo.source=val
				expinfo.sourcedata= Specslabexp_getinfo(file)
				break
			case "EnergyAnalyser":
				expinfo.analyser=val
				expinfo.analyserdata= Specslabexp_getinfo(file)
				break
			case "tag":
				expinfo.mytag=val
				break
			case "measure_date":
				expinfo.mydate=val
				break
			case "visible":
				expinfo.visible=str2num(val)
				break
			case "depth":
				expinfo.depth=str2num(val)
				break
			case "data":
				Debugprintf2("Begin of data block!",0)
				expinfo.data=str2num(val)
				Specslabexp_getdata(file, expinfo, groupc)
				break
			case "enddata":
				Debugprintf2("End of data block!",0)
				break
			case "newgroup":
				Debugprintf2("New Group!",0)
				groupc+=1
				break
			case "endregion":
				Debugprintf2("End of region block!",0)
				Specslabexp_clearinfo(expinfo)
				break
		endswitch

	
		Fstatus file
	while (V_logEOF>V_filePOS)  	
	
	importloader.success = 1
	loaderend(importloader)
end


static function Specslabexp_getdata(file, expinfo, groupc)
	variable file
	struct SpecsLabexpinfo &expinfo
	variable groupc
	variable i=0, exen=0
	string tmps=""
	tmps="region_"+num2str(expinfo.region)+"_group_"+num2str(groupc)+"_detector"
	Make /O/R/N=(expinfo.data)  $tmps /wave=detector
	
	exen=str2num("1")
	strswitch(StringByKey("xrs_anode",expinfo.sourcedata,"="))
		case "Mg":
			exen=1253.6
			break
		case "Al":
			exen=1486.7
			break
		default:
			exen=0
			break
	endswitch
	strswitch(expinfo.method)
		case "XPS":
			SetScale/P  x,expinfo.start,expinfo.step, "eV", detector
//			if (posbinde == 0)
//				SetScale/P  x,-exen+expinfo.start,-expinfo.step, "eV", detector
//			else
//				SetScale/P  x,exen-expinfo.start,expinfo.step, "eV", detector
//			endif
//			break
		default:
			SetScale/P  x,expinfo.start,expinfo.step, "eV", detector
			break
	endswitch
	note detector, ""+expinfo.header
	note detector, "Source: "+expinfo.source
	note detector, "EnergyAnalyser: "+expinfo.analyser
	note detector, "Region: "+num2str(expinfo.region)
	note detector, "Active: "+num2str(expinfo.active)
	note detector, "Start: "+num2str(expinfo.start)
	note detector, "Stop: "+num2str(expinfo.stop)
	note detector, "Step: "+num2str(expinfo.step)
	note detector, "Dwell time: "+num2str(expinfo.scans)
	note detector, ": "+num2str(expinfo.dwell)
	note detector, "X_shift: "+num2str(expinfo.x_shift)
	note detector, "X_gain: "+num2str(expinfo.x_gain)
	note detector, "Work function: "+num2str(expinfo.wf)
	note detector, "Visible: "+num2str(expinfo.visible)
	note detector, "Depth: "+num2str(expinfo.depth)
	note detector, "Data: "+num2str(expinfo.data)
	note detector, "Method: "+expinfo.method
	note detector, "Tag: "+expinfo.mytag
	note detector, "Date: "+expinfo.mydate
	
	
	
	
	for(i=0;i<expinfo.data;i+=1)
		Freadline file, tmps
		If (strlen(tmps)==0)
			return 0
		endif
		detector[i]=str2num(mycleanupstr(tmps))
		if(str2num(get_flags("CB_DivScans"))==1)
			detector[i]/=expinfo.scans
		endif
		If(str2num(get_flags("CB_DivLifeTime")) ==1)
			detector[i]/=expinfo.dwell
		endif
	endfor
end


static function Specslabexp_clearinfo(expinfo)
	struct SpecsLabexpinfo &expinfo
	//expinfo.header = ""
	expinfo.region =0
	expinfo.active =0
	expinfo.start =0
	expinfo.step =0
	expinfo.stop =0
	expinfo.scans =0
	expinfo.dwell =0
	expinfo.x_shift =0
	expinfo.x_gain =0
	expinfo.wf =0
	expinfo.visible =0
	expinfo.depth =0
	expinfo.data =0
	expinfo.method = ""
	expinfo.source = ""
	expinfo.mytag = ""
	expinfo.analyser = ""
	expinfo.mydate = ""
	expinfo.sourcedata = ""
	expinfo.analyserdata = ""
end


static function /S Specslabexp_getinfo(file)
	variable file
	string list="", key="", val=""
	if (getkeyval(file, key, val)==-1)
		return "-1"
	endif
	if(strsearch(key,"}",0)==0 )
		return "-1"
	endif
	do
		if (getkeyval(file, key, val)==-1)
			break
		endif
		if(strsearch(key,"}",0)==0 )
			break // end of region block because of double "}"
		endif
		list+=key+"="+val
		Fstatus file
	while (V_logEOF>V_filePOS)  
	if(strlen(list)>1)
		list=list[0,strlen(list)-2]
	endif
	return list	
end


// ###################### SpecsLab I *.exp END ######################
