//
//  CanariMergerBoardScrollView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 14/07/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CanariMergerBoardScrollView) class CanariMergerBoardScrollView : CanariScrollViewWithPlacard {

  //····················································································································

  @IBOutlet weak var mDocument : MergerDocument? = nil

  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder:coder)
    self.register (forDraggedTypes: [kDragAndDropModelType])
  }

  //····················································································································

  override init (frame:NSRect) {
    super.init (frame:frame)
    self.register (forDraggedTypes: [kDragAndDropModelType])
  }
  
  //····················································································································
  //   Drag destination
  //The six NSDraggingDestination methods are invoked in a distinct order:
  //
  // ① As the image is dragged into the destination’s boundaries, the destination is sent a draggingEntered: message.
  //       The method should return a value that indicates which dragging operation the destination will perform.
  // ② While the image remains within the destination, a series of draggingUpdated: messages are sent.
  //       The method should return a value that indicates which dragging operation the destination will perform.
  // ③ If the image is dragged out of the destination, draggingExited: is sent and the sequence of`
  //       NSDraggingDestination messages stops. If it re-enters, the sequence begins again (with a new
  //       draggingEntered: message).
  // ④ When the image is released, it either slides back to its source (and breaks the sequence) or a 
  //       prepareForDragOperation: message is sent to the destination, depending on the value returned by the most
  //       recent invocation of draggingEntered: or draggingUpdated:.
  // ⑤  If the prepareForDragOperation: message returned YES, a performDragOperation: message is sent.
  // ⑥  Finally, if performDragOperation: returned YES, concludeDragOperation: is sent.
  //····················································································································

  override func draggingEntered (_ sender: NSDraggingInfo) -> NSDragOperation {
    // NSLog ("draggingEntered")
    return .copy
  }

  //····················································································································

  override func draggingUpdated (_ sender: NSDraggingInfo) -> NSDragOperation {
    // NSLog ("draggingUpdated")
    return .copy
  }

  //····················································································································

//  override func draggingExited (_ sender: NSDraggingInfo?) {
//    // NSLog ("draggingExited")
//  }

  //····················································································································

  override func prepareForDragOperation (_ sender: NSDraggingInfo) -> Bool {
    // NSLog ("prepareForDragOperation")
    return true
  }

  //····················································································································

  override func performDragOperation (_ sender: NSDraggingInfo) -> Bool {
    // NSLog ("performDragOperation")
    return true
  }

  //····················································································································

  override func concludeDragOperation (_ inSender: NSDraggingInfo?) {
    if let sender = inSender, let document = mDocument, let documentView = self.documentView {
      let draggingLocationInWindow = sender.draggingLocation ()
      let draggingLocationInDestinationView = documentView.convert (draggingLocationInWindow, from:nil)
      // NSLog ("concludeDragOperation at \(draggingLocationInWindow), \(documentView) \(draggingLocationInDestinationView)")
      let pasteboard = sender.draggingPasteboard ()
      if let data = pasteboard.data (forType: kDragAndDropModelType), let boardModelName = String (data: data, encoding: .ascii) {
        // NSLog ("\(boardModelName)")
        var possibleBoardModel : BoardModel? = nil
        for boardModel in document.rootObject.boardModels_property.propval {
          if boardModel.name == boardModelName {
            possibleBoardModel = boardModel
            break
          }
        }
        if  let boardModel = possibleBoardModel {
         // NSLog ("x \(mouseLocation.x), y \(mouseLocation.y)")
          let newBoard = MergerBoardInstance (managedObjectContext: document.managedObjectContext())
          newBoard.myModel_property.setProp (boardModel)
          newBoard.x = cocoaToCanariUnit (draggingLocationInDestinationView.x)
          newBoard.y = cocoaToCanariUnit (draggingLocationInDestinationView.y)
          document.rootObject.boardInstances_property.add (newBoard)
        }else{
          NSLog ("Cannot find '\(boardModelName)' board model")
        }
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
