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

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return ((self.mX + inDx) >= 0) && ((self.mY + inDy) >= 0)
  }

  //····················································································································

  override func translate (xBy inDx: Int, yBy inDy: Int) {
    self.mX += inDx
    self.mY += inDy
  }

  //····················································································································

  override func operationAfterRemoving () {
    super.operationAfterRemoving ()
    if let symbolType = self.mType_property.propval {
    //--- Unlink to symbol type
      self.mType_property.setProp (nil)
    //--- If symbol instance it the last one, remove also symbol type
      if symbolType.mInstances_property.propval.count == 0 {
        symbolType.mRoot_property.setProp (nil)
        symbolType.cleanUpRelationshipsAndRemoveAllObservers ()
      }
    }
    self.cleanUpRelationshipsAndRemoveAllObservers ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
