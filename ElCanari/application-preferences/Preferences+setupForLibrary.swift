import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor private var gStream : FSEventStreamRef? = nil
@MainActor private var gPreferences : Preferences? = nil

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// https://stackoverflow.com/questions/31173903/swift-2-cannot-invoke-fseventstreamcreate-with-an-argument-list-of-type
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func callbackForFSEvent (streamRef : ConstFSEventStreamRef,
                                    clientCallBackInfo : UnsafeMutableRawPointer?,
                                    numEvents : Int,
                                    eventPaths : UnsafeMutableRawPointer,
                                    eventFlags : UnsafePointer <FSEventStreamEventFlags>?,
                                    eventIds : UnsafePointer <FSEventStreamEventId>?) {
  gPreferences?.updateForLibrary ()
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension Preferences {
  
  //····················································································································

  final func setupForLibrary () {
    gPreferences = self
    self.updateForLibrary ()
  //--- Use an FSEvent for tracking Canari System Library changes
    let pathsToWatch : [String] = [systemLibraryPath (), userLibraryPath ()]
  //--- Latency
    let latency : CFTimeInterval = 1.0 // Latency in seconds
  //---
    let callback: FSEventStreamCallback = {
      (streamRef, clientCallBackInfo, numEvents, eventPaths, eventFlags, eventIds) -> Void
    in
      callbackForFSEvent (
        streamRef: streamRef,
        clientCallBackInfo: clientCallBackInfo,
        numEvents: numEvents,
        eventPaths: eventPaths,
        eventFlags: eventFlags,
        eventIds: eventIds
      )
    }
  //--- Create the stream, passing in a callback
    gStream = FSEventStreamCreate (
      kCFAllocatorDefault,
      callback,
      nil,
      pathsToWatch as CFArray, // pathsToWatch,
      FSEventStreamEventId (kFSEventStreamEventIdSinceNow),
      latency,
      FSEventStreamCreateFlags (kFSEventStreamCreateFlagNoDefer | kFSEventStreamCreateFlagWatchRoot)
    )
    if let stream = gStream {
      FSEventStreamScheduleWithRunLoop (stream, CFRunLoopGetMain (), "" as CFString)
      FSEventStreamStart (stream)
    }
  }

  //····················································································································

  func updateForLibrary () {
    let fm = FileManager ()
  //--- System Library
    do{
      let path = systemLibraryPath ()
      let pathExists = fm.fileExists (atPath: path)
      self.mRevealInFinderSystemLibraryButton?.toolTip = path
      self.mRevealInFinderSystemLibraryButton?.title = path
      self.mRevealInFinderSystemLibraryButton?.isEnabled = pathExists
    }
  //--- User Library
//    do{
//      let path = userLibraryPath ()
//      let pathExists = fm.fileExists (atPath: path)
//      self.mRevealInFinderSystemLibraryButton?.toolTip = path
//      self.mRevealInFinderSystemLibraryButton?.title = path
//      self.mRevealInFinderSystemLibraryButton?.isEnabled = pathExists
//      self.mUseLibraryInUserApplicationSupportPathCheckBox?.isEnabled = pathExists
//    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
