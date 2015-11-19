
Function spikedetect(w,threshold)
        
        Wave w
        Variable threshold
	
        FindLevels/DEST=crosswave w threshold //finds x coordinate for where wave crosses threshold (up and down i.e. 2 spikes = 4 crossings)
        
        Make /O/D/N=(numpnts(crosswave)/2) spikepeaks
        Make /O/D/N=(numpnts(crosswave)/2) spiketimes
        
        Variable peak
        Variable peaktime
        variable i
        variable pos=0
        
        for (i=0;i<numpnts(crosswave);i+=2)
        	Variable xUp = crosswave[i]
        	Variable xDown=crosswave[i+1]
        	WaveStats/Q/R=(xUp,xDown) w
        	peak = V_max
        	peaktime = V_maxloc
        	Spikepeaks[pos]=peak
        	spiketimes[pos]=peaktime
        	pos += 1
      
        	
        endfor
        	
        	
        	
        

End
