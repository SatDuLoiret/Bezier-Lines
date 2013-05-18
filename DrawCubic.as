package {
	import flash.display.MovieClip; import flash.display.Shape; import flash.events.MouseEvent; import flash.geom.Point; import flash.display.Sprite; import flash.events.Event;
	import flash.text.TextField; import flash.text.TextFieldAutoSize; import flash.text.TextFormat; import flash.text.TextFormatAlign; import flash.events.KeyboardEvent; 
	import Sat.control.Box; import Sat.control.BoxRacerRoundII; import Sat.control.EntryBoxRacer; import Sat.control.BoxRacerList; import Sat.graphic.GraphPoint; 
	import Sat.control.BoxGradient; import Sat.Output;
	[SWF(width = 1800, height = 950, frameRate = 15, backgroundColor = 0x444444)]

	public class DrawCubic extends MovieClip {
//class contants
		private const AM:Number =180/Math.PI; //conversion radians vers degrés.
		private const MA:Number = Math.PI / 180; //conversion degrés vers radians.
//class vars----------------------------------------------------------------------------------------------------------------------------------
		private var OutputSize:Number = 150;
		private var stageWidthUtil:Number = stage.stageWidth, stageHeightUtil:Number = stage.stageHeight - ( OutputSize +20);
		private var pA:MovieClip, pB:MovieClip, pC:MovieClip, pD:MovieClip;														//bases & controls points
		private var ax:Number, bx:Number, cx:Number, ay:Number, by:Number, cy:Number;								//intermediates calc
		private var resol:Number = 30;																												// fix init résolution
	//board Penner Points
		private var boardPenner:BoxRacerList;													
		private var pennerPoints:Array;																												//points on Bezier line
		private var pennerNames:Array;																											//Penner points name, for boardPenner
		private var pennerString:Array;																											//Penner points values to String, for boardPenner
	//board Casteljau récurse
		private var boardCasteljau:BoxRacerList;
		private var angleAB:Number, angleBC:Number, angleCD:Number, angleEF:Number, angleAD:Number,angleFG:Number;	// angular tangeante at points A, B, D,  . . .  in radians 
		private var casteljauItems:Array = new Array("len AB", "len BC", "len DC", "angl AB", "angl BC", "angl CD", "Point","E", "F", "G", "H", "I");
		private var casteljauValues:Array; 
		private var currentIndex:int = 15;
		private var lenAB:Number, lenBC:Number, lenDC:Number, lenAD:Number, lenEF:Number, lenFG:Number, lenHI:Number;						// distances, in absolute value
		private var pE:Point, pF:Point, pG:Point, pH:Point, pI:Point;																													// recurse points values
		private var lineEF:Shape = new Shape(), lineFG:Shape = new Shape(), lineHI:Shape = new Shape;															// recurse lines
	// construct lines & points
		private var lenOF:Number, lenOM:Number, lenMF:Number,angleOM:Number;
		private var lineOF:Shape = new Shape(), lineOM:Shape = new Shape();																									
		private var pV:MovingPoint, pO:MovingPoint;
	// recurse point graphic are GraphPoint
		private var pEG:RecursePoint = new RecursePoint("E"), pFG:RecursePoint = new RecursePoint("F"), pGG:RecursePoint = new RecursePoint("G");
		private var pHG:RecursePoint = new RecursePoint("H"), pIG:RecursePoint = new RecursePoint("I"), pMG:RecursePoint = new RecursePoint("M");			
	//board Parameters Values
		private var boardParams:BoxRacerList;
		private var paramsItems:Array = new Array("A", "B", "C", "D", "O", "len AD", "angl AD");									//params items names
		private var pSA:String, pSB:String, pSC:String, pSD:String, pSO:String;															//params values String
		private var paramsValues:Array = new Array();																									//Array params values String 
		private var  boxTyp:BoxTypes = new BoxTypes();
	//lines
		private var BezierLine:Sprite = new Sprite(), Spline:Sprite = new Sprite(), lineAB:Shape = new Shape(), lineDC:Shape = new Shape, lineBC:Shape = new Shape;
	//init button
		private var reqInit:BoxGradient = new BoxGradient("Init");
	//states
		private var ISbCubic:Boolean= false, ISbDown:Boolean, bMoving:MovieClip;
		private var ISmDown:Boolean, objMoving:MovieClip;
		private var inc:Number, index:int, pointBase:Point, pointDest:Point, delta:Point =new Point();
		
//class func--------------------------------------------------------------------------------------------------------------------------------------------		
		function DrawCubic() {
			addChild( new Output( OutputSize, "senocular trace"));
			Réticule(0, 0, stage.stageWidth, stage.stageHeight - OutputSize, 100, 0x66cc33, 0xff7c80, 0.3);
//base points
			pA = new GraphPoint("A", "R", 8, 0x333333, 0x666699, 0x999999, "B"); pA.Draw(); pD = new GraphPoint("D", "R", 8, 0x333333, 0x666699, 0x999999, "B");  pD.Draw();
//control points
			pB = new GraphPoint("B", "C", 8, 0x333333, 0xff0000, 0xff0000, "T"); pB.Draw(); pC = new GraphPoint("C", "C", 8, 0x333333, 0xff0000, 0xff0000, "T"); pC.Draw(); 
			pV = new MovingPoint("M"); pO = new MovingPoint("O"); pB.visible = pC.visible = false; pV.visible = pO.visible = true;
//position points  + init + Draw
			reInit();
//board Penner Points			
			boardPenner = new BoxRacerList("Penner", "Points", 200, 100, pennerNames, pennerString, 50, 110); boardPenner.x = boardPenner.y = 0; addChildAt( boardPenner, 0); 
//board Casteljau recurse
			boardCasteljau = new BoxRacerList("Casteljau", "recurse", 160, 100, casteljauItems, casteljauValues, 60, 120); 
			boardCasteljau.x = (stageWidthUtil - boardCasteljau.width); boardCasteljau.y = 0; addChild( boardCasteljau);
//board parameters
			boardParams = new BoxRacerList("Parameters", "Values", 160, 100, paramsItems, paramsValues, 60, 120); 
			boardParams.x = (stageWidthUtil - boardParams.width); boardParams.y = boardCasteljau.height; addChild( boardParams);
//Init button
			reqInit.x = 1600; reqInit.y = 700; addChild( reqInit); reqInit.addEventListener(MouseEvent.MOUSE_DOWN, onInit);
//add objects in child order.
			addChild( lineEF); addChild( lineFG); addChild( lineHI); addChild( pEG); addChild( pFG); addChild( pGG); addChild( pHG); addChild(pIG); addChild( pMG);
			addChild( lineAB); addChild( lineDC); addChild( lineBC); addChild( pA); addChild( pD); addChild( pB); addChild( pC); addChild( pO); addChild( BezierLine); addChild( pV); addChild( lineOF);
//listeners controls points, stage
			pA.buttonMode = true; pA.addEventListener(MouseEvent.MOUSE_DOWN, mDown); pD.buttonMode = true; pD.addEventListener(MouseEvent.MOUSE_DOWN, mDown); 	
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownListener);}
			
		private function reInit():void {
			pB.visible = pC.visible = pV.visible =  lineAB.visible = lineDC.visible = lineBC.visible = ISbCubic = false; 
			pEG.visible = pFG.visible = pGG.visible = pHG.visible = pIG.visible = pMG.visible = lineEF.visible = lineFG.visible = lineHI.visible = false ;
			pA.x = pB.x = 500; pA.y = pB.y = 400; pC.x = pD.x = 1200; pC.y = pD.y = 400; 
			newboardPenner(); 
		//board Parameters.Values
			pSA = pointStr( new Point(pA.x, pA.y)); pSB = "--"; pSC = "--"; pSD = pointStr( new Point(pD.x, pD.y)); 
		//board Casteljau
			casteljauValues = new Array("--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--");
		//center Point pO
			pointBase = new Point(pA.x, pA.y); pointDest = new Point(pD.x, pD.y); delta = pointDest.subtract( pointBase); 
			lenAD = Point.distance( pointDest, pointBase); angleAD = Math.atan2( delta.y, delta.x); 
			pointDest = pointBase.add( Point.polar( lenAD / 2 , angleAD)); pO.x = pointDest.x; pO.y = pointDest.y; pSO = pointStr( pointDest);			
			paramsValues = new Array( pSA, pSB, pSC, pSD, pSO, Math.round(lenAD), Math.round( angleAD * AM));
		//draw Bezier line
			with (BezierLine.graphics) { clear(); lineStyle( 4, 0xffffff); moveTo(pA.x, pA.y); lineTo(pD.x, pD.y);} BezierLine.name = "BezierLine";
			BezierLine.addEventListener(MouseEvent.MOUSE_DOWN, bDown); BezierLine.buttonMode = true;}
			
//services Events-------------------------------------------------------------------------------------------------------------------------------------------------------	
		private function onInit(evt:MouseEvent):void {
			reInit(); boardPenner.newValues( pennerString); boardCasteljau.newValues ( casteljauValues); boardParams.newValues( paramsValues);
		}
		private function bDown(evt:MouseEvent):void {
			pV.x = evt.stageX; pV.y = evt.stageY; pV.visible = true; 
			pV.startDrag(); stage.addEventListener(MouseEvent.MOUSE_MOVE, bMove); stage.addEventListener(MouseEvent.MOUSE_UP, bUP);}
		
		private function bMove(evt:MouseEvent):void { 
				if ( !ISbCubic) { 
					pB.visible = pC.visible = pV.visible =  lineAB.visible = lineDC.visible = lineBC.visible = ISbCubic = true; 
					pEG.visible = pFG.visible = pGG.visible = pHG.visible = pIG.visible = lineEF.visible = lineFG.visible = lineHI.visible = true ;}
				pointBase = new Point( pO.x, pO.y); pointDest = new Point( pV.x, pV.y);																															//calc distance OM & angle OM
				delta = pointDest.subtract( pointBase); lenOM = Point.distance( pointDest, pointBase); angleOM = Math.atan2( delta.y, delta.x);
				lenOF = lenOM + (lenOM / 3);																																													//calc distance OF with constant 4
				pointBase = new Point( pA.x, pA.y); pointDest = pointBase.add( Point.polar(lenOF, angleOM)); pB.x = pointDest.x; pB.y = pointDest.y;								//point B & C with constant 4
				pointBase = new Point( pD.x, pD.y); pointDest = pointBase.add( Point.polar(lenOF, angleOM)); pC.x = pointDest.x; pC.y = pointDest.y; ABCDlineDraw(); 
				pennerPointsCubic(); boardParams.newValues( paramsValues); boardPenner.newValues( pennerString); ViewRecurse( pennerNames[(resol/2) -1]); }			//point B & C
				
		private function bUP(evt:MouseEvent):void {
			pV.visible = false; pV.stopDrag(); 
			if ( ISbCubic) { boardCasteljau.newValues( casteljauValues);
			pB.buttonMode = pC.buttonMode = true; pB.addEventListener(MouseEvent.MOUSE_DOWN, mDown); pC.addEventListener(MouseEvent.MOUSE_DOWN, mDown);	
			BezierLine.removeEventListener(MouseEvent.MOUSE_DOWN, bDown); BezierLine.buttonMode = false;}
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, bMove); stage.removeEventListener(MouseEvent.MOUSE_UP, bUP); }
				
		private function mDown(evt:MouseEvent):void { 
			objMoving = evt.currentTarget as MovieClip; 
			evt.currentTarget.startDrag(); stage.addEventListener(MouseEvent.MOUSE_MOVE, mMove); stage.addEventListener(MouseEvent.MOUSE_UP, mUP); }		

		private function mMove(evt:MouseEvent):void { 
			if ( ISbCubic) { pennerPointsCubic(); boardParams.newValues( paramsValues); boardPenner.newValues( pennerString); ViewRecurse( pennerNames[currentIndex]); }	reDraw();}																																			

		private function mUP(evt:MouseEvent):void { objMoving.stopDrag(); stage.removeEventListener(MouseEvent.MOUSE_MOVE, mMove); stage.removeEventListener(MouseEvent.MOUSE_UP, mUP); }
		
		private function keyDownListener (event:KeyboardEvent):void {
			switch( event.keyCode) {
				case 37: if( currentIndex >0) ViewRecurse( pennerNames[currentIndex -1]);break;
				case 39: ; if ( currentIndex < ( pennerNames.length -1)) ViewRecurse( pennerNames[currentIndex +1]); break; }}
		
