import AppKit

//--------------------------------------------------------------------------------------------------

@MainActor private var gStream : FSEventStreamRef? = nil
@MainActor private var gConfigureLibraryFileSystemObservationTriggered = false

//--------------------------------------------------------------------------------------------------

@MainActor func configureLibraryFileSystemObservation () {
  if !gConfigureLibraryFileSystemObservationTriggered {
    gConfigureLibraryFileSystemObservationTriggered = true
    DispatchQueue.main.asyncAfter (deadline: .now ().advanced (by: .milliseconds (250))) {
      gConfigureLibraryFileSystemObservationTriggered = false
      gPreferences?.configureLibraryFileSystemObservation ()
    }
  }
}

//--------------------------------------------------------------------------------------------------

extension Preferences {
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func configureLibraryFileSystemObservation () {
    self.updateLibrariesUserInterfaceStatus ()
  //--- If the stream was already created, remove it
    if let previousStream = unsafe gStream {
      unsafe FSEventStreamStop (previousStream)
      unsafe FSEventStreamInvalidate (previousStream)
      unsafe FSEventStreamRelease (previousStream)
      unsafe gStream = nil
    }
  //--- Use an FSEvent for tracking Canari System Library changes
    let pathsToWatch : [String] = [systemLibraryPath ()] + existingLibraryPathArray ()
  //--- Latency
    let latency : CFTimeInterval = 1.0 // Latency in seconds
  //--- Flags
    let streamCreationFlags = FSEventStreamCreateFlags (
      kFSEventStreamCreateFlagWatchRoot // Request notifications of changes along the path to the path(s) you're watching.
    )
  //--- Call back function
    let callback: FSEventStreamCallback = {
      (streamRef, clientCallBackInfo, numEvents, eventPaths, eventFlags, eventIds) -> Void
    in
      unsafe callbackForFSEvent (
        streamRef: streamRef,
        clientCallBackInfo: clientCallBackInfo,
        numEvents: numEvents,
        eventPaths: eventPaths,
        eventFlags: eventFlags,
        eventIds: eventIds
      )
    }
  //--- Create the stream
    unsafe gStream = unsafe FSEventStreamCreate (
      kCFAllocatorDefault,
      callback,
      nil,
      pathsToWatch as CFArray,
      FSEventStreamEventId (kFSEventStreamEventIdSinceNow),
      latency,
      streamCreationFlags
    )
    if let stream = unsafe gStream {
      unsafe FSEventStreamSetDispatchQueue (stream, DispatchQueue.main)
      unsafe FSEventStreamStart (stream)
      runCallbackForFSEvent ()
//      Swift.print ("Start observing \(pathsToWatch)")
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

@MainActor fileprivate
func callbackForFSEvent (streamRef /*inStreamRef*/ : ConstFSEventStreamRef,
                         clientCallBackInfo /*inClientCallBackInfo*/ : UnsafeMutableRawPointer?,
                         numEvents /*inNumEvents*/ : Int,
                         eventPaths /*inEventPaths*/ : UnsafeMutableRawPointer,
                         eventFlags /*inEventFlags*/ : UnsafePointer <FSEventStreamEventFlags>?,
                         eventIds /*inEventIds*/ : UnsafePointer <FSEventStreamEventId>?) {
  runCallbackForFSEvent ()
}

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate func runCallbackForFSEvent () {
  gPreferences?.updateLibrariesUserInterfaceStatus ()
  gPreferences?.checkFileSystemLibrary ()
  for document in NSDocumentController.shared.documents {
    if let deviceDocument = document as? AutoLayoutDeviceDocument {
      deviceDocument.triggerStandAlonePropertyComputationForDeviceDocument ()
    }else if let projectDocument = document as? AutoLayoutProjectDocument {
      projectDocument.triggerStandAlonePropertyComputationForProject ()
    }else if let mergerDocument = document as? AutoLayoutMergerDocument {
      mergerDocument.triggerStandAlonePropertyComputationForMerger ()
    }
  }
}

//--------------------------------------------------------------------------------------------------
