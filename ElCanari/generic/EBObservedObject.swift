//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EBObservedObject
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class EBObservedObject : EBSwiftBaseObject {

  //····················································································································

  private final var mObservers = EBWeakEventSet ()

  //····················································································································

  final func addEBObserver (_ inObserver : EBObserverProtocol) {
    self.mObservers.insert (inObserver)
    inObserver.observedObjectDidChange ()
  }

  //····················································································································

  final func removeEBObserver (_ inObserver : EBObserverProtocol) {
    self.mObservers.remove (inObserver)
    inObserver.observedObjectDidChange ()
  }

  //····················································································································

  func observedObjectDidChange () {
    for (_, entry) in self.mObservers.dictionary {
      if let observer = entry.possibleObserver {
        observer.observedObjectDidChange ()
      }else{
        self.mObservers.triggerPacking ()
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
