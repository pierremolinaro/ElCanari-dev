//
//  extension-SymbolRoot.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/03/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

extension SymbolRoot {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func accumulate (withUndoManager inUndoManager : UndoManager?,
                   strokeBezierPathes : NSBezierPath,
                   filledBezierPathes : NSBezierPath,
                   symbolPins : inout EBReferenceArray <SymbolPinTypeInDevice>) {
    for symbolObject in self.symbolObjects.values {
      if let object = symbolObject as? SymbolPin, let bp = object.filledBezierPath {
        filledBezierPathes.append (bp)
        let newPin = SymbolPinTypeInDevice (inUndoManager)
        newPin.mPinX = object.xPin.cuValue
        newPin.mPinY = object.yPin.cuValue
        newPin.mXName = object.xName.cuValue
        newPin.mYName = object.yName.cuValue
        newPin.mName = object.name
        newPin.mNameHorizontalAlignment = object.nameHorizontalAlignment
        newPin.mPinNameIsDisplayedInSchematics = object.pinNameIsDisplayedInSchematics
        newPin.mXNumber = object.xNumber.cuValue
        newPin.mYNumber = object.yNumber.cuValue
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
          NSAttributedString.Key.font : preferences_pinNameFont_property.propval
        ]
        let origin = NSPoint (x: object.x, y: object.y)
        let bp = BezierPath (
          withString: object.text,
          at: origin,
          object.horizontalAlignment.ebTextShapeHorizontalAlignment,
          .center,
          withAttributes: textAttributes
        )
        filledBezierPathes.append (bp.nsBezierPath)
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
