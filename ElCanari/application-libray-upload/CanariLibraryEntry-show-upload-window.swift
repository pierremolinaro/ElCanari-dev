//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
// https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/storing_keys_in_the_keychain
//--------------------------------------------------------------------------------------------------

@MainActor final class LibraryUploadDialog {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Properties
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let mLibraryUploadWindow : NSPanel
  let mSetLibraryRepositoryButton = AutoLayoutButton (title: "Repository…", size: .regular)
  let mLibraryRepositoryTextField = AutoLayoutLabel (bold: false, size: .regular).expandableWidth ().set (alignment: .left)
  let mSetUserAndPasswordButton = AutoLayoutButton (title: "User and Password…", size: .regular)
  let mUserAndPasswordTextField = AutoLayoutLabel (bold: false, size: .regular).expandableWidth ().set (alignment: .left)

  let mLibraryRepositoryLoadCurrentReleaseButton = AutoLayoutButton (title: "Current Release", size: .regular)
  let mLibraryRepositoryCurrentReleaseTextField = AutoLayoutLabel (bold: false, size: .regular).expandableWidth ().set (alignment: .left)
  let mLibraryRepositoryStatusButton = AutoLayoutButton (title: "Status", size: .regular)
  let mLibraryRepositoryCommitButton = AutoLayoutButton (title: "Commit…", size: .regular)

  let mLibraryRepositoryLogTextView = AutoLayoutStaticTextView (drawsBackground: true, horizontalScroller: false, verticalScroller: true)
    .expandableWidth ()
    .expandableHeight ()

