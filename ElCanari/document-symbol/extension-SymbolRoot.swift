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
                   symbolPins : inout EBReferenceArray <SymbolPinTypeInDevice>) {
    for symbolObject in self.symbolObjects.values {
      if let object = symbolObject as? SymbolPin, let bp = object.filledBezierPath {
        filledBezierPathes.append (bp)
        let newPin = SymbolPinTypeInDevice (inUndoManager)
        newPin.mPinX = object.xPin
        newPin.mPinY = object.yPin
        newPin.mXName = object.xName
        newPin.mYName = object.yName
        newPin.mName = object.name
        newPin.mNameHorizontalAlignment = object.nameHorizontalAlignment
        newPin.mPinNameIsDisplayedInSchematics = object.pinNameIsDisplayedInSchematics
        newPin.mXNumber = object.xNumber
        newPin.mYNumber = object.yNumber
        newPin.mNumberHorizontalAlignment = object.numberHorizontalAlignment
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
      }else if let object = symbolObject as? SymbolText {
        let textAttributes : [NSAttributedString.Key : Any] = [
          NSAttributedString.Key.font : preferences_pinNameFont
        ]
        let origin = CanariPoint (x: object.x, y: object.y).cocoaPoint
        let bp = EBBezierPath (
          with: object.text,
          at: origin,
          object.horizontalAlignment.ebTextShapeHorizontalAlignment,
          .center,
          withAttributes: textAttributes
        )
        filledBezierPathes.append (bp.nsBezierPath)
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
