//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EBObservedObject
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class EBObservedObject : EBSwiftBaseObject {

  //····················································································································

  private final var mObservers = EBWeakEventSet ()

  //····················································································································

  final func startsToBeObserved (by inObserver : EBObserverProtocol) {
    self.mObservers.insert (inObserver)
    inObserver.observedObjectDidChange ()
  }

  //····················································································································

  final func stopsBeingObserved (by inObserver : EBObserverProtocol) {
    self.mObservers.remove (inObserver)
    inObserver.observedObjectDidChange ()
  }

  //····················································································································

  func observedObjectDidChange () {
    for entry in self.mObservers.values () {
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