  let mLibraryRepositoryCloseButton : AutoLayoutSheetDefaultOkButton

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  init
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (title inTitle : String,
        userAndPassword inUserAndPassword : String,
        repositoryURL inRepositoryURL : String) {
  //--- User and Password
    let title : String
    if inUserAndPassword.isEmpty {
      title = "— undefined —"
    }else{
      title = String (repeating: "•", count: inUserAndPassword.count)
    }
    self.mUserAndPasswordTextField.stringValue = title
  //--- Repository URL
    self.mLibraryRepositoryTextField.stringValue = (inRepositoryURL.isEmpty) ? "— undefined —" : inRepositoryURL
  //--- Current release text field
    self.mLibraryRepositoryCurrentReleaseTextField.stringValue = "— not loaded —"
  //--- Build Panel
    self.mLibraryUploadWindow = NSPanel (
      contentRect: NSRect (x: 0, y: 0, width: 600, height: 400),
      styleMask: [.titled, .resizable],
      backing: .buffered,
      defer: false
    )
    self.mLibraryUploadWindow.title = inTitle
    self.mLibraryUploadWindow.hasShadow = true
    self.mLibraryRepositoryCloseButton = AutoLayoutSheetDefaultOkButton (
      title: "Close",
      size: .regular,
      sheet: self.mLibraryUploadWindow
    )
  //--- Main view
    let mainView = AutoLayoutVerticalStackView ().set (margins: 20)
  //--- Grid view
    let gridView = AutoLayoutGridView2 ()
      .addFirstBaseLineAligned (left: self.mSetLibraryRepositoryButton, right: self.mLibraryRepositoryTextField)
      .addFirstBaseLineAligned (left: self.mSetUserAndPasswordButton, right: self.mUserAndPasswordTextField)
      .addSeparator ()
      .addFirstBaseLineAligned (left: self.mLibraryRepositoryLoadCurrentReleaseButton, right: self.mLibraryRepositoryCurrentReleaseTextField)
      .addFirstBaseLineAligned (left: self.mLibraryRepositoryStatusButton, right: AutoLayoutHorizontalStackView.viewFollowedByFlexibleSpace (self.mLibraryRepositoryCommitButton))
    _ = mainView.appendView (gridView)
  //--- Log Text View
    _ = mainView.appendView (self.mLibraryRepositoryLogTextView)
  //--- Last line
    let lastLine = AutoLayoutHorizontalStackView ()
    _ = lastLine.appendFlexibleSpace ()
    _ = lastLine.appendView (self.mLibraryRepositoryCloseButton)
    _ = mainView.appendView (lastLine)
  //--- Set autolayout view to panel
    self.mLibraryUploadWindow.contentView = AutoLayoutViewByPrefixingAppIcon (prefixedView: AutoLayoutWindowContentView (view: mainView))
    noteObjectAllocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func runModal () {
    _ = NSApplication.shared.runModal (for: self.mLibraryUploadWindow)
    self.mLibraryUploadWindow.orderOut (nil)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate var gLibraryUploadDialog : LibraryUploadDialog? = nil

//--------------------------------------------------------------------------------------------------

extension CanariLibraryEntry {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func showUploadDialog () {
  //--- Setup dialog
    let dialog = LibraryUploadDialog (
      title: "Library Repository Management for " + self.mPath,
      userAndPassword: self.mUserAndPasswordTag,
      repositoryURL: self.mLibraryRepositoryURL
    )
    gLibraryUploadDialog = dialog
  //--- Set repository action
    dialog.mSetUserAndPasswordButton.target = self
    dialog.mSetUserAndPasswordButton.action = #selector (Self.showDefineUserAndPasswordDialogAction (_:))
  //--- Commit button
    dialog.mLibraryRepositoryCommitButton.target = self
    dialog.mLibraryRepositoryCommitButton.action = #selector (Self.repositorPerformCommitAction (_:))
  //--- Status button
    dialog.mLibraryRepositoryStatusButton.target = self
    dialog.mLibraryRepositoryStatusButton.action = #selector (Self.showStatusAction (_:))
  //--- Set repository action
    dialog.mSetLibraryRepositoryButton.target = self
    dialog.mSetLibraryRepositoryButton.action = #selector (Self.showDefineRepositoryDialogAction (_:))
  //--- Load current release action
    dialog.mLibraryRepositoryLoadCurrentReleaseButton.target = self
    dialog.mLibraryRepositoryLoadCurrentReleaseButton.action = #selector (Self.loadRepositorCurrentCommitAction (_:))
    self.updateLibraryRepositoryLoadCurrentReleaseButton ()
  //--- Dialog
    dialog.runModal ()
  //--- Free dialog
    gLibraryUploadDialog = nil
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func updateLibraryRepositoryLoadCurrentReleaseButton () {
    let enable = (self.mLibraryRepositoryURL != "") && (self.mUserAndPasswordTag != "")
    gLibraryUploadDialog?.mLibraryRepositoryLoadCurrentReleaseButton.isEnabled = enable
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func showStatusAction (_ _ : Any?) {
    if let logTextView = gLibraryUploadDialog?.mLibraryRepositoryLogTextView {
      _ = self.status (logTextView)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func showDefineUserAndPasswordDialogAction (_ _ : Any?) {
    if let window = gLibraryUploadDialog?.mLibraryUploadWindow {
      let alert = NSAlert ()
      alert.messageText = "User and password:"
      _ = alert.addButton (withTitle: "Ok")
      _ = alert.addButton (withTitle: "Cancel")
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func showDefineRepositoryDialogAction (_ _ : Any?) {
    if let window = gLibraryUploadDialog?.mLibraryUploadWindow {
      let alert = NSAlert ()
      alert.messageText = "Repository URL:"
      _ = alert.addButton (withTitle: "Ok")
      _ = alert.addButton (withTitle: "Cancel")
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc func repositorPerformCommitAction (_ _ : Any?) {
    if let logTextView = gLibraryUploadDialog?.mLibraryRepositoryLogTextView {
      self.repositorPerformCommit (logTextView)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func repositorPerformCommit (_ inLogTextView : AutoLayoutStaticTextView) {
    let (possibleCurrentCommit, operations) = status (inLogTextView)
    if let currentCommit = possibleCurrentCommit {
      var needsToWriteCommitFile = false
      for op in operations {
        switch op.operation {
        case .nop :
          ()
        case .remove, .upgrade, .upload :
          needsToWriteCommitFile = true
        }
      }
      var ok = false
      var commitMessage = ""
      if needsToWriteCommitFile {
        let alert = NSAlert ()
        alert.messageText = "Commit message:"
        _ = alert.addButton (withTitle: "Ok")
        _ = alert.addButton (withTitle: "Cancel")
      //--- Textfield
        let tf = NSTextField (frame: NSRect (x: 0.0, y: 0.0, width: 400.0, height: 22.0))
        tf.isEnabled = true
        tf.isEditable = true
        tf.stringValue = ""
        tf.drawsBackground = true
        tf.isBordered = false
        tf.bezelStyle = .squareBezel
        alert.accessoryView = tf
        let response = alert.runModal ()
        if response == .alertFirstButtonReturn {
          commitMessage = tf.stringValue
          ok = true
        }
      }
    //--- Upload files
      if ok {
        for op in operations {
          switch op.operation {
          case .remove :
            inLogTextView.appendMessageString ("Remove \(op.relativePath)\n")
          case .nop :
            ()
            // inLogTextView.appendMessageString ("No change for \(op.relativePath)\n")
          case .upload :
            inLogTextView.appendMessageString ("Upload \(op.relativePath) (\(op.length.stringWithSeparators) bytes)... ")
            let localFullPath = self.mPath + "/" + op.relativePath
            let remoteRelativePath = "files/\(op.commit)/" + op.relativePath
            let r = writeRemoteFile (remoteRelativePath, url: self.mLibraryRepositoryURL, userPwd: self.mUserAndPasswordTag, localFullPath)
            switch r {
            case .error (let status) :
              inLogTextView.appendErrorString ("error \(status)\n")
              ok = false
            case .ok (_) :
              inLogTextView.appendSuccessString ("ok\n")
            }
          case .upgrade :
            inLogTextView.appendMessageString ("Upgrade \(op.relativePath) (\(op.length.stringWithSeparators) bytes)... ")
            let localFullPath = self.mPath + "/" + op.relativePath
            let remoteRelativePath = "files/\(op.commit)/" + op.relativePath
            let r = writeRemoteFile (remoteRelativePath, url: self.mLibraryRepositoryURL, userPwd: self.mUserAndPasswordTag, localFullPath)
            switch r {
            case .error (let status) :
              inLogTextView.appendErrorString ("error \(status)\n")
              ok = false
            case .ok (_) :
              inLogTextView.appendSuccessString ("ok\n")
            }
          }
        }
      }
    //--- Write commit file
      if ok {
        var commitDictionaryArray = [[String : Any]] ()
        var needsToWriteCommitFile = false
        for op in operations {
          switch op.operation {
          case .nop :
            commitDictionaryArray.append (op.dictionary ())
          case .remove :
            needsToWriteCommitFile = true
          case .upgrade, .upload :
            needsToWriteCommitFile = true
            commitDictionaryArray.append (op.dictionary ())
          }
        }
        if !needsToWriteCommitFile {
          inLogTextView.appendMessageString ("Commit file is up to date\n")
        }else{
          inLogTextView.appendMessageString ("Upload commit contents... ")
          if let data = try? PropertyListSerialization.data (fromPropertyList: commitDictionaryArray, format: .binary, options: 0) {
            let remoteRelativePath = "contents/contents-\(currentCommit+1).plist"
            let r = writeRemoteData (remoteRelativePath, url: self.mLibraryRepositoryURL, userPwd: self.mUserAndPasswordTag, data)
            switch r {
            case .error (let status) :
              inLogTextView.appendErrorString ("error \(status)\n")
              ok = false
            case .ok (_) :
              inLogTextView.appendSuccessString ("ok\n")
            }
          }else{
            inLogTextView.appendErrorString ("internal error\n")
            ok = false
          }
        //--- Write commit description file
          if ok {
            inLogTextView.appendMessageString ("Upload commit description... ")
            let dictionary : [String : Any] = [
              "message" : commitMessage,
              "date" : Date ()
            ]
            if let data = try? PropertyListSerialization.data (fromPropertyList: dictionary, format: .binary, options: 0) {
              let remoteRelativePath = "commits/commit-\(currentCommit+1).plist"
              let r = writeRemoteData (remoteRelativePath, url: self.mLibraryRepositoryURL, userPwd: self.mUserAndPasswordTag, data)
              switch r {
              case .error (let status) :
                inLogTextView.appendErrorString ("error \(status)\n")
                ok = false
              case .ok (_) :
                inLogTextView.appendSuccessString ("ok\n")
              }
            }else{
              inLogTextView.appendErrorString ("internal error\n")
              ok = false
            }
          }
        //--- Register commit
          if ok {
            inLogTextView.appendMessageString ("Register commit... ")
            if let data = "\(currentCommit+1)".data (using: .ascii) {
              let remoteRelativePath = "lastCommit.txt"
              let r = writeRemoteData (remoteRelativePath, url: self.mLibraryRepositoryURL, userPwd: self.mUserAndPasswordTag, data)
              switch r {
              case .error (let status) :
                inLogTextView.appendErrorString ("error \(status)\n")
                ok = false
              case .ok (_) :
                inLogTextView.appendSuccessString ("ok\n")
                gLibraryUploadDialog?.mLibraryRepositoryCurrentReleaseTextField.stringValue = "\(currentCommit+1)"
              }
            }else{
              inLogTextView.appendErrorString ("internal error\n")
              ok = false
            }
          }
        }
      }
      if ok {
        inLogTextView.appendSuccessString ("Done\n")
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func set (repositoryURL : String) {
    let title = (repositoryURL.isEmpty) ? "— undefined —" : repositoryURL
    gLibraryUploadDialog?.mLibraryRepositoryTextField.stringValue = title
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func set (userAndPassword : String) {
    let title : String
    if userAndPassword.isEmpty {
      title = "— undefined —"
    }else{
      title = String (repeating: "•", count: userAndPassword.count)
    }
    gLibraryUploadDialog?.mUserAndPasswordTextField.stringValue = title
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc func loadRepositorCurrentCommitAction (_ _ : Any?) {
    _ = self.loadRepositorCurrentCommit ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func loadRepositorCurrentCommit () -> Int? {
    let response = readRemoteFile ("lastCommit.txt", url: self.mLibraryRepositoryURL, userPwd: self.mUserAndPasswordTag)
    let result : Int?
    switch response {
    case .error (let status) :
      gLibraryUploadDialog?.mLibraryRepositoryCurrentReleaseTextField.stringValue = "Error \(status)"
      result = nil
    case .ok (let data) :
      if let s = String (data: data, encoding: .utf8), let currentCommit = Int (s) {
        gLibraryUploadDialog?.mLibraryRepositoryCurrentReleaseTextField.stringValue = "\(currentCommit)"
        result = currentCommit
      }else{
        gLibraryUploadDialog?.mLibraryRepositoryCurrentReleaseTextField.stringValue = "invalid value"
        result = nil
      }
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
