//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EBTransientProperty <T>
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class EBTransientProperty <T : Equatable> : EBObservableProperty <T> {

  //····················································································································

  private final var mValueCache : EBSelection <T>? = nil
  final var mReadModelFunction : Optional <() -> EBSelection <T> > = nil

  //····················································································································

  override final var selection : EBSelection <T> {
    if let valueCache = self.mValueCache {
      return valueCache
    }else{
      self.mValueCache = self.mReadModelFunction? ()
      if let valueCache = self.mValueCache {
        return valueCache
      }else{
        self.mValueCache = .empty
        return .empty
      }
    }
  }

  //····················································································································

  override final func observedObjectDidChange () {
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