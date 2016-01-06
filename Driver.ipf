#pragma rtGlobals=3		// Use modern global access method and strict wave access.
//Author: Dan Pollak
//12/23/2015

Function driver_batch()// use of *_batch here will allow us to use preexisting code for running script on all waves in experiment file
	//for spont, do something like below for stepDataAnalysis()
	Make /O/D/N=(0, 0, 0)/N=0/WAVE cStepCurves//dim=0: Cell number dim=1: FI dim=2: IV
	stepDataAnalysis(cStepCurves)//changes sStepData
	DisplayCurves(cStepCurves)
end
//***************************************************************************************************************************

Function stepDataAnalysis(cStepCurves)
	wave cStepCurves
	//eventually, have it generate a wave per cell
	String list = WaveList("*Cell*pa*", "\r", "")//list of cells, includes .r2, .r3...
	//get list of cell nums, for elem in each, call fi curve on sublist
	variable ic, listSize = itemsInList(list)
	Make/O/T=2/N=0 cellNumbers//ie, Cell1, Cell2, Cell3, etc
	
	for(ic = 0; ic < listSize; ic +=1)
		String currentItem = stringfromlist(ic, list, "\r")
		variable cellPos  = strsearch(currentItem, "Cell", 0)//cellPos is literally the index where cell's c is in the string. will use that as reference point.

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
		String wName = "Cell" + cellNumbers[ic]//This is the umpteenth cell patched onto in the experiment
		variable jd//just a counter
		String sublist = ""//will add on to this the names of filenames of this particular umteenth cell
		//making sublist 1; 2; 3
		
		for(jd = 0; jd < listSize; jd +=1)
			if(stringmatch(stringfromlist(jd, list, "\r"), "*" + wName + "*"))
				sublist += stringfromlist(jd, list) + "\r"
				
			endif
		endfor
		//^^^^^^^^^^^^^^^^^^^^^
		InsertPoints/M=0 numpnts(cStepCurves), 1, cStepCurves//adds to length of base wave
		Curves(sublist, cStepCurves)//now cStepFICurves is in data browser w data
	endfor
	
end

Function Curves(sublist, wName)//doesnt return anything, just adds values.
	String sublist
	wave wName//wName<-cStepCurves
	//dont use wavelist here, its for current string
	variable i, numNeg = 5//bc -50 -40 -30 -20 -10
	String label
	//NEG
	for(i = 0; i < numNeg; i+=1)
		wave current = $stringfromlist(i, sublist, "\r")
		label = num2str((i - 5) * 10)//bc for i = 1, 1- 6 = -5 times 10 is -50, i = 2 is -40 etc //DEPENDS ON CONSISTENT 		InsertPoints M=1 numpnts(wName) , 1, wName
		//^^^^^^^^^^^^^^^^^^^^^^^^^
		InsertPoints/M=1 DimSize(wName, 1), 1, wName
		//^^^^^^^^^^^^^^^^^^^^^^^^^
		InsertPoints/M=2 DimSize(wName, 2), 1, wName
		wName[DimSize(wName, 0) - 1][i][0]=FI(label, current)//adds an FI value to the FI branch of this cell			currentInjected = label
		wName[DimSize(wName, 0) - 1][0][i]=IV(label, current)
	endfor
	//POS
	variable numPos = 10 //bc 0 1 2 3 4 5 6  7 8 9
	for(i = 0; i < numPos; i+=1)
		wave current = $stringfromlist(i + numNeg, sublist, "\r")
		label = num2str((i) * 10)//bc for i = 1, 1- 6 = -5 times 10 is -50, i = 2 is -40 etc //DEPENDS ON CONSISTENT LABELING
		//^^^^^^^^^^^^^^^^^^^^^^^^^
		InsertPoints/M=1 DimSize(wName, 1), 1, wName
		//^^^^^^^^^^^^^^^^^^^^^^^^^
		InsertPoints/M=2 DimSize(wName, 2), 1, wName
		wName[DimSize(wName, 0) - 1][i + numNeg][0] =FI(label, current)//i + numNeg b/c thats how we do.
		wName[DimSize(wName, 0) - 1][0][i + numNeg] =IV(label, current)
		//use label to take the decimal it returns and turn it back into the constituent parts
	endfor
	
	
