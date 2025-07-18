//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_ProjectRoot_borderOutlineBackground (
       _ self_mBorderCurves_descriptor : [any BorderCurve_descriptor],
       _ self_mBoardShape : BoardShape,                        
       _ self_mRectangularBoardWidth : Int,                    
       _ self_mRectangularBoardHeight : Int,                   
       _ self_mBoardLimitsWidth : Int,                         
       _ prefs_boardLimitsColorForBoard : NSColor,             
       _ self_mBoardClearance : Int,                           
       _ prefs_boardClearanceColorForBoard : NSColor
) -> EBShape {
//--- START OF USER ZONE 2
        var bp = BézierPath ()
        switch self_mBoardShape {
        case .rectangular :
          let d = self_mBoardClearance + self_mBoardLimitsWidth
          let r = CanariRect (
            left: d,
            bottom: d,
            width: self_mRectangularBoardWidth - 2 * d,
            height: self_mRectangularBoardHeight - 2 * d
          )
          bp.appendRect (r.cocoaRect)
        case .bezierPathes :
//          if self_mBorderCurves_descriptor.count == 4 {
            var curveDictionary = [CanariPoint : BorderCurveDescriptor] ()
            for curve in self_mBorderCurves_descriptor {
              let descriptor = curve.descriptor!
              curveDictionary [descriptor.p1] = descriptor
            }
            var descriptor = self_mBorderCurves_descriptor [0].descriptor!
            let p = descriptor.p1
            bp.move (to: p.cocoaPoint)
            var loop = true
            while loop {
              switch descriptor.shape {
              case .line :
                bp.line (to: descriptor.p2.cocoaPoint)
              case .bezier :
                let cp1 = descriptor.cp1.cocoaPoint
                let cp2 = descriptor.cp2.cocoaPoint
                bp.curve (to: descriptor.p2.cocoaPoint, controlPoint1: cp1, controlPoint2: cp2)
              }
              descriptor = curveDictionary [descriptor.p2]!
              loop = p != descriptor.p1
            }
//          }
        }
        bp.lineCapStyle = .round
        bp.lineJoinStyle = .round
        var shape = EBShape ()
      //---
        var outlineFrame = bp
        outlineFrame.lineWidth = 2.0 * canariUnitToCocoa (self_mBoardLimitsWidth + self_mBoardClearance)
        shape.add (filled: [outlineFrame.pathToFillByStroking], prefs_boardLimitsColorForBoard, clip: .outside (bp))
      //---
        var clearanceFrame = bp
        clearanceFrame.lineWidth = 2.0 * canariUnitToCocoa (self_mBoardClearance)
        shape.add (filled: [clearanceFrame.pathToFillByStroking], prefs_boardClearanceColorForBoard, clip: .outside (bp))
        return shape
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
