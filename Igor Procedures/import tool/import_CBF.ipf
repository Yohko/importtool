// Licence: Lesser GNU Public License 2.1 (LGPL)
#pragma rtGlobals=3		// Use modern global access method.


// This implementation is based on a code snippet by Jan Ilavsky:
// http://www.igorexchange.com/node/5889

// http://www.bernstein-plus-sons.com/software/CBF/doc/CBFlib.html#3.3.3
// http://www.igorexchange.com/node/5889
// http://xrpp.iucr.org/cgi-bin/itr?url_ver=Z39.88-2003&rft_dat=what%3Dchapter%26volid%3DGa%26chnumo%3D2o3%26chvers%3Dv0001
// http://www.bernstein-plus-sons.com/software/CBF/doc/CBFlib.html#3.2.2

//*************************************************************************************************
//	This function imports Cbf file with byte_offset compression
//	see: <a href="http://www.bernstein-plus-sons.com/software/CBF/doc/CBFlib.html#3.3.3<br />
//	"title="http://www.bernstein-plus-sons.com/software/CBF/doc/CBFlib.html#3.3.3<br />
//	"rel="nofollow">http://www.bernstein-plus-sons.com/software/CBF/doc/CBFlib.html#3.3.3<br />
//	</a> for compression description and lots of other information. 
//	tested on Pilatus 2M images (from PSI)
//*************************************************************************************************



function CBF_check_file(file)
	variable file
	fsetpos file, 0
	
	fstatus file
	if(V_logEOF<16800)
		return -1
	endif
	string testLine=""
	testLine=PadString (testLine, 16800, 0x20)
	FBinRead file, testLine
	variable SkipBytes=strsearch(testLine, "\014\032\004\325" , 0)+4 // this is string I found in test images
	if(SkipBytes<5) // string not found...
		SkipBytes=strsearch(testLine, "\012\026\004\213" , 0)+4 // this is per <a href="http://www.bernstein-plus-sons.com/software/CBF/doc/CBFlib.html#3.2.2" title="http://www.bernstein-plus-sons.com/software/CBF/doc/CBFlib.html#3.2.2" rel="nofollow">http://www.bernstein-plus-sons.com/software/CBF/doc/CBFlib.html#3.2.2</a> what should be there. Go figure... 
	endif
	if(SkipBytes<5)
		return -1
	endif
	testLine=ReplaceString("\r\n\r\n", testLine, ";")
	testLine=ReplaceString("\r\n", testLine, ";")
	testLine=ReplaceString("#", testLine, "")
	testLine=ReplaceString(";;;;", testLine, ";")
	testLine=ReplaceString(";;;", testLine, ";")
	testLine=ReplaceString(";;", testLine, ";")
	testLine = ReplaceString(":", testLine, "=")
	variable sizeToExpect = NumberByKey("X-Binary-Number-of-Elements", testLine, "=", ";")
	if(numtype(sizeToExpect) !=0)
		return -1
	endif
	fsetpos file, 0
	return 1
end


function CBF_load_data_info(importloader)
	struct importloader &importloader
	importloader.name = "Crystallographic Binary Files"
	importloader.filestr = "*.cbf"
	importloader.category = "XRD"
end


