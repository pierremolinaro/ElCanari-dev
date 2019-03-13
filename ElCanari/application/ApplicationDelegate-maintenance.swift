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

  @IBAction func actionOpenAllDocumentsInDirectory (_ inSender : AnyObject) {
    let fileExtensions = Set (["ElCanariSymbol", "ElCanariPackage", "ElCanariDevice", "ElCanariProject"])
    self.actionOpenAllDocumentsInDirectory (fileExtensions, "document", inSender)
  }

  //····················································································································

  @IBAction func actionOpenAllSymbolsInDirectory (_ inSender : Any?) {
    self.actionOpenAllDocumentsInDirectory (["ElCanariSymbol"], "symbol", inSender)
  }

  //····················································································································

  @IBAction func actionOpenAllPackagesInDirectory (_ inSender : Any?) {
    self.actionOpenAllDocumentsInDirectory (["ElCanariPackage"], "package", inSender)
  }

  //····················································································································

  @IBAction func actionOpenAllDevicesInDirectory (_ inSender : Any?) {
    self.actionOpenAllDocumentsInDirectory (["ElCanariDevice"], "device", inSender)
  }

  //····················································································································

  private func actionOpenAllDocumentsInDirectory (_ extensions : Set <String>, _ inTitle : String, _ inSender : Any?) {
    if let button = inSender as? NSButton, let window = button.window {
      self.mMaintenanceLogTextView?.string = ""
      self.mMaintenanceLogTextField?.stringValue = ""
      let op = NSOpenPanel ()
      op.allowsMultipleSelection = false
      op.canChooseDirectories = true
      op.canChooseFiles = false
      op.beginSheetModal (for: window, completionHandler: { (_ response : NSApplication.ModalResponse) in
        op.orderOut (nil)
        if response == .OK {
          let baseDirectory : String = op.urls [0].path
          let fm = FileManager ()
          let dc = NSDocumentController ()
          let files = try? fm.subpathsOfDirectory (atPath: baseDirectory)
          var fileCount = 0
          for f in files ?? [] {
            let fullpath = baseDirectory + "/" + f
            if extensions.contains (fullpath.pathExtension) {
              fileCount += 1
            }
          }
          if fileCount == 0 {
            let alert = NSAlert ()
            alert.messageText = "No document to Open"
            _ = alert.runModal ()
          }else{
            let alert = NSAlert ()
            alert.messageText = "Open \(fileCount) \(inTitle)\((fileCount > 1) ? "s" : "")?"
            alert.accessoryView = self.mOpenAllDialogAccessoryCheckBox
            alert.informativeText = "Animating is slower, but you have a visual effect during documents opening."
            alert.addButton (withTitle: "Ok")
            alert.addButton (withTitle: "Cancel")
            let response = alert.runModal ()
            if response == .alertFirstButtonReturn {
              let message = "Opening \(fileCount) \(inTitle)\((fileCount > 1) ? "s" : "")"
              self.mMaintenanceLogTextView?.appendMessageString (message)
              let animating = (self.mOpenAllDialogAccessoryCheckBox?.state ?? .on) == .on
              var count = 0
              for f in files ?? [] {
                let fullpath = baseDirectory + "/" + f
                if extensions.contains (fullpath.pathExtension) {
                  dc.openDocument (
                    withContentsOf: URL (fileURLWithPath: fullpath),
                    display: true,
                    completionHandler: { (document : NSDocument?, documentWasAlreadyOpen : Bool, error : Error?) in
                      if animating {
                        _ = RunLoop.main.run (mode: .default, before: Date ())
                      }
                      if document != nil {
                      count += 1
                        let message = (count > 1)
                          ? "\(count) \(inTitle)s have been opened"
                          : "\(count) \(inTitle) has been opened"
                        self.mMaintenanceLogTextField?.stringValue = message
                      }else{
                        self.mMaintenanceLogTextView?.appendErrorString ("Cannot open \(f)")
                      }
                    }
                  )
                }
              }
            }
          }
        }
      })
    }
  }

  //····················································································································

  @IBAction func updateAllDevicesInDirectory (_ inSender : Any?) {
    if let button = inSender as? NSButton, let window = button.window {
      self.mMaintenanceLogTextView?.string = ""
      self.mMaintenanceLogTextField?.stringValue = ""
      self.mCount = 0
      let fileExtension = "ElCanariDevice"
      let op = NSOpenPanel ()
      op.allowsMultipleSelection = false
      op.canChooseDirectories = true
      op.canChooseFiles = false
      op.beginSheetModal (for: window, completionHandler: { (_ response : NSApplication.ModalResponse) in
        if response == .OK {
          let baseDirectory : String = op.urls [0].path
          let fm = FileManager ()
          let dc = NSDocumentController ()
          let files = try? fm.subpathsOfDirectory (atPath: baseDirectory)
          var fileCount = 0
          for f in files ?? [] {
            let fullpath = baseDirectory + "/" + f
            if fullpath.pathExtension == fileExtension {
              fileCount += 1
            }
          }
          if fileCount == 0 {
            let alert = NSAlert ()
            alert.messageText = "No device to Open"
            _ = alert.beginSheetModal (for: window, completionHandler: nil)
          }else{
            let alert = NSAlert ()
            alert.messageText = "Update \(fileCount) device\((fileCount > 1) ? "s" : "")?"
//            alert.accessoryView = self.mOpenAllDialogAccessoryCheckBox
//            alert.informativeText = "Animating is slower, but you have a visual effect during devices update."
            alert.addButton (withTitle: "Ok")
            alert.addButton (withTitle: "Cancel")
            let response = alert.runModal ()
            if response == .alertFirstButtonReturn {
              self.mMaintenanceLogTextField?.stringValue = "No update device"
              self.mMaintenanceLogTextView?.appendMessageString ("Updating \(fileCount) device\((fileCount > 1) ? "s" : "")")
//              let animating = (self.mOpenAllDialogAccessoryCheckBox?.state ?? .on) == .on
              for f in files ?? [] {
                let fullpath = baseDirectory + "/" + f
                if fullpath.pathExtension == fileExtension {
                  dc.openDocument (
                    withContentsOf: URL (fileURLWithPath: fullpath),
                    display: true, // animating,
                    completionHandler: { (document : NSDocument?, documentWasAlreadyOpen : Bool, error : Error?) in
                      if let deviceDocument = document as? CustomizedDeviceDocument {
                        var okMessages = [String] ()
                        var errorMessages = [String] ()
                        deviceDocument.performSymbolsUpdate (deviceDocument.rootObject.mSymbolTypes_property.propval, &okMessages, &errorMessages)
                        deviceDocument.performPackagesUpdate (deviceDocument.rootObject.mPackages_property.propval, &okMessages, &errorMessages)
                        deviceDocument.save (nil)
//                        if animating {
                          deviceDocument.close ()
//                        }else{
//                          DispatchQueue.main.async { deviceDocument.close () }
//                        }
//                        DispatchQueue.main.async {
                          if errorMessages.count == 0 {
                            self.incrementAndDisplayUpdateCount ()
                          }else{
                            self.mMaintenanceLogTextView?.appendErrorString ("Cannot update \(f)\n")
                            self.mMaintenanceLogTextView?.appendMessageString (errorMessages.joined (separator: "\n"))
                          }
//                        }
                      }
                    }
                  )
                }
              }
            }
          }
        }
      })
    }
  }

  //····················································································································

  private func incrementAndDisplayUpdateCount () {
    self.mCount += 1
    let message = (self.mCount > 1)
      ? "\(self.mCount) devices have been updated."
      : "1 device has been updated."
    self.mMaintenanceLogTextField?.stringValue = message
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
