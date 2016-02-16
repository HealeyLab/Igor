pragma rtGlobals=1		// Use modern global access method.
	
Menu "RS"
		"Run Analysis", AllWave()
End
	
Function AllWave()
	
	String SpontWave
	String cStepWave
	Variable level
	
	
	Make/O/N=(1,16) statsWave //goes in driver
	Make/O/T/N=(1,16) indexWave //goes in driver, will hold names of each wave and title of each column
	
		variable labels=1
		variable row = 0 // will go in driver, advance row for new wave 
		
		indexwave[0][0]= "Name of Wave"
		indexWave[0][labels]= "Spike Amplitude(mean)"
		labels+=1
		indexWave[0][labels]= "Spike Amplitude(stdev)"
		labels+=1
		indexWave[0][labels]= "Threshold"
		labels+=1
		indexWave[0][labels]= "Threshold(sdev)"
		labels+=1
		indexWave[0][labels]= "Spike Half-Width"
		labels+=1
		indexWave[0][labels]= "Spike Half-Width(sdev)"
		labels+=1
		indexWave[0][labels]= "AHP Amplitude"
		labels+=1
		indexWave[0][labels]= "AHP Amplitude(sdev)"
		labels+=1
		indexWave[0][labels]= "AHP duration"
		labels+=1
		indexWave[0][labels]= "AHP duration(sdev)"
		labels+=1
		indexWave[0][labels]= "RMP"
		labels+=1
		indexWave[0][labels]= "# spikes"
		labels+=1
		indexWave[0][labels]= "spike rate"
		labels+=1
		indexWave[0][labels]= "Interspike Interval (avg)"
		labels+=1
		indexWave[0][labels]= "Interspike Interval(sdev)"
		labels+=1
		
	
	
	
	Prompt Spontwave, "Enter string that only spont recordings contain"
	Prompt cStepWave, "Enter string that only current step recordings contain"
	Prompt level, "Spike detection amplitude (mV):"
	DoPrompt "Analyze", SpontWave, cStepWave, level
	
	if (V_flag)
	return -1
	Endif
	
	String spont = "*"+ SpontWave + "*"
	string cstep = "*" + cStepWave + "*"
	String SpontWaveList= WaveList(spont, "\r","")
	String cStepWaveList = WaveList(cstep, "\r","")

	Variable i = 0
	
	
	for (i=0; i<itemsinlist(Spontwavelist,"\r"); i+=1)
		row+=1
		insertpoints row, 1, indexWave
		
		Wave current= $StringfromList(i, SpontWaveList, "\r")
		indexWave[row][0]=nameofwave(current)
		spontspikeanalysis(current, -0.030)
		Insertpoints  (numpnts(statswave)-2),1, statsWave
		stats(current,row)
		
		
		endfor
		
	
	
	variable j = 0
	String cstepWaveName=""
	Do
		wave current = $StringfromList(j, cStepWaveList, "\r")
		//print cstepWaveName //sub in analysis program here .....cstepanalysis(cstepWaveName)
		j+=1
	While (strlen(StringFromList(j, cStepWavelist))!=0)
		
		
end	

Function Stats(w,row)

	Wave w
	Variable row
	Wave statswave=root:statswave
	
	Wave spikepeaks= root:spikepeaks
	Wave spimetimes= root:spiketimes
	Wave spikeamps =root:spikeamps
       Wave AHPtimes=root:AHPtimes
       Wave AHPpeaks= root:AHPpeaks
       Wave AHPamplitudes=root:AHPamplitudes
       Wave AHPendtimes=root:AHPendtimes
       Wave AHPdurations = root:AHPdurations
       Wave values = root:values
     
	statswave[0][]=NaN
	statswave[][0]=NaN

	Variable column = 1

	//spike amplitude (1)
	Wavestats/Q spikeamps
	statsWave[row][column]=V_avg
	column+=1
	statsWave[row][column]=V_sdev //(2)
	column+=1
	
	//spike threshold (3)
	Wavestats/Q  values
	statsWave[row][column]=V_avg
	column+=1
	statsWave[row][column]=V_sdev //(4)
	column+=1
	
	//half widths (5)
	
	
	Wavestats/Q  halfwidthpointsAllvalues
	statsWave[row][column]=V_avg
	column+=1
	statsWave[row][column]=V_sdev //(6)
	column+=1
	
	//AHP amplitude (7)
	Wavestats/Q AHPamplitudes
	statsWave[row][column]=V_avg 
	column+=1
	statsWave[row][column]=V_sdev  //(8)
	column+=1
	
	// AHP duration (9)
	Wavestats/Q AHPdurations
	statsWave[row][column]=V_avg
	column+=1
	statsWave[row][column]=V_sdev //(10)
	column+=1
	
	//RMP (11)
	Wavestats/Q RMPwave	
	statsWave[row][column]=V_avg
	column+=1
	
	// # spikes (12)
	statsWave[row][column]=numpnts(spikepeaks)
	column+=1
	
	// spike rate (13)
	variable waveduration
	variable lastpoint = numpnts(w)
	waveduration = pnt2x(w,lastpoint)
	statsWave[row][column]=(numpnts(spikepeaks))/waveduration
	column+=1
	
	//spike interval (14)
	
	Wavestats/Q spikeintervals
	statsWave[row][column]=V_avg
	column+=1
	statsWave[row][column]=V_sdev //(15)
	column+=1
	
End
