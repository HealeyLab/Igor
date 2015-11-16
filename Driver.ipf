#pragma rtGlobals=3		// Use modern global access method and strict wave access.
//Author: Dan Pollak
//10/30/15

Function driver_batch(w) // use of *_batch here will allow us to use preexisting code for running script on all waves in experiment file

	Wave w
	String waveName = NameofWave(w)
	 //will need some sort of "data dump" wave, that will contain the name of the current wave and output of analysis functions 
	//can then run a separate "sorter" script that will group data for each cell together, average duplicate trials, and return final average values   				
	if (stringmatch(waveName, "spont")>0)
		spontanalysis(w) //this function will need to be fixed, since it takes RMP as a user-calculated parameter
	else
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
//*********************************************************************************************************************
//takes advantage of how negatice and positive steps tend to look diferent
//if negative, will simply take the average
//FIND STEADY STATE POTENTIAL
Function/D findSSV(w)
	wave w
	variable output
	variable ic
	
	//way to see if it is negative
	String isNeg = "false"
	for(ic = 0; ic<strlen(nameOfWave(w)); ic+=1)
		if(StringMatch(nameOfWave(w)[ic], "-"))//if it is negative step
			isNeg = "true"
		endif
	endfor
	
	variable startTrial
	variable endTrial
	//if NEGATIVE
	if(StringMatch(isNeg, "true"))
		//go through wave from 3 sec to whenever it ends
		startTrial = x2pnt(w, 3)
		endTrial = x2pnt(w, 3.5)
		//print nameOfWave(w)
		//print isNeg
		//print startTrial
		//print endTrial
		
		return mean(w, startTrial, endTrial)
	endif
	
	//if POSITIVE
	if(StringMatch(isNeg, "false"))
		print nameOfWave(w)
		print isNeg
		return findMode(w)//dont forget you have to return these things
	endif
end
//*****************************************************************************************************************************************
Function/D findMode(w)
	wave w
	///Thus, increment by slightly more than the minimum, and then find the mean of the wave of values
	variable ic
	variable yvar
	//goes through all yvars above rmv, skipping a few along the way to save time
	//.010
	//.00025
	//      .
	variable minVolt = -0.070//mV
	variable maxVolt = -0.010//mV
	variable increment = .00025//mV
	variable mostCommonY = minVolt
	
	Make/D/O/N = ((maxVolt - minVolt) / increment) yvarCandidates //((maxVolt - minVolt) / increment)
	//		y sigs scaling col
	SetScale/I y, minVolt, maxVolt, "mV", yVarCandidates
	//tally up occurrences of each thing
	for(ic = x2pnt(w, 3); ic < x2pnt(w, 3.5); ic += 1) //3 and 3.5 is the X value and not the pnt (index, rather),
											// it is not always a round integer; its in seconds
		mostCommonY(w[ic]) = mostCommonY(w[ic]) + 1	
	
	endfor
	//now go through your wave and find the index of the highest value.
	variable i
	for()//goes from -70mv to -10 mv just to be safe
		endfor
	
	KillWaves /Z yvarCandidates//save memory
	return mostCommonY
end
//*****************************************************************************************************************************************
Function/D findMode1(w)
	wave w
	//doing this will probably return at least two waves, not one. 
	///Thus, increment by slightly more than the minimum, and then find the mean of the wave of values
	variable ic
	variable yvar
	//goes through all yvars above rmv, skipping a few along the way to save time
	//.010
	//.00025
	//      .
	variable minVolt = -0.070//mV
	variable maxVolt = -0.010//mV
	variable increment = .00025//mV
	variable mostCommonY = minVolt
	
	Make/D/O/N = ((maxVolt - minVolt) / increment) yvarCandidates //((maxVolt - minVolt) / increment)
	//		y sigs scaling col
	SetScale/I y, minVolt, maxVolt, "mV", yVarCandidates
	
	for(yvar = minVolt; yvar < maxVolt; yvar += increment)//goes from -70mv to -10 mv just to be safe
		for(ic = x2pnt(w, 3); ic < x2pnt(w, 3.5); ic += 1) //3 and 3.5 is the X value and not the pnt (index, rather),
											// it is not always a round integer; its in seconds
			if((w[ic - 1] < yvar && w[ic] > yvar) || (w[ic - 1] > yvar && w[ic] < yvar))//if it crosses the thing
				yvarCandidates[yvar] += 1
			endif
		endfor
	endfor
	//now go through your wave and find the index of the highest value.
	variable i
	for(i = minVolt; i < maxVolt; i += increment)//goes from -70mv to -10 mv just to be safe
		if(yVarCandidates(i) > yVarCandidates(mostCommonY))//if it crosses the thing
			mostCommonY = i//equals idnex, which sould also be the index
		endif
	endfor
	
	KillWaves /Z yvarCandidates//save memory
	return mostCommonY
end
//************************************************
Function findMin(w)
	wave w
	
	Make/D/O output
	variable outputIndex = 0
	variable ic
	for(ic = 1; ic<numpnts(w) - 1; ic+=1)
		if(min(w[ic - 1], w[ic]) == w[ic] && min(w[ic], w[ic + 1]) == w[ic])
			output[outputIndex] = w[ic]
			outputIndex = outputIndex + 1
		endif
	endfor
	return output

end
//*************************************************
Function findMaxValue(w)
	wave w
	
	variable output = -1110//ridiculously low val
	
	variable ic
	for(ic = 1; ic<numpnts(w) - 1; ic+=1)
		if(w[ic] > output)
			output = w[ic]
		endif
	endfor
	return output
end

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
		if (w[i]<Threshold && w[i+1]>=Threshold)
			SpikeCount=SpikeCount+1
			InsertPoints numpnts(SpikeTimes),1, SpikeTimes
			SpikeTimes[numpnts(SpikeTimes)-1]=pnt2x(w,i)
			crossUpx=i	
		endif
		
		if (w[i]>=Threshold && w[i+1]<Threshold)
			crossDownx=i
			WaveStats/Q/Z/R=[crossUpx, crossDownx] w // grabs wave portion between crossup and crossdown
			Variable MaxY=V_max //finds maximum
			Variable MaxYloc= x2pnt(w,V_maxloc) //converts maximum into point number
			InsertPoints numpnts(SpikeAmplitudes),1, SpikeAmplitudes // adds point to output wave
			SpikeAmplitudes[numpnts(SpikeAmplitudes)-1]=abs(MaxY-RMP)  // ^
			Variable AHPwindow = MaxYloc+1000 //defines interval after peak (in points) to look for AHP
			WaveStats/Q/Z/R=[MaxYloc, AHPwindow] w
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
				
				
			
			Variable halfheight = ((abs(MaxY))- ((abs(minY)))/2 //hafwidth calculation (voltage)
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
