#pragma rtGlobals=3		// Use modern global access method and strict wave access.
//Author: Dan Pollak
//1/4/2016

Function driver_batch()// use of *_batch here will allow us to use preexisting code for running script on all waves in experiment file
	//for spont, do something like below for stepDataAnalysis()
	Make /D /O /N=(0,15, 1) IVCurves//dim=0: Cell number dim=1: IV dim=2: .r
	Make /D /O /N=(0,15, 1) FICurves//dim=0: Cell number dim=1: FI dim=2: .r
	variable NUMBER_OF_TRIALS = getTrials()
	variable i
	String expNumber
	print "IV DIM 0: " + num2str(DimSize(IVCurves, 0)) + "\t\tFI DIM 0: " + num2str(DimSize(FICurves, 0))
	print "IV DIM 1: " + num2str(DimSize(IVCurves, 1)) + "\t\tFI DIM 1: " + num2str(DimSize(FICurves, 1))
	print "IV DIM 2: " + num2str(DimSize(IVCurves, 2)) + "\t\tFI DIM 2: " + num2str(DimSize(FICurves, 2))
	
	for(i = 1; i <= NUMBER_OF_TRIALS; i+=1)
		expNumber = ".r" + num2str(i)
		//The reason I insert points in all but the first is that Igor has a weird thing where it can't 
		//work in a dimension for which /N=0. So I had to put in a "hook" for Igor to latch onto.
		if(i != 1)
			//add layer to IV and FI Curves
			InsertPoints/M=2 DimSize(IVCurves, 2), 1, IVCurves
			InsertPoints/M=2 DimSize(FICurves, 2), 1, FICurves
			stepDataAnalysis(IVCurves, FICurves, expNumber) // ,.r2, .r3
		else
			//don't add to third dimension first time, that's been taken care of
			stepDataAnalysis(IVCurves, FICurves, "")//since it is not.r1, its just blank 
		endif
	endfor
	print "***********************&&&&&&\r\tIV DIM 0: " + num2str(DimSize(IVCurves, 0)) + "\tFI DIM 0: " + num2str(DimSize(FICurves, 0))
	print "IV DIM 1: " + num2str(DimSize(IVCurves, 1)) + "\t\tFI DIM 1: " + num2str(DimSize(FICurves, 1))
	print "IV DIM 2: " + num2str(DimSize(IVCurves, 2)) + "\t\tFI DIM 2: " + num2str(DimSize(FICurves, 2))
	//for DisplayCurves, 1 = IV, 2=FI
	DisplayCurves(IVCurves, 1, 1)//input the .r and cell #'s as position not index, will be translated to index in function.
	DisplayCurves(FICurves, 1, 2);
end
//***************************************************************************************************************************
Function getTrials()
	String list = WaveList("*Cell*.r*", "\r", "")
	variable lSize = itemsInList(list)
	variable i
	String curr
	variable temp = 1
	variable max = temp
	for(i = 0; i < lSize; i+=1)
		curr = stringfromlist(i, list, "\r")
		temp = str2num(curr[strsearch(curr, ".r", 0) + 1, strlen(curr) - 1])//from the one after .r to the end, so it can be 
																//as long as it needs to be in the double digits
		if(temp > max)
			max = temp
		endif
	endfor
	return max
end
Function stepDataAnalysis(IVCurves, FICurves, expNumber)
	wave FICurves
	wave IVCurves
	String expNumber
	//eventually, have it generate a wave per cell
	String list = WaveList("*Cell*pa" + expNumber, "\r", "")//list of cells, includes .r2, .r3...
	//get list of cell nums, for elem in each, call fi curve on sublist
	variable ic, listSize = itemsInList(list)
	Make /O /T=2 /N=0 cellNumbers	//ie, Cell1, Cell2, Cell3, etc

	for(ic = 0; ic < listSize; ic +=1)
		String currentItem = stringfromlist(ic, list, "\r")
		variable cellPos  = strsearch(currentItem, "Cell", 0)	//cellPos is literally the index where cell's c is in the string. will use that as reference point.

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
	
	//now call Curves on a custom list of strings corresponding to waves whose names contain "Cell" + cellNames[i]
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
		//add to cell Number
		InsertPoints/M=0 DimSize(IVCurves, 0), 1, IVCurves
		InsertPoints/M=0 DimSize(FICurves, 0), 1, FICurves
		Curves(sublist, IVCurves, FICurves, ic)
	endfor
end

