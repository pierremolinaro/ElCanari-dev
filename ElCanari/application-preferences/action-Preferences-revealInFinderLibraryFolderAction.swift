//--- START OF USER ZONE 1


//--- END OF USER ZONE 1
//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension Preferences {
  @objc func revealInFinderLibraryFolderAction (_ inSender : NSObject?) {
//--- START OF USER ZONE 2
        let array = preferences_userLibraryArrayController.selectedArray_property.propval
        if array.count == 1 {
          let entry = array [0]
          if NSApplication.shared.currentEvent?.modifierFlags.contains (.option) ?? false {
            entry.showUploadDialog ()
          }else{
            NSWorkspace.shared.open (URL (fileURLWithPath: entry.mPath))
          }
        }
//--- END OF USER ZONE 2
  }
}

//--------------------------------------------------------------------------------------------------
