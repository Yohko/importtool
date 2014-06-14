// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

// http://www.jawoollam.com/wvase.html


Menu "Macros"
	submenu "Import Tool "+importloaderversion
		submenu "FTIR-RAMAN-VASE"
				"WVASE32						*.dat	file... b1", WVASE32_load_data() 
		end
	end
end


function WVASE32_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "WVASE32"
	importloader.filestr = "*.dat"
	importloader.category = "VASE"
end



function WVASE32_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	WVASE32_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file

	string tmps= "", tmps2=""
	variable points = 1, i=0

	FReadLine file, tmps
	tmps = mycleanupstr(tmps)
	If (strlen(tmps)==0)
		return 0
	endif
	string name = cleanname(tmps)
	header+="\rnComment: "+tmps
	
	FReadLine file, tmps
	tmps = mycleanupstr(tmps)
	If (strlen(tmps)==0)
		return 0
	endif
	tmps=tmps[strsearch(tmps,"[",0)+1,strlen(tmps)-2]
	for(i=0;i<ItemsInList(tmps,",");i+=1)
		tmps2=StringFromList(i,tmps,",")
		if(strsearch(tmps2,"=",0)!=-1)
			header+="\r"+stripstrfirstlastspaces(tmps2[0,strsearch(tmps2,"=",0)-1])+": "+stripstrfirstlastspaces(tmps2[strsearch(tmps2,"=",0)+1,strlen(tmps2)])
		else
			header+="\rParameter"+num2str(i)+": "+stripstrfirstlastspaces(tmps2)
		endif
	endfor

	FReadLine file, tmps
	tmps = mycleanupstr(tmps)
	If (strlen(tmps)==0)
		return 0
	endif
	header+="\rOriginal name: "+tmps[strsearch(tmps,"[",0)+1,strlen(tmps)-2]
	FReadLine file, tmps
	tmps = mycleanupstr(tmps)
	If (strlen(tmps)==0)
		return 0
	endif

	header+="\runit x-axis: "+tmps
	string xunit = tmps
	
	
	tmps="datatmp"
	Make /O/R/N=(points,0)  $tmps /wave=datatmp
	note datatmp, header
	
	
	do
		FReadLine file, tmps
		tmps = mycleanupstr(tmps)
		If (strlen(tmps)==0)
			return 0
		endif
		Redimension/N=(points, 1+ItemsInList(tmps,"\t")) datatmp
		datatmp[points-1][0] = 1239.8424/str2num(StringFromList(0,tmps,"\t"))
		for(i=1;i<1+ItemsInList(tmps,"\t");i+=1)
			datatmp[points-1][i] = str2num(StringFromList(i-1,tmps,"\t"))
		endfor
		points +=1
		Fstatus file
	while (V_logEOF>V_filePOS)

	// 0 - energy eV
	// 1 - energy nm
	// 2 - E angle
	// 3 - psi
	// 4 - delta
	// 5 - ?
	// 6 - ?
	splitmatrix(datatmp,name)
	SetScale d 0,100,"eV",$(name+"_spk0")
	SetScale d 0,100,"nm",$(name+"_spk1")
	rename $(name+"_spk0"), $(name+"_eV") 
	rename $(name+"_spk1"), $(name+"_nm") 
	rename $(name+"_spk2"), $(name+"_E_angle") 
	rename $(name+"_spk3"), $(name+"_psi") 
	rename $(name+"_spk4"), $(name+"_delta") 

	importloader.success = 1
	loaderend(importloader)
end