function CBF_load_data([optfile])
	variable optfile
	optfile = paramIsDefault(optfile) ? -1 : optfile
	struct importloader importloader
	CBF_load_data_info(importloader)
	if(loaderstart(importloader, optfile=optfile)!=0)
		return -1
	endif
	string header = importloader.header
	variable file = importloader.file
	string tmps=""
  
	// this function loads and uncompresses the Cbf byte_offset compressed file format with:
	// conversions="x-CBF_BYTE_OFFSET";Content-Transfer-Encoding=BINARY;
	// X-Binary-Element-Type="signed 32-bit integer";X-Binary-Element-Byte-Order=LITTLE_ENDIAN;
	// Searches for start of binary data, checks how much data there should be and creates 1D wave output wave (stream) 
	// with uncompressed data in the current data folder. 
	variable SkipBytes
	variable filevar
	variable bufSize 
	variable sizeToExpect
	string testLine

	// locate start of the binary data
	testLine=""
	testLine=PadString (testLine, 16800, 0x20)
	FBinRead file, testLine
	SkipBytes=strsearch(testLine, "\014\032\004\325" , 0)+4 // this is string I found in test images
	if(SkipBytes<5) // string not found...
		SkipBytes=strsearch(testLine, "\012\026\004\213" , 0)+4 // this is per <a href="http://www.bernstein-plus-sons.com/software/CBF/doc/CBFlib.html#3.2.2" title="http://www.bernstein-plus-sons.com/software/CBF/doc/CBFlib.html#3.2.2" rel="nofollow">http://www.bernstein-plus-sons.com/software/CBF/doc/CBFlib.html#3.2.2</a> what should be there. Go figure... 
	endif
	if(SkipBytes<5) // string still not found. This is problem. 
		Debugprintf2("Failed to find start of binary section in the Cbf file",0)
		loaderend(importloader)
		return -1
	endif

	// Figure out now how much data are we expecting
	// this header is quite messy, let's clean ti up a bit
	testLine=ReplaceString("\r\n\r\n", testLine, ";")
	testLine=ReplaceString("\r\n", testLine, ";")
	testLine=ReplaceString("#", testLine, "")
	testLine=ReplaceString(";;;;", testLine, ";")
	testLine=ReplaceString(";;;", testLine, ";")
	testLine=ReplaceString(";;", testLine, ";")
	testLine = ReplaceString(":", testLine, "=")
	sizeToExpect = NumberByKey("X-Binary-Number-of-Elements", testLine, "=", ";")
	variable dimfast = NumberByKey("X-Binary-Size-Fastest-Dimension", testLine, "=", ";")
	variable dimslow = NumberByKey("X-Binary-Size-Second-Dimension", testLine, "=", ";")
	if(numtype(dimfast)!=0 || numtype(dimslow) !=0)
		dimslow = sqrt(sizeToExpect)
		dimfast = dimslow
	endif
	FSetPos file, SkipBytes								// start of the image
	FStatus file
	bufSize = V_logEOF-V_filePos						// this is how mcuh data we have in the image starting at the binary data start
	make/B/O/N=(bufSize)/Free BufWv				// signed 1 byte wave for the data
	make/O/N=(sizeToExpect)/Free ResultImage		// here go teh converted singed integers. Note, they can be 8, 16, or 32 bits. 64bits not supported here. 
	//make/O/N=(sizeToExpect) ResultImage			// here go teh converted singed integers. Note, they can be 8, 16, or 32 bits. 64bits not supported here. 
	FBinRead/B=1/F=1 file, BufWv						// read 1 Byte each into singed integers wave

	//and not decompress the data here 	
	variable i, j, PixelValue, ReadValue
	j=0													// j is index of the signed 1 byte wave (stream of data in) 
	PixelValue = 0										// value in current pixel in image. 
	For(i=0;i<(sizeToExpect);i+=1)					// i is index for output wave
		if(j>bufSize-1)
			break										// just in case, we run our of j. Should never happen
		endif
		ReadValue = BufWv[j]							// read 1 Byte integer
		if(ReadValue>-128)							// this is useable value if +/- 127
			PixelValue += ReadValue					// add to prior pixel value
			ResultImage[i] = PixelValue					// store in output stream
			j+=1										// move to another j point 
		elseif(ReadValue==-128)						// This is indicator that the difference did not fit in 1Byte, read 2 bytes and use those.
			j+=1										// move to another point to start reading the 2 bytes
			ReadValue =  CBF_Conv2Bytes(BufWv[j],BufWv[j+1])	        //read and convert 2 Bytes in integer
			if(ReadValue>-32768)						// This is useable value, use these two bytes
				PixelValue += ReadValue				// add to prior pixel value
				ResultImage[i] = PixelValue				// store in output stream
				j+=2									// move to another j point  
			elseif(ReadValue==-32768)				// This is indicator that the difference did not fit in 2Bytes, read 4 bytes and use those.
				j+=2									// move to another point to start reading the 4 bytes 
				ReadValue = CBF_Conv4Bytes(BufWv[j],BufWv[j+1], BufWv[j+2], BufWv[j+3])		//read and convert next 4 Bytes in integer
				if(abs(ReadValue)<2147483648)		// this is correct value for 32 bits
					PixelValue += ReadValue			// add to prior pixel value
					ResultImage[i] = PixelValue			// store in output stream
					j+=4								// move to another j point 
				else										// abort, do not support 64 byte integers (no such detector exists... 
					Debugprintf2("64 bits data are not supported.",0)
					loaderend(importloader)
					return -1
				endif
			else
				Debugprintf2("error",0)
			endif
		else
			Debugprintf2("error",0)
		endif
	endfor

	// redimension to a 2D wave (image)
	make/O/N=(dimfast, dimslow)  image
	image[][] = ResultImage[p*q]

	importloader.success = 1
	loaderend(importloader)
end


static Function CBF_Conv2Bytes(B1,B2)		
	variable B1, B2
	// takes two signed integer bytes, and converts them to 16 bit signed integer, little-endian, two's complement signed interpretation
	// assume B1 is first byte for little-endian should be unsigned integer as it is the smaller part of the data
	// assume B2 contains the larger values and sign
	variable unsB1=(B1>=0) ? B1 : (256 + B1) // this should convert two's complement signed interpretation to Usigned interpretation
	return unsB1 + 256*B2
end


static Function CBF_Conv4Bytes(B1,B2, B3, B4)		
	variable B1, B2, B3, B4
	// takes four signed integer bytes, and converts them to 32 bit signed integer, little-endian, two's complement signed interpretation
	// assume B1, B2, B3 are first bytes for little-endian should be unsigned integer as it is the smaller part of the data
	// assume B4 contains the larger values and sign
	variable unsB1=(B1>=0) ? B1 : (256 + B1) // this should convert two's complement signed interpretation to Usigned interpretation
	variable unsB2=(B2>=0) ? B2 : (256 + B2) // this should convert two's complement signed interpretation to Usigned interpretation
	variable unsB3=(B3>=0) ? B3 : (256 + B3) // this should convert two's complement signed interpretation to Usigned interpretation
	return unsB1 + 256*unsB2 + 256*256*unsB3 + 256*256*256*B4
end
