//
//  delegate-NSOpenPanel-update-model.swift
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
     //         updatedBoardModel.modelWidthUnit = newTemporaryBoardModel.modelWidthUnit
              updatedBoardModel.modelHeight = newTemporaryBoardModel.modelHeight
   //           updatedBoardModel.modelHeightUnit = newTemporaryBoardModel.modelHeightUnit
              updatedBoardModel.modelLimitWidth = newTemporaryBoardModel.modelLimitWidth
      //        updatedBoardModel.modelLimitWidthUnit = newTemporaryBoardModel.modelLimitWidthUnit
      //        updatedBoardModel.zoom = newTemporaryBoardModel.zoom

              var newArray = newTemporaryBoardModel.backPackages
              newTemporaryBoardModel.backPackages = EBReferenceArray ()
              updatedBoardModel.backPackages = newArray

              newArray = newTemporaryBoardModel.frontPackages
              newTemporaryBoardModel.frontPackages = EBReferenceArray ()
              updatedBoardModel.frontPackages = newArray

              newArray = newTemporaryBoardModel.frontTracks
              newTemporaryBoardModel.frontTracks = EBReferenceArray ()
              updatedBoardModel.frontTracks = newArray

              newArray = newTemporaryBoardModel.inner1Tracks
              newTemporaryBoardModel.inner1Tracks = EBReferenceArray ()
              updatedBoardModel.inner1Tracks = newArray

              newArray = newTemporaryBoardModel.inner2Tracks
              newTemporaryBoardModel.inner2Tracks = EBReferenceArray ()
              updatedBoardModel.inner2Tracks = newArray

              newArray = newTemporaryBoardModel.inner3Tracks
              newTemporaryBoardModel.inner3Tracks = EBReferenceArray ()
              updatedBoardModel.inner3Tracks = newArray

              newArray = newTemporaryBoardModel.inner4Tracks
              newTemporaryBoardModel.inner4Tracks = EBReferenceArray ()
              updatedBoardModel.inner4Tracks = newArray

              newArray = newTemporaryBoardModel.backTracks
              newTemporaryBoardModel.backTracks = EBReferenceArray ()
              updatedBoardModel.backTracks = newArray

              newArray = newTemporaryBoardModel.backComponentValues
              newTemporaryBoardModel.backComponentValues = EBReferenceArray ()
              updatedBoardModel.backComponentValues = newArray

              newArray = newTemporaryBoardModel.frontComponentValues
              newTemporaryBoardModel.frontComponentValues = EBReferenceArray ()
              updatedBoardModel.frontComponentValues = newArray

              newArray = newTemporaryBoardModel.frontComponentNames
              newTemporaryBoardModel.frontComponentNames = EBReferenceArray ()
              updatedBoardModel.frontComponentNames = newArray

              newArray = newTemporaryBoardModel.backComponentNames
              newTemporaryBoardModel.backComponentNames = EBReferenceArray ()
              updatedBoardModel.backComponentNames = newArray

              let newBackPadArray = newTemporaryBoardModel.backPads
              newTemporaryBoardModel.backPads = EBReferenceArray ()
              updatedBoardModel.backPads = newBackPadArray

              let newTraversingPadArray = newTemporaryBoardModel.traversingPads
              newTemporaryBoardModel.traversingPads = EBReferenceArray ()
              updatedBoardModel.traversingPads = newTraversingPadArray

              let newFrontPadArray = newTemporaryBoardModel.frontPads
              newTemporaryBoardModel.frontPads = EBReferenceArray ()
              updatedBoardModel.frontPads = newFrontPadArray

              let newViaArray = newTemporaryBoardModel.vias
              newTemporaryBoardModel.vias = EBReferenceArray ()
              updatedBoardModel.vias = newViaArray

              let newDrillArray = newTemporaryBoardModel.drills
              newTemporaryBoardModel.drills = EBReferenceArray ()
              updatedBoardModel.drills = newDrillArray

              newArray = newTemporaryBoardModel.backLayoutTexts
              newTemporaryBoardModel.backLayoutTexts = EBReferenceArray ()
              updatedBoardModel.backLayoutTexts = newArray

              newArray = newTemporaryBoardModel.backLegendTexts
              newTemporaryBoardModel.backLegendTexts = EBReferenceArray ()
              updatedBoardModel.backLegendTexts = newArray

              newArray = newTemporaryBoardModel.frontLayoutTexts
              newTemporaryBoardModel.frontLayoutTexts = EBReferenceArray ()
              updatedBoardModel.frontLayoutTexts = newArray

              newArray = newTemporaryBoardModel.frontLegendTexts
              newTemporaryBoardModel.frontLegendTexts = EBReferenceArray ()
              updatedBoardModel.frontLegendTexts = newArray

              newArray = newTemporaryBoardModel.backLegendLines
              newTemporaryBoardModel.backLegendLines = EBReferenceArray ()
              updatedBoardModel.backLegendLines = newArray

              newArray = newTemporaryBoardModel.frontLegendLines
              newTemporaryBoardModel.frontLegendLines = EBReferenceArray ()
              updatedBoardModel.frontLegendLines = newArray

              newArray = newTemporaryBoardModel.internalBoardsLimits
              newTemporaryBoardModel.internalBoardsLimits = EBReferenceArray ()
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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate var gPanel : OpenPanelDelegateForUpdatingBoardModels? = nil

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate class OpenPanelDelegateForUpdatingBoardModels : EBObjcBaseObject, NSOpenSavePanelDelegate {

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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
