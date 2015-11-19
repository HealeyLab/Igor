Function spikedetect(w,threshold)
        
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
        	spikeamps[pos]= peak -RMPWave[peaktimepoint] //this is wrong because spike amp is (peak-threshold), not (peak-RMV). Treshold can be detected with 1st derivative threshold
        	pos += 1
     
        endfor
End
