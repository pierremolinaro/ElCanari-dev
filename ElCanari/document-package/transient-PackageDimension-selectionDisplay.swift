//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_PackageDimension_selectionDisplay (
       _ prefs_selectionHiliteColor : NSColor,               
       _ self_x1 : Int,                                      
       _ self_y1 : Int,                                      
       _ self_x2 : Int,                                      
       _ self_y2 : Int,                                      
       _ prefs_packageBackgroundColor : NSColor,             
       _ prefs_packageDimensionColor : NSColor,              
       _ self_drawDimensionBackground : Bool,                
       _ self_xDimension : Int,                              
       _ self_yDimension : Int,                              
       _ self_distanceInCanariUnit : Int,                    
       _ self_distanceUnit : Int,                            
       _ prefs_dimensionFont : NSFont,                       
       _ self_PackageObject_knobSize : Double
) -> EBShape {
//--- START OF USER ZONE 2
  let p1 = NSPoint (x: canariUnitToCocoa (self_x1), y: canariUnitToCocoa (self_y1))
  let p2 = NSPoint (x: canariUnitToCocoa (self_x2), y: canariUnitToCocoa (self_y2))
  let pText = CanariPoint (x: self_xDimension + (self_x1 + self_x2) / 2, y: self_yDimension + (self_y1 + self_y2) / 2).cocoaPoint
  var bp = BézierPath ()
  bp.lineWidth = 0.25
  bp.lineCapStyle = .round
  bp.move (to: p1)
  bp.line (to: p2)
  bp.move (to: NSPoint.center (p1, p2))
  bp.line (to: pText)
//--- Text
  let dimensionText = intValueAndUnitStringFrom (valueInCanariUnit: self_distanceInCanariUnit, displayUnit: self_distanceUnit)
  var shape = EBShape ()
  shape.add (stroke: [bp], prefs_selectionHiliteColor)
  let center = NSPoint.center (p1, p2)
  shape.add (knobAt: center, knobIndex: PACKAGE_DIMENSION_CENTER, .rect, CGFloat (self_PackageObject_knobSize))
  shape.add (knobAt: p1, knobIndex: PACKAGE_DIMENSION_ENDPOINT_1, .diamond, CGFloat (self_PackageObject_knobSize))
  shape.add (knobAt: p2, knobIndex: PACKAGE_DIMENSION_ENDPOINT_2, .diamond, CGFloat (self_PackageObject_knobSize))
  shape.add (
    textKnob: dimensionText,
    pText,
    prefs_dimensionFont,
    foreColor: prefs_packageDimensionColor,
    backColor: self_drawDimensionBackground ? prefs_packageBackgroundColor : .clear,
    .center,
    .center,
    .circ,
    knobIndex: PACKAGE_DIMENSION_TEXT
  )
//---
  return shape
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