Function Curves(sublist, IVc, FIc, cellNum)//doesnt return anything, just adds values.
	String sublist
	wave IVc
	wave FIc	
	variable cellNum
	//dont use wavelist here, its for current string
	variable i, numNeg = 5//bc -50 -40 -30 -20 -10
	String label//currentInjected = label
	//NEG
	for(i = 0; i < numNeg; i+=1)
		wave current = $stringfromlist(i, sublist, "\r")
		label = num2str((i - 5) * 10)//bc for i = 1, 1- 6 = -5 times 10 is -50, i = 2 is -40 etc //DEPENDS ON CONSISTENT LABELING
		IVc[cellNum][i][DimSize(IVc, 2) - 1] = findSSV(current)//IV(label, current)
		FIc[cellNum][i][DimSize(FIc, 2) - 1] = FI(label, current)
	endfor
	//POS
	variable numPos = 10 //bc 0 1 2 3 4 5 6  7 8 9
	for(i = 0; i < numPos; i+=1)
		wave current = $stringfromlist(i + numNeg, sublist, "\r")
		label = num2str((i) * 10)//bc for i = 1, 1- 6 = -5 times 10 is -50, i = 2 is -40 etc //DEPENDS ON CONSISTENT LABELING
		IVc[cellNum][i + numNeg][DimSize(IVc, 2) - 1] = findSSV(current)//IV(label, current)
		FIc[cellNum][i + numNeg][DimSize(FIc, 2) - 1] = FI(label, current)//use label to take the decimal it returns and turn it back into the constituent parts
	endfor
end
//to change colors for .r values, see the ModifyGraph for colors*

Function DisplayCurves(curves, cellNum, type)// we are overlaying all .rs , rValue)//rValue = , .r2, .r3, .r4
	wave curves
	variable cellNum
	variable type
	//first, close all other graphs
	
	//Graphing each cell now
	Make/O xWave ={-50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50, 60, 70, 80, 90}
	Make/U/O/N=15 yWave//spikes
	variable i
	variable rValue
	for(rValue = 0; rValue < DimSize(curves, 2); rValue += 1)
		for(i = 0; i < 15; i+=1)
			
			yWave[i] = curves[cellNum - 1][i][rValue]//*current
		endfor
		//overlay all r values
		String name
		if(type == 1)
			name =  "Cell_" + num2str(cellNum) + "_IV_Curve"
			Display/K=1/N=$name
			AppendToGraph/C=(mod(rValue * 9973, 65535), mod(rValue * 9973, 65535), mod(rValue * 9973, 65535))/W=$name xWave vs yWave 
			Label left "Current_Injected_(pA)"
			Label bottom "Voltage_(mV\u#2)"
		elseif(type == 2)
			name = "Cell_" + num2str(cellNum) + "_FI_Curve"
			Display/K=1/N=$name
//			the whole thing with the prime number and the mod is that
//			it will not repeat colors for a long time and it won't overrun everything you feel?
			variable current = (i - 5) * 10
			yWave = yWave * current
			AppendToGraph/C=(mod(i * 9973, 65535), mod(i * 9973, 65535), mod(i * 9973, 65535))/W=$name yWave vs xWave
			Label left "Spikes"
			Label bottom "Current_Injected (pA\u#2)"

		else
			print "This type of analysis (wave) not supported." 
		endif
	endfor
end

//spikes/current
Function/D FI(label, current)
	String label
	wave current
	
	variable spikes, currentInjected, FI
	
	variable level = 0 //threshold for spike detection
	
	//evoked peak detection
	findLevels/R=(3,3.5)/DEST=levels/Q/M=.001 current, level
	
	variable numEvoked= numpnts(levels)/2
	print "NUMEVOKED" + num2str(numEvoked)
	Make /O/D/N=(numEvoked) evokedPeaks
	Make /O/D/N=(numEvoked) evokedPeakTimes
	
	variable evokedPeak
	variable evokedPeakTime
	
	variable i
	variable pos=0
	
	for (i=0;i<numpnts(levels) - 1;i+=2)
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
	
	
	//print ("*********************\r" + nameofwave(current) + "- " + "\rFI: " + num2str(FI) + "\rspikes: " + num2str(spikes) )
	//print ("current injected: " + num2str(currentInjected))
	
	//Add to wave
	return spikes //CHANGED FI FUNCTION TO RETURN SPIKES NOT FI**
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
	//OVERLAY THE POINTS FOUNDHERE OVER
	//THE ORIGINAL w WAVE TO SEE HOW WELL IT PICKS OUT POINTS
	Make/O/D/N = (numpnts(w)) destWave
	Differentiate w /D=destWave//differentiates wave, now its 0 when its a peak, pos when incr, neg when dec
	Smooth 1, destwave//smoothed differentiated wave
	findLevels/DEST=leveledWave/M=(x2pnt(w, .010))/Q destWave 1//MAKE THIS STD DEV
	variable leveledWaveCount = 0
	variable startTrial = x2pnt(w, 3)
	variable endTrial = x2pnt(w, 3.5)
	for(i = startTrial; i < endTrial; i+=1)
		if(i == leveledWave[leveledWaveCount])
			leveledWaveCount += 1//will go to check next value in leveledWave
			i += 50//MAKE DYNAMIC
		else
			InsertPoints numpnts(output), 1, output
			output[numpnts(output) - 1] = w[i]
		endif
	endfor
       
       return mean(output)

end
//**************************************************************
