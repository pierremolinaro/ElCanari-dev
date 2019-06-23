//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func transient_BoardText_objectDisplay (
       _ self_mX : Int,                 
       _ self_mY : Int,                 
       _ self_mText : String,           
       _ self_mFontSize : Double,       
       _ self_mFont_descriptor : BoardFontDescriptor?,
       _ self_mHorizontalAlignment : HorizontalAlignment,
       _ self_mVerticalAlignment : BoardTextVerticalAlignment,
       _ self_mLayer : BoardTextLayer,  
       _ self_mRotation : Int,          
       _ self_mWeight : Double,         
       _ self_mOblique : Bool,          
       _ prefs_frontSideLegendColorForBoard : NSColor,
       _ prefs_frontSideLayoutColorForBoard : NSColor,
       _ prefs_backSideLayoutColorForBoard : NSColor,
       _ prefs_backSideLegendColorForBoard : NSColor
) -> EBShape {
//--- START OF USER ZONE 2
        let (textBP, _, _, _) = boardText_displayInfos (
          self_mX,
          self_mY,
          self_mText,
          self_mFontSize,
          self_mFont_descriptor!,
          self_mHorizontalAlignment,
          self_mVerticalAlignment,
          self_mLayer,
          self_mRotation,
          self_mWeight,
          self_mOblique
        )
        let textColor : NSColor
        switch self_mLayer {
        case .legendFront :
          textColor = prefs_frontSideLegendColorForBoard
        case .layoutFront :
          textColor = prefs_frontSideLayoutColorForBoard
        case .layoutBack :
          textColor = prefs_backSideLayoutColorForBoard
        case .legendBack :
          textColor = prefs_backSideLegendColorForBoard
        }
        let textShape = EBStrokeBezierPathShape ([textBP], textColor)
      //--- Transparent background
        let backgroundBP = EBBezierPath (rect: textShape.boundingBox)
        let shape = EBShape ()
        shape.append (EBFilledBezierPathShape ([backgroundBP], nil))
        shape.append (textShape)
      //---
        return shape
//--- END OF USER ZONE 2
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————