//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CanariLibraryEntry {

  //····················································································································

  internal func showUploadDialog (_ inLibraryPath : String) {
    if let window = g_Preferences?.mLibraryUploadWindow {
      window.title = "Library Repository Management for " + inLibraryPath
    //--- Reposition name
      self.set (repositoryURL: self.mLibraryRepositoryURL)
    //--- Set repository action
      g_Preferences?.mSetLibraryRepositoryButton?.target = self
      g_Preferences?.mSetLibraryRepositoryButton?.action = #selector (showDefineRepositoryDialogAction (_:))
    //--- Dialog
      window.makeKeyAndOrderFront (nil)
    }
  }

  //····················································································································

  @objc func showDefineRepositoryDialogAction (_ inSender : Any?) {
    if let window = g_Preferences?.mLibraryUploadWindow {
      let alert = NSAlert ()
      alert.messageText = "Repository URL:"
      alert.addButton (withTitle: "Ok")
      alert.addButton (withTitle: "Cancel")
    //--- Textfield
      let tf = NSTextField (frame: NSRect (x: 0.0, y: 0.0, width: 400.0, height: 22.0))
      tf.isEnabled = true
      tf.isEditable = true
      tf.stringValue = self.mLibraryRepositoryURL
      tf.drawsBackground = true
      tf.isBordered = false
      tf.bezelStyle = .squareBezel
      alert.accessoryView = tf
    //---
      alert.beginSheetModal (for: window, completionHandler: { response in
        if response == .alertFirstButtonReturn {
          self.mLibraryRepositoryURL = tf.stringValue
          self.set (repositoryURL: tf.stringValue)
        }
      })
    }
  }

  //····················································································································

  private func set (repositoryURL : String) {
    let title = (repositoryURL == "") ? "— undefined —" : repositoryURL
    g_Preferences?.mLibraryRepositoryTextField?.stringValue = title
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
