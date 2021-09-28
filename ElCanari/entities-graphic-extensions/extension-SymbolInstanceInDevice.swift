//
//  extension-SymbolInstanceInDevice.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/03/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION SymbolInstanceInDevice
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension SymbolInstanceInDevice {

  //····················································································································

  func acceptToTranslate_SymbolInstanceInDevice (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return ((self.mX + inDx) >= 0) && ((self.mY + inDy) >= 0)
  }

  //····················································································································

  func translate_SymbolInstanceInDevice (xBy inDx: Int, yBy inDy: Int, userSet ioSet : ObjcObjectSet) {
    self.mX += inDx
    self.mY += inDy
  }

  //····················································································································

  func operationBeforeRemoving_SymbolInstanceInDevice () {
    for pinInstance in self.mPinInstances {
      pinInstance.mSymbolInstance = nil
      pinInstance.mType = nil
      pinInstance.mPadProxy = nil
    }
    self.mType = nil
    super.operationBeforeRemoving ()
  }

  //····················································································································
  //  Alignment Points
  //····················································································································

  func alignmentPoints_SymbolInstanceInDevice () -> ObjcCanariPointSet {
    return ObjcCanariPointSet ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
