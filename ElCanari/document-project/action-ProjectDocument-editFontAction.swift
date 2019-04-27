//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ProjectDocument {
  @objc func editFontAction (_ sender : NSObject?) {
//--- START OF USER ZONE 2
        let selectedFonts = self.mProjectFontController.selectedArray_property.propval
        let dc = NSDocumentController.shared 
        var messages = [String] ()
        for font in selectedFonts {
          let pathes = fontFilePathInLibraries (font.mFontName)
          if pathes.count == 0 {
            messages.append ("No file for \(font.mFontName) font in Library")
          }else if pathes.count == 1 {
            let url = URL (fileURLWithPath: pathes [0])
            dc.openDocument (withContentsOf: url, display: true) {(document : NSDocument?, alreadyOpen : Bool, error : Error?) in }
          }else{ // pathes.count > 1
            messages.append ("Several files for \(font.mFontName) font in Library:")
            for path in pathes {
              messages.append ("  - \(path)")
            }
          }
        }
        if messages.count > 0 {
          let alert = NSAlert ()
          alert.messageText = "Error opening Font"
          alert.informativeText = messages.joined (separator: "\n")
          alert.beginSheetModal (for: self.windowForSheet!, completionHandler: nil)
        }
//--- END OF USER ZONE 2
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————