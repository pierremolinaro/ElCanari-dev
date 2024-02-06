//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor protocol EBObservableObjectProtocol : AnyObject {
  func startsBeingObserved (by inObserver : EBObserverProtocol)
  func stopsBeingObserved (by inObserver : EBObserverProtocol)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————
