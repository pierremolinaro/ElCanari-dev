//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_BoardImage_selectionDisplay (
       _ prefs_selectionHiliteColor : NSColor,         
       _ self_mCenterX : Int,                          
       _ self_mCenterY : Int,                          
       _ self_boardImageCodeDescriptor : BoardImageDescriptor,
       _ self_mLayer : BoardQRCodeLayer,               
       _ self_mRotation : Int,                         
       _ self_mPixelSize : Int,                        
       _ prefs_frontSideLegendColorForBoard : NSColor, 
       _ prefs_backSideLegendColorForBoard : NSColor,  
       _ prefs_hiliteWidthMultipliedByTen : Int,       
       _ prefs_mShowTextRotationKnobInBoard : Bool
) -> EBShape {
//--- START OF USER ZONE 2
       let foreColor : NSColor
        switch self_mLayer {
        case .legendFront :
          foreColor = prefs_frontSideLegendColorForBoard
        case .legendBack :
          foreColor = prefs_backSideLegendColorForBoard
        }
        var shape = EBShape ()
        let displayInfos = boardImage_displayInfos (
          centerX: self_mCenterX,
          centerY: self_mCenterY,
          self_boardImageCodeDescriptor,
          frontSide: self_mLayer == .legendFront,
          pixelSizeInCanariUnit: self_mPixelSize,
          rotation: self_mRotation
        )
      //--- Background
        shape.add (filled: [displayInfos.backgroundBP], (foreColor == .white) ? .lightGray : .white)
        shape.add (stroke: [displayInfos.backgroundBP], prefs_selectionHiliteColor)
      //--- Image
        shape.add (filled: [displayInfos.imageBP], foreColor)
      //--- Rotation knob
        let center = NSPoint (x: canariUnitToCocoa (self_mCenterX), y: canariUnitToCocoa (self_mCenterY))
        if prefs_mShowTextRotationKnobInBoard {
          var knobLine = BézierPath ()
          knobLine.move (to : center)
          knobLine.line (to : displayInfos.rotationKnobLocation)
          knobLine.lineWidth = CGFloat (prefs_hiliteWidthMultipliedByTen) / 10.0
          knobLine.lineCapStyle = .round
          knobLine.lineJoinStyle = .round
          shape.add (stroke: [knobLine], prefs_selectionHiliteColor)
          shape.add (knobAt:  displayInfos.rotationKnobLocation, knobIndex: BOARD_IMAGE_ROTATION_KNOB, .circ, 2.0)
        }
      //--- Knob
         shape.add (knobAt: center, knobIndex: BOARD_QRCODE_ORIGIN_KNOB, .rect, 2.0)
      //---
        return shape
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
