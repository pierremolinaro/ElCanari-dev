//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func transient_SymbolText_objectDisplay (
       _ self_x : Int,                   
       _ self_y : Int,                   
       _ self_text : String,             
       _ prefs_symbolColor : NSColor,    
       _ prefs_pinNameFont : NSFont
) -> EBShape {
//--- START OF USER ZONE 2
    let textAttributes : [NSAttributedString.Key : Any] = [
      NSAttributedString.Key.font : prefs_pinNameFont,
      NSAttributedString.Key.foregroundColor : prefs_symbolColor
    ]
  //  let size = self_text.size (withAttributes: textAttributes)
    let origin = NSPoint (x: canariUnitToCocoa (self_x), y: canariUnitToCocoa (self_y))
    let shape = EBShape ()
    shape.append (shape: EBTextShape (self_text, origin, textAttributes, .left, .center))
    return shape
//--- END OF USER ZONE 2
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————