//services---------------------------------------------------------------------------------------------------------------------------------------------------------------	
		private function ABCDlineDraw():void {
			with(lineAB.graphics) { clear(); lineStyle( 2, 0xff0000); moveTo( pA.x, pA.y); lineTo( pB.x, pB.y); }
			with(lineDC.graphics) { clear(); lineStyle( 2, 0xff0000); moveTo( pD.x, pD.y); lineTo( pC.x, pC.y); }
			with(lineBC.graphics) { clear(); lineStyle( 2, 0xff0000); moveTo( pB.x, pB.y); lineTo( pC.x, pC.y); }}
				
		private function ViewRecurse( Name:String):void {	
			var pointST:Number, pointBase:Point, valueS:Number, valueT:Number, delta:Point; 
	//compute Point index with name
			for ( index = 0; index < pennerNames.length; index ++) if ( pennerNames[index] == Name) break; currentIndex = index ; valueS = inc * (index +1); valueT = 1 -valueS;
				//preCalc for multi use
			var S2:Number = Math.pow(valueS, 2), S3:Number = Math.pow(valueS, 3), T2:Number = Math.pow(valueT, 2), T3:Number = Math.pow(valueT, 3);
			var valueT3S2:Number = 3 * valueT * S2; 		//somme des contributions qui constitue le coefficient du point B
			var valueS3T2:Number = 3 * valueS * T2;		//coefficient du point C
			Output.clear(); 
			Output.trace( "Coefficient Point B is ( 3 s² t):  " + roundToPrecision(valueT3S2, 2) + "    Point C is ( 3 s t²):  " + roundToPrecision(valueS3T2, 2));
	//compute recurse points
			pointST = lenAB * valueS; pointBase = new Point( pA.x, pA.y); pE = pointBase.add( Point.polar(pointST, angleAB)); 																					//point E = sA + tB
			pointST = lenBC * valueS; pointBase = new Point( pB.x, pB.y); pF = pointBase.add( Point.polar( pointST, angleBC));																						//point F = sB + tC
			pointST = lenDC * valueS; pointBase = new Point( pC.x, pC.y); pG = pointBase.add( Point.polar( pointST, angleCD));																						//point G = sC + tD
			delta = pF.subtract( pE); lenEF = Point.distance( pF, pE); angleEF = Math.atan2( delta.y, delta.x); pointST = lenEF * valueS; pH = pE.add( Point.polar( pointST, angleEF));	//point H = sE + tF		
			delta = pG.subtract( pF); lenFG = Point.distance( pG, pF); angleFG = Math.atan2( delta.y, delta.x); pointST = lenFG * valueS; pI = pF.add( Point.polar( pointST, angleFG));	//point I = sF + tG
	//recurse points graphic
			pEG.x = pE.x; pEG.y = pE.y; pFG.x = pF.x; pFG.y = pF.y; pGG.x = pG.x; pGG.y = pG.y; pHG.x = pH.x; pHG.y = pH.y; pIG.x = pI.x; pIG.y = pI.y;
			pMG.x = pennerPoints[index].x; pMG.y =  pennerPoints[index].y; pMG.visible = true;																																	//point M = sH + tI
	//recurse lines graphic		
			with(lineEF.graphics) { clear(); lineStyle( 1, 0xffff00); moveTo( pE.x, pE.y); lineTo( pF.x, pF.y); }
			with(lineFG.graphics) { clear(); lineStyle( 1, 0xffff00); moveTo( pF.x, pF.y); lineTo( pG.x, pG.y); }
			with(lineHI.graphics) { clear(); lineStyle( 1, 0xffff00); moveTo( pH.x, pH.y); lineTo( pI.x, pI.y); }
	//board Casteljau recurse
			casteljauValues = new Array( Math.round(lenAB), Math.round(lenBC), Math.round(lenDC), Math.round(angleAB * AM), Math.round(angleBC * AM), Math.round(angleCD * AM), Name,
														pointStr(pE), pointStr(pF), pointStr(pG), pointStr(pH), pointStr(pI)) ; boardCasteljau.newValues( casteljauValues);
	//trace constant4 & distances Center O to points M & F
			pointBase = new Point(pO.x, pO.y); Output.trace(); lenOF = Point.distance( pointBase, pF); lenOM = Point.distance( pointBase, new Point(pMG.x, pMG.y)); 
			lenMF = Point.distance( new Point(pMG.x, pMG.y), pF);
			Output.trace("Distances:    OM: " + roundToPrecision(lenOM, 2) + "   OF: " + roundToPrecision(lenOF, 2)
			+ "    MF: " + roundToPrecision(lenMF, 2) + "    OF/MF: " + roundToPrecision( lenOF / lenMF, 2)  ); Output.trace();
			Output.trace("At midle point of points of curve, the factor: (OF/MF) is constant, is = 4");}
				
		private function newboardPenner():void {
			var item:String; pennerNames = new Array; pennerString = new Array();
			for ( index = 0; index < resol -1; index ++) { item = "Pn" + (index +1); pennerNames.push(item); item = "--"; pennerString.push(item); }}
		
		private function reDraw():void {
			var p:Point = new Point();  pennerString = new Array(); 
	//lines to controls points
			if (ISbCubic) { 
				with(lineAB.graphics){ clear(); lineStyle( 1, 0xff0000); moveTo( pA.x, pA.y); lineTo( pB.x, pB.y); }
				with(lineDC.graphics){ clear(); lineStyle( 1, 0xff0000); moveTo( pD.x, pD.y); lineTo( pC.x, pC.y); }
				with(lineBC.graphics){ clear(); lineStyle( 1, 0xff0000); moveTo( pB.x, pB.y); lineTo( pC.x, pC.y); }}
	//center Point pO
			pointBase = new Point(pA.x, pA.y); pointDest = new Point(pD.x, pD.y); delta = pointDest.subtract( pointBase); lenAD = Point.distance( pointDest, pointBase); angleAD = Math.atan2( delta.y, delta.x); 
			pointDest = pointBase.add( Point.polar( lenAD / 2 , angleAD)); pO.x = pointDest.x; pO.y = pointDest.y;
	//Bezier line
			BezierLine.graphics.clear(); BezierLine.graphics.lineStyle( 4, 0xffffff); BezierLine.graphics.moveTo(pA.x, pA.y);
			if( ISbCubic) {
				for ( index = 0; index < pennerPoints.length; index ++) { p = pennerPoints[index]; BezierLine.graphics.lineTo( p.x, p.y); pennerString.push( pointStr( new Point(p.x, p.y))); }
				BezierLine.graphics.lineTo(pD.x, pD.y); }
			else BezierLine.graphics.lineTo(pD.x, pD.y);
	//board "Parameters Values" convert points value to String. is point String Name
			pSA = pointStr( new Point( pA.x, pA.y)); pSD = pointStr( new Point( pD.x, pD.y)); pSO = pointStr( new Point( pO.x, pO.y));
			if(ISbCubic) { pSB = pointStr( new Point( pB.x, pB.y)); pSC = pointStr( new Point( pC.x, pC.y));} 
			paramsValues = new Array( pSA, pSB, pSC, pSD, pSO, Math.round(lenAD), Math.round(angleAD * AM)); boardParams.newValues( paramsValues);
	//board Casteljau recurse
			if(ISbCubic) {
				var start:Point, end:Point, delta:Point;
				start = new Point(pA.x, pA.y); end = new Point(pB.x, pB.y); delta = end.subtract( start); lenAB = Point.distance( end, start); angleAB = Math.atan2( delta.y, delta.x); 
				start = new Point(pB.x, pB.y); end = new Point(pC.x, pC.y); delta = end.subtract( start); lenBC = Point.distance( end, start); angleBC = Math.atan2( delta.y, delta.x); 
				start = new Point(pC.x, pC.y); end = new Point(pD.x, pD.y); delta = end.subtract( start); lenDC = Point.distance( end, start); angleCD = Math.atan2( delta.y, delta.x);	
				casteljauValues = new Array( Math.round(lenAB), Math.round(lenBC), Math.round(lenDC), Math.round(angleAB * AM), Math.round(angleBC * AM), Math.round(angleCD * AM), "--","--","--","--","--","--") ;
			}} 

