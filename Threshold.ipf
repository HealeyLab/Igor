
Function threshdetect(w)

	Wave w
	Differentiate w/D=diffWave
	Wave diffWave
	FindLevels/EDGE=1/M=.05/Q/DEST=diffWaveCrossWave diffWave 100
	
	End
