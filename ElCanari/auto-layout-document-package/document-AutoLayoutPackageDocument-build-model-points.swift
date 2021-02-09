//
//  PackageDocument-extension.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 29/03/2020.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

extension AutoLayoutPackageDocument {

  //····················································································································

  @objc func buildModelPoints () { // @objc for making it overridable
    self.rootObject.mModelImageDoublePoint = nil
    self.rootObject.mModelImageObjects = []
    let pp = PackageModelImageDoublePoint (self.ebUndoManager)
    self.rootObject.mModelImageDoublePoint = pp
    self.rootObject.mModelImageObjects = []
    self.rootObject.mModelImageObjects = [pp]
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
