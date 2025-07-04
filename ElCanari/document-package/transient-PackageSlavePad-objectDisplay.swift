//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_PackageSlavePad_objectDisplay (
       _ self_xCenter : Int,                             
       _ self_yCenter : Int,                             
       _ self_width : Int,                               
       _ self_height : Int,                              
       _ self_holeWidth : Int,                           
       _ self_holeHeight : Int,                          
       _ self_padShape : PadShape,                       
       _ self_padStyle : SlavePadStyle,                  
       _ prefs_frontSidePadColor : NSColor,              
       _ prefs_displayPackageFrontSidePads : Bool,       
       _ prefs_backSidePadColor : NSColor,               
       _ prefs_displayPackageBackSidePads : Bool
) -> EBShape {
//--- START OF USER ZONE 2
    let xCenter = canariUnitToCocoa (self_xCenter)
    let yCenter = canariUnitToCocoa (self_yCenter)
    let width = canariUnitToCocoa (self_width)
    let height = canariUnitToCocoa (self_height)
    let rPad = NSRect (x: xCenter - width / 2.0, y: yCenter - height / 2.0, width: width, height: height)
    var bp : BézierPath
    switch self_padShape {
    case .rect :
      bp = BézierPath (rect: rPad)
    case .round :
      bp = BézierPath (oblongInRect: rPad)
    case .octo :
      bp = BézierPath (octogonInRect: rPad)
    }
    switch self_padStyle {
    case .traversing :
      let holeWidth = canariUnitToCocoa (self_holeWidth)
      let holeHeight = canariUnitToCocoa (self_holeHeight)
      let rHole = NSRect (x: xCenter - holeWidth / 2.0, y: yCenter - holeHeight / 2.0, width: holeWidth, height: holeHeight)
      bp.appendOblong (in: rHole)
      bp.windingRule = .evenOdd
      if prefs_displayPackageFrontSidePads {
        return EBShape (filled: [bp], prefs_frontSidePadColor)
      }else if prefs_displayPackageBackSidePads {
        return EBShape (filled: [bp], prefs_backSidePadColor)
      }else{
        return EBShape ()
      }
    case .componentSide :
      if prefs_displayPackageFrontSidePads {
        return EBShape (filled: [bp], prefs_frontSidePadColor)
      }else{
        return EBShape ()
      }
    case .oppositeSide :
      if prefs_displayPackageBackSidePads {
        return EBShape (filled: [bp], prefs_backSidePadColor)
      }else{
        return EBShape ()
      }
    }
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
