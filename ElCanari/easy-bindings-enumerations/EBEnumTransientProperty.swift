//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EBTransientEnumProperty <T>
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class EBTransientEnumProperty <T : EBEnumProtocol> : EBReadOnlyEnumProperty <T> where T : Equatable {

  //····················································································································

  private var mValueCache : EBSelection <T>? = nil
  var mReadModelFunction : Optional <() -> EBSelection <T> > = nil

  //····················································································································

  override var selection : EBSelection <T> {
    if self.mValueCache == nil {
      self.mValueCache = self.mReadModelFunction? ()
      if self.mValueCache == nil {
        self.mValueCache = .empty
      }
    }
    return self.mValueCache!
  }

  //····················································································································

  override func observedObjectDidChange () {
    if self.mValueCache != nil {
      self.mValueCache = nil
      if logEvents () {
        appendMessageString ("Transient #\(self.objectIndex) propagation\n")
      }
      super.observedObjectDidChange ()
    }else if logEvents () {
      appendMessageString ("Transient #\(self.objectIndex) nil\n")
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————