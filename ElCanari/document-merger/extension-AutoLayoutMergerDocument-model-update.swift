//
//  delegate-NSOpenPanel-update-model.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/06/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutMergerDocument {

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
            if filePath.pathExtension == EL_CANARI_MERGER_ARCHIVE {
              self.parseBoardModel_ELCanariArchive (fromData: fileData, named: s, callBack: { self.performUpdateModel (updatedBoardModel, with: $0) })
            }else if filePath.pathExtension == KICAD_PCB {
              let possibleBoardModel = self.parseBoardModel_kicad (fromData: fileData, named: s)
              if let newTemporaryBoardModel = possibleBoardModel {
                self.performUpdateModel (updatedBoardModel, with: newTemporaryBoardModel)
              }
            }
          }else{ // Cannot read file
            let alert = NSAlert ()
            alert.messageText = "Cannot read file"
            alert.informativeText = "The file \(filePath) cannot be read."
            alert.beginSheetModal (for: window)
          }
        }
      }
    }
  }

  //····················································································································

  private func performUpdateModel (_ inModelToUpdate : BoardModel, with inLoadedModel : BoardModel) {
    inModelToUpdate.artworkName = inLoadedModel.artworkName
    inModelToUpdate.modelWidth = inLoadedModel.modelWidth
    inModelToUpdate.modelHeight = inLoadedModel.modelHeight
    inModelToUpdate.modelLimitWidth = inLoadedModel.modelLimitWidth
    inModelToUpdate.modelVersion = inLoadedModel.modelVersion
    inModelToUpdate.ignoreModelVersionError = inLoadedModel.ignoreModelVersionError

    var newArray = inLoadedModel.backPackages
    inLoadedModel.backPackages = EBReferenceArray ()
    inModelToUpdate.backPackages = newArray

    newArray = inLoadedModel.frontPackages
    inLoadedModel.frontPackages = EBReferenceArray ()
    inModelToUpdate.frontPackages = newArray

    newArray = inLoadedModel.frontTracks
    inLoadedModel.frontTracks = EBReferenceArray ()
    inModelToUpdate.frontTracks = newArray

    newArray = inLoadedModel.inner1Tracks
    inLoadedModel.inner1Tracks = EBReferenceArray ()
    inModelToUpdate.inner1Tracks = newArray

    newArray = inLoadedModel.inner2Tracks
    inLoadedModel.inner2Tracks = EBReferenceArray ()
    inModelToUpdate.inner2Tracks = newArray

    newArray = inLoadedModel.inner3Tracks
    inLoadedModel.inner3Tracks = EBReferenceArray ()
    inModelToUpdate.inner3Tracks = newArray

    newArray = inLoadedModel.inner4Tracks
    inLoadedModel.inner4Tracks = EBReferenceArray ()
    inModelToUpdate.inner4Tracks = newArray

    newArray = inLoadedModel.backTracks
    inLoadedModel.backTracks = EBReferenceArray ()
    inModelToUpdate.backTracks = newArray

    newArray = inLoadedModel.backComponentValues
    inLoadedModel.backComponentValues = EBReferenceArray ()
    inModelToUpdate.backComponentValues = newArray

    newArray = inLoadedModel.frontComponentValues
    inLoadedModel.frontComponentValues = EBReferenceArray ()
    inModelToUpdate.frontComponentValues = newArray

    newArray = inLoadedModel.frontComponentNames
    inLoadedModel.frontComponentNames = EBReferenceArray ()
    inModelToUpdate.frontComponentNames = newArray

    newArray = inLoadedModel.backComponentNames
    inLoadedModel.backComponentNames = EBReferenceArray ()
    inModelToUpdate.backComponentNames = newArray

    let newBackPadArray = inLoadedModel.backPads
    inLoadedModel.backPads = EBReferenceArray ()
    inModelToUpdate.backPads = newBackPadArray

    let newTraversingPadArray = inLoadedModel.traversingPads
    inLoadedModel.traversingPads = EBReferenceArray ()
    inModelToUpdate.traversingPads = newTraversingPadArray

    let newFrontPadArray = inLoadedModel.frontPads
    inLoadedModel.frontPads = EBReferenceArray ()
    inModelToUpdate.frontPads = newFrontPadArray

    let newViaArray = inLoadedModel.vias
    inLoadedModel.vias = EBReferenceArray ()
    inModelToUpdate.vias = newViaArray

    let newDrillArray = inLoadedModel.drills
    inLoadedModel.drills = EBReferenceArray ()
    inModelToUpdate.drills = newDrillArray

    newArray = inLoadedModel.backLayoutTexts
    inLoadedModel.backLayoutTexts = EBReferenceArray ()
    inModelToUpdate.backLayoutTexts = newArray

    newArray = inLoadedModel.backLegendTexts
    inLoadedModel.backLegendTexts = EBReferenceArray ()
    inModelToUpdate.backLegendTexts = newArray

    newArray = inLoadedModel.frontLayoutTexts
    inLoadedModel.frontLayoutTexts = EBReferenceArray ()
    inModelToUpdate.frontLayoutTexts = newArray

    newArray = inLoadedModel.frontLegendTexts
    inLoadedModel.frontLegendTexts = EBReferenceArray ()
    inModelToUpdate.frontLegendTexts = newArray

    newArray = inLoadedModel.backLegendLines
    inLoadedModel.backLegendLines = EBReferenceArray ()
    inModelToUpdate.backLegendLines = newArray

    newArray = inLoadedModel.frontLegendLines
    inLoadedModel.frontLegendLines = EBReferenceArray ()
    inModelToUpdate.frontLegendLines = newArray

    newArray = inLoadedModel.internalBoardsLimits
    inLoadedModel.internalBoardsLimits = EBReferenceArray ()
    inModelToUpdate.internalBoardsLimits = newArray

  //--- QR Codes
    inModelToUpdate.legendFrontQRCodes = inLoadedModel.legendFrontQRCodes
    inModelToUpdate.legendBackQRCodes = inLoadedModel.legendBackQRCodes
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor fileprivate var gPanel : OpenPanelDelegateForUpdatingBoardModels? = nil

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate final class OpenPanelDelegateForUpdatingBoardModels : NSObject, NSOpenSavePanelDelegate {

  //····················································································································
  //   PROPERTIES
  //····················································································································

  let mBoardModelName : String

  //····················································································································
  //   INIT
  //····················································································································

  init (_ boardModelName : String) {
    self.mBoardModelName = boardModelName
    super.init ()
    noteObjectAllocation (self)
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
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
