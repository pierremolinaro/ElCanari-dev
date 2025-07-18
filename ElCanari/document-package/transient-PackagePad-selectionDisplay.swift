//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_PackagePad_selectionDisplay (
       _ prefs_selectionHiliteColor : NSColor,         
       _ self_xCenter : Int,                           
       _ self_yCenter : Int,                           
       _ self_width : Int,                             
       _ self_height : Int,                            
       _ self_padShape : PadShape
) -> EBShape {
//--- START OF USER ZONE 2
    var bp = BézierPath.pad (
      centerX: self_xCenter,
      centerY: self_yCenter,
      width: self_width,
      height: self_height,
      shape: self_padShape
    )
    bp.lineWidth = 0.25
    bp.lineCapStyle = .round
    var shape = EBShape ()
    shape.add (stroke: [bp], prefs_selectionHiliteColor)
    return shape
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
