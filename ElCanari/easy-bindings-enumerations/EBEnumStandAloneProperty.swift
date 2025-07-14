//
//  EBEnumStandAloneProperty.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 19/10/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//   EBEnumStandAloneProperty <TYPE>
//--------------------------------------------------------------------------------------------------

final class EBEnumStandAloneProperty <TYPE : EBEnumPropertyProtocol> : EBEnumReadWriteProperty <TYPE> {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inValue : TYPE) {
    self.mValue = inValue
    super.init ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mValue : TYPE {
    didSet {
      if self.mValue != oldValue {
        if logEvents () {
          appendMessage ("Property #\(self.objectIndex) did change value to \(self.mValue)\n")
        }
        self.observedObjectDidChange ()
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var selection : EBSelection <TYPE> { return .single (mValue) }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var propval : TYPE { return self.mValue }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func setProp (_ inValue : TYPE) { self.mValue = inValue }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