//-------------------------------------------------- Cubic Bezier spline ( polynome degree 3) --------------------------------------------------------------------
// la formule générale est:	M(t) = ( 1-t)^3 PA   +    3 t(1-t)² PB    +    3 t²( 1-t) PC    +     t^3  PD
		private function pennerPointsCubic():void {
			var U:Number =0;
			pennerPoints = new Array(); inc = 1 / resol;
			cx = 3 * (pB.x - pA.x); 		bx = 3 * (pC.x - pB.x) - cx;		ax = pD.x - pA.x - cx - bx;			
			cy = 3 * (pB.y - pA.y);	 	by = 3 * (pC.y - pB.y) - cy;	 	ay = pD.y - pA.y - cy - by;			
			for ( index = 1 ; index < resol; index ++) {
				var M:Point = new Point(); U = U + inc;
				M.x = (ax * Math.pow(U, 3)) + (bx * Math.pow( U, 2)) + cx * U + pA.x; 
				M.y = (ay * Math.pow( U, 3)) + (by * Math.pow( U, 2)) + cy * U + pA.y;
				pennerPoints.push( M); } 
			reDraw(); }		
//----------------------------------------------------- Quadratic Bezier spline ( polynome degree 2)---------------------------------------------------------------
		// Returns the point on a bezier curve for a given time (t is 0-1). This is based on Robert Penner's Math.pointOnCurve() function.
		// http://ibiblio.org/e-notes/Splines/Bezier.htm.
		// More information: http://actionscript-toolbox.com/samplemx_pathguide.php
		public function pennerPointQuadratic( point1x:Number, point1y:Number, controlx:Number, controly:Number, point2x:Number, point2y:Number, index:Number):Point {				
				var pT:Point = new Point; 
				pT.x = point1x + index * (2 * (1-index) * (controlx - point1x) + index * (point2x - point1x)), 
				pT.y = point1y + index * (2 * (1-index) * (controly - point1y) + index * (point2y - point1y)); return pT };			
			
