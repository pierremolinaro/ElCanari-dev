import AppKit

//--------------------------------------------------------------------------------------------------

@MainActor private var gStream : FSEventStreamRef? = nil
@MainActor private var gPreferences : Preferences? = nil

//--------------------------------------------------------------------------------------------------

@MainActor func configureLibraryFileSystemObservation () {
  gPreferences?.configureLibraryFileSystemObservation ()
}

//--------------------------------------------------------------------------------------------------

extension Preferences {
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func configureLibraryFileSystemObservation () {
    gPreferences = self
    self.updateLibrariesUserInterfaceStatus ()
  //--- If the stream was already created, remove it
    if let previousStream = gStream {
      FSEventStreamStop (previousStream)
      FSEventStreamInvalidate (previousStream)
      FSEventStreamRelease (previousStream)
      gStream = nil
    }
  //--- Use an FSEvent for tracking Canari System Library changes
    let pathsToWatch : [String] = [systemLibraryPath ()] + existingLibraryPathArray ()
  //--- Latency
    let latency : CFTimeInterval = 1.0 // Latency in seconds
  //--- Flags
    let streamCreationFlags = FSEventStreamCreateFlags (
//      kFSEventStreamCreateFlagUseCFTypes |
      kFSEventStreamCreateFlagWatchRoot // Request notifications of changes along the path to the path(s) you're watching.
    )
  //--- Call back function
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
  //--- Create the stream
    gStream = FSEventStreamCreate (
      kCFAllocatorDefault,
      callback,
      nil,
      pathsToWatch as CFArray,
      FSEventStreamEventId (kFSEventStreamEventIdSinceNow),
      latency,
      streamCreationFlags
    )
    if let stream = gStream {
      FSEventStreamSetDispatchQueue (stream, DispatchQueue.main)
//      FSEventStreamScheduleWithRunLoop (stream, CFRunLoopGetMain (), "" as CFString) // Deprecated
      FSEventStreamStart (stream)
      Swift.print ("Start observing \(pathsToWatch)")
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func updateLibrariesUserInterfaceStatus () {
    let fm = FileManager ()
  //--- System Library
 //   do{
      let path = systemLibraryPath ()
      let pathExists = fm.fileExists (atPath: path)
      self.mRevealInFinderSystemLibraryButton?.toolTip = path
      self.mRevealInFinderSystemLibraryButton?.title = path
      self.mRevealInFinderSystemLibraryButton?.isEnabled = pathExists
//    }
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
// https://stackoverflow.com/questions/31173903/swift-2-cannot-invoke-fseventstreamcreate-with-an-argument-list-of-type
//--------------------------------------------------------------------------------------------------

@MainActor fileprivate func callbackForFSEvent (streamRef _ : ConstFSEventStreamRef,
                                    clientCallBackInfo _ : UnsafeMutableRawPointer?,
                                    numEvents _ : Int,
                                    eventPaths _ : UnsafeMutableRawPointer,
                                    eventFlags _ : UnsafePointer <FSEventStreamEventFlags>?,
                                    eventIds _ : UnsafePointer <FSEventStreamEventId>?) {
  gPreferences?.updateLibrariesUserInterfaceStatus ()
  for document in NSDocumentController.shared.documents {
    if let deviceDocument = document as? AutoLayoutDeviceDocument {
      deviceDocument.checkEmbeddedPackagesAndSymbols ()
    }
  }
}

//--------------------------------------------------------------------------------------------------
