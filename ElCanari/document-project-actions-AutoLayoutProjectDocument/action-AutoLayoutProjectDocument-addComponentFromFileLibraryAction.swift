//--- START OF USER ZONE 1


//--- END OF USER ZONE 1
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {
  @objc func addComponentFromFileLibraryAction (_ inSender : NSObject?) {
//--- START OF USER ZONE 2
        if self.rootObject.mFonts.count == 0 {
          let alert = NSAlert ()
          alert.messageText = "Cannot Currently Add a Component: first, you need to add a Font."
          alert.informativeText = "This project does not embed any font. A font is needed for displaying component name and value in board."
          _ = alert.addButton (withTitle: "Add Font")
          _ = alert.addButton (withTitle: "Cancel")
          alert.beginSheetModal (for: self.windowForSheet!) {(inReturnCode : NSApplication.ModalResponse) in
            if (inReturnCode == .alertFirstButtonReturn) {
              self.addFont (postAction: self.addComponentDialog)
            }
          }
        }else{
          self.addComponentDialog ()
        }
//--- END OF USER ZONE 2
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————