//library base-------------------------------------------------------------------------------------------------------------------------------------------------------------------
		private function roundToPrecision( num:Number, precision:int = 0):Number { var decimalPlaces:Number = Math.pow(10, precision); return (Math.round(decimalPlaces * num) / decimalPlaces); }
		private function pointStr( point:Point):String { var ret:String = "x="; ret += Math.round(point.x) + ", y=" + Math.round( point.y); return ret; }

		private function Réticule( minX:Number, minY:Number, maxX:Number, maxY:Number, pas:Number, color1:Number, color2:Number, alpha:Number = 0.3):void {
			var demiPas:Number = pas / 2, Hor:Number, Vert:Number;
			//lignes secondaires
			graphics.lineStyle(1, color2, alpha);
			for(Hor = demiPas; Hor < maxX; Hor += pas){ graphics.moveTo(Hor, minY); graphics.lineTo(Hor, maxY); }					//verticales.
			for (Vert = demiPas; Vert < maxY; Vert += pas) { graphics.moveTo(minX, Vert); graphics.lineTo(maxX, Vert); }		//horizontales.
			//lignes principales
			graphics.lineStyle(2, color1, alpha);
			for(Hor = pas; Hor < maxX; Hor += pas){ graphics.moveTo(Hor, minY); graphics.lineTo(Hor, maxY); }							//verticales.
			for (Vert = pas; Vert < maxY; Vert += pas) { graphics.moveTo(minX, Vert); graphics.lineTo(maxX, Vert); }}				//horizontales.	
	}//
}//
//library graphic-------------------------------------------------------------------------------------------------------------------------------------------------
import flash.geom.Point; import Sat.graphic.GraphPoint; import flash.display.MovieClip;
class PennerPoint extends MovieClip { 
	public var skin:GraphPoint;
	public function PennerPoint(Name:String = "PN") { skin = new GraphPoint( Name, "C", 4, 0xff0000, 0xff0000, 0xff0000, null); skin.Draw(); addChild( skin); visible = false; }}
	
import flash.geom.Point; import Sat.graphic.GraphPoint; import flash.display.MovieClip;
class RecursePoint extends MovieClip { 
	public var skin:GraphPoint;
	public function RecursePoint(Name:String = "RP") { skin = new GraphPoint( Name, "C", 3, 0xffff00, 0xffff00, 0xffff00, "T"); skin.Draw(); addChild( skin); visible = false; }}	
	
import flash.geom.Point; import Sat.graphic.GraphPoint; import flash.display.MovieClip;
class MovingPoint extends MovieClip { 
	public var skin:GraphPoint;
	public function MovingPoint(Name:String = "RP") { skin = new GraphPoint( Name, "C", 3, 0x00ff00, 0x00ff00, 0x00ff00, "T"); skin.Draw(); addChild( skin); visible = false; }}	

import Sat.control.Box;
class BoxTypes {	public const BOX_RECT:int = 0,BOX_ROUNDRECT:int = 1, BOX_KULER:int = 2;	//format
							public const BOX_NONE:int = 0, BOX_FILET:int = 1, BOX_BORDER:int = 2; }  		//border		
