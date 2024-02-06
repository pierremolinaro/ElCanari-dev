//
//  extension-SheetInProject-add-nc.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 09/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension SheetInProject {

  //····················································································································

  func addLabelToPin (toPoint inPoint : PointInSchematic,
                      newNetCreator inNewNetCreator : @MainActor () -> NetInProject) -> LabelInSchematic? {
    let isConnected = inPoint.isConnected ?? true
    if !isConnected {
      let label = LabelInSchematic (self.undoManager)
      inPoint.mNet = inNewNetCreator ()
      label.mPoint = inPoint
      label.mOrientation = self.findPreferredNCOrientation (for: inPoint)
      self.mObjects.append (label)
      return label
    }else{
      return nil
    }
  }

  //····················································································································

  func addNCToPin (toPoint inPoint : PointInSchematic) -> NCInSchematic? {
    let isConnected = inPoint.isConnected ?? true
    if !isConnected {
      let nc = NCInSchematic (self.undoManager)
      nc.mPoint = inPoint
      nc.mOrientation = self.findPreferredNCOrientation (for: inPoint)
      self.mObjects.append (nc)
      return nc
    }else{
      return nil
    }
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

//——————————————————————————————————————————————————————————————————————————————————————————————————
