//
//  ApplicationDelegate-maintenance.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/11/2018.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension ApplicationDelegate {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @IBAction func showBatchWindow (_ inSender : Any?) {
    self.instanciatedBatchWindow ()
    self.mBatchWindow?.makeKeyAndOrderFront (inSender)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor @objc func actionOpenAllDocumentsInDirectory (_ inSender : Any?) {
    self.actionOpenAllDocumentsInDirectory (ALL_ELCANARI_DOCUMENT_EXTENSIONS, "document", inSender)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor @objc func actionOpenAllSymbolsInDirectory (_ inSender : Any?) {
    self.actionOpenAllDocumentsInDirectory ([ElCanariSymbol_EXTENSION], "symbol", inSender)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor @objc func actionOpenAllPackagesInDirectory (_ inSender : Any?) {
    self.actionOpenAllDocumentsInDirectory ([ElCanariPackage_EXTENSION], "package", inSender)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor @objc func actionOpenAllDevicesInDirectory (_ inSender : Any?) {
    self.actionOpenAllDocumentsInDirectory ([ElCanariDevice_EXTENSION], "device", inSender)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor @objc func actionOpenAllFontsInDirectory (_ inSender : Any?) {
    self.actionOpenAllDocumentsInDirectory ([ElCanariFont_EXTENSION], "font", inSender)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor private func actionOpenAllDocumentsInDirectory (_ inExtensions : Set <String>,
                                                             _ inTitle : String,
                                                             _ inSender : Any?) {
    self.instanciatedBatchWindow ()
    if let button = inSender as? NSButton, let window = button.window {
      self.mMaintenanceLogTextView?.string = ""
      self.mMaintenanceLogTextField?.stringValue = ""
      let op = NSOpenPanel ()
      op.allowsMultipleSelection = false
      op.canChooseDirectories = true
      op.canChooseFiles = false
      op.beginSheetModal (for: window) { (_ response : NSApplication.ModalResponse) in
        DispatchQueue.main.async {
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
                  if inExtensions.contains (fullPath.pathExtension.lowercased ()) {
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
              _ = alert.addButton (withTitle: "Ok")
              _ = alert.addButton (withTitle: "Cancel")
              alert.beginSheetModal (for: window) { (response : NSApplication.ModalResponse) in
                if response == .alertFirstButtonReturn {
                  DispatchQueue.main.async {
                    let message = "Opening \(retainedFiles.count) \(inTitle)\((retainedFiles.count > 1) ? "s" : "")\n"
                    let maintenanceLogTextView = self.mMaintenanceLogTextView
                    let maintenanceLogTextField = self.mMaintenanceLogTextField
                    maintenanceLogTextView?.appendMessageString (message)
                    self.mCount = 0
                    for fullPath in retainedFiles {
                      dc.openDocument (
                        withContentsOf: URL (fileURLWithPath: fullPath),
                        display: true
                      ){ (document : NSDocument?, documentWasAlreadyOpen : Bool, error : Error?) in
                        DispatchQueue.main.async {
                          if document != nil {
                            self.mCount += 1
                            let message = (self.mCount > 1)
                              ? "\(self.mCount) \(inTitle)s have been opened"
                              : "\(self.mCount) \(inTitle) has been opened"
                            maintenanceLogTextField?.stringValue = message
                          }else{
                            maintenanceLogTextView?.appendErrorString ("Cannot open \(fullPath)")
                          }
                        }
                        _ = RunLoop.main.run (mode: .default, before: Date ())
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor @objc func updateAllProjectsInDirectory (_ inSender : Any?) {
    self.instanciatedBatchWindow ()
    if let button = inSender as? NSButton, let window = button.window {
      self.mMaintenanceLogTextView?.string = ""
      self.mMaintenanceLogTextField?.stringValue = ""
      self.mCount = 0
      let fileExtension = ElCanariProject_EXTENSION
      let op = NSOpenPanel ()
      op.allowsMultipleSelection = false
      op.canChooseDirectories = true
      op.canChooseFiles = false
      op.beginSheetModal (for: window) { (_ response : NSApplication.ModalResponse) in
        DispatchQueue.main.async {
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
              _ = alert.addButton (withTitle: "Ok")
              _ = alert.addButton (withTitle: "Cancel")
              alert.beginSheetModal (for: window) { (response : NSApplication.ModalResponse) in
                if response == .alertFirstButtonReturn {
                  DispatchQueue.main.async {
                    self.mMaintenanceLogTextField?.stringValue = "No updated project"
                    self.mMaintenanceLogTextView?.appendMessageString ("Updating \(retainedFiles.count) project\((retainedFiles.count > 1) ? "s" : "")\n")
                    for fullpath in retainedFiles {
                      dc.openDocument (
                        withContentsOf: URL (fileURLWithPath: fullpath),
                        display: true // animating,
                      ){ (document : NSDocument?, documentWasAlreadyOpen : Bool, error : Error?) in
                        NSSound.beep ()
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor @objc func updateAllDevicesInDirectory (_ inSender : Any?) {
    self.instanciatedBatchWindow ()
    if let button = inSender as? NSButton, let window = button.window {
      self.mMaintenanceLogTextView?.string = ""
      self.mMaintenanceLogTextField?.stringValue = ""
      self.mCount = 0
      let op = NSOpenPanel ()
      op.allowsMultipleSelection = false
      op.canChooseDirectories = true
      op.canChooseFiles = false
      op.beginSheetModal (for: window) { (_ response : NSApplication.ModalResponse) in
        DispatchQueue.main.async {
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
                  if fullpath.pathExtension.lowercased() == ElCanariDevice_EXTENSION {
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
              _ = alert.addButton (withTitle: "Ok")
              _ = alert.addButton (withTitle: "Cancel")
              alert.beginSheetModal (for: window) { (response : NSApplication.ModalResponse) in
                if response == .alertFirstButtonReturn {
                  DispatchQueue.main.async {
                    self.mMaintenanceLogTextField?.stringValue = "No updated device"
                    self.mMaintenanceLogTextView?.appendMessageString ("Updating \(retainedFiles.count) device\((retainedFiles.count > 1) ? "s" : "")\n")
                    for fullPath in retainedFiles {
                      dc.openDocument (
                        withContentsOf: URL (fileURLWithPath: fullPath),
                        display: true // animating,
                      ){ (document : NSDocument?, documentWasAlreadyOpen : Bool, error : Error?) in
                        if let deviceDocument = document as? AutoLayoutDeviceDocument {
                          DispatchQueue.main.async {
                            var okMessages = [String] ()
                            var errorMessages = [String] ()
                            deviceDocument.performSymbolsUpdate (deviceDocument.rootObject.mSymbolTypes, okMessages: &okMessages, errorMessages: &errorMessages)
                            deviceDocument.performPackagesUpdate (deviceDocument.rootObject.mPackages, okMessages: &okMessages, errorMessages: &errorMessages)
                            deviceDocument.save (nil)
                            deviceDocument.close ()
                            if errorMessages.count == 0 {
                              self.mCount += 1
                              let message = (self.mCount > 1)
                                ? "\(self.mCount) devices have been updated."
                                : "1 device has been updated."
                              self.mMaintenanceLogTextField?.stringValue = message
                            }else{
                              self.mMaintenanceLogTextView?.appendErrorString ("Cannot update \(fullPath)\n")
                              self.mMaintenanceLogTextView?.appendMessageString (errorMessages.joined (separator: "\n"))
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
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor @objc func actionConvertToTextualFormatAllDocumentsInDirectory (_ inSender : AnyObject) {
    self.convertFiles (withExtensions: ALL_ELCANARI_DOCUMENT_EXTENSIONS, toFormat: .textual, sender: inSender)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor @objc func actionConvertToBinaryFormatAllDocumentsInDirectory (_ inSender : AnyObject) {
    self.convertFiles (withExtensions: ALL_ELCANARI_DOCUMENT_EXTENSIONS, toFormat: .binary, sender: inSender)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor private func convertFiles (withExtensions inExtensionSet : Set <String>,
                                        toFormat inFormat : EBManagedDocumentFileFormat,
                                        sender inSender : AnyObject) {
    self.instanciatedBatchWindow ()
    if let button = inSender as? NSButton, let window = button.window {
      self.mMaintenanceLogTextView?.string = ""
      self.mMaintenanceLogTextField?.stringValue = ""
      self.mCount = 0
      let op = NSOpenPanel ()
      op.allowsMultipleSelection = false
      op.canChooseDirectories = true
      op.canChooseFiles = false
      op.beginSheetModal (for: window) { (_ response : NSApplication.ModalResponse) in
        DispatchQueue.main.async {
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
              _ = alert.addButton (withTitle: "Ok")
              _ = alert.addButton (withTitle: "Cancel")
              alert.beginSheetModal (for: window) { (response : NSApplication.ModalResponse) in
                if response == .alertFirstButtonReturn {
                  DispatchQueue.main.async {
                    self.mMaintenanceLogTextField?.stringValue = "0 document has been converted to \(inFormat.string) format."
                    self.mMaintenanceLogTextView?.appendMessageString ("Examining \(retainedFiles.count) document\((retainedFiles.count > 1) ? "s" : "")\n")
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
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor func examineAndConvertDocuments (toFormat inFormat : EBManagedDocumentFileFormat) {
    self.instanciatedBatchWindow ()
    if self.mHandledFiles.count > 0 {
      let fullPath = self.mHandledFiles.remove (at: 0)
      let fileURL = URL (fileURLWithPath: fullPath)
      let documentReadData = loadEasyBindingFile (fromURL: fileURL)
      switch documentReadData {
      case .ok (let documentData) :
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
            self.mMaintenanceLogTextView?.appendMessageString ("\(fullPath) has been converted.\n")
          }catch _ {
            let message = "Cannot save \(fullPath)\n"
            self.mMaintenanceLogTextView?.appendErrorString (message)
          }
        }
      case .readError (_) :
        let message = "Cannot read \(fullPath)\n"
        self.mMaintenanceLogTextView?.appendErrorString (message)
      }
      self.mHandledFileCount += 1
      var message = "Handled \(self.mHandledFileCount)/\(self.mTotalFileCount), converted to \(inFormat.string): \(self.mCount)"
      if self.mHandledFiles.count == 0 {
        let duration = Int (Date ().timeIntervalSince (self.mStartDate))
        message += " — DONE in \(duration / 60) min \(duration % 60) s"
        self.mMaintenanceLogTextView?.appendMessageString ("DONE.\n")
      }
      self.mMaintenanceLogTextField?.stringValue = message
      DispatchQueue.main.async { self.examineAndConvertDocuments (toFormat: inFormat) }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
