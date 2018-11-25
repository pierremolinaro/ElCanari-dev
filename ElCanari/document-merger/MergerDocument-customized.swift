//
//  MergerDocument-customized.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 25/11/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CustomizedMergerDocument) class CustomizedMergerDocument : MergerDocument {

  //····················································································································
  //    windowControllerDidLoadNib: customization of interface
  //····················································································································

  override func windowControllerDidLoadNib (_ aController: NSWindowController) {
    super.windowControllerDidLoadNib (aController)
  //--- Set document to scroll view for enabling drag and drop
    self.mComposedBoardScrollView?.mDocument = self
  }

  //····················································································································
  //    Drag and drop destination
  //····················································································································

  override func draggingEntered (_ sender: NSDraggingInfo, _ destinationScrollView : NSScrollView) -> NSDragOperation {
    return .copy
  }

  //····················································································································

  override func draggingUpdated (_ sender: NSDraggingInfo, _ destinationScrollView : NSScrollView) -> NSDragOperation {
    return .copy
  }

  //····················································································································

  override func performDragOperation (_ sender: NSDraggingInfo, _ destinationScrollView : NSScrollView) -> Bool {
    return true
  }

  //····················································································································

  override func concludeDragOperation (_ inSender: NSDraggingInfo?, _ destinationScrollView : NSScrollView) {
    if let sender = inSender, let documentView = destinationScrollView.documentView {
      let draggingLocationInWindow = sender.draggingLocation
      let draggingLocationInDestinationView = documentView.convert (draggingLocationInWindow, from:nil)
      // NSLog ("concludeDragOperation at \(draggingLocationInWindow), \(documentView) \(draggingLocationInDestinationView)")
      let pasteboard = sender.draggingPasteboard
      if let data = pasteboard.data (forType: kDragAndDropModelType), let boardModelName = String (data: data, encoding: .ascii) {
        // NSLog ("\(boardModelName)")
        var possibleBoardModel : BoardModel? = nil
        for boardModel in self.rootObject.boardModels_property.propval {
          if boardModel.name == boardModelName {
            possibleBoardModel = boardModel
            break
          }
        }
        if  let boardModel = possibleBoardModel {
         // NSLog ("x \(mouseLocation.x), y \(mouseLocation.y)")
          let rotation = QuadrantRotation (rawValue: self.mInsertedInstanceDefaultOrientation?.selectedTag () ?? 0)!
          let newBoard = MergerBoardInstance (managedObjectContext: self.managedObjectContext, file: #file, #line)
          newBoard.myModel_property.setProp (boardModel)
          newBoard.x = cocoaToCanariUnit (draggingLocationInDestinationView.x)
          newBoard.y = cocoaToCanariUnit (draggingLocationInDestinationView.y)
          newBoard.instanceRotation = rotation
          self.rootObject.boardInstances_property.add (newBoard)
          self.mBoardInstanceController.setSelection ([newBoard])
        }else{
          NSLog ("Cannot find '\(boardModelName)' board model")
        }
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
