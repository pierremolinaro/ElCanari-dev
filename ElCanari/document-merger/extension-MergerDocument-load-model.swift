//
//  delegate-NSOpenPanel.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/06/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension MergerDocument {

  //····················································································································

  func addBoardModel () {
  //--- Build list of current board model names
    var boardModelNames = [String] ()
    for boardModel in rootObject.boardModels_property.propval {
      let name : String = boardModel.name
      boardModelNames.append (name)
    }
  //--- Dialog
    if let window = self.windowForSheet {
      let openPanel = NSOpenPanel ()
      openPanel.canChooseFiles = true
      openPanel.canChooseDirectories = false
      openPanel.allowsMultipleSelection = false
      openPanel.allowedFileTypes = ["ElCanariBoardArchive"]
    //--- MANDATORY! This object is set to NSOpenPanel delegate that DOES NOT retain it
      gPanel = OpenPanelDelegateForFilteringBoardModels (boardModelNames)
      openPanel.delegate = gPanel
      openPanel.beginSheetModal (for: window, completionHandler: { (returnCode : SW34_ApplicationModalResponse) in
        gPanel = nil
        if returnCode == sw34_FileHandlingPanelOKButton {
          if let url = openPanel.url, url.isFileURL {
            let filePath = url.path
          //--- Load file, as plist
            let optionalFileData : Data? = FileManager ().contents (atPath: filePath)
            if let fileData = optionalFileData {
              do {
                let optionalBoardArchiveDictionary = try PropertyListSerialization.propertyList (
                  from: fileData,
                  options: [],
                  format: nil
                )
                if let boardArchiveDictionary = optionalBoardArchiveDictionary as? NSDictionary {
                  let s = filePath.lastPathComponent.deletingPathExtension
                  let possibleBoardModel = self.parseBoardModel (fromDictionary: boardArchiveDictionary, named : s)
                  if let boardModel = possibleBoardModel {
                    self.rootObject.boardModels_property.add (boardModel)
                    self.mBoardModelController.select (object:boardModel)
                  }
                }else{
                  NSLog ("Invalid dictionary!")
                }
              }catch let error {
                window.presentError (error)
              }
            }else{ // Cannot read file
              let alert = NSAlert ()
              alert.messageText = "Cannot read file"
              alert.addButton (withTitle: "Ok")
              alert.informativeText = "The file \(filePath) cannot be read."
              alert.beginSheetModal (for: window, completionHandler: {(NSModalResponse) in})
            }
          }else{
            NSLog ("Not a file URL!")
          }
        }
      })
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate var gPanel : OpenPanelDelegateForFilteringBoardModels?

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate class OpenPanelDelegateForFilteringBoardModels : EBSimpleClass, NSOpenSavePanelDelegate {

  //····················································································································
  //   PROPERTIES
  //····················································································································

  let mBoardModelNames : [String]

  //····················································································································
  //   INIT
  //····················································································································

  init (_ boardModelNames : [String]) {
    mBoardModelNames = boardModelNames
    super.init ()
  }

  //····················································································································
  //   DELEGATE METHOD
  //····················································································································

  func panel (_ sender: Any, shouldEnable url: URL) -> Bool {
    let fileName = url.path.lastPathComponent.deletingPathExtension
    // NSLog ("\(fileName)")
    return mBoardModelNames.index (of:fileName) == nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
