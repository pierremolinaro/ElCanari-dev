//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func transient_SymbolText_selectionDisplay (
       _ self_x : Int,                      
       _ self_y : Int,                      
       _ self_text : String,                
       _ prefs_pinNameFont : NSFont
) -> EBShape {
//--- START OF USER ZONE 2
    let origin = NSPoint (
      x: canariUnitToCocoa (self_x),
      y: canariUnitToCocoa (self_y)
    )
    let shape = EBShape ()
    shape.append (shape: EBKnobShape (at: origin, index: 0, .rect))
    return shape
//--- END OF USER ZONE 2
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————