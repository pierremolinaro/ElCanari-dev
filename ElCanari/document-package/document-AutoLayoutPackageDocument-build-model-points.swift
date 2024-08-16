//
//  PackageDocument-extension.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 29/03/2020.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutPackageDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc func buildModelPoints () { // @objc for making it overridable
    self.rootObject.mModelImageDoublePoint = nil
    self.rootObject.mModelImageObjects = EBReferenceArray ()
    let pp = PackageModelImageDoublePoint (self.undoManager)
    self.rootObject.mModelImageDoublePoint = pp
    self.rootObject.mModelImageObjects = EBReferenceArray ()
    self.rootObject.mModelImageObjects = EBReferenceArray (pp)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
