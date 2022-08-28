//
//  document-AutoLayoutMerger-sub-class.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 03/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let EL_CANARI_MERGER_ARCHIVE = "ElCanariMergerArchive"

let KICAD_PCB = "kicad_pcb"

let kDragAndDropMergerModelType = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.board.model")

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(AutoLayoutMergerDocumentSubClass) final class AutoLayoutMergerDocumentSubClass : AutoLayoutMergerDocument {

  //····················································································································

  override func ebBuildUserInterface () {
    super.ebBuildUserInterface ()
    self.mComposedBoardGraphicView?.mScrollView?.registerContextualMenuBuilder { [weak self] (inMouseDownLocation : CanariPoint) in
      return self?.buildInsertModelInBoardMenuBuilder (inMouseDownLocation) ?? NSMenu ()
    }
  }

  //····················································································································
  //    Properties for insert array of boards dialog
  //····················································································································

  let mInsertArrayOfBoardsXCount = EBGenericStoredProperty <Int> (defaultValue: 1, undoManager: nil)
  let mInsertArrayOfBoardsYCount = EBGenericStoredProperty <Int> (defaultValue: 1, undoManager: nil)
  let mInsertArrayOfBoardsOrientation = EBStoredProperty_QuadrantRotation (defaultValue: .rotation0, undoManager: nil)

  //····················································································································
  //    Drag and drop destination
  //····················································································································

  override func prepareForDragOperation (_ sender: NSDraggingInfo, _ destinationScrollView : NSScrollView) -> Bool {
    return true
  }

  //····················································································································

  override func performDragOperation (_ sender: NSDraggingInfo, _ destinationScrollView : NSScrollView) -> Bool {
    var ok = false
    if let documentView = destinationScrollView.documentView {
      let draggingLocationInWindow = sender.draggingLocation
      let draggingLocationInDestinationView = documentView.convert (draggingLocationInWindow, from:nil)
      // NSLog ("concludeDragOperation at \(draggingLocationInWindow), \(documentView) \(draggingLocationInDestinationView)")
      let pasteboard = sender.draggingPasteboard
      if let data = pasteboard.data (forType: kDragAndDropMergerModelType), let boardModelName = String (data: data, encoding: .ascii) {
        NSLog ("\(boardModelName)")
        var possibleBoardModel : BoardModel? = nil
        for boardModel in self.rootObject.boardModels_property.propval.values {
          if boardModel.name == boardModelName {
            possibleBoardModel = boardModel
            break
          }
        }
        if  let boardModel = possibleBoardModel {
         // NSLog ("x \(mouseLocation.x), y \(mouseLocation.y)")
          let rotation = self.rootObject.modelInsertionRotation
          let newBoard = MergerBoardInstance (self.ebUndoManager)
          newBoard.myModel_property.setProp (boardModel)
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
    }
    return ok
  }

  //····················································································································
  // Providing the drag image, called by a source drag table view (CanariDragSourceTableView)
  //····················································································································

  override func dragImageForRows (source inSourceTableView : AutoLayoutCanariDragSourceTableView,
                                  with dragRows: IndexSet,
                                  tableColumns: [NSTableColumn],
                                  event dragEvent: NSEvent,
                                  offset dragImageOffset: NSPointPointer) -> NSImage {
    if let boardView = super.mComposedBoardGraphicView?.mGraphicView,
       dragRows.count == 1,
       let idx = dragRows.first,
       let boardModelTag = super.mModelDragSourceTableView?.tag (atIndex: idx) {
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
          let temp = width
          width = height
          height = temp
        }
      //--- By default, image is centered
        dragImageOffset.pointee = NSPoint (x: horizontalFlip * width / 2.0, y: verticalFlip * height / 2.0)
      //--- Build image
        let r = NSRect (x: 0.0, y: 0.0, width: width, height: height)
        var bp = EBBezierPath (rect: r.insetBy (dx: 0.5, dy: 0.5))
        bp.lineWidth = 1.0
        var shape = EBShape ()
        shape.add (stroke: [bp], NSColor.gray)
        let image = buildPDFimage (frame: r, shape: shape, backgroundColor:NSColor.gray.withAlphaComponent (0.25))
        return image
      }else{
        return NSImage (named: NSImage.Name ("exclamation"))!
      }
    }else{
      return NSImage (named: NSImage.Name ("exclamation"))!
   }
//    return NSImage (named: NSImage.Name ("exclamation"))!
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
