//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
// https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/storing_keys_in_the_keychain
//----------------------------------------------------------------------------------------------------------------------

extension CanariLibraryEntry {

  //····················································································································

  internal func showUploadDialog (_ inLibraryPath : String) {
    if let window = g_Preferences?.mLibraryUploadWindow {
      window.title = "Library Repository Management for " + inLibraryPath
    //--- User and password
      self.set (userAndPassword: self.mUserAndPasswordTag)
    //--- Commit button
      g_Preferences?.mLibraryRepositoryCommitButton?.target = self
      g_Preferences?.mLibraryRepositoryCommitButton?.action = #selector (repositorPerformCommitAction (_:))
    //--- Set repository action
      g_Preferences?.mSetUserAndPasswordButton?.target = self
      g_Preferences?.mSetUserAndPasswordButton?.action = #selector (showDefineUserAndPasswordDialogAction (_:))
    //--- Repository name
      self.set (repositoryURL: self.mLibraryRepositoryURL)
    //--- Status button
      g_Preferences?.mLibraryRepositoryStatusButton?.target = self
      g_Preferences?.mLibraryRepositoryStatusButton?.action = #selector (showStatusAction (_:))
    //--- Set repository action
      g_Preferences?.mSetLibraryRepositoryButton?.target = self
      g_Preferences?.mSetLibraryRepositoryButton?.action = #selector (showDefineRepositoryDialogAction (_:))
    //--- Current release text field
      g_Preferences?.mLibraryRepositoryCurrentReleaseTextField?.stringValue = "— not loaded —"
    //--- Load current release action
      g_Preferences?.mLibraryRepositoryLoadCurrentReleaseButton?.target = self
      g_Preferences?.mLibraryRepositoryLoadCurrentReleaseButton?.action = #selector (loadRepositorCurrentCommitAction (_:))
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

  @objc private func showStatusAction (_ inSender : Any?) {
    if let logTextView = g_Preferences?.mLibraryRepositoryLogTextView {
      _ = self.status (logTextView)
    }
  }

  //····················································································································

  @objc private func showDefineUserAndPasswordDialogAction (_ inSender : Any?) {
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
      alert.beginSheetModal (for: window) { response in
        if response == .alertFirstButtonReturn {
          self.mUserAndPasswordTag = tf.stringValue
          self.set (userAndPassword: tf.stringValue)
          self.updateLibraryRepositoryLoadCurrentReleaseButton ()
        }
      }
    }
  }

  //····················································································································

  @objc private func showDefineRepositoryDialogAction (_ inSender : Any?) {
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
      alert.beginSheetModal (for: window) { response in
        if response == .alertFirstButtonReturn {
          self.mLibraryRepositoryURL = tf.stringValue
          self.set (repositoryURL: tf.stringValue)
          self.updateLibraryRepositoryLoadCurrentReleaseButton ()
        }
      }
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

//----------------------------------------------------------------------------------------------------------------------
