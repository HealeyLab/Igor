#pragma rtGlobals=3		// Use modern global access method and strict wave access.
//Author: Dan Pollak
//1/4/2016
	
Menu "Curves"
	"Run cStep Analysis", driver_batch()
	"Display Firing Rates", DisplayFR()
	"Ooh, Killem", Killem()
end
Function DisplayFR()
	String sublist = WaveList("*Cell*" + "*pa*", "\r", "")//includes all cells b/c of the *pa*
	print "sublist:\r" +  sublist
	variable ic
	for(ic = 10; ic < 13; ic+=1) //itemsInList(sublist, "\r")
		String name = StringFromList(ic, sublist, "\r")
		variable currInj = mod(ic, 15)*10 - 50
		variable spikes = FI(num2str(currInj), $name)
		variable FR = spikes/.5 //the mod gets us the current injected based on place in list
		Display/K=1/N=name $name
		TextBox/N=ic/A=LB "Firing rate:" + num2str(FR) + "Hz\rSpikes: " + num2str(spikes)
	endfor
	if(StringMatch(sublist, ""))
		print "no waves found"
	endif
end
Function Killem()
	String sublist = WaveList("*Cell*" + "*pa*", "\r", "")//includes all cells b/c of the *pa*
	variable ic
	for(ic = 0; ic<ItemsInList(sublist, "\r"); ic += 1)
		String curr = ("root:'" + StringFromList(ic, sublist, "\r") + "'")//StringFromList(ic, sublist, "\r")
		KillWindow $curr
	endfor
end
Function driver_batch()// use of *_batch here will allow us to use preexisting code for running script on all waves in experiment file
	//for spont, do something like below for stepDataAnalysis()
	Make /D /O /N=(0,15, 1) IVCurves//dim=0: Cell number	 dim=1: IV	 dim=2: .r
	Make /D /O /N=(0,15, 1) FICurves//dim=0: Cell number	 dim=1: FI	 dim=2: .r
	
	variable NUMBER_OF_TRIALS, numOfCells
	String nameOfExperiment
	Prompt numOfCells "Enter number of cells"
	Prompt NUMBER_OF_TRIALS "Enter number of trials"
	Prompt nameOfExperiment "Enter the date this experiment was undertaken (for exporting purporses)"
	DoPrompt "Cells, trials, name of experiment", numOfCells, NUMBER_OF_TRIALS, nameOfExperiment
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
			stepDataAnalysis(IVCurves, FICurves, expNumber, numOfCells) // ,.r2, .r3
		else
			//don't add to third dimension first time, that's been taken care of
			stepDataAnalysis(IVCurves, FICurves, "", numOfCells)//since it is not.r1, its just blank 
		endif
		
	endfor
	print "***********************&&&&&&\r\tIV DIM 0: " + num2str(DimSize(IVCurves, 0)) + "\tFI DIM 0: " + num2str(DimSize(FICurves, 0))
	print "IV DIM 1: " + num2str(DimSize(IVCurves, 1)) + "\t\tFI DIM 1: " + num2str(DimSize(FICurves, 1))
	print "IV DIM 2: " + num2str(DimSize(IVCurves, 2)) + "\t\tFI DIM 2: " + num2str(DimSize(FICurves, 2))

	NewPath/O export_to_matlab "C:Users:danieljonathan:Desktop:Healey data pipeline (finished product):igor_ibws" 
	Save/C/O/P=export_to_matlab FICurves as nameOfExperiment + "FICurves.ibw"
	Save/C/O/P=export_to_matlab IVCurves as nameOfExperiment + "IVCurves.ibw"
	//NewPath/O export_to_matlab "C:Users:danieljonathan:Desktop:Healey:analyzed_files"
	//for(i = 0; i < numOfCells; i+=1)
	//	DisplayCurves(IVCurves, i,1)
	//	DisplayCurves(FICurves, i,2)
	//endfor
