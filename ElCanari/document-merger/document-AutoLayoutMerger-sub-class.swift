//
//  document-AutoLayoutMerger-sub-class.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 03/12/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

let EL_CANARI_LEGACY_MERGER_ARCHIVE = "ElCanariMergerArchive"

let EL_CANARI_MERGER_ARCHIVE = "ElCanariBoardArchive"

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
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    Properties for insert array of boards dialog
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let mInsertArrayOfBoardsXCount = EBStoredProperty <Int> (defaultValue: 1, undoManager: nil, key: nil)
  let mInsertArrayOfBoardsYCount = EBStoredProperty <Int> (defaultValue: 1, undoManager: nil, key: nil)
  let mInsertArrayOfBoardsOrientation = EBStoredProperty_QuadrantRotation (defaultValue: .rotation0, undoManager: nil, key: nil)

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    Drag and drop destination
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func prepareForDragOperation (_ inSender : NSDraggingInfo,
                                         _ inDestinationScrollView : NSScrollView) -> Bool {
    if DEBUG_DRAG_AND_DROP {
      Swift.print (self.className + "." + #function)
    }
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func performDragOperation (_ inSender : NSDraggingInfo,
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
        newBoard.x = cocoaToCanariUnit (draggingLocationInDestinationView.x)
        newBoard.y = cocoaToCanariUnit (draggingLocationInDestinationView.y)
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
                       forDragRowIndex inDragRow : Int) -> (NSImage, NSPoint) {
    if DEBUG_DRAG_AND_DROP {
      Swift.print (self.className + "." + #function)
    }
    var resultImage = NSImage (named: NSImage.Name ("exclamation"))!
    var resultOffset = NSPoint ()
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
     //   Swift.print ("Model size: \(canariUnitToCocoa (boardModel.modelWidth)), \(canariUnitToCocoa (boardModel.modelHeight))")
        var width  : CGFloat = scale * canariUnitToCocoa (boardModel.modelWidth)
        var height : CGFloat = scale * canariUnitToCocoa (boardModel.modelHeight)
     //   Swift.print ("Image size: \(width), \(height)")
      //--- Orientation
        let rotation = self.rootObject.modelInsertionRotation
        if (rotation == .rotation90) || (rotation == .rotation270) {
          (width, height) = (height, width)
        }
      //--- By default, image is centered
        resultOffset = NSPoint (x: horizontalFlip * width / 2.0, y: verticalFlip * height / 2.0)
      //--- Build image
        let r = NSRect (x: 0.0, y: 0.0, width: width, height: height)
        var bp = EBBezierPath (rect: r.insetBy (dx: 0.5, dy: 0.5))
        bp.lineWidth = 1.0
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
