//source material, is deposit: https://raw.github.com/raphaelluchini/Bezier-Samples/master/Bezier_01.as
/*** ... * @author Raphael Luchini - relooked by SatDuLoiret.
 * 
 * sorry, but your ForNext Raphael, it contain two invisibles mistakes: 
 *     ForNext start to 0 = recalc start point, ForNext use decimals exotics values in Flash.
 *     experiment this line: for( var index:Number =0; index <1; index +=0.1) trace( index); this line display 11 values !  with 4 exotics values.
 *     your ForNext recalc end point */

package {
	//import greensock.TweenLite;import greensock.easing.Linear;
	import flash.display.DisplayObject;
	import flash.display.MovieClip; import flash.display.Shape; import flash.events.MouseEvent; import flash.geom.Point; import flash.display.Sprite; import flash.events.Event;
	import flash.media.Sound;
	import flash.text.TextField; import flash.text.TextFieldAutoSize; import flash.text.TextFormat; import flash.text.TextFormatAlign; import flash.events.KeyboardEvent; 
	import Sat.control.Box; import Sat.control.BoxRacerRoundII; import Sat.control.EntryBoxRacer; import Sat.control.BoxRacerList; import Sat.graphic.GraphPoint; 
	import Sat.control.Pickers.SliderPicker; import Sat.Output; import Sat.control.Renders.RenderSound;
	[SWF(width = 1800, height = 950, frameRate = 15, backgroundColor = 0x444444)]

	public class Constant4 extends MovieClip {
//class contants
		private const AM:Number =180/Math.PI; 		//converse radians to degree.
		private const MA:Number = Math.PI / 180; 	//converse degree to radians.
//class vars----------------------------------------------------------------------------------------------------------------------------------
		private var OutputSize:Number = 150;			//senocular trace height
		private var stageWidthUtil:Number = stage.stageWidth, stageHeightUtil:Number = stage.stageHeight - ( OutputSize +20);
		private var pA:MovieClip, pB:MovieClip, pC:MovieClip, pD:MovieClip;												//bases & controls points
		private var ax:Number, bx:Number, cx:Number, ay:Number, by:Number, cy:Number;						//intermediates calc, for recurse Points 
		private var resol:Number = 30;																										// fix init résolution
	//board Penner Points
		private var boardPenner:BoxRacerList;													
		private var pennerPoints:Array = new Array();																											//points on Bezier line
		private var pennerNames:Array = new Array();																											//Penner points name, for boardPenner
		private var pennerString:Array = new Array();																											//Penner points values to String, for boardPenner
		private var pennerGraphic:Array = new Array();																											//Penner points graphic are GraphPoint.
	//board Casteljau récurse
		private var boardCasteljau:BoxRacerList;
		private var tanAB:Number, tanBC:Number, tanCD:Number, tanAD:Number, tanEF:Number, tanFG:Number;											// angular tangeante at points A, B, D,  . . .  in radians 
		private var casteljauItems:Array = new Array("len AB", "len BC", "len DC", "angl AB", "angl BC", "angl CD", "Point","E", "F", "G", "H", "I");
		private var casteljauValues:Array, currentIndex:int, ISrecurse:Boolean = false;
		private var lenAB:Number, lenBC:Number, lenDC:Number, lenAD:Number, lenEF:Number, lenFG:Number, lenHI:Number;						// distances, in absolute value
		private var lenOM:Number, lenOF:Number, lenMF:Number;
		private var pE:Point, pF:Point, pG:Point, pH:Point, pI:Point;																													// recurse points values
		private var lineEF:Shape = new Shape(), lineFG:Shape = new Shape(), lineHI:Shape = new Shape;
		private var pEG:RecursePoint, pFG:RecursePoint, pGG:RecursePoint, pHG:RecursePoint, pIG:RecursePoint, pMG:RecursePoint;				// recurse point graphic are GraphPoint
	//board Parameters Values
		private var boardParams:BoxRacerList;
		private var paramsItems:Array = new Array("A", "B", "C", "D", "point a'", "point b'", "point c'");						//params items names
		private var pSA:String, pSB:String, pSC:String, pSD:String, pSa:String, pSb:String, pSc:String;						//params values String
		private var paramsValues:Array = new Array();																									//Array params values String 
		private var  boxTyp:BoxTypes = new BoxTypes();
		private var reqResol:SliderPicker;
		//private var letras:Vector.<Letra> = new Vector.<Letra>(30);
		//private var texto:String = "Lorem ipsum dolor sit posuere.", 
	//lines
		private var BezierLine:Shape = new Shape(), lineAB:Shape = new Shape(), lineDC:Shape = new Shape, lineBC:Shape = new Shape;
		private var pCentre:MovingPoint;
	//states
		private var ISmDown:Boolean, objMoving:MovieClip;
		private var inc:Number, index:int;
	//sound
		//unable to sampling rate 8000Hz / 12000Hz  !
		//[Embed(source="mysound.mp3")]		
		//private var soundClass:Class; 	
		private var theSound:RenderSound = new RenderSound( 50, 50, "mysound.mp3",  true, true);
		
//class func--------------------------------------------------------------------------------------------------------------------------------------------		
		function Constant4() {
			addChild( new Output( OutputSize, "senocular trace"));
			Réticule(0, 0, stage.stageWidth, stage.stageHeight - OutputSize, 100, 0x66cc33, 0xff7c80, 0.3);
//base points
			pA = new GraphPoint("A", "R", 10, 0x333333, 0x666699, 0x999999, "B"); pD = new GraphPoint("D", "R", 10, 0x333333, 0x666699, 0x999999, "B"); pA.Draw(); pD.Draw();
//control points
			pB = new GraphPoint("B", "C", 10, 0x333333, 0xff0000, 0xff0000, "T");  pC = new GraphPoint("C", "C", 10, 0x333333, 0xff0000, 0xff0000, "T"); pB.Draw(); pC.Draw();
			pCentre = new MovingPoint("O"); pCentre.x = 850; pCentre.y = 700; pCentre.visible = true;
//position points  + init + Draw
			pA.x = 400; pA.y = 400; pB.x = 600; pB.y = 100; pC.x = 1300; pC.y = 100; pD.x = 1500; pD.y = 700; 
			pennerPointsCubic(); 
//board Penner Points			
			newboardPenner();
//board Casteljau recurse
			boardCasteljau = new BoxRacerList("Casteljau", "recurse", 160, 100, casteljauItems, casteljauValues, 60, 120); 
			boardCasteljau.x = (stageWidthUtil - boardCasteljau.width); boardCasteljau.y = 0; addChild( boardCasteljau);
			pEG = new RecursePoint("E"); pEG.visible = false;  pFG = new RecursePoint("F"); pFG.visible = false; 
			pGG = new RecursePoint("G"); pGG.visible = false;  pHG = new RecursePoint("H"); pHG.visible = false;
			pIG = new RecursePoint("I"); pIG.visible = false;  pMG = new RecursePoint("M"); pMG.visible = false; 
//board Parameters.Values
			boardParams = new BoxRacerList("Parameters", "Values", 160, 100, paramsItems, paramsValues, 60, 120); 
			boardParams.x = (stageWidthUtil - boardParams.width); boardParams.y = boardCasteljau.height; 
			reqResol = new SliderPicker( "Resol", 180, 5, 30, resol, boxTyp.BOX_ROUNDRECT, 0xFFFFFF); boardParams.addObject( reqResol, new Point(120, 205));
			reqResol.addEventListener("Update", onReqResol); addChild( boardParams);
//add objects in child order.
			 addChild( lineAB); addChild( lineDC); addChild( lineBC); addChild( pA); addChild( pD); addChild( pB); addChild( pC); addChild(pCentre); addChild( BezierLine);
			 addChild( pEG); addChild( pFG); addChild( pGG); addChild( pHG); addChild(pIG); addChild( pMG); addChild( lineEF); addChild( lineFG); addChild( lineHI);
//add graphic Penner Points
			addGraphicsPennerPoints()
//listeners controls points, stage
			pA.buttonMode = true; pA.addEventListener(MouseEvent.MOUSE_DOWN, mDown); pB.buttonMode = true; pB.addEventListener(MouseEvent.MOUSE_DOWN, mDown); 
			pC.buttonMode = true; pC.addEventListener(MouseEvent.MOUSE_DOWN, mDown);	pD.buttonMode = true; pD.addEventListener(MouseEvent.MOUSE_DOWN, mDown); 	
			stage.addEventListener(MouseEvent.MOUSE_UP, mUP); stage.addEventListener(MouseEvent.MOUSE_MOVE, mMove); 
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownListener);
			ViewRecurse("Pn15");
//sound
			addObject( theSound, new Point( 0, 700));
		}
			
//services Events-------------------------------------------------------------------------------------------------------------------------------------------------------				
		private function mMove(evt:MouseEvent):void { if (ISmDown) { 
			pennerPointsCubic(); boardParams.newValues( paramsValues); boardPenner.newValues( pennerString); boardCasteljau.newValues( casteljauValues);
			pEG.visible = false; pFG.visible = false; pGG.visible = false; pHG.visible = false; pIG.visible = false; pMG.visible = false;
			for (index = 0; index < pennerGraphic.length; index ++ ) { pennerGraphic[index].x = pennerPoints[index].x; pennerGraphic[index].y = pennerPoints[index].y; }
			if(ISrecurse) ViewRecurse( pennerNames[currentIndex]);}}					

		private function mDown(evt:MouseEvent):void { objMoving = evt.currentTarget as MovieClip; evt.currentTarget.startDrag(); ISmDown = true;}		

		private function mUP(evt:MouseEvent):void { if ( objMoving) objMoving.stopDrag(); ISmDown = false; }

		private function onReqResol(evt:Event):void { 
			//ISrecurse = false; pEG.visible = false; pFG.visible = false; pGG.visible = false; pHG.visible = false; pIG.visible = false; pMG.visible = false;
			removeGraphicsPennerPoints(); resol = Math.floor(reqResol.Tick /2) *2; pennerPointsCubic(); removeChild( boardPenner); newboardPenner(); addGraphicsPennerPoints();
			ViewRecurse(pennerNames[ (resol/2) -1]); }
		
		private function onPenner(evt:MouseEvent):void { ViewRecurse(evt.target.name); }
		
		private function keyDownListener (event:KeyboardEvent):void {
			//Output.trace("Key Pressed: " +   " (key code: " + event.keyCode + " character code: " + event.charCode + ")");	
			if ( ISrecurse) { switch( event.keyCode) {
				case 37: if( currentIndex >0) ViewRecurse( pennerNames[currentIndex -1]);break;
				case 39: ; if ( currentIndex < ( pennerNames.length -1)) ViewRecurse( pennerNames[currentIndex +1]); break; }}}
		
//services---------------------------------------------------------------------------------------------------------------------------------------------------------------	
		private function addGraphicsPennerPoints():void {
			for ( index = 0; index < pennerPoints.length; index ++) { 
				var p:PennerPoint = new PennerPoint( pennerNames[index]); p.x = pennerPoints[index].x; p.y = pennerPoints[index].y; p.buttonMode = true; 
				pennerGraphic.push(p); addChild(p); p.addEventListener(MouseEvent.MOUSE_DOWN, onPenner); }}
		
		private function removeGraphicsPennerPoints():void {
			var p:PennerPoint; for ( index = 0; index < pennerGraphic.length; index ++) { p = pennerGraphic[index]; removeChild( p); p.removeEventListener( MouseEvent.MOUSE_DOWN, onPenner); }
			pennerGraphic = new Array();}
				
		private function ViewRecurse( Name:String):void {	
			var pointST:Number, pointBase:Point, pointDest:Point, valueT:Number, valueS:Number, delta:Point; 
	//search Point index with name
			for ( index = 0; index < pennerNames.length; index ++) if ( pennerNames[index] == Name) break; currentIndex = index ; valueT = inc * (index +1); valueS = 1-valueT
				//preCalc for multi use
			var S2:Number = Math.pow(valueS, 2), S3:Number = Math.pow(valueS, 3), T2:Number = Math.pow(valueT, 2), T3:Number = Math.pow(valueT, 3);
			var valueT3S2:Number = 3 * valueT * S2; 		//somme des contributions qui constitue le coefficient du point B
			var valueS3T2:Number = 3 * valueS * T2;		//coefficient du point C
				//calcul avec formule version analytique
			var Mx:Number = (S3 * pA.x) + ( valueT3S2 * pB.x) + ( valueS3T2 * pC.x) + (T3 * pD.x);
			var My:Number = (S3 * pA.y) + ( valueT3S2 * pB.y) + ( valueS3T2 * pC.y) + (T3 * pD.y);
			Output.clear(); 
			Output.trace( "Coefficient Point B is ( 3 s² t):  " + roundToPrecision(valueT3S2, 2) + "    Point C is ( 3 s t²):  " + roundToPrecision(valueS3T2, 2));
			Output.trace();
			Output.trace( "With analytic formula ( M = s^3 A + 3 s^2 tB + 3s t^2 C + t^3 D):   Point " + Name + "  M: " + pointStr( new Point(Mx, My)));
				//calcul inverse des positions inconnues de B & C, mission impossible !
			//var Bx:Number = (Mx - ( (S3 * pA.x) + ( valueS3T2 * pC.x) + (T3 * pD.x))) / valueT3S2;		//oui mais pC est inconnu !
			//var By:Number = (My - ( (S3 * pA.y) + ( valueS3T2 * pC.y) + (T3 * pD.y))) / valueT3S2;		//oui mais valueS3T2 = valueT3S2 et pour pn15( s = t = 0.5) (S3T2 = T3S2 = 0.38)
			
	//compute recurse points
			pointST = lenAB * valueT; pointBase = new Point( pA.x, pA.y); pE = pointBase.add( Point.polar(pointST, tanAB)); 				//point E = tA + sB
			pointST = lenBC * valueT; pointBase = new Point( pB.x, pB.y); pF = pointBase.add( Point.polar( pointST, tanBC));					//point F = tB + sC
			pointST = lenDC * valueT; pointBase = new Point( pC.x, pC.y); pG = pointBase.add( Point.polar( pointST, tanCD));				//point G = tC + sD
			delta = pF.subtract( pE); lenEF = Point.distance( pF, pE); tanEF = Math.atan2( delta.y, delta.x); pointST = lenEF * valueT; pH = pE.add( Point.polar( pointST, tanEF));	//point H = tE + sF		
			delta = pG.subtract( pF); lenFG = Point.distance( pG, pF); tanFG = Math.atan2( delta.y, delta.x); pointST = lenFG * valueT; pI = pF.add( Point.polar( pointST, tanFG));	//point I = tF + sG
			//lenHI = Point.distance( pH, pI); Output.trace( "Distance HI:" + roundToPrecision(lenHI,2));
	//recurse points graphic
			pEG.x = pE.x; pEG.y = pE.y; pEG.visible = true; pFG.x = pF.x; pFG.y = pF.y; pFG.visible = true; pGG.x = pG.x; pGG.y = pG.y; pGG.visible = true;
			pHG.x = pH.x; pHG.y = pH.y; pHG.visible = true; pIG.x = pI.x; pIG.y = pI.y; pIG.visible = true;
			pMG.x = pennerPoints[index].x; pMG.y =  pennerPoints[index].y; pMG.visible = true;														//point M = tH + sI
	//recurse lines graphic		
			with(lineEF.graphics) { clear(); lineStyle( 1, 0xffff00); moveTo( pE.x, pE.y); lineTo( pF.x, pF.y); }
			with(lineFG.graphics) { clear(); lineStyle( 1, 0xffff00); moveTo( pF.x, pF.y); lineTo( pG.x, pG.y); }
			with(lineHI.graphics) { clear(); lineStyle( 1, 0xffff00); moveTo( pH.x, pH.y); lineTo( pI.x, pI.y); }
	//board Casteljau recurse
			casteljauValues = new Array( Math.round(lenAB), Math.round(lenBC), Math.round(lenDC), Math.round(tanAB * AM), Math.round(tanBC * AM), Math.round(tanCD * AM), Name,
														pointStr(pE), pointStr(pF), pointStr(pG), pointStr(pH), pointStr(pI)) ; boardCasteljau.newValues( casteljauValues);
	//trace distance Center O to points M & F
			pointBase = new Point(pCentre.x, pCentre.y); Output.trace();
			lenOF = Point.distance( pointBase, pF); 
			lenOM = Point.distance( pointBase, new Point(pMG.x, pMG.y)); 
			lenMF = Point.distance( new Point(pMG.x, pMG.y), pF);
			Output.trace("Center point O: " + pointStr( pointBase) + "     Distances:    OM: " + roundToPrecision(lenOM, 2) + "   OF: " + roundToPrecision(lenOF, 2)
			+ "    MF: " + roundToPrecision(lenMF, 2) + "    OF/MF: " + roundToPrecision( lenOF / lenMF, 2)  ); Output.trace();
			Output.trace("At midle point of points of curve, the factor: (OF/MF) is constant, is = 4");
			ISrecurse = true; }
				
		private function newboardPenner():void {
			var item:String; pennerNames = new Array; for ( index = 0; index < pennerPoints.length; index ++) { item = "Pn" + (index +1); pennerNames.push(item); }
			boardPenner = new BoxRacerList("Penner", "Points", 200, 100, pennerNames, pennerString, 50, 110); boardPenner.x = boardPenner.y = 0; addChildAt( boardPenner, 0); }
		
		//private function getDegree( add:Boolean = false):void {
		//	for (var i:int = 0; i < points.length; i++) { if (i < points.length - 1){
		//			var p:Point = points[i], pPost:Point = points[i + 1], radians:Number = Math.atan2(p.y - pPost.y, p.x - pPost.x), degrees:Number = (radians / Math.PI) * 180;
		//			if(add) addChild( drawPoint(p, degrees, i)); else pennerPointsCubicLetters(p, degrees, i)}}}
		//private function pennerPointsCubicLetters(p:Point, num:int, i:int) { letras[i].x = p.x; letras[i].y = p.y; letras[i].rotation = num + 180;}
			
		private function reDraw():void {
			//var group:String; //forever is AS3 code for graphic editor.
			var p:Point, pointBase:Point, pointDest:Point; pennerString = new Array(); 
	//lines to controls points
			with(lineAB.graphics) { clear(); lineStyle( 1, 0xff0000); moveTo( pA.x, pA.y); lineTo( pB.x, pB.y); }
			with(lineDC.graphics) { clear(); lineStyle( 1, 0xff0000); moveTo( pD.x, pD.y); lineTo( pC.x, pC.y); }
			with(lineBC.graphics) { clear(); lineStyle( 1, 0xff0000); moveTo( pB.x, pB.y); lineTo( pC.x, pC.y); }
	//center Point
			pointBase = new Point(pA.x, pA.y); pointDest = new Point(pD.x, pD.y); delta = pointDest.subtract( pointBase); lenAD = Point.distance( pointDest, pointBase); tanAD = Math.atan2( delta.y, delta.x); 
			pointDest = pointBase.add( Point.polar( lenAD / 2 , tanAD)); pCentre.x = pointDest.x; pCentre.y = pointDest.y;
	//Bezier line
			with(BezierLine.graphics) { clear(); lineStyle( 2, 0xffffff); moveTo(pA.x, pA.y);}
			//group = "    moveTo( " + pA.x + ", " + pA.y + "); "; 
			for ( index = 0; index < pennerPoints.length; index ++) { 
				p = pennerPoints[index]; 
				BezierLine.graphics.lineTo( p.x, p.y); 
				pennerString.push( pointStr( new Point(p.x, p.y)));}
				//group += "lineTo( " + Math.round( p.x) + ", " + Math.round( p.y) + "); "; } 
			BezierLine.graphics.lineTo(pD.x, pD.y); 
				//group += "lineTo( " + pD.x + ", " + pD.y + ");"; 
	//board "Parameters Values" convert points value to String.
			pSA = pointStr( new Point( pA.x, pA.y)); pSB = pointStr( new Point( pB.x, pB.y)); pSC = pointStr( new Point( pC.x, pC.y)); pSD = pointStr( new Point( pD.x, pD.y));
			pSa = pointStr( new Point( ax, ay)); pSb = pointStr( new Point( bx, by)); pSc = pointStr( new Point( cx, cy)); 
			paramsValues = new Array( pSA, pSB, pSC, pSD, pSa, pSb, pSc); 
	//board Casteljau recurse
			var start:Point, end:Point, delta:Point;
			start = new Point(pA.x, pA.y); end = new Point(pB.x, pB.y); delta = end.subtract( start); lenAB = Point.distance( end, start); tanAB = Math.atan2( delta.y, delta.x); 
			start = new Point(pB.x, pB.y); end = new Point(pC.x, pC.y); delta = end.subtract( start); lenBC = Point.distance( end, start); tanBC = Math.atan2( delta.y, delta.x); 
			start = new Point(pC.x, pC.y); end = new Point(pD.x, pD.y); delta = end.subtract( start); lenDC = Point.distance( end, start); tanCD = Math.atan2( delta.y, delta.x);	
			casteljauValues = new Array( Math.round(lenAB), Math.round(lenBC), Math.round(lenDC), Math.round(tanAB * AM), Math.round(tanBC * AM), Math.round(tanCD * AM), "--","--","--","--","--","--");
			lineEF.graphics.clear(); lineFG.graphics.clear(); lineHI.graphics.clear(); 
	//trace
			//Output.clear(); 
			//Output.trace("Graphic : " ); Output.trace( group); Output.trace();
			}

//-------------------------------------------------- Cubic Bezier spline ( polynome degree 3) --------------------------------------------------------------------
//général formula is :	M(t) = ( 1-t)^3 PA   +    3 t(1-t)^2 PB    +    3 t^2 ( 1-t) PC    +     t^3 PD
		private function pennerPointsCubic():void {
			var U:Number =0;
			pennerPoints = new Array(); inc = 1 / resol;
			cx = 3 * (pB.x - pA.x); 		bx = 3 * (pC.x - pB.x) - cx;		ax = pD.x - pA.x - cx - bx;			
			cy = 3 * (pB.y - pA.y);	 	by = 3 * (pC.y - pB.y) - cy;	 	ay = pD.y - pA.y - cy - by;			
			for ( index = 1 ; index < resol; index ++) {
				var M:Point = new Point(); U = U + inc;
				M.x = (ax * Math.pow(U, 3)) + (bx * Math.pow( U, 2)) + cx * U + pA.x; 
				M.y = (ay * Math.pow( U, 3)) + (by * Math.pow( U, 2)) + cy * U + pA.y; pennerPoints.push( M); } 
			reDraw(); }		
//----------------------------------------------------- Quadratic Bezier spline ( polynome degree 2)---------------------------------------------------------------
		// Returns the point on a bezier curve for a given time (t is 0-1).
		// http://ibiblio.org/e-notes/Splines/Bezier.htm.This is based on Robert Penner's Math.pointOnCurve() function.
		// More information: http://actionscript-toolbox.com/samplemx_pathguide.php
		private function pennerPointQuadratic( pointStart:Point, pointControl:Point, pointEnd:Point, t:Number):Point {				
				var s:Number = 1 - t; return new Point( 
				pointStart.x     +     t * (2 * s * (pointControl.x - pointStart.x)     +     t * (pointEnd.x - pointStart.x)), 
				pointStart.y     +     t * (2 * s * (pointControl.y - pointStart.y)     +     t * (pointEnd.y - pointStart.y))); }		

		//github.com/ArthurWulfWhite/Bezier.as	
		private function BezierGetPoint( pointStart:Point, pointControl:Point, pointEnd:Point, t:Number):Point {
			var s:Number = 1 - t; return new Point(
				s * ((s * pointStart.x) + (t * pointControl.x)) + t * ((s * pointControl.x) + (t * pointEnd.x)), 
				s * ((s * pointStart.y) + (t * pointControl.y)) + t * ((s * pointControl.y + t * pointEnd.y))); }
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------
		//private function drawPoint(p:Point, num:int, i:int):Letra {
		//	var tf:Letra = new Letra(); tf.x = p.x; tf.y = p.y; tf.txt.autoSize = TextFieldAutoSize.CENTER; tf.txt.text = texto.charAt(i); tf.rotation = num + 180; letras[i] = tf;
			/*var sprite:Shape = new Shape(); sprite.graphics.beginFill(0x000000 ); sprite.graphics.drawRect(-2.5,-2.5,5,5); sprite.x = p.x; sprite.y = p.y; sprite.rotation = num;*/
		//	return tf; } */
			
//library base-------------------------------------------------------------------------------------------------------------------------------------------------------------------
		private function roundToPrecision( num:Number, precision:int = 0):Number { var decimalPlaces:Number = Math.pow(10, precision); return (Math.round(decimalPlaces * num) / decimalPlaces); }
		private function pointStr( point:Point):String { var ret:String = "x="; ret += Math.round(point.x) + ", y=" + Math.round( point.y); return ret; }
		private function addObject( obj:DisplayObject, pos:Point, ScaleX:Number = 1, ScaleY:Number = 1):void { PositionPoint( obj, pos); Scaled( obj, ScaleX, ScaleY); addChild( obj); }
		private function Scaled( obj:DisplayObject, ScaleX:Number, ScaleY:Number):void { obj.scaleX = ScaleX; obj.scaleY = ScaleY; }
		public function PositionPoint( obj:DisplayObject, point:Point):void { obj.x = point.x; obj.y = point.y;} 
		private function Réticule( minX:Number, minY:Number, maxX:Number, maxY:Number, pas:Number, color1:Number, color2:Number, alpha:Number = 0.3):void {
			var demiPas:Number = pas / 2, Hor:Number, Vert:Number;
			graphics.lineStyle(1, color2, alpha);																														// lignes secondaires
			for(Hor = demiPas; Hor < maxX; Hor += pas){ graphics.moveTo(Hor, minY); graphics.lineTo(Hor, maxY); }					// V
			for (Vert = demiPas; Vert < maxY; Vert += pas) { graphics.moveTo(minX, Vert); graphics.lineTo(maxX, Vert); }				// H
			graphics.lineStyle(2, color1, alpha);																														// lignes principales
			for(Hor = pas; Hor < maxX; Hor += pas){ graphics.moveTo(Hor, minY); graphics.lineTo(Hor, maxY); }							// V
			for (Vert = pas; Vert < maxY; Vert += pas) { graphics.moveTo(minX, Vert); graphics.lineTo(maxX, Vert); }}					// H	
	}//
}//
import flash.geom.Point; import Sat.graphic.GraphPoint; import flash.display.MovieClip;
class PennerPoint extends MovieClip { 
	public var skin:GraphPoint;
	public function PennerPoint(Name:String = "PN") { skin = new GraphPoint( Name, "C", 4, 0xff0000, 0xff0000, 0xff0000, null); skin.Draw(); addChild( skin); }}
	
import flash.geom.Point; import Sat.graphic.GraphPoint; import flash.display.MovieClip;
class RecursePoint extends MovieClip { 
	public var skin:GraphPoint;
	public function RecursePoint(Name:String = "RP") { skin = new GraphPoint( Name, "C", 3, 0xffff00, 0xffff00, 0xffff00, "T"); skin.Draw(); addChild( skin); }}	
	
import flash.geom.Point; import Sat.graphic.GraphPoint; import flash.display.MovieClip;
class MovingPoint extends MovieClip { 
	public var skin:GraphPoint;
	public function MovingPoint(Name:String = "RP") { skin = new GraphPoint( Name, "C", 3, 0x00ff00, 0x00ff00, 0x00ff00, "B"); skin.Draw(); addChild( skin); visible = false; }}

//import Sat.control.Box;
class BoxTypes {	public const BOX_RECT:int = 0,BOX_ROUNDRECT:int = 1, BOX_KULER:int = 2;	//format
							public const BOX_NONE:int = 0, BOX_FILET:int = 1, BOX_BORDER:int = 2; }  		//border		
