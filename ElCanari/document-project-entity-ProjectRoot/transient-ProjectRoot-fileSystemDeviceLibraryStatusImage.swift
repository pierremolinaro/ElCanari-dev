//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_ProjectRoot_fileSystemDeviceLibraryStatusImage (
       _ self_mDevices_mFileSystemStatusRequiresAttention : [any DeviceInProject_mFileSystemStatusRequiresAttention]
) -> NSImage {
//--- START OF USER ZONE 2
         var result = false
         var idx = 0
         while !result && idx < self_mDevices_mFileSystemStatusRequiresAttention.count {
           result = self_mDevices_mFileSystemStatusRequiresAttention [idx].mFileSystemStatusRequiresAttention
           idx += 1
         }
         return result ? NSImage.statusWarning : NSImage ()
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------