//
//  extension-MergerDocument-importArtworkAction.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/07/2018.
//
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

extension MergerDocument {

  //····················································································································

  func importArtwork () {
    if let window = self.windowForSheet {
      let openPanel = NSOpenPanel ()
      openPanel.canChooseFiles = true
      openPanel.canChooseDirectories = false
      openPanel.allowsMultipleSelection = false
      openPanel.allowedFileTypes = ["ElCanariArtwork"]
    //--- Add panel delegate
      gPanelDelegate = OpenPanelDelegateForImportingArtwork (openPanel:openPanel, savedURL: openPanel.directoryURL)
      openPanel.delegate = gPanelDelegate
    //--- Add accessory view
      let libraries = existingLibraryPathArray ()
      let VIEW_WIDTH : CGFloat = 600.0
      let MARGIN : CGFloat = 14.0
      let BUTTON_HEIGHT : CGFloat = 32.0
      var rView = NSRect (x:0.0, y:0.0, width:VIEW_WIDTH, height:MARGIN)
      let accessoryView = CanariViewWithBackground (frame: rView)
      for lib in libraries {
        let artworkPath = artworkLibraryPathForPath (lib)
        let rButton = NSRect (x:MARGIN, y:rView.size.height, width:VIEW_WIDTH - 2.0 * MARGIN, height:BUTTON_HEIGHT)
        rView.size.height += BUTTON_HEIGHT + MARGIN
        let button = NSButton (frame: rButton)
        button.isEnabled = true
        button.isBordered = true
        button.bezelStyle = .regularSquare
        button.title = artworkPath
        button.toolTip = artworkPath
        button.target = gPanelDelegate
        button.action = #selector(OpenPanelDelegateForImportingArtwork.selectDirectory(_:))
        accessoryView.addSubview (button)
      }
      accessoryView.frame = rView
      openPanel.accessoryView = accessoryView
      openPanel.isAccessoryViewDisclosed = true
    //--- Dialog
      openPanel.beginSheetModal (for: window) { (returnCode : NSApplication.ModalResponse) in
        gPanelDelegate?.restoreSavedURLAndReleasePanel ()
        gPanelDelegate = nil
        if returnCode == .OK {
          if let url = openPanel.url, url.isFileURL {
            let filePath = url.path
          //--- Load file, as plist
            let optionalFileData : Data? = FileManager ().contents (atPath: filePath)
            if let fileData = optionalFileData {
              do {
                let documentData = try loadEasyBindingFile (fromData: fileData, undoManager: self.ebUndoManager)
                if let loadedArtwork = documentData.documentRootObject as? ArtworkRoot {
                  self.rootObject.mArtwork_property.setProp (loadedArtwork)
                  self.rootObject.mArtworkName = filePath.lastPathComponent.deletingPathExtension
                  if let version = documentData.documentMetadataDictionary [PMArtworkVersion] as? Int {
                    self.rootObject.mArtworkVersion = version
                  }else{
                    self.rootObject.mArtworkVersion = 0
                  }
                }
              }catch let error {
                window.presentError (error)
              }
            }else{ // Cannot read file
              let alert = NSAlert ()
              alert.messageText = "Cannot read file"
              alert.informativeText = "The file \(filePath) cannot be read."
              alert.beginSheetModal (for: window) { (NSModalResponse) in }
            }
          }else{
            NSLog ("Not a file URL!")
          }
        }
      }
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------

fileprivate var gPanelDelegate : OpenPanelDelegateForImportingArtwork?

//----------------------------------------------------------------------------------------------------------------------

fileprivate class OpenPanelDelegateForImportingArtwork : EBObject, NSOpenSavePanelDelegate {

  //····················································································································
  //   PROPERTIES
  //····················································································································

  private var mOpenPanel : NSOpenPanel?
  private let mSavedURL : URL?

  //····················································································································
  //   INIT
  //····················································································································

  init (openPanel : NSOpenPanel, savedURL inURL : URL?) {
    mOpenPanel = openPanel
    mSavedURL = inURL
    super.init ()
  }

  //····················································································································

  @objc func selectDirectory (_ inButton : NSButton) {
    let path = inButton.title
    mOpenPanel?.directoryURL = URL (fileURLWithPath: path, isDirectory: true)
  }

  //····················································································································

  func restoreSavedURLAndReleasePanel () {
    mOpenPanel?.directoryURL = self.mSavedURL
    mOpenPanel = nil
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
