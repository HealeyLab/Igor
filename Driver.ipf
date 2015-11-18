#pragma rtGlobals=3		// Use modern global access method and strict wave access.
//Author: Dan Pollak
//10/30/15

Function driver_batch(w) // use of *_batch here will allow us to use preexisting code for running script on all waves in experiment file
	Wave w
	String waveName = NameofWave(w)
	Make O/T spontWaveNames
	Make O/D spontData
	Make O/T cStepWaveNames
	Make O/D cStepData
	if (stringmatch(waveName, "spont")>0)
		Insertpoints numpnts(spontWaveNames),1,spontWaveNames	
		spontanalysis(w) //this function will need to be fixed, since it takes RMP as a user-calculated parameter
	else
		Insertpoints numpnts(cStepWaveNames),1,cStepWaveNames
		cstepanalysis(w) //function needs to be made 
		
	endif	

end
//******************************************************************************************************************************
//FIND RESTING MEMBRANE POTENTIAL

// right now this code makes a new wave called restVals, which contains all values of the original wave that are between -90 and -50 mV
// will not take into account subthreshold activity throwing off mean of these values 
Function/D findRMV(w)
	wave w
	
	Variable minMilliVolt = -.090
	Variable maxMilliVolt = -.050
	Make/O/D/N=(numpnts(w)) restVals
	variable ic

	
	for(ic = 0; ic < numpnts(w) - 1; ic+=1)
		if(w[ic] < maxMilliVolt && w[ic] > minMilliVolt)// && slope between w[ic] andw[ic+a few points] <some amount but > (-)someamount
			restVals[ic] = w[ic]
		endif
	endfor
	
	return mean(restVals)
	
end
//************************************************
//This function detects spikes using the threshold method and returns spike times, spike ampitudes, spike half-widths, AHP amplitude, and AHP half-width

Function spontanalysis(w, RMP) 
	Wave w
	Variable RMP // resting potential (Volts)
	Variable ReturnValue
	Variable SpikeCount=0
	Variable Threshold=-0.04      //Defines threshold as -40 mV
	Make/O/D/N=0 SpikeAmplitudes
	Make/O/D/N=0 SpikeTimes
	Make/O/D/N=0 AHPAmplitudes
	Make/O/D/N=0 HalfWidths
	Make/O/D/N=0 AHPDecays
	Variable crossUpx //where wave crosses threshold up
	Variable crossDownx //where wave crosses threshold down
	Variable decaystart
	Variable decayend
	Variable decaytime
	Variable i //current x position


	
	for (i=0;i<numpnts(w)-1;i+=1)
		if (w[i]=<Threshold && w[i+1]>Threshold)
			SpikeCount=SpikeCount+1
			
			crossUpx=i	
		endif
		
		if (w[i]>=Threshold && w[i+1]<Threshold)
			crossDownx=i
			WaveStats/Q/Z/R=[crossUpx, crossDownx] w // grabs wave portion between crossup and crossdown
			Variable MaxY=V_max //finds maximum
			InsertPoints numpnts(SpikeTimes),1,SpikeTimes
			SpikeTimes[numpnts(SpikeTimes)-1]=MaxY			
			Variable MaxYloc= x2pnt(w,V_maxloc) //converts maximum into point number
			InsertPoints numpnts(SpikeAmplitudes),1, SpikeAmplitudes // adds point to output wave
			SpikeAmplitudes[numpnts(SpikeAmplitudes)-1]=abs(MaxY-RMP)  // ^
			Variable AHPwindow = MaxYloc+1000 //defines interval after peak (in points) to look for AHP
			WaveStats/Q/Z/R=[MaxYloc, AHPwindow] w //new wavestats for spike peak => ahp peak
			Variable MinY=V_min
			Decaystart = V_minloc
			Variable MinYloc= x2pnt(w,V_minloc)
			
			InsertPoints numpnts(AHPAmplitudes),1, AHPAmplitudes
			AHPAmplitudes[numpnts(AHPAmplitudes)-1]= abs(MinY - RMP)
			
			variable a = MinYloc
			variable b = 0
			
			Do
				if (w[a]<=RMP && w[a+1]>RMP)
				decayend= pnt2x(w, a)
				decaytime = decayend - decaystart
				InsertPoints numpnts(AHPDecays),1, AHPDecays // adds point to output wave
				AHPDecays[numpnts(AHPDecays)-1]=decaytime
				b = 1
				endif
				a = a+1	
			While (b<=0)
				
				
			
			Variable halfheight = ((abs(MaxY))- ((abs(RMP))/2 //halfamplitude calculation (voltage)
			variable h
			for (h=minYloc;h>=MaxYloc;h-=1) 
				if (w[h]<halfheight && w[h-1]>=halfheight)
					Variable halfwidthr=h
					Variable halfwidthvoltage = w[halfwidthr]
				endif
			endfor
			variable j
			for (j=MaxYloc; j>=1;j-=1)
				if (w[j]>halfwidthvoltage && w[j-1]<=halfwidthvoltage)
					Variable halfwidthl = j 
					j = -1
				endif
				endfor 
			Variable halfleftx = pnt2x(w,halfwidthl)
			Variable halfrightx = pnt2x (w,halfwidthr)

			Variable halfwidth = (halfrightx - halfleftx)
			InsertPoints numpnts(halfwidths),1, halfwidths
			halfwidths[numpnts(halfwidths)-1]=halfwidth		
	endif
	endfor
	ReturnValue=SpikeCount/((numpnts(w)-1)*deltax(w))
	Return ReturnValue
End
