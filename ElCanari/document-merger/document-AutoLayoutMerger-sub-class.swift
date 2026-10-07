//
//  document-AutoLayoutMerger-sub-class.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 03/12/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

let EL_CANARI_LEGACY_MERGER_ARCHIVE = "ElCanariMergerArchive"

let EL_CANARI_MERGER_ARCHIVE = "ElCanariBoardArchive2"

let KICAD_PCB = "kicad_pcb"

let kDragAndDropMergerModelType = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.board.model")

//--------------------------------------------------------------------------------------------------

@objc(AutoLayoutMergerDocumentSubClass) final class AutoLayoutMergerDocumentSubClass : AutoLayoutMergerDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func ebBuildUserInterface () {
    super.ebBuildUserInterface ()
    self.mComposedBoardGraphicView?.mScrollView?.registerContextualMenuBuilder { [weak self] (inMouseDownLocation : CanariPoint) in
      return self?.buildInsertModelInBoardMenuBuilder (inMouseDownLocation) ?? NSMenu ()
    }
  //--- Update models for detecting legacy models (without JSON description)
    var modelsToUpdate = [BoardModel] ()
    for model in self.rootObject.boardModels.values {
      if model.modelData.count == 0 {
        modelsToUpdate.append (model)
      }
    }
    if modelsToUpdate.count > 0 {
      DispatchQueue.main.async {
        self.updateLegacyModel (legacyBoardModels: modelsToUpdate)
      }
    }
  //--- Needs library update ?
    self.triggerStandAlonePropertyComputationForMerger ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    Properties for insert array of boards dialog
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let mInsertArrayOfBoardsXCount = EBStandAloneProperty <Int> (1)
  let mInsertArrayOfBoardsYCount = EBStandAloneProperty <Int> (1)
  let mInsertArrayOfBoardsOrientation = EBStandAloneProperty_QuadrantRotation (.rotation0)

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    Drag and drop destination
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func prepareForDragOperation (_ inSender : any NSDraggingInfo,
                                         _ inDestinationScrollView : NSScrollView) -> Bool {
    if DEBUG_DRAG_AND_DROP {
      Swift.print (self.className + "." + #function)
    }
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func performDragOperation (_ inSender : any NSDraggingInfo,
                                      _ inDestinationScrollView : NSScrollView) -> Bool {
    if DEBUG_DRAG_AND_DROP {
      Swift.print (self.className + "." + #function)
    }
    var ok = false
    if let documentView = inDestinationScrollView.documentView,
       let boardModelName = inSender.draggingPasteboard.string (forType: kDragAndDropMergerModelType) {
      let draggingLocationInWindow = inSender.draggingLocation
      let draggingLocationInDestinationView = documentView.convert (draggingLocationInWindow, from: nil)
      var possibleBoardModel : BoardModel? = nil
      for boardModel in self.rootObject.boardModels.values {
        if boardModel.name == boardModelName {
          possibleBoardModel = boardModel
          break
        }
      }
      if let boardModel = possibleBoardModel {
       // NSLog ("x \(mouseLocation.x), y \(mouseLocation.y)")
        let rotation = self.rootObject.modelInsertionRotation
        let newBoard = MergerBoardInstance (self.undoManager)
        newBoard.myModel = boardModel
        newBoard.x = CanariLength.pt (draggingLocationInDestinationView.x)
        newBoard.y = CanariLength.pt (draggingLocationInDestinationView.y)
        newBoard.instanceRotation = rotation
        self.rootObject.boardInstances_property.add (newBoard)
        self.mBoardInstanceController.setSelection ([newBoard])
        ok = true
      }else{
        NSLog ("Cannot find '\(boardModelName)' board model")
      }
    }
    return ok
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Providing the drag image, called by a source drag table view (CanariDragSourceTableView)
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func image (forDragSource inSourceTableView : AutoLayoutCanariDragSourceTableView,
                       forDragRowIndex inDragRow : Int) -> (NSImage, CanariPoint) {
    if DEBUG_DRAG_AND_DROP {
      Swift.print (self.className + "." + #function)
    }
    var resultImage = NSImage (named: NSImage.Name ("exclamation"))!
    var resultOffset = CanariPoint ()
    if let boardView = super.mComposedBoardGraphicView?.mGraphicView,
       let boardModelTag = super.mModelDragSourceTableView?.tag (atIndex: inDragRow) {
    //--- Find board model
      var optionalBoardModel : BoardModel? = nil
      for boardModel in self.rootObject.boardModels.values {
        if boardModel.objectIndex == boardModelTag {
          optionalBoardModel = boardModel
          break
        }
      }
      if let boardModel = optionalBoardModel {
      //--- Get board view scale and flip
        let scale : CGFloat = boardView.actualScale
       // Swift.print ("Scale \(scale)")
        let horizontalFlip : CGFloat = boardView.horizontalFlip ? -1.0 : 1.0
        let verticalFlip   : CGFloat = boardView.verticalFlip   ? -1.0 : 1.0
      //--- Image size
        var width  = scale * boardModel.modelWidth
        var height = scale * boardModel.modelHeight
      //--- Orientation
        let rotation = self.rootObject.modelInsertionRotation
        if (rotation == .rotation90) || (rotation == .rotation270) {
          (width, height) = (height, width)
        }
      //--- By default, image is centered
        resultOffset = CanariPoint (x: horizontalFlip * width / 2.0, y: verticalFlip * height / 2.0)
      //--- Build image
        let r = CanariRect (left: .zero, bottom: .zero, width: width, height: height)
        var bp = BezierPath (rect: r.insetBy (dx: .pt (0.5), dy: .pt (0.5)))
        bp.lineWidth = CanariLength.pt (1.0)
        var shape = EBShape ()
        shape.add (stroke: [bp], NSColor.gray)
        resultImage = buildPDFimage (frame: r, shape: shape, backgroundColor: .gray.withAlphaComponent (0.25))
      }
    }
    return (resultImage, resultOffset)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
