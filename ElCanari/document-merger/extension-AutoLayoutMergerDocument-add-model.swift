//
//  AutoLayoutMergerDocument-addBoardModel.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/06/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutMergerDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func addBoardModel () {
  //--- Build list of current board model names
    var boardModelNames = [String] ()
    for boardModel in rootObject.boardModels_property.propval.values {
      let name : String = boardModel.name
      boardModelNames.append (name)
    }
  //--- Dialog
    if let window = self.windowForSheet {
      let openPanel = NSOpenPanel ()
      openPanel.canChooseFiles = true
      openPanel.canChooseDirectories = false
      openPanel.allowsMultipleSelection = false
      openPanel.allowedFileTypes = [
        EL_CANARI_LEGACY_MERGER_ARCHIVE,
        EL_CANARI_MERGER_ARCHIVE,
        KICAD_PCB
      ]
    //--- MANDATORY! This object is set to NSOpenPanel delegate that DOES NOT retain it
      gPanel = OpenPanelDelegateForFilteringBoardModels (boardModelNames)
      openPanel.delegate = gPanel
      openPanel.beginSheetModal (for: window) { (returnCode : NSApplication.ModalResponse) in
        gPanel = nil
        if returnCode == .OK {
          if let url = openPanel.url, url.isFileURL {
            let filePath = url.path
            if filePath.pathExtension == EL_CANARI_LEGACY_MERGER_ARCHIVE {
              self.loadBoardModelLegacy_ELCanariArchive (filePath : filePath, windowForSheet: window)
            }else if filePath.pathExtension == EL_CANARI_MERGER_ARCHIVE {
              self.loadBoardModelELCanariBoardArchive (filePath : filePath, windowForSheet: window)
            }else if filePath.pathExtension == KICAD_PCB {
              self.loadBoardModel_kicad (filePath : filePath, windowForSheet: window)
            }
          }else{
            NSLog ("Not a file URL!")
          }
        }
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//——————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor fileprivate var gPanel : OpenPanelDelegateForFilteringBoardModels?

//——————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate final class OpenPanelDelegateForFilteringBoardModels : NSObject, NSOpenSavePanelDelegate {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   PROPERTIES
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let mBoardModelNames : [String]

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   INIT
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ boardModelNames : [String]) {
    mBoardModelNames = boardModelNames
    super.init ()
    noteObjectAllocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   DELEGATE METHOD
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func panel (_ sender: Any, shouldEnable url: URL) -> Bool {
    let fileName = url.path.lastPathComponent.deletingPathExtension
    // NSLog ("\(fileName)")
    return mBoardModelNames.firstIndex (of:fileName) == nil
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
