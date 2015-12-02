#pragma rtGlobals=3		// Use modern global access method and strict wave access.
//Author: Dan Pollak
//10/30/15

Function driver_batch(w) // use of *_batch here will allow us to use preexisting code for running script on all waves in experiment file
	Wave w
	String waveName = NameofWave(w)
	Make /O/T spontWaveNames
	Make /O/D spontData
	Make /O/T cStepWaveNames
	Make /O/D cStepData
	if (stringmatch(waveName, "spont")>0)
		Insertpoints numpnts(spontWaveNames),1,spontWaveNames	
		//spontanalysis(w) //this function will need to be fixed, since it takes RMP as a user-calculated parameter
	elseif(stringmatch(waveName, "-")>0)
	// bc all other cases of waves are NOT current steps, we need to discriminate further using this conditional
		Insertpoints numpnts(cStepWaveNames),1,cStepWaveNames
		//cstepanalysis(w) //function needs to be made 
		
	endif	

end
//***************************************************************************************************************************
Function FIWaves(w)//root
	//eventually, have it generate a wave per cell
	wave w
	String list = WaveList("*Cell*", ";", "")
	//get list of cell nums, for elem in each, call fi curve on sublist
	variable ic, listSize = itemsInList(list)
	Make/O/T=2/N=0 cellNumbers//ie, Cell1, Cell2, Cell3, etc
	for(ic = 0; ic < listSize - 14; ic +=1)
		String currentItem = stringfromlist(ic, list)
		variable cellPos  = strsearch(currentItem, "Cell", 0)//cell pos is literally the index where cell's c is in the string. will use that as reference point.

		//Basically, the last part of the for loop is extracting the cell number. Here's how we do it:
		//while next char is not ".", keep adding on to the number. It'll either be 1 or 2 digits long, but this will always work
		//ex, if it is Cell15.50pa, it will add 1, then 5, to string cellNum, so it is 15.
		variable i = 0
		String cellNum = ""
		do
			cellNum += currentItem[cellPos + 4 + i]
			i += 1
		while(!stringmatch(currentItem[cellPos + 4 + i], "."))
		InsertPoints numpnts(cellNumbers), 1, cellNumbers
		cellNumbers[numpnts(cellNumbers) - 1] = cellNum
	endfor

	//now call FICurve on a custom list of strings corresponding to wves whose names contain "Cell" + cellNames[i]
	for(ic = 0; ic < numpnts(cellNumbers); ic+=1)
		String wName = "Cell" + cellNumbers[ic]
		Make/O/D/N=0 $wName//for insertPoints
		
	endfor
	
end
Function FICurve(sublist, wName)
	String sublist
	wave wName
	//dont use wavelist here, its for current string
	variable ic, spikes, currentInjected, FI, numNeg = 5//bc -50 -40 -30 -20 -10
	String label
	//NEG
	for(ic = 0; ic < numNeg; ic+=1)
		wave current = $stringfromlist(ic, sublist)
		label = num2str((ic - 6) * 10)//bc for ic = 1, 1- 6 = -5 times 10 is -50, ic = 2 is -40 etc //DEPENDS ON CONSISTENT LABELING
		//FI is spikes over curr injected
		spikes = spontanalysis(current, findRMV(current))
		currentInjected = str2num(label)
		FI = spikes / currentInjected
		//Add to wave
		InsertPoints numpnts(wName) , 1, wName
		wName[numpnts(wName)] =FI
	endfor
	//POS
	variable numPos = 10 //bc 0 1 2 3 4 5 6  7 8 9
	for(ic = 0; ic < numPos; ic+=1)
		wave current = $stringfromlist(ic, sublist)
		label = num2str((ic) * 10)//bc for ic = 1, 1- 6 = -5 times 10 is -50, ic = 2 is -40 etc //DEPENDS ON CONSISTENT LABELING
		//FI is spikes over curr injected
		spikes = spontanalysis(current, findRMV(current))
		currentInjected = str2num(label)
		FI = spikes / currentInjected
		//Add to wave
		InsertPoints numpnts(wName) , 1, wName
		wName[numpnts(wName)] =FI
	endfor
end
//***************************************************************************************************************************
Function/D findSSV(w)
       wave w
       Make/O/D/N=1 output
       variable ic
	
	Make/O/D/N = (numpnts(w)) destWave
	Differentiate w /D=destWave//differentiates wave, now its 0 when its a peak, pos when incr, neg when dec
	Smooth 1, destwave//smoothed differentiated wave
	findLevels/DEST=leveledWave/M=(x2pnt(w, .010))/Q destWave 1
	variable leveledWaveCount = 0
	variable startTrial = x2pnt(w, 3)
	variable endTrial = x2pnt(w, 3.5)
	for(ic = startTrial; ic < endTrial; ic+=1)
		if(ic == leveledWave[leveledWaveCount])
			leveledWaveCount += 1//will go to check next value in leveledWave
			ic += 50//skip ahead by however much
		else
			InsertPoints numpnts(output), 1, output
			output[numpnts(output) - 1] = w[ic]
		endif
	endfor
       
       print mean(output)

end
//******************************************************************************************************************************

//*****************************************************************************************************************************
Function/D findRMV(w)
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
	return (RMPWave[numpnts(RMPWave) - 1] + RMPWave[0]) / 2
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
		//if (w[i]=<Threshold && w[i+1]>Threshold)
			SpikeCount=SpikeCount+1
			
			crossUpx=i	
		//endif
		
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
