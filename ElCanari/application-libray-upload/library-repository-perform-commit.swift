//
//  library-repository-commit.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 02/02/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CanariLibraryEntry {

  //····················································································································

  @objc internal func repositorPerformCommitAction (_ inSender : Any?) {
    if let logTextView = g_Preferences?.mLibraryRepositoryLogTextView {
      self.repositorPerformCommit (logTextView)
    }
  }

  //····················································································································

  internal func repositorPerformCommit (_ inLogTextView : NSTextView) {
    let (possibleCurrentCommit, operations) = status (inLogTextView)
    if let currentCommit = possibleCurrentCommit {
      var needsToWriteCommitFile = false
      for op in operations {
        switch op.mOperation {
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
        alert.addButton (withTitle: "Ok")
        alert.addButton (withTitle: "Cancel")
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
          switch op.mOperation {
          case .remove :
            inLogTextView.appendMessageString ("Remove \(op.mRelativePath)\n")
          case .nop :
            ()
            // inLogTextView.appendMessageString ("No change for \(op.mRelativePath)\n")
          case .upload :
            inLogTextView.appendMessageString ("Upload \(op.mRelativePath) (\(op.mLength) bytes)... ")
            let localFullPath = self.mPath + "/" + op.mRelativePath
            let remoteRelativePath = "files/\(op.mCommit)/" + op.mRelativePath
            let r = writeRemoteFile (remoteRelativePath, url: self.mLibraryRepositoryURL, userPwd: self.mUserAndPasswordTag, localFullPath)
            switch r {
            case .error (let status) :
              inLogTextView.appendErrorString ("error  \(status)\n")
              ok = false
            case .ok (_) :
              inLogTextView.appendSuccessString ("ok\n")
            }
          case .upgrade :
            inLogTextView.appendMessageString ("Upgrade \(op.mRelativePath) (\(op.mLength) bytes)... ")
            let localFullPath = self.mPath + "/" + op.mRelativePath
            let remoteRelativePath = "files/\(op.mCommit)/" + op.mRelativePath
            let r = writeRemoteFile (remoteRelativePath, url: self.mLibraryRepositoryURL, userPwd: self.mUserAndPasswordTag, localFullPath)
            switch r {
            case .error (let status) :
              inLogTextView.appendErrorString ("error  \(status)\n")
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
          switch op.mOperation {
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
                g_Preferences?.mLibraryRepositoryCurrentReleaseTextField?.stringValue = "\(currentCommit+1)"
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

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