end
Function DisplayCurves(cStepCurves)
	wave cStepCurves
	//Graphing each cell now
	Make xWave ={-5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
	variable i
	for(i = 0; i < DimSize(cStepCurves, 0) - 1; i+=1)
		variable electricCurrent = i - 5
		String bottom = "Current Injected"
		String left = "Spikes"
		String name = "Cell " + num2str(i) + " FI Curve"
		Make/N=15 yWave
		Display/B=bottom/L=left/K=1/N=name cStepCurves[i][0][] vs xWave//FI//(cStepCurves[i][0][] * electricCurrent) vs xWave
	endfor
	
end

//spikes/current
Function/D FI(label, current)
	String label
	wave current
	
	variable spikes, currentInjected, FI
	
	variable level = 0 //threshold for spike detection
	
	//evoked peak detection
	findLevels/R=(3,3.5)/DEST=levels/Q current, level
	
	variable numEvoked= numpnts(levels)/2
	
	Make /O/D/N=(numEvoked) evokedPeaks
	Make /O/D/N=(numEvoked) evokedPeakTimes
	
	variable evokedPeak
	variable evokedPeakTime
	
	variable i
	variable pos=0
	
	for (i=0;i<numpnts(levels);i+=2)
		Variable xUp=levels[i]
		Variable xDown=levels[i+1]
		Wavestats/Q/R=(xUp,xDown) current
		evokedPeak = V_max
		evokedPeakTime= V_maxloc
		evokedPeaks[pos]=evokedpeak
		evokedPeakTimes[pos]=evokedPeakTime
		pos+=1
	endfor
	

	spikes = numpnts(evokedPeaks)
	currentInjected = str2num(label)
	FI = spikes / currentInjected

	//interspike intervals
	
	Make /O/D/N=(numpnts(evokedPeakTimes)-1) evokedISI
	variable k
	variable n=0
	
	for (k=0;k<numpnts(evokedPeakTimes)-1;k+=1)
		variable interval
		interval= evokedPeakTimes[k+1]-evokedPeakTimes[k]
		print interval
		endfor	
	
	
	print ("*********************\r" + nameofwave(current) + "- " + "\rFI: " + num2str(FI) + "\rspikes: " + num2str(spikes) )
	print ("current injected: " + num2str(currentInjected))
	
	//Add to wave
	return FI
end
//current/volts
Function/D IV(label, current)
	String label
	wave current //current cell, not I.
	//voltage (x) versus current (y), iv is current over voltage
	variable electricalCurrent = str2num(label)
	variable IV 
	variable voltage = findSSV(current);//voltage is the steady state voltage
	IV = electricalCurrent / voltage
	return IV
end
//***************************************************************************************************************************
Function/D findSSV(w)
       wave w
       Make/O/D/N=1 output
       variable i
	
	Make/O/D/N = (numpnts(w)) destWave
	Differentiate w /D=destWave//differentiates wave, now its 0 when its a peak, pos when incr, neg when dec
	Smooth 1, destwave//smoothed differentiated wave
	findLevels/DEST=leveledWave/M=(x2pnt(w, .010))/Q destWave 1
	variable leveledWaveCount = 0
	variable startTrial = x2pnt(w, 3)
	variable endTrial = x2pnt(w, 3.5)
	for(i = startTrial; i < endTrial; i+=1)
		if(i == leveledWave[leveledWaveCount])
			leveledWaveCount += 1//will go to check next value in leveledWave
			i += 50//skip ahead by however much
		else
			InsertPoints numpnts(output), 1, output
			output[numpnts(output) - 1] = w[i]
		endif
	endfor
       
       return mean(output)

end
//**************************************************************
