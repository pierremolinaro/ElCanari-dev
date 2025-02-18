//--------------------------------------------------------------------------------------------------
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//  Extension NSBezierPath
//--------------------------------------------------------------------------------------------------

extension NSBezierPath {
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  
  public func addArrow (withFilledPath fillPath : NSBezierPath,
                        to inEndPoint : NSPoint,
                        arrowSize inArrowSize : CGFloat) {
    if inEndPoint != self.currentPoint {
   //--- Compute angle
      let angle = NSPoint.angleInRadian (self.currentPoint, inEndPoint)
    //--- Affine transform
      let tr = NSAffineTransform ()
      tr.translateX (by: inEndPoint.x, yBy: inEndPoint.y)
      tr.rotate (byRadians: angle)
    //--- Draw path
      let path = NSBezierPath ()
      path.move (to: NSPoint (x: 0.0, y: 0.0))
      path.line (to: NSPoint (x: -2.0 * inArrowSize, y:  inArrowSize))
      path.curve (
        to: NSPoint (x: -2.0 * inArrowSize, y: -inArrowSize),
        controlPoint1: NSPoint (x: -inArrowSize, y: -inArrowSize),
        controlPoint2: NSPoint (x: -inArrowSize, y:  inArrowSize)
      )
      path.close ()
    //--- Add path
      fillPath.append (tr.transform (path))
    //--- Draw line
      self.line (to: inEndPoint)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  open override var description : String {
    return "\(self.elementCount) elements"
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
