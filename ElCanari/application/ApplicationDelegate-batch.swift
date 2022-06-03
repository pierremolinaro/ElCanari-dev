//
//  ApplicationDelegate-maintenance.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/11/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ApplicationDelegate {

  //····················································································································

  @IBAction func showBatchWindow (_ inSender : Any?) {
    self.mBatchWindow.makeKeyAndOrderFront (inSender)
  }

  //····················································································································

  @objc func actionOpenAllDocumentsInDirectory (_ inSender : AnyObject) {
    let extensions = Set (["elcanarisymbol", "elcanaripackage", "elcanaridevice", "elcanarifont", "elcanariartwork", "elcanariproject", "elcanarimerger"])
    self.actionOpenAllDocumentsInDirectory (extensions, "document", inSender)
  }

  //····················································································································

  @objc func actionOpenAllSymbolsInDirectory (_ inSender : Any?) {
    self.actionOpenAllDocumentsInDirectory (["elcanarisymbol"], "symbol", inSender)
  }

  //····················································································································

  @objc func actionOpenAllPackagesInDirectory (_ inSender : Any?) {
    self.actionOpenAllDocumentsInDirectory (["elcanaripackage"], "package", inSender)
  }

  //····················································································································

  @objc func actionOpenAllDevicesInDirectory (_ inSender : Any?) {
    self.actionOpenAllDocumentsInDirectory (["elcanaridevice"], "device", inSender)
  }

  //····················································································································

  @objc func actionOpenAllFontsInDirectory (_ inSender : Any?) {
    self.actionOpenAllDocumentsInDirectory (["elcanarifont"], "font", inSender)
  }

  //····················································································································

  private func actionOpenAllDocumentsInDirectory (_ extensions : Set <String>, _ inTitle : String, _ inSender : Any?) {
    if let button = inSender as? NSButton, let window = button.window {
      self.mMaintenanceLogTextView.string = ""
      self.mMaintenanceLogTextField.stringValue = ""
      let op = NSOpenPanel ()
      op.allowsMultipleSelection = false
      op.canChooseDirectories = true
      op.canChooseFiles = false
      op.beginSheetModal (for: window) { (_ response : NSApplication.ModalResponse) in
        op.orderOut (nil)
        if response == .OK {
          let baseDirectory : String = op.urls [0].path
          let fm = FileManager ()
          let dc = NSDocumentController ()
          var retainedFiles = [String] ()
          if let files = fm.subpaths (atPath: baseDirectory) {
            for f in files {
              if f.first! != "." {
                let fullPath = baseDirectory + "/" + f
                if extensions.contains (fullPath.pathExtension.lowercased ()) {
                  retainedFiles.append (fullPath)
                }
              }
            }
          }
          if retainedFiles.count == 0 {
            let alert = NSAlert ()
            alert.messageText = "No \(inTitle) to Open"
            alert.beginSheetModal (for: window)
          }else{
            let alert = NSAlert ()
            alert.messageText = "Open \(retainedFiles.count) \(inTitle)\((retainedFiles.count > 1) ? "s" : "")? You cannot cancel this operation."
            alert.addButton (withTitle: "Ok")
            alert.addButton (withTitle: "Cancel")
            alert.beginSheetModal (for: window) { (response : NSApplication.ModalResponse) in
              if response == .alertFirstButtonReturn {
                let message = "Opening \(retainedFiles.count) \(inTitle)\((retainedFiles.count > 1) ? "s" : "")\n"
                self.mMaintenanceLogTextView.appendMessageString (message)
                var count = 0
                for fullPath in retainedFiles {
                  dc.openDocument (
                    withContentsOf: URL (fileURLWithPath: fullPath),
                    display: true
                  ){ (document : NSDocument?, documentWasAlreadyOpen : Bool, error : Error?) in
                    _ = RunLoop.main.run (mode: .default, before: Date ())
                    if document != nil {
                      count += 1
                      let message = (count > 1)
                        ? "\(count) \(inTitle)s have been opened"
                        : "\(count) \(inTitle) has been opened"
                      self.mMaintenanceLogTextField.stringValue = message
                    }else{
                      self.mMaintenanceLogTextView.appendErrorString ("Cannot open \(fullPath)")
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  //····················································································································

  @objc func updateAllProjectsInDirectory (_ inSender : Any?) {
    if let button = inSender as? NSButton, let window = button.window {
      self.mMaintenanceLogTextView.string = ""
      self.mMaintenanceLogTextField.stringValue = ""
      self.mCount = 0
      let fileExtension = "elcanariproject"
      let op = NSOpenPanel ()
      op.allowsMultipleSelection = false
      op.canChooseDirectories = true
      op.canChooseFiles = false
      op.beginSheetModal (for: window) { (_ response : NSApplication.ModalResponse) in
        op.orderOut (nil)
        if response == .OK {
          let baseDirectory : String = op.urls [0].path
          let fm = FileManager ()
          let dc = NSDocumentController ()
          var retainedFiles = [String] ()
          if let filesInCurrentDirectory = fm.subpaths (atPath: baseDirectory) {
            for f in filesInCurrentDirectory {
              if f.first! != "." { // No hidden file
                let fullPath = baseDirectory + "/" + f
                if fullPath.pathExtension.lowercased() == fileExtension {
                  retainedFiles.append (fullPath)
                }
              }
            }
          }
          if retainedFiles.count == 0 {
            let alert = NSAlert ()
            alert.messageText = "No project to Open"
            alert.beginSheetModal (for: window)
          }else{
            let alert = NSAlert ()
            alert.messageText = "Update \(retainedFiles.count) project\((retainedFiles.count > 1) ? "s" : "")? You cannot cancel this operation."
            alert.addButton (withTitle: "Ok")
            alert.addButton (withTitle: "Cancel")
            alert.beginSheetModal (for: window) { (response : NSApplication.ModalResponse) in
              if response == .alertFirstButtonReturn {
                self.mMaintenanceLogTextField.stringValue = "No updated project"
                self.mMaintenanceLogTextView.appendMessageString ("Updating \(retainedFiles.count) project\((retainedFiles.count > 1) ? "s" : "")\n")
                for fullpath in retainedFiles {
                  dc.openDocument (
                    withContentsOf: URL (fileURLWithPath: fullpath),
                    display: true // animating,
                  ){ (document : NSDocument?, documentWasAlreadyOpen : Bool, error : Error?) in
                    NSSound.beep ()
//                    if let projectDocument = document as? CustomizedProjectDocument {
//                      projectDocument.resetDevicesAndFontsVersionAction (nil)
//                      var errorMessages = [String] ()
//                      projectDocument.updateDevices (projectDocument.rootObject.mDevices, &errorMessages)
//                      projectDocument.updateFonts (projectDocument.rootObject.mFonts, &errorMessages)
//                      projectDocument.save (nil)
//                      projectDocument.close ()
//                      if errorMessages.count == 0 {
//                        self.mCount += 1
//                        let message = (self.mCount > 1)
//                          ? "\(self.mCount) projects have been updated."
//                          : "1 project has been updated."
//                        self.mMaintenanceLogTextField.stringValue = message
//                      }else{
//                        self.mMaintenanceLogTextView.appendErrorString ("Cannot update \(fullpath)\n")
//                        self.mMaintenanceLogTextView.appendMessageString (errorMessages.joined (separator: "\n"))
//                      }
//                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  //····················································································································

  @objc func updateAllDevicesInDirectory (_ inSender : Any?) {
    if let button = inSender as? NSButton, let window = button.window {
      self.mMaintenanceLogTextView.string = ""
      self.mMaintenanceLogTextField.stringValue = ""
      self.mCount = 0
      let fileExtension = "elcanaridevice"
      let op = NSOpenPanel ()
      op.allowsMultipleSelection = false
      op.canChooseDirectories = true
      op.canChooseFiles = false
      op.beginSheetModal (for: window) { (_ response : NSApplication.ModalResponse) in
        op.orderOut (nil)
        if response == .OK {
          let baseDirectory : String = op.urls [0].path
          let fm = FileManager ()
          let dc = NSDocumentController ()
          var retainedFiles = [String] ()
          if let subPathes = fm.subpaths (atPath: baseDirectory) {
            for f in subPathes {
              if f.first! != "." {
                let fullpath = baseDirectory + "/" + f
                if fullpath.pathExtension.lowercased() == fileExtension {
                  retainedFiles.append (fullpath)
                }
              }
            }
          }
          if retainedFiles.count == 0 {
            let alert = NSAlert ()
            alert.messageText = "No device to Open"
            alert.beginSheetModal (for: window)
          }else{
            let alert = NSAlert ()
            alert.messageText = "Update \(retainedFiles.count) device\((retainedFiles.count > 1) ? "s" : "")? You cannot cancel this operation."
            alert.addButton (withTitle: "Ok")
            alert.addButton (withTitle: "Cancel")
            alert.beginSheetModal (for: window) { (response : NSApplication.ModalResponse) in
              if response == .alertFirstButtonReturn {
                self.mMaintenanceLogTextField.stringValue = "No updated device"
                self.mMaintenanceLogTextView.appendMessageString ("Updating \(retainedFiles.count) device\((retainedFiles.count > 1) ? "s" : "")\n")
                for fullPath in retainedFiles {
                  dc.openDocument (
                    withContentsOf: URL (fileURLWithPath: fullPath),
                    display: true // animating,
                  ){ (document : NSDocument?, documentWasAlreadyOpen : Bool, error : Error?) in
                    if let deviceDocument = document as? CustomizedDeviceDocument {
//                        deviceDocument.resetSymbolsVersion ()
//                        deviceDocument.resetPackagesVersion ()
                      var okMessages = [String] ()
                      var errorMessages = [String] ()
                      deviceDocument.performSymbolsUpdate (&okMessages, &errorMessages)
                      deviceDocument.performPackagesUpdate (deviceDocument.rootObject.mPackages, &okMessages, &errorMessages)
                      deviceDocument.save (nil)
                      deviceDocument.close ()
                      if errorMessages.count == 0 {
                        self.mCount += 1
                        let message = (self.mCount > 1)
                          ? "\(self.mCount) devices have been updated."
                          : "1 device has been updated."
                        self.mMaintenanceLogTextField.stringValue = message
                      }else{
                        self.mMaintenanceLogTextView.appendErrorString ("Cannot update \(fullPath)\n")
                        self.mMaintenanceLogTextView.appendMessageString (errorMessages.joined (separator: "\n"))
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  //····················································································································

  @objc func actionConvertToTextualFormatAllDocumentsInDirectory (_ inSender : AnyObject) {
    let extensions = Set (["elcanarisymbol", "elcanaripackage", "elcanaridevice", "elcanarifont", "elcanariproject", "elcanarimerger"])
    self.convertFiles (withExtensions: extensions, toFormat: .textual, sender: inSender)
  }

  //····················································································································

  @objc func actionConvertToBinaryFormatAllDocumentsInDirectory (_ inSender : AnyObject) {
    let extensions = Set (["elcanarisymbol", "elcanaripackage", "elcanaridevice", "elcanarifont", "elcanariproject", "elcanarimerger"])
    self.convertFiles (withExtensions: extensions, toFormat: .binary, sender: inSender)
  }

  //····················································································································

  private func convertFiles (withExtensions inExtensionSet : Set <String>,
                             toFormat inFormat : EBManagedDocumentFileFormat,
                             sender inSender : AnyObject) {
    if let button = inSender as? NSButton, let window = button.window {
      self.mMaintenanceLogTextView.string = ""
      self.mMaintenanceLogTextField.stringValue = ""
      self.mCount = 0
      let op = NSOpenPanel ()
      op.allowsMultipleSelection = false
      op.canChooseDirectories = true
      op.canChooseFiles = false
      op.beginSheetModal (for: window) { (_ response : NSApplication.ModalResponse) in
        op.orderOut (nil)
        if response == .OK {
          let baseDirectory : String = op.urls [0].path
          let fm = FileManager ()
          var retainedFiles = [String] ()
          if let subPathes = fm.subpaths (atPath: baseDirectory) {
            for f in subPathes {
              if f.first! != "." {
                let fullpath = baseDirectory + "/" + f
                if inExtensionSet.contains (fullpath.pathExtension.lowercased ()) {
                  retainedFiles.append (fullpath)
                }
              }
            }
          }
          if retainedFiles.count == 0 {
            let alert = NSAlert ()
            alert.messageText = "No Document to Examine"
            alert.beginSheetModal (for: window)
          }else{
            let alert = NSAlert ()
            alert.messageText = "Examine \(retainedFiles.count) document\((retainedFiles.count > 1) ? "s" : "")? You cannot cancel this operation."
            alert.addButton (withTitle: "Ok")
            alert.addButton (withTitle: "Cancel")
            alert.beginSheetModal (for: window) { (response : NSApplication.ModalResponse) in
              if response == .alertFirstButtonReturn {
                self.mMaintenanceLogTextField.stringValue = "0 document has been converted to \(inFormat.string) format."
                self.mMaintenanceLogTextView.appendMessageString ("Examining \(retainedFiles.count) document\((retainedFiles.count > 1) ? "s" : "")\n")
                self.mHandledFiles = retainedFiles
                self.mTotalFileCount = retainedFiles.count
                self.mHandledFileCount = 0
                self.mStartDate = Date ()
                self.examineAndConvertDocuments (toFormat: inFormat)
              }
            }
          }
        }
      }
    }
  }

  //····················································································································

  func examineAndConvertDocuments (toFormat inFormat : EBManagedDocumentFileFormat) {
    if self.mHandledFiles.count > 0 {
      let fullPath = self.mHandledFiles.remove (at: 0)
      let fileURL = URL (fileURLWithPath: fullPath)
      if let documentData = try? loadEasyBindingFile (fromURL: fileURL) {
        if documentData.documentFileFormat != inFormat {
          let newDocumentData = EBDocumentData (
            documentMetadataStatus: documentData.documentMetadataStatus,
            documentMetadataDictionary: documentData.documentMetadataDictionary,
            documentRootObject: documentData.documentRootObject,
            documentFileFormat: inFormat
          )
          do{
            try save (documentData: newDocumentData, toURL: fileURL)
            self.mCount += 1
            self.mMaintenanceLogTextView.appendMessageString ("\(fullPath) has been converted.\n")
          }catch _ {
            let message = "Cannot save \(fullPath)\n"
            self.mMaintenanceLogTextView.appendErrorString (message)
          }
        }
        collectAndPrepareObjectsForDeletion (fromRoot: documentData.documentRootObject)
      }else{
        let message = "Cannot read \(fullPath)\n"
        self.mMaintenanceLogTextView.appendErrorString (message)
      }
      self.mHandledFileCount += 1
      var message = "Handled \(self.mHandledFileCount)/\(self.mTotalFileCount), converted to \(inFormat.string): \(self.mCount)"
      if self.mHandledFiles.count == 0 {
        let duration = Int (Date ().timeIntervalSince (self.mStartDate))
        message += " — DONE in \(duration / 60) min \(duration % 60) s"
        self.mMaintenanceLogTextView.appendMessageString ("DONE.\n")
      }
      self.mMaintenanceLogTextField.stringValue = message
      DispatchQueue.main.async { self.examineAndConvertDocuments (toFormat: inFormat) }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
