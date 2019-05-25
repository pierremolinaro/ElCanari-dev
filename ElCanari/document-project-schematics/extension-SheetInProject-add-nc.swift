//
//  extension-SheetInProject-add-nc.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 09/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension SheetInProject {

  //····················································································································

  func addNCToPin (toPoint inPoint : PointInSchematic) -> NCInSchematic {
    let nc = NCInSchematic (self.ebUndoManager)
    nc.mPoint = inPoint
    nc.mOrientation = self.findPreferredNCOrientation (for: inPoint)
    self.mObjects.append (nc)
    return nc
  }

  //····················································································································

  private func findPreferredNCOrientation (for inPoint : PointInSchematic) -> QuadrantRotation {
  //--- Find the rectangle of all pins of current symbol
    let symbol = inPoint.mSymbol!
    let symbolInfo = symbol.symbolInfo!
  //---
    var cocoaRect = NSRect.null
    if !symbolInfo.strokeBezierPath.isEmpty {
      cocoaRect = cocoaRect.union (symbolInfo.strokeBezierPath.bounds)
    }
    if !symbolInfo.filledBezierPath.isEmpty {
      cocoaRect = cocoaRect.union (symbolInfo.filledBezierPath.bounds)
    }
   // let symbolPinRect = CanariRect (points: symbolPinLocationArray)
    let relativeLocation = cocoaRect.relativeLocation (of: inPoint.location!.cocoaPoint)
    switch relativeLocation {
    case .above :
      return .rotation90
    case .left :
      return .rotation180
    case .below :
      return .rotation270
    case .right :
      return .rotation0
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
