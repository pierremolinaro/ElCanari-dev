//
//  CanariLibraryEntryDelegate.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 09/11/2015.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  http://blog.beecomedigital.com/2015/06/27/developing-a-filesystemwatcher-for-os-x-by-using-fsevents-with-swift-2/
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class CanariLibraryEntryDelegate : EBObserverProtocol {
  
  private weak var mObject : CanariLibraryEntry? // SHOULD BE WEAK
  private var mStream : FSEventStreamRef? = nil

  //····················································································································

  init (object inObject : CanariLibraryEntry) {
    self.mObject = inObject
    inObject.mPath_property.startsToBeObserved (by: self)
    noteObjectAllocation (self)
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  func observedObjectDidChange () {
    let possiblePath = self.mObject?.mPath
  //--- Remove previous monitoring (if any)
    removeFileSystemMonitoring ()
  //--- Install new monitoring
    if let path = possiblePath, "" != path {
    //--- Use an FSEvent for tracking Canari System Library changes
      let pathsToWatch : [String] = [path]
    //--- Latency
      let latency : CFTimeInterval = 1.0 // Latency in seconds
    //--- Set self as context
      var context = FSEventStreamContext (version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
      context.info = UnsafeMutableRawPointer (mutating: Unmanaged.passUnretained (self).toOpaque ())
    //---
      let callback: FSEventStreamCallback = {
        (streamRef, clientCallBackInfo, numEvents, eventPaths, eventFlags, eventIds) -> Void in
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
      let possibleStream = FSEventStreamCreate (
        kCFAllocatorDefault,
        callback, //callbackForLibraryEntryFSEvent,
        &context, // self as context
        pathsToWatch as CFArray, // pathsToWatch,
        FSEventStreamEventId (kFSEventStreamEventIdSinceNow),
        latency,
        FSEventStreamCreateFlags (kFSEventStreamCreateFlagNoDefer | kFSEventStreamCreateFlagWatchRoot)
      )
      if let stream = possibleStream {
        FSEventStreamScheduleWithRunLoop (stream, CFRunLoopGetMain (), "" as CFString) // CFRunLoopMode.defaultMode)
        FSEventStreamStart (stream)
      }
      self.mStream = possibleStream
    }
  }
  
  //····················································································································

//  fileprivate final func monitoredFileDidChange () {
//    self.mObject?.mStatusImage_property.observedObjectDidChange ()
//  }
  
  //····················································································································

  final func removeFileSystemMonitoring () {
    if let stream = self.mStream {
      FSEventStreamStop (stream)
      FSEventStreamInvalidate (stream)
      FSEventStreamRelease (stream)
      self.mStream = nil
    }
  }
  
  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
