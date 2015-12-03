#Pragma rtGlobals=1     // Use modern global access method. rtGlobals=1     // Use modern global access method.

Function spontspikeAnalysis(w, ampThresh)
        
        Wave w
        Variable ampThresh
        findRMV(w)
        threshdetect(w) 
        peakdetect(w, AmpThresh)
        //to do:
        //ISI or spike rate
        
        //graphall function to plot everything that the program calculated for this wave on top of the source wave
        //graph can then be saved (w/wavename) so that user can visualy verify results 
       
        
        // "stats" function, that calculates the mean and standard deviation of all the calculated values and then outputs them into the final results wave 
       // threshold voltage
       // spike amplitude
       // spike half width
       // AHP amplitude
       // AHP duration
       // spike rate
       // ISI
       // ISI standard deviation
       // RMP
       
        
End

//************************************************


Function threshdetect(w) //wave "times" and wave "values" contain the timing and voltage values of the detected AP thresholds

        Wave w
        Differentiate w/D=diffWave
        
    Smooth 10, diffWave

        
        Wave diffWave
        FindLevels/EDGE=1/M=.05/Q/DEST=threshTimes diffWave 5
            
        
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
        
        Make/O/D/N=0 times
        Make/O/D/N=0 values
        
        for (i=0;i<=(numpnts(threshTimes));i+=1)
            
            diff1point = x2pnt(diffWave, threshTimes[i])
            diff2point = diff1point + 30
            
            if(diffWave[diff2point]>20)
                Insertpoints numpnts(times),1,times
                times[numpnts(times)]=threshTimes[i]
                Insertpoints numpnts(values),1,values
                variable valuefinder = x2pnt(w,times[numpnts(times)])
                values[numpnts(values)]=w[valuefinder]
                
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
         
        Curvefit /Q/N/NTHR=0 line restVals /D=RMPWave  
         
        if (abs(((RMPWave[numpnts(RMPWave)])-(RMPWave[0]))>.010))  
                print "Error: Significant change in RMP in Wave: "+ NameofWave(w) // detects if the starting and ending RMP are significantly different 
                endif 
 
      end
      
//****************************************************
      
Function peakdetect(w,threshold)

        Wave w
        Variable threshold
        Wave values = root:values

        FindLevels/Q/DEST=crosswave w threshold //finds x coordinate for where wave crosses threshold (up and down i.e. 2 spikes = 4 crossings)

        variable numspikes = numpnts(crosswave)/2

        Make /O/D/N=(numspikes) spikepeaks
        Make /O/D/N=(numspikes) spiketimes
        Make /O/D/N=(numspikes) spikeamps
        Make /O/D/N=(numspikes) AHPtimes
        Make /O/D/N=(numspikes) AHPpeaks
        Make /O/D/N=(numspikes) AHPamplitudes
        Make /O/D/N=(numspikes) AHPendtimes
        Make /O/D/N=(numspikes) AHPendvalues
        Make /O/D/N=(numspikes) AHPdurations
        Make /O/D/N=(numspikes) halfwidths
        Wave times = root:times
        Make /O/D/N= (numspikes*2) halfwidthpointsAll

        Variable peak
        Variable peaktime
        Variable peaktimepoint
        variable i
        variable pos=0
        wave RMPWave = root:RMPWave
        variable amplitude
        variable halfamp
        variable halfampvoltage
        variable halfwidthrightpos= 0 
       
        Wave diffWaveCrossWave //from threshdetect()

        for (i=0;i<numpnts(crosswave);i+=2)
                Variable xUp = crosswave[i]
                Variable xDown=crosswave[i+1]
                WaveStats/Q/R=(xUp,xDown) w
                peak = V_max
                peaktime = V_maxloc
                peaktimepoint= x2pnt(V_maxloc,w)
                Spikepeaks[pos]=peak
                spiketimes[pos]=peaktime
                
                amplitude = peak - values[pos]
                halfamp = amplitude/2
                spikeamps[pos]= amplitude
                halfampvoltage = values[pos] + halfamp
                
                AHP(pos,0.030,spiketimes[pos],w)
                AHPcurvefit(w,AHPtimes[pos],pos)
                Findlevels/Q/R=(times[pos],AHPtimes[pos])/DEST=halfwidthpoints w halfampvoltage // halfwidth finder
                halfwidths[pos] = halfwidthpoints[1]-halfwidthpoints[0]
                halfwidthpointsAll[halfwidthrightpos] = halfwidthpoints[0]
                halfwidthpointsAll[halfwidthrightpos+1]= halfwidthpoints[1]
                halfwidthrightpos +=2
                pos+=1
                

        endfor
End

//**********************************************************

Function AHP(p,searchRight,peaktime,w)

        //parameters
        Variable p //position holder, see peakdetect
        Wave w
        Variable searchright //defines right limit of window to search for AHPpeak. May not work optimally.
        Variable peaktime //contained in wave made by spikepeak()
        
        Wave AHPtimes = root:AHPTimes
        Wave AHPpeaks = root:AHPpeaks
     Wave AHPamplitudes=root:AHPamplitudes
     Wave values=root:values
     
        //Internal variables
        Variable AHPpeakvalue
        Variable AHPpeaktime
        Variable AHPamplitude


        WaveStats/Q/Z/R=(peaktime,peaktime+searchright) w

                AHPpeakvalue = V_min
                AHPpeaktime = V_minloc
                
                AHPtimes[p]=AHPpeaktime
                AHPpeaks[p]=AHPpeakvalue
                AHPamplitudes[p]= AHPpeaks[p]-values[p]
                
              
End

//*********************************

Function compareValues(w1,w2,x)  ///

    Wave w1 //wave1
    Wave w2 //wave2
    Variable x
    
    if (w1[x]>=w2[x])
        return 0
    else
        return 1
    endif
        
end

Function AHPCurvefit(w,peaktime, p)

    Variable p //position holder, see peakdetect
    Wave w
    Variable peaktime
    Wave AHPtimes = root:AHPtimes
    Wave AHPendtimes=root:AHPendtimes
    Wave AHPendvalues=root:AHPendvalues
    Wave AHPdurations = root:AHPdurations
    
    Variable peakpoint= x2pnt(w, peaktime)
    
    variable i
    
    
    for (i=peakpoint;i<=numpnts(w);i+=1)
        variable pastRMV = compareValues(RMPwave, w, i)
        if (pastRMV>0)
            AHPendtimes[p]=pnt2x(w,i)
            AHPdurations[p]=AHPendtimes[p] - peaktime
            AHPendvalues[p]=w[i]
            break
        Endif
    Endfor
    
End



//Display all calculations on top of source wave
Display 'PMPulse_1_1_1_1_V-mon'; AppendToGraph spikepeaks vs spiketimes; AppendToGraph RMPWave; AppendToGraph AHPpeaks vs AHPtimes; AppendToGraph threshValues vs threshTimes; AppendToGraph AHPendvalues vs AHPendtimes