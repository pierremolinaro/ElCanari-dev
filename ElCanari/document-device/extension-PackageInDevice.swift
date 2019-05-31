//
//  extension-PackageInDevice.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 02/03/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION PackageInDevice
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension PackageInDevice {

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return ((self.mX + inDx) >= 0) && ((self.mY + inDy) >= 0)
  }

  //····················································································································

  override func translate (xBy inDx: Int, yBy inDy: Int, userSet ioSet : OCObjectSet) {
    self.mX += inDx
    self.mY += inDy
  }

  //····················································································································

  override func operationBeforeRemoving () {
    super.operationBeforeRemoving ()
    for masterPad in self.mMasterPads_property.propval {
      for slavePad in masterPad.mSlavePads_property.propval {
        slavePad.cleanUpRelationshipsAndRemoveAllObservers ()
      }
      masterPad.cleanUpRelationshipsAndRemoveAllObservers ()
    }
    self.cleanUpRelationshipsAndRemoveAllObservers ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
