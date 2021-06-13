//
//  extension-SymbolInstanceInDevice.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/03/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   EXTENSION SymbolInstanceInDevice
//----------------------------------------------------------------------------------------------------------------------

extension SymbolInstanceInDevice {

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return ((self.mX + inDx) >= 0) && ((self.mY + inDy) >= 0)
  }

  //····················································································································

  override func translate (xBy inDx: Int, yBy inDy: Int, userSet ioSet : ObjcObjectSet) {
    self.mX += inDx
    self.mY += inDy
  }

  //····················································································································

  override func operationBeforeRemoving () {
    for pinInstance in self.mPinInstances {
      pinInstance.mSymbolInstance = nil
      pinInstance.mType = nil
      pinInstance.mPadProxy = nil
    }
    self.mType = nil
    super.operationBeforeRemoving ()
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
