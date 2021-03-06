//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func transient_CommentInSchematic_objectDisplay (
       _ self_mComment : String,                 
       _ self_mColor : NSColor,                  
       _ self_mSize : Double,                    
       _ self_mHorizontalAlignment : HorizontalAlignment,
       _ self_mVerticalAlignment : VerticalAlignment,
       _ self_mX : Int,                          
       _ self_mY : Int
) -> EBShape {
//--- START OF USER ZONE 2
        // Swift.print ("self_mSize \(self_mSize)")
        let s = CGFloat (self_mSize)
        let font = NSFont (name: "LucidaGrande", size: s)!
        let p = CanariPoint (x: self_mX, y: self_mY).cocoaPoint
        let textAttributes : [NSAttributedString.Key : Any] = [
          NSAttributedString.Key.font : font,
          NSAttributedString.Key.foregroundColor : self_mColor
        ]
        return EBShape (
          text: (self_mComment == "") ? "Empty comment" : self_mComment,
          p,
          textAttributes,
          self_mHorizontalAlignment.ebTextShapeHorizontalAlignment,
          self_mVerticalAlignment.ebTextShapeVerticalAlignment
        )
//--- END OF USER ZONE 2
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
