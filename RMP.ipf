Function RMP(w)

	Wave w 
	
	Duplicate/O w,$"fitLine"
	Wave fitLine

	Curvefit/NTHR=0 line w /D=fitLine

End
