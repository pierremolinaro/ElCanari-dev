//
//  ProjectDocument-mouse-moved-flags-changed.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/09/2020.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

extension CustomizedProjectDocument {

  //····················································································································

  internal func mouseMovedOrFlagsChangedInBoard (_ inUnalignedMouseLocation : NSPoint) -> EBShape? {
    var shape : EBShape? = nil
    let d = milsToCocoaUnit (CGFloat (self.rootObject.mControlKeyHiliteDiameter))
    if NSEvent.modifierFlags.contains (.control), d > 0.0, let boardView = self.mBoardView {
      if boardView.frame.contains (inUnalignedMouseLocation) {
        let r = NSRect (
          x: inUnalignedMouseLocation.x - d / 2.0,
          y: inUnalignedMouseLocation.y - d / 2.0,
          width: d,
          height: d
        )
        var bp = EBBezierPath (ovalIn: r)
        bp.lineWidth = 1.0 / boardView.actualScale
        shape = EBShape (filled: [bp], NSColor.lightGray.withAlphaComponent (0.2))
        shape?.add(stroke: [bp], NSColor.green)
      }
    }
    return shape
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
