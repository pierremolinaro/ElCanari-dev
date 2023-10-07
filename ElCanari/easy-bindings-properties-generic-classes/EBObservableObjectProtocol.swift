//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor protocol EBObservableObjectProtocol : AnyObject {
  func startsToBeObserved (by inObserver : EBObserverProtocol)
  func stopsBeingObserved (by inObserver : EBObserverProtocol)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
