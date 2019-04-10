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
    let selectedModels : EBSelection < [BoardModel] > = mBoardModelController.selectedArray_property.prop
    switch selectedModels {
    case .single (let models) :
      if models.count == 1 {
        let updatedBoardModel = models [0]
        let boardModelName : String = updatedBoardModel.name
      //--- Dialog
        if let window = self.windowForSheet {
          let openPanel = NSOpenPanel ()
          openPanel.canChooseFiles = true
          openPanel.canChooseDirectories = false
          openPanel.allowsMultipleSelection = false
          openPanel.allowedFileTypes = [EL_CANARI_MERGER_ARCHIVE, KICAD_PCB]
        // MANDATORY! This object is set to NSOpenPanel delegate that DOES NOT retain it
          gPanel = OpenPanelDelegateForUpdatingBoardModels (boardModelName) // MANDATORY! This object is set to NSOpenPanel delegate that DOES NOT retain it
          openPanel.delegate = gPanel
          openPanel.beginSheetModal (for: window) { (returnCode : NSApplication.ModalResponse) in
            gPanel = nil
            if returnCode == .OK {
              if let url = openPanel.url, url.isFileURL {
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

                    var newArray = newTemporaryBoardModel.backPackages_property.propval
                    newTemporaryBoardModel.backPackages_property.setProp ([])
                    updatedBoardModel.backPackages_property.setProp (newArray)

                    newArray = newTemporaryBoardModel.frontPackages_property.propval
                    newTemporaryBoardModel.frontPackages_property.setProp ([])
                    updatedBoardModel.frontPackages_property.setProp (newArray)

                    newArray = newTemporaryBoardModel.frontTracks_property.propval
                    newTemporaryBoardModel.frontTracks_property.setProp ([])
                    updatedBoardModel.frontTracks_property.setProp (newArray)

                    newArray = newTemporaryBoardModel.backTracks_property.propval
                    newTemporaryBoardModel.backTracks_property.setProp ([])
                    updatedBoardModel.backTracks_property.setProp (newArray)

                    newArray = newTemporaryBoardModel.backComponentValues_property.propval
                    newTemporaryBoardModel.backComponentValues_property.setProp ([])
                    updatedBoardModel.backComponentValues_property.setProp (newArray)

                    newArray = newTemporaryBoardModel.frontComponentValues_property.propval
                    newTemporaryBoardModel.frontComponentValues_property.setProp ([])
                    updatedBoardModel.frontComponentValues_property.setProp (newArray)

                    newArray = newTemporaryBoardModel.frontComponentNames_property.propval
                    newTemporaryBoardModel.frontComponentNames_property.setProp ([])
                    updatedBoardModel.frontComponentNames_property.setProp (newArray)

                    newArray = newTemporaryBoardModel.backComponentNames_property.propval
                    newTemporaryBoardModel.backComponentNames_property.setProp ([])
                    updatedBoardModel.backComponentNames_property.setProp (newArray)

                    let newBackPadArray = newTemporaryBoardModel.backPads_property.propval
                    newTemporaryBoardModel.backPads_property.setProp ([])
                    updatedBoardModel.backPads_property.setProp (newBackPadArray)

                    let newFrontPadArray = newTemporaryBoardModel.frontPads_property.propval
                    newTemporaryBoardModel.frontPads_property.setProp ([])
                    updatedBoardModel.frontPads_property.setProp (newFrontPadArray)

                    let newViaArray = newTemporaryBoardModel.vias_property.propval
                    newTemporaryBoardModel.vias_property.setProp ([])
                    updatedBoardModel.vias_property.setProp (newViaArray)

                    let newDrillArray = newTemporaryBoardModel.drills_property.propval
                    newTemporaryBoardModel.drills_property.setProp ([])
                    updatedBoardModel.drills_property.setProp (newDrillArray)

                    newArray = newTemporaryBoardModel.backLayoutTexts_property.propval
                    newTemporaryBoardModel.backLayoutTexts_property.setProp ([])
                    updatedBoardModel.backLayoutTexts_property.setProp (newArray)

                    newArray = newTemporaryBoardModel.backLegendTexts_property.propval
                    newTemporaryBoardModel.backLegendTexts_property.setProp ([])
                    updatedBoardModel.backLegendTexts_property.setProp (newArray)

                    newArray = newTemporaryBoardModel.frontLayoutTexts_property.propval
                    newTemporaryBoardModel.frontLayoutTexts_property.setProp ([])
                    updatedBoardModel.frontLayoutTexts_property.setProp (newArray)

                    newArray = newTemporaryBoardModel.frontLegendTexts_property.propval
                    newTemporaryBoardModel.frontLegendTexts_property.setProp ([])
                    updatedBoardModel.frontLegendTexts_property.setProp (newArray)

                    newArray = newTemporaryBoardModel.backLegendLines_property.propval
                    newTemporaryBoardModel.backLegendLines_property.setProp ([])
                    updatedBoardModel.backLegendLines_property.setProp (newArray)

                    newArray = newTemporaryBoardModel.frontLegendLines_property.propval
                    newTemporaryBoardModel.frontLegendLines_property.setProp ([])
                    updatedBoardModel.frontLegendLines_property.setProp (newArray)
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
    default :
      break
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate var gPanel : OpenPanelDelegateForUpdatingBoardModels?

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate class OpenPanelDelegateForUpdatingBoardModels : EBObject, NSOpenSavePanelDelegate {

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

  func panel (_ sender: Any, shouldEnable url: URL) -> Bool {
    let path = url.path
    let fm = FileManager ()
    var isDirectory : ObjCBool = false
    _ = fm.fileExists(atPath: path, isDirectory: &isDirectory)
    return isDirectory.boolValue || (mBoardModelName == path.lastPathComponent.deletingPathExtension)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
