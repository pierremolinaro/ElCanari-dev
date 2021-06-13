//
//  delegate-NSOpenPanel-update-model.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/06/2018.
//
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

extension MergerDocument {

  //····················································································································

  func updateBoardModel () {
    let selectedModels = self.mBoardModelController.selectedArray
    if selectedModels.count == 1, let window = self.windowForSheet {
      let updatedBoardModel = selectedModels [0]
      let boardModelName : String = updatedBoardModel.name
    //--- Dialog
      let openPanel = NSOpenPanel ()
      openPanel.canChooseFiles = true
      openPanel.canChooseDirectories = false
      openPanel.allowsMultipleSelection = false
      openPanel.allowedFileTypes = [EL_CANARI_MERGER_ARCHIVE, KICAD_PCB]
    // MANDATORY! This object is set to NSOpenPanel delegate that DOES NOT retain it
      gPanel = OpenPanelDelegateForUpdatingBoardModels (boardModelName) // MANDATORY! This object is set to NSOpenPanel delegate that DOES NOT retain it
      openPanel.delegate = gPanel
      openPanel.beginSheetModal (for: window) { (returnCode) in
        gPanel = nil
        if returnCode == .OK, let url = openPanel.url, url.isFileURL {
          let filePath = url.path
        //--- Load file, as plist
          let optionalFileData : Data? = FileManager ().contents (atPath: filePath)
          if let fileData = optionalFileData {
            let s = filePath.lastPathComponent.deletingPathExtension
            var possibleBoardModel : BoardModel? = nil
            if filePath.pathExtension == EL_CANARI_MERGER_ARCHIVE {
              possibleBoardModel = self.parseBoardModel_ELCanariArchive (fromData: fileData, named: s)
            }else if filePath.pathExtension == KICAD_PCB {
              possibleBoardModel = self.parseBoardModel_kicad (fromData: fileData, named: s)
            }
            if let newTemporaryBoardModel = possibleBoardModel {
              updatedBoardModel.artworkName = newTemporaryBoardModel.artworkName
              updatedBoardModel.modelWidth = newTemporaryBoardModel.modelWidth
              updatedBoardModel.modelWidthUnit = newTemporaryBoardModel.modelWidthUnit
              updatedBoardModel.modelHeight = newTemporaryBoardModel.modelHeight
              updatedBoardModel.modelHeightUnit = newTemporaryBoardModel.modelHeightUnit
              updatedBoardModel.modelLimitWidth = newTemporaryBoardModel.modelLimitWidth
              updatedBoardModel.modelLimitWidthUnit = newTemporaryBoardModel.modelLimitWidthUnit
              updatedBoardModel.zoom = newTemporaryBoardModel.zoom

              var newArray = newTemporaryBoardModel.backPackages
              newTemporaryBoardModel.backPackages = []
              updatedBoardModel.backPackages = newArray

              newArray = newTemporaryBoardModel.frontPackages
              newTemporaryBoardModel.frontPackages = []
              updatedBoardModel.frontPackages = newArray

              newArray = newTemporaryBoardModel.frontTracks
              newTemporaryBoardModel.frontTracks = []
              updatedBoardModel.frontTracks = newArray

              newArray = newTemporaryBoardModel.backTracks
              newTemporaryBoardModel.backTracks = []
              updatedBoardModel.backTracks = newArray

              newArray = newTemporaryBoardModel.backComponentValues
              newTemporaryBoardModel.backComponentValues = []
              updatedBoardModel.backComponentValues = newArray

              newArray = newTemporaryBoardModel.frontComponentValues
              newTemporaryBoardModel.frontComponentValues = []
              updatedBoardModel.frontComponentValues = newArray

              newArray = newTemporaryBoardModel.frontComponentNames
              newTemporaryBoardModel.frontComponentNames = []
              updatedBoardModel.frontComponentNames = newArray

              newArray = newTemporaryBoardModel.backComponentNames
              newTemporaryBoardModel.backComponentNames = []
              updatedBoardModel.backComponentNames = newArray

              let newBackPadArray = newTemporaryBoardModel.backPads
              newTemporaryBoardModel.backPads = []
              updatedBoardModel.backPads = newBackPadArray

              let newFrontPadArray = newTemporaryBoardModel.frontPads
              newTemporaryBoardModel.frontPads = []
              updatedBoardModel.frontPads = newFrontPadArray

              let newViaArray = newTemporaryBoardModel.vias
              newTemporaryBoardModel.vias = []
              updatedBoardModel.vias = newViaArray

              let newDrillArray = newTemporaryBoardModel.drills
              newTemporaryBoardModel.drills = []
              updatedBoardModel.drills = newDrillArray

              newArray = newTemporaryBoardModel.backLayoutTexts
              newTemporaryBoardModel.backLayoutTexts = []
              updatedBoardModel.backLayoutTexts = newArray

              newArray = newTemporaryBoardModel.backLegendTexts
              newTemporaryBoardModel.backLegendTexts = []
              updatedBoardModel.backLegendTexts = newArray

              newArray = newTemporaryBoardModel.frontLayoutTexts
              newTemporaryBoardModel.frontLayoutTexts = []
              updatedBoardModel.frontLayoutTexts = newArray

              newArray = newTemporaryBoardModel.frontLegendTexts
              newTemporaryBoardModel.frontLegendTexts = []
              updatedBoardModel.frontLegendTexts = newArray

              newArray = newTemporaryBoardModel.backLegendLines
              newTemporaryBoardModel.backLegendLines = []
              updatedBoardModel.backLegendLines = newArray

              newArray = newTemporaryBoardModel.frontLegendLines
              newTemporaryBoardModel.frontLegendLines = []
              updatedBoardModel.frontLegendLines = newArray

              newArray = newTemporaryBoardModel.internalBoardsLimits
              newTemporaryBoardModel.internalBoardsLimits = []
              updatedBoardModel.internalBoardsLimits = newArray
            }
          }else{ // Cannot read file
            let alert = NSAlert ()
            alert.messageText = "Cannot read file"
            alert.informativeText = "The file \(filePath) cannot be read."
            alert.beginSheetModal (for: window) { (NSModalResponse) in }
          }
        }
      }
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------

fileprivate var gPanel : OpenPanelDelegateForUpdatingBoardModels? = nil

//----------------------------------------------------------------------------------------------------------------------

fileprivate class OpenPanelDelegateForUpdatingBoardModels : ObjcObject, NSOpenSavePanelDelegate {

  //····················································································································
  //   PROPERTIES
  //····················································································································

  let mBoardModelName : String

  //····················································································································
  //   INIT
  //····················································································································

  init (_ boardModelName : String) {
    mBoardModelName = boardModelName
    super.init ()
  }

  //····················································································································
  //   DELEGATE METHOD
  //····················································································································

  func panel (_ sender : Any, shouldEnable url : URL) -> Bool {
    let path = url.path
    let fm = FileManager ()
    var isDirectory : ObjCBool = false
    _ = fm.fileExists (atPath: path, isDirectory: &isDirectory)
    return isDirectory.boolValue || (self.mBoardModelName == path.lastPathComponent.deletingPathExtension)
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
