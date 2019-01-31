//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CanariLibraryEntry {

  //····················································································································

  internal func showUploadDialog (_ inLibraryPath : String) {
    if let window = g_Preferences?.mLibraryUploadWindow {
      window.title = "Library Repository Management for " + inLibraryPath
    //--- User and password
      self.set (userAndPassword: self.mUserAndPasswordTag)
    //--- Set repository action
      g_Preferences?.mSetUserAndPasswordButton?.target = self
      g_Preferences?.mSetUserAndPasswordButton?.action = #selector (showDefineUserAndPasswordDialogAction (_:))
    //--- Repository name
      self.set (repositoryURL: self.mLibraryRepositoryURL)
    //--- Set repository action
      g_Preferences?.mSetLibraryRepositoryButton?.target = self
      g_Preferences?.mSetLibraryRepositoryButton?.action = #selector (showDefineRepositoryDialogAction (_:))
    //--- Current release text field
      g_Preferences?.mLibraryRepositoryCurrentReleaseTextField?.stringValue = "— not loaded —"
    //--- Load current release action
      g_Preferences?.mLibraryRepositoryLoadCurrentReleaseButton?.target = self
      g_Preferences?.mLibraryRepositoryLoadCurrentReleaseButton?.action = #selector (loadRepositorCurrentReleaseAction (_:))
      self.updateLibraryRepositoryLoadCurrentReleaseButton ()
    //--- Dialog
      _ = NSApp.runModal (for: window)
      window.orderOut (nil)
    }
  }

  //····················································································································

  private func updateLibraryRepositoryLoadCurrentReleaseButton () {
    let enable = (self.mLibraryRepositoryURL != "") && (self.mUserAndPasswordTag != "")
    g_Preferences?.mLibraryRepositoryLoadCurrentReleaseButton?.isEnabled = enable
  }

  //····················································································································

  @objc func loadRepositorCurrentReleaseAction (_ inSender : Any?) {
    let response = readRemoteFile ("last-commit", self.mLibraryRepositoryURL, userPwd: self.mUserAndPasswordTag)
    switch response {
    case .error (let status) :
      g_Preferences?.mLibraryRepositoryCurrentReleaseTextField?.stringValue = "Error \(status)"
    case .ok (let data) :
      if let s = String (data: data, encoding: .utf8) {
        g_Preferences?.mLibraryRepositoryCurrentReleaseTextField?.stringValue = s
      }else{
        g_Preferences?.mLibraryRepositoryCurrentReleaseTextField?.stringValue = "invalid value"
      }
    }
  }

  //····················································································································

  @objc func showDefineUserAndPasswordDialogAction (_ inSender : Any?) {
    if let window = g_Preferences?.mLibraryUploadWindow {
      let alert = NSAlert ()
      alert.messageText = "User and password:"
      alert.addButton (withTitle: "Ok")
      alert.addButton (withTitle: "Cancel")
    //--- Textfield
      let tf = NSTextField (frame: NSRect (x: 0.0, y: 0.0, width: 400.0, height: 22.0))
      tf.isEnabled = true
      tf.isEditable = true
      tf.stringValue = self.mUserAndPasswordTag
      tf.drawsBackground = true
      tf.isBordered = false
      tf.bezelStyle = .squareBezel
      alert.accessoryView = tf
    //---
      alert.beginSheetModal (for: window, completionHandler: { response in
        if response == .alertFirstButtonReturn {
          self.mUserAndPasswordTag = tf.stringValue
          self.set (userAndPassword: tf.stringValue)
          self.updateLibraryRepositoryLoadCurrentReleaseButton ()
        }
      })
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
          self.updateLibraryRepositoryLoadCurrentReleaseButton ()
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

  private func set (userAndPassword : String) {
    let title : String
    if userAndPassword == "" {
      title = "— undefined —"
    }else{
      title = String (repeating: "•", count: userAndPassword.count)
    }
    g_Preferences?.mUserAndPasswordTextField?.stringValue = title
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
