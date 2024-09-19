//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

@MainActor protocol EBObservableObjectProtocol : AnyObject {
  func startsBeingObserved (by inObserver : any EBObserverProtocol)
  func stopsBeingObserved (by inObserver : any EBObserverProtocol)
}

//--------------------------------------------------------------------------------------------------
