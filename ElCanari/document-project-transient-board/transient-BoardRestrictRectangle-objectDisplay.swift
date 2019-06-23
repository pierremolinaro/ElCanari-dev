//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func transient_BoardRestrictRectangle_objectDisplay (
       _ self_mX : Int,                              
       _ self_mY : Int,                              
       _ self_mWidth : Int,                          
       _ self_mHeight : Int,                         
       _ self_mIsInFrontLayer : Bool,                
       _ self_mIsInBackLayer : Bool,                 
       _ prefs_frontSideRestrictRectangleColorForBoard : NSColor,
       _ prefs_backSideRestrictRectangleColorForBoard : NSColor
) -> EBShape {
//--- START OF USER ZONE 2
        let r = CanariRect (left: self_mX, bottom: self_mY, width: self_mWidth, height: self_mHeight)
        let cocoaRect = r.cocoaRect
        let rectBP = EBBezierPath (rect: cocoaRect)
        let lg = max (cocoaRect.size.width, cocoaRect.size.height)
      //--- Transparent background (for selection)
        let shape = EBFilledBezierPathShape ([rectBP], nil)
      //--- Back layer
        if self_mIsInBackLayer {
          var bp = EBBezierPath ()
          bp.lineWidth = 0.5
          bp.lineJoinStyle = .round
          bp.lineCapStyle = .round
          var x = cocoaRect.minX
          while x < cocoaRect.maxX {
            bp.move (to: NSPoint (x: x, y: cocoaRect.maxY))
            bp.relativeLine (to: NSPoint (x: lg, y: -lg))
            x += 10.0
          }
          var y = cocoaRect.maxY - 10.0
          while y > cocoaRect.minY {
            bp.move (to: NSPoint (x: cocoaRect.minX, y: y))
            bp.relativeLine (to: NSPoint (x: lg, y: -lg))
            y -= 10.0
          }
          shape.append (EBStrokeBezierPathShape ([bp], prefs_backSideRestrictRectangleColorForBoard, clip: rectBP))
        }
      //--- Front layer
        if self_mIsInFrontLayer {
          var bp = EBBezierPath ()
          bp.lineWidth = 0.5
          bp.lineJoinStyle = .round
          bp.lineCapStyle = .round
          var x = cocoaRect.minX
          while x < cocoaRect.maxX {
            bp.move (to: NSPoint (x: x, y: cocoaRect.minY))
            bp.relativeLine (to: NSPoint (x: lg, y: lg))
            x += 10.0
          }
          var y = cocoaRect.minY + 10.0
          while y < cocoaRect.maxY {
            bp.move (to: NSPoint (x: cocoaRect.minX, y: y))
            bp.relativeLine (to: NSPoint (x: lg, y: lg))
            y += 10.0
          }
          shape.append (EBStrokeBezierPathShape ([bp], prefs_frontSideRestrictRectangleColorForBoard, clip: rectBP))
        }
      //--- Append rect frame
        do{
          var bp = EBBezierPath (rect: cocoaRect.insetBy (dx: 0.25, dy: 0.25))
          bp.lineWidth = 0.5
          bp.lineJoinStyle = .round
          bp.lineCapStyle = .round
          let frameColor : NSColor
          if self_mIsInFrontLayer {
            frameColor = prefs_frontSideRestrictRectangleColorForBoard
          }else{
            frameColor = prefs_backSideRestrictRectangleColorForBoard
          }
          shape.append (EBStrokeBezierPathShape ([bp], frameColor))
        }
      //---
        return shape
//--- END OF USER ZONE 2
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————