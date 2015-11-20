a rtGlobals=1		// Use modern global access method.

Function spontspikeAnalysis(w, ampThresh)
		
		Wave w
		Variable ampThresh
		findRMV(w)
		threshdetect(w) //detects threshold for each spike
		peakdetect(w, AmpThresh) //generates peak (x) wave and peak (y) wave
		//to do:
		//half width
		//AHPanalysis (amplitude, decay time)
		//ISI/spike rate
		//
		
End

//*******************************************
		
Function peakdetect(w,threshold)

        Wave w
        Variable threshold

        FindLevels/Q/DEST=crosswave w threshold //finds x coordinate for where wave crosses threshold (up and down i.e. 2 spikes = 4 crossings)

        variable numspikes = numpnts(crosswave)/2

        Make /O/D/N=(numspikes) spikepeaks
        Make /O/D/N=(numspikes) spiketimes
        Make /O/D/N=(numspikes) spikeamps

        Variable peak
        Variable peaktime
        Variable peaktimepoint
        variable i
        variable pos=0
        wave RMPWave = root:RMPWave
       
        Wave diffWaveCrossWave //from threshdetect()

        for (i=0;i<numpnts(crosswave);i+=2)
                Variable xUp = crosswave[i]
                Variable xDown=crosswave[i+1]
                WaveStats/Q/R=(xUp,xDown) w
                peak = V_max
                //print peak
                peaktime = V_maxloc
                peaktimepoint= x2pnt(V_maxloc,w)
                //print peaktime
                Spikepeaks[pos]=peak
                spiketimes[pos]=peaktime
                spikeamps[pos]= peak -w[diffwavecrosswave[pos]]
                pos += 1

        endfor
End

//************************************************

Function threshdetect(w)

        Wave w
        Differentiate w/D=diffWave
        
	Smooth 10, diffWave

        
        Wave diffWave
        FindLevels/EDGE=1/M=.05/Q/DEST=threshTimes diffWave 15
        	
        
        Make /O/D/N=(numpnts(threshTimes)) threshValues
        variable pos
        variable threshpoint
        
        for(pos=0;pos<=(numpnts(threshValues));pos+=1)
        	threshpoint= x2pnt(w,threshTimes[pos])
        	threshValues[pos]=w[threshpoint]
        endfor
        
        variable i
       
       //get rid of detections resulting from noise
        variable diff1point
        variable diff2point
        
        Duplicate/O threshTimes refinedThreshTimes1
        
        Duplicate/O threshValues refinedThreshValues1
        
        for (i=0;i<=(numpnts(threshTimes));i+=1)
        	diff1point = x2pnt(diffWave, threshTimes[i])
        	diff2point = diff1point + 8
        	print threshTimes[i]
        	print diffWave[diff1point]
        	print diffWave[diff2point]
        	if(diffWave[diff2point]<15)
        		DeletePoints i,1,refinedThreshTimes1
        		DeletePoints i,1,refinedThreshValues1
        		
        	endif
        endfor
        		
end


//*************************************************

Function findRMV(w) 
        wave w 
 
        Variable minVoltage = -.090 //lower limit for RMP 
        Variable maxVoltage = -.040 // upper limit for RMP 
        Duplicate/O w $"restVals" 
        Wave restVals 
        variable ic 
 
        for(ic = 0; ic < numpnts(w); ic+=1) // can set to 3 to 3.5 s (in points) for current step protocol 
                if(w[ic]<maxVoltage && w[ic] > minVoltage) 
                restVals[ic]=w[ic] 
                else 
                restVals[ic]=NaN 
                endif 
        endfor 
         
        Duplicate/O restVals $"RMPWave" 
        Wave RMPWave 
         
        Curvefit /NTHR=0 line restVals /D=RMPWave  // detects if  
         
         
        if (abs(((RMPWave[numpnts(RMPWave)])-(RMPWave[0]))>.010))  
                print "Error: Significant change in RMP" // detects if the starting and ending RMP are significantly different 
                endif 
 
      end


