// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.

// This procedure is based on the MATLAB script provided by Keysight:
// http://www.keysight.com/main/editorial.jspx?cc=US&lc=eng&ckey=1185953&nid=-11143.0.00&id=1185953


static structure AgilentBin_waveform_header
	int32 headerSize
	int32 waveformType
	int32 nWaveformBuffers
	int32 nPoints
	int32 count
	float xDisplayRange
	double xDisplayOrigin
	double xIncrement
	double xOrigin
	int32 xUnits
	int32 yUnits
	char dateString[16]
	char timeString[16]
	char frameString[24]
	char waveformString[16]
	double timeTag
	uint32 segmentIndex
endstructure


static structure AgilentBin_wavebuffer_header
	int32 headerSize
	int16 bufferType
	int16 bytesPerPoint
	int32 bufferSize
endstructure


function AgilentBin_check_file(file)
	variable file
	fsetpos file, 0

	// read file header
	string fileCookie = mybinread(file, 2)
	string fileVersion = mybinread(file, 2)
	variable fileSize
	fbinread /B=3/F=3 file, filesize
	variable nWaveforms
	fbinread /B=3/F=3 file, nWaveforms

	// verify file
	if (cmpstr(fileCookie,"AG",1)!=0)
		fsetpos file, 0
		return -1
	endif
	if(filesize<=0 || nWaveforms <=0 || str2num(fileVersion) <= 0)
		fsetpos file, 0
		return -1
	endif
	fsetpos file, 0
	return 1
end


function AgilentBin_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "Agilent Binary Waveform"
	importloader.filestr = "*.bin"
	importloader.category = "misc"
end


function AgilentBin_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	AgilentBin_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file
	string tmps=""
	

	// read file header
	string fileCookie = mybinread(file, 2)
	string fileVersion = mybinread(file, 2)
	variable fileSize
	fbinread /B=3/F=3 file, filesize
	variable nWaveforms
	fbinread /B=3/F=3 file, nWaveforms

	// verify file
	if (cmpstr(fileCookie,"AG",1)!=0)
		Debugprintf2("Unrecognized file format.",0)
		loaderend(importloader)
		return -1
	endif

	variable waveformIndex =0, cof=0, bufferIndex =0
	for(waveformIndex=0;waveformIndex<nWaveforms;waveformIndex+=1)
		fstatus file
		cof = V_filePos
		// read waveform header
		struct  AgilentBin_waveform_header waveheader
		fbinread /B=3 file, waveheader

		// skip over any remaining data in the header
		fstatus file
		mybinread(file, waveheader.headerSize - (V_filePos-cof))

		for(bufferIndex=0;bufferIndex<waveheader.nWaveformBuffers;bufferIndex+=1)
			// read waveform buffer header
			fstatus file
			cof = V_filePos
			struct AgilentBin_wavebuffer_header buffer_header
			fbinread /B=3 file, buffer_header
			//skip over any remaining data in the header
			fstatus file
			mybinread(file, buffer_header.headerSize - (V_filePos-cof))

			tmps = "spk_"+num2str(waveformIndex)+"_"+num2str(bufferIndex)
			Make /O/D/N=(waveheader.nPoints) $tmps /wave=detector
			// generate time vector from xIncrement and xOrigin values
			SetScale/P  x,waveheader.xOrigin,waveheader.xIncrement,"s", detector
			
			if ((buffer_header.bufferType == 1) || (buffer_header.bufferType == 2) || (buffer_header.bufferType == 3))
				fbinread /B=3/F=4 file, detector
			elseif (buffer_header.bufferType == 4)
				fbinread /B=3/F=3 file, detector
			elseif (buffer_header.bufferType == 5)
				fbinread /B=3/F=1/U file, detector
			else // unkown, read as unformated bytes
				fbinread /B=3/F=1/U file, detector
			endIF
	
			note detector, header
			Debugprintf2("exported: "+tmps,0)

		endfor
	endfor	
	
	importloader.success = 1
	loaderend(importloader)
end
