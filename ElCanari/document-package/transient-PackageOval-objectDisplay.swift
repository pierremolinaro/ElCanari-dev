//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_PackageOval_objectDisplay (
       _ self_strokeBezierPath : NSBezierPath,       
       _ prefs_packageColor : NSColor,               
       _ prefs_packageDrawingWidthMultipliedByTen : Int
) -> EBShape {
//--- START OF USER ZONE 2
  var bp = BézierPath ()
  bp.append (self_strokeBezierPath)
  bp.lineWidth = CGFloat (prefs_packageDrawingWidthMultipliedByTen) / 10.0
  bp.lineCapStyle = .round
  return EBShape (stroke: [bp], prefs_packageColor)
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
