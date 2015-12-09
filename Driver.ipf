#pragma rtGlobals=3		// Use modern global access method and strict wave access.
//Author: Dan Pollak
//10/30/15

Function driver_batch()// use of *_batch here will allow us to use preexisting code for running script on all waves in experiment file
	//for spont, do something like below for cSteps
	Make /O/D/N=(0, 0, 0) cStepCurves//dim=0: Cell number dim=1: FI dim=2: IV
	stepDataAnalysis(cStepCurves)//changes sStepData

end
//***************************************************************************************************************************
Function stepDataAnalysis(cStepCurves)
	wave cStepCurves
	//eventually, have it generate a wave per cell
	String list = WaveList("*Cell*pa*", "\r", "")//list of cells
	//get list of cell nums, for elem in each, call fi curve on sublist
	variable ic, listSize = itemsInList(list)
	Make/O/T=2/N=0 cellNumbers//ie, Cell1, Cell2, Cell3, etc
	
	for(ic = 0; ic < listSize; ic +=1)
		String currentItem = stringfromlist(ic, list, "\r")
		variable cellPos  = strsearch(currentItem, "Cell", 0)//cell pos is literally the index where cell's c is in the string. will use that as reference point.

		//Basically, the last part of the for loop is extracting the cell number. Here's how we do it:
		//while next char is not ".", keep adding on to the number. It'll either be 1 or 2 digits long, but this will always work
		//ex, if it is Cell15.50pa, it will add 1, then 5, to string cellNum, so it is 15.
		variable i = 0
		String cellNum = ""
		do
			cellNum += currentItem[cellPos + 4 + i] //cell is 4 letters long
			i += 1
		while(!stringmatch(currentItem[cellPos + 4 + i], "."))
		InsertPoints numpnts(cellNumbers), 1, cellNumbers
		cellNumbers[numpnts(cellNumbers) - 1] = cellNum
	endfor
	
	//now call FICurve on a custom list of strings corresponding to waves whose names contain "Cell" + cellNames[i]
	for(ic = 0; ic < numpnts(cellNumbers); ic+=1)
		String wName = "Cell" + cellNumbers[ic]
		variable jd
		String sublist = ""
		//making sublist 1; 2; 3
		
		for(jd = 0; jd < listSize; jd +=1)
			if(stringmatch(stringfromlist(jd, list, "\r"), "*" + wName + "*"))
				sublist += stringfromlist(jd, list) + "\r"
				
			endif
		endfor
		InsertPoints/M=0 numpnts(cStepCurves), 1, cStepCurves//adds to length of base wave
		Curves(sublist, cStepCurves)//now cStepFICurves is in data browser w data
	endfor
end

Function Curves(sublist, wName)//doesnt return anything, just adds values.
	String sublist
	wave wName
	//dont use wavelist here, its for current string
	variable ic, numNeg = 5//bc -50 -40 -30 -20 -10
	String label
	//NEG
	for(ic = 0; ic < numNeg; ic+=1)
		wave current = $stringfromlist(ic, sublist, "\r")
		label = num2str((ic - 5) * 10)//bc for ic = 1, 1- 6 = -5 times 10 is -50, ic = 2 is -40 etc //DEPENDS ON CONSISTENT 		InsertPoints M=1 numpnts(wName) , 1, wName
		InsertPoints/M=1 numpnts(wName), 1, wName
		InsertPoints/M=2 numpnts(wName), 1, wName
		wName[numpnts(wName) - 1][ic][] =FI(label, current)
		//wName[numpnts(wName) - 1][][ic] =IV(label, current)
	endfor
	//POS
	variable numPos = 10 //bc 0 1 2 3 4 5 6  7 8 9
	for(ic = 0; ic < numPos; ic+=1)
		wave current = $stringfromlist(ic + numNeg, sublist, "\r")
		label = num2str((ic) * 10)//bc for ic = 1, 1- 6 = -5 times 10 is -50, ic = 2 is -40 etc //DEPENDS ON CONSISTENT LABELING
		//InsertPoints M=0 numpnts(wName) , 1, wName
		InsertPoints/M=1 numpnts(wName), 1, wName
		InsertPoints/M=2 numpnts(wName), 1, wName
		wName[numpnts(wName) - 1][ic][] =FI(label, current)
		//wName[numpnts(wName) - 1][][ic] =IV(label, current)
	endfor
end

Function FI(label, current)
	String label
	wave current
	
	variable spikes, currentInjected, FI
	//find num spikes
	variable level = 0
	findLevels/DEST=levels/Q current, level
	
	spikes = numpnts(levels) / 2
	currentInjected = str2num(label)
	FI = spikes / currentInjected
	print "*********************\r" + nameofwave(current) + "- " + "\rFI: " + num2str(FI) + "\rspikes: " + num2str(spikes) + "\rcurrent injected: " + num2str(currentInjected) + "\rlevel: " + num2str(level)//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
	
	//Add to wave
	return FI
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
       
       return mean(output)

end
//**************************************************************
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
