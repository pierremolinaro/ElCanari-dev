import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private var gStream : FSEventStreamRef?
private var gPreferences : Preferences?

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// https://stackoverflow.com/questions/31173903/swift-2-cannot-invoke-fseventstreamcreate-with-an-argument-list-of-type

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func callbackForFSEvent (_ streamRef : ConstFSEventStreamRef,
                         clientCallBackInfo : UnsafeMutableRawPointer?,
                         numEvents : Int,
                         eventPaths : UnsafeMutableRawPointer,
                         eventFlags : UnsafePointer<FSEventStreamEventFlags>?,
                         eventIds : UnsafePointer<FSEventStreamEventId>?) {
  gPreferences?.updateForLibrary ()
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension Preferences {
  
  //····················································································································

  func setupForLibrary () {
    gPreferences = self
    self.updateForLibrary ()
  //--- Set update box title
    mUpdateSystemLibraryBox?.title = "Updating " + systemLibraryPath ()
  //--- Use an FSEvent for tracking Canari System Library changes
    let pathsToWatch : [String] = [systemLibraryPath (), userLibraryPath ()]
  //--- Latency
    let latency : CFTimeInterval = 1.0 // Latency in seconds
  //---
    let callback: FSEventStreamCallback = {
      (streamRef, clientCallBackInfo, numEvents, eventPaths, eventFlags, eventIds) -> Void
    in
      callbackForFSEvent (streamRef,
                          clientCallBackInfo: clientCallBackInfo,
                          numEvents: numEvents,
                          eventPaths: eventPaths,
                          eventFlags: eventFlags,
                          eventIds: eventIds)
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
    FSEventStreamScheduleWithRunLoop (gStream!, CFRunLoopGetCurrent(), "" as CFString)
    FSEventStreamStart (gStream!)
  }

  //····················································································································

  func updateForLibrary () {
    let fm = FileManager ()
  //--- System Library
    do{
      let path = systemLibraryPath ()
      let pathExists = fm.fileExists (atPath: path)
//      mRevealInFinderLibraryInSystemApplicationSupportButton?.toolTip = path
 //     mRevealInFinderLibraryInSystemApplicationSupportButton?.title = path
//      mRevealInFinderLibraryInSystemApplicationSupportButton?.isEnabled = pathExists
      mRevealInFinderLibraryInUserApplicationSupportButton?.isEnabled = pathExists
    }
  //--- User Library
    do{
      let path = userLibraryPath ()
      let pathExists = fm.fileExists (atPath: path)
      mRevealInFinderLibraryInUserApplicationSupportButton?.toolTip = path
      mRevealInFinderLibraryInUserApplicationSupportButton?.title = path
      mRevealInFinderLibraryInUserApplicationSupportButton?.isEnabled = pathExists
      mUseLibraryInUserApplicationSupportPathCheckBox?.isEnabled = pathExists
//      mCreateLibraryInSystemApplicationSupportButton?.isEnabled = !pathExists
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
