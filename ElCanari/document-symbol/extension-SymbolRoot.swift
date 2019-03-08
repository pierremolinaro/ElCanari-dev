//
//  extension-SymbolRoot.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/03/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension SymbolRoot {

  //····················································································································

  func accumulate (withUndoManager inUndoManager : EBUndoManager,
                   strokeBezierPathes : NSBezierPath,
                   filledBezierPathes : NSBezierPath,
                   symbolPins : inout [SymbolPinInDevice]) {
    for symbolObject in self.symbolObjects_property.propval {
      if let object = symbolObject as? SymbolPin, let bp = object.filledBezierPath {
        filledBezierPathes.append (bp)
        let newPin = SymbolPinInDevice (inUndoManager, file: #file, #line)
        newPin.mX = object.xName
        newPin.mY = object.yName
        newPin.mName = object.name
        newPin.mNameHorizontalAlignment = object.nameHorizontalAlignment
        newPin.mPinNameIsDisplayedInSchematics = object.pinNameIsDisplayedInSchematics
        symbolPins.append (newPin)
      }else if let object = symbolObject as? SymbolSolidRect, let bp = object.filledBezierPath {
        filledBezierPathes.append (bp)
      }else if let object = symbolObject as? SymbolOval, let bp = object.strokeBezierPath {
        strokeBezierPathes.append (bp)
      }else if let object = symbolObject as? SymbolSolidOval, let bp = object.filledBezierPath {
        filledBezierPathes.append (bp)
      }else if let object = symbolObject as? SymbolBezierCurve, let bp = object.strokeBezierPath {
        strokeBezierPathes.append (bp)
      }else if let object = symbolObject as? SymbolSegment, let bp = object.strokeBezierPath {
        strokeBezierPathes.append (bp)
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
