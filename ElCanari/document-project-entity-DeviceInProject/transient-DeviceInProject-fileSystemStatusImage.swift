//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_DeviceInProject_fileSystemStatusImage (
       _ self_mFileSystemStatusRequiresAttention : Bool
) -> NSImage {
//--- START OF USER ZONE 2
  return self_mFileSystemStatusRequiresAttention ? NSImage.statusWarning : NSImage ()
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------