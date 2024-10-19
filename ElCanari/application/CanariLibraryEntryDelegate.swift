//
//  CanariLibraryEntryDelegate.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 09/11/2015.
//
//
//--------------------------------------------------------------------------------------------------
//  http://blog.beecomedigital.com/2015/06/27/developing-a-filesystemwatcher-for-os-x-by-using-fsevents-with-swift-2/
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class CanariLibraryEntryDelegate : EBObserverProtocol {
  
  private weak var mObject : CanariLibraryEntry? // SHOULD BE WEAK

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (object inObject : CanariLibraryEntry) {
    self.mObject = inObject
    inObject.mPath_property.startsBeingObserved (by: self)
    inObject.mUses_property.startsBeingObserved (by: self)
    noteObjectAllocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func observedObjectDidChange () {
    configureLibraryFileSystemObservation ()
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