end
//***************************************************************************************************************************
Function stepDataAnalysis(IVCurves, FICurves, expNumber, numOfCells)
	wave FICurves
	wave IVCurves
	String expNumber//either "" or ".r\#"
	variable numOfCells
	variable ic
		
	//now call Curves on a custom list of strings corresponding to waves whose names contain "Cell" + 1, 2, ...num Of cells
	for(ic = 0; ic < numOfCells; ic+=1)
		String sublist = WaveList("*Cell" + num2str(ic + 1) + "*pa" + expNumber, "\r", "")//cells per .r
		//at this point, sublist is the lis tof cells with the same .r and the same Cell#, so it should just be 15 long. But it's not.
		print "print sublist *********************************" + num2str(ic + 1) + "\r" +  sublist + "print sublist*****************************************"
		InsertPoints/M=0 DimSize(IVCurves, 0), 1, IVCurves
		InsertPoints/M=0 DimSize(FICurves, 0), 1, FICurves
		if(!StringMatch(sublist, ""))
		Curves(sublist, IVCurves, FICurves, ic)
		endif
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
		if(WaveExists($stringfromlist(i, sublist, "\r")))
			wave current = $stringfromlist(i, sublist, "\r")
			label = num2str((i - 5) * 10)//bc for i = 1, 1- 6 = -5 times 10 is -50, i = 2 is -40 etc //DEPENDS ON CONSISTENT LABELING
			IVc[cellNum][i][DimSize(IVc, 2) - 1] = findSSV(current)//IV(label, current)
			FIc[cellNum][i][DimSize(FIc, 2) - 1] = FI(label, current)
			//print nameofwave(current) + " curr"
		endif
	endfor
	//POS
	variable numPos = 10 //bc 0 1 2 3 4 5 6  7 8 9
	for(i = 0; i < numPos; i+=1)
		if(WaveExists($stringfromlist(i + numNeg, sublist, "\r")))//in case it doesn't go up as far as you'd guess
			wave current = $stringfromlist(i + numNeg, sublist, "\r")
			label = num2str((i) * 10)//bc for i = 1, 1- 6 = -5 times 10 is -50, i = 2 is -40 etc //DEPENDS ON CONSISTENT LABELING
			IVc[cellNum][i + numNeg][DimSize(IVc, 2) - 1] = findSSV(current)//IV(label, current)
			FIc[cellNum][i + numNeg][DimSize(FIc, 2) - 1] = FI(label, current)//use label to take the decimal it returns and turn it back into the constituent parts
		//print nameofwave(current) + " curr"
		endif
	endfor
end

//to change colors for .r values, see the ModifyGraph for colors*
Function DisplayCurves(curves, cellNum, type)// we are overlaying all .rs , rValue)//rValue = , .r2, .r3, .r4
	wave curves
	variable cellNum
	variable type	
	//Graphing each cell now
	Make/O xWave ={-50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50, 60, 70, 80, 90}
	Make/U/O/N=15 yWave//spikes
	variable i
	variable rValue
	for(rValue = 0; rValue < DimSize(curves, 2); rValue += 1)
		for(i = 0; i < 15; i+=1)
		//3d wave to one
			yWave[i] = curves[cellNum - 1][i][rValue]
		endfor
		//overlay all r values
		String name
		//NewPath thisPath "C:Users:danieljonathan:Desktop:Healey:analyzed_files"
		//IV
		if(type == 1)
			name =  "Cell_" + num2str(cellNum) + "_IV_Curve"
			Display/K=1/N=$name
			AppendToGraph/C=(mod(rValue * 9973, 65535), mod(rValue * 9973, 65535), mod(rValue * 9973, 65535))/W=$name xWave vs yWave 
			Label left "Current_Injected_(pA)" 
			Label bottom "Voltage_(mV\u#2)" 
			//SavePICT/O/SNAP=2/E=-5/P=thisPath as name//SaveGraphCopy/O/W=$name/P=thisPath as name//SavePICT/O/SNAP=1/E=-5/P=$"C:Users:danieljonathan:Desktop:Healey:analyzed_files" as name
			variable yes
			Prompt yes "continue?"
			DoPrompt "input info"
//			KillFreeAxis left
//			KillFreeAxis bottom
			KillWindow $name
			
		
		//FI
		elseif(type == 2)
			name = "Cell_" + num2str(cellNum) + "_FI_Curve"
			Display/K=1/N=$name
//			the whole thing with the prime number and the mod is that
//			it will not repeat colors for a long time and it won't overrun everything you feel?
			variable current = (i - 5) * 10
			AppendToGraph/C=(mod(i * 9973, 65535), mod(i * 9973, 65535), mod(i * 9973, 65535))/W=$name yWave vs xWave
			Label left "Spikes" 
			Label bottom "Current_Injected (pA\u#2)" 
			//SavePICT/O/SNAP=1/E=-5/P=thisPath as name//SaveGraphCopy/O/W=$name/P=thisPath as name//
			variable yep
			Prompt yep "continue?"
			DoPrompt "input info"
			KillFreeAxis left
			//KillFreeAxis bottom
			KillWindow $name

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
	//print "NUMEVOKED" + num2str(numEvoked)
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
		//print interval
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
