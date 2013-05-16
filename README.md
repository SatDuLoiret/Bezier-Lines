Constant 4 in Bezier cubic:
===========================
  Start & end points are A & D.
	Controls points B & C.
	Recurse Casteljau points E, F, G, H, I.
	Recurse résult M.
	Point O is center vector AD.
	
	At mid point of points of curve The OF/OM is constant = 4.
	
	Use this constant for calc controls points position, in drawnig editor, when user drag the line.
	
	The file Constant4.swf démonstrate this.
	In this editor you have possibility:
		- drag the 4 points A, B, C, D.
		- click select, Penner intermédiates points, for view recurse.
		- navigate in Penner points with keyboard arrows keys left & right
		- change number of segments in line whith slider Resol.
	Sorry for the bug of this slider, when you drag it, if you Mouse-up outside the container,
		the click on Penner points is not active. Resolve this by re-click to the slider.
		
	The file DrawCubic.swf is base drawning editor, the Constant4 is used.
	When the user click at any point of line, consider the clicked point is mid point of points M.
		calc the distance & angular position with this clicked point and the center point O.
		applic the constant4: Distance / 3 * 4.
		applic the result & angle at point A & D, for obtain the position of controls points B & C.
	With this editor, you start whith two points A & D and "droite" line.
	In this editor you have possibility:
		- Drag the two points before tranform.
		- Click & drag at any point of line, this tranform line in Bezier cubic.
		- Drag the 4 points A, B, C, D.
		- navigate in Penner intermédiates points with keyboard arrows keys.
		- Restart with button Init.
	The Coefficients of point B & C, is forever, is for edit, 
		when user drag any point of Bezier cubic line.
