//
//  MergerDocument-customized.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 25/11/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate let kDragAndDropModelType = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.board.model")

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CustomizedMergerDocument) class CustomizedMergerDocument : MergerDocument {

  //····················································································································
  //    buildUserInterface: customization of interface
  //····················································································································

  override func windowControllerDidLoadNib (_ aController: NSWindowController) {
    super.windowControllerDidLoadNib (aController)
  //--- Set pages segmented control
    let pages = [self.mModelPageView, self.mBoardPageView, self.mProductPageView]
    self.mPageSegmentedControl?.register (masterView: self.mMasterView, pages)
  //--- Set board inspector segmented control
    let boardInspectors = [self.mBoardOperationInspectorView, self.mBoardIssueInspectorView]
    self.mBoardInspectorSegmentedControl?.register (masterView: self.mBoardInspectorMasterView, boardInspectors)
  //--- Set document to scroll view for enabling drag and drop
    self.mComposedBoardScrollView?.register (document: self, draggedTypes: [kDragAndDropModelType])
    self.mModelDragSourceTableView?.register (document: self, draggedType: kDragAndDropModelType)
  //--- Set issue display view
    self.mIssueTableView?.register (issueDisplayView: self.mComposedBoardView)
    self.mIssueTableView?.register (hideIssueButton: self.mDeselectIssueButton)
    self.mIssueTableView?.register (segmentedControl: self.mBoardInspectorSegmentedControl, segment: 1)
  }

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
          let newBoard = MergerBoardInstance (self.ebUndoManager, file: #file, #line)
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

  override func dragImageForRows (with dragRows: IndexSet,
                                  tableColumns: [NSTableColumn],
                                  event dragEvent: NSEvent,
                                  offset dragImageOffset: NSPointPointer) -> NSImage {
    if let boardView = self.mComposedBoardView, dragRows.count == 1, let idx = dragRows.first {
    //--- Get board view scale and flip
      let scale : CGFloat = boardView.actualScale
     // Swift.print ("Scale \(scale)")
      let horizontalFlip : CGFloat = boardView.horizontalFlip ? -1.0 : 1.0
      let verticalFlip   : CGFloat = boardView.verticalFlip   ? -1.0 : 1.0
    //--- Image size
      let boardModel = self.rootObject.boardModels_property.propval [idx]
   //   Swift.print ("Model size: \(canariUnitToCocoa (boardModel.modelWidth)), \(canariUnitToCocoa (boardModel.modelHeight))")
      var width  : CGFloat = scale * canariUnitToCocoa (boardModel.modelWidth)
      var height : CGFloat = scale * canariUnitToCocoa (boardModel.modelHeight)
   //   Swift.print ("Image size: \(width), \(height)")
    //--- Orientation (0 -> 0°, 1 -> 90°, 2 -> 180°, 3 -> 270°)
      let rotation = self.mInsertedInstanceDefaultOrientation?.selectedTag () ?? 0
      if (rotation == 1) || (rotation == 3) {
        let temp = width
        width = height
        height = temp
      }
    //--- By default, image is centered
      dragImageOffset.pointee = NSPoint (x: horizontalFlip * width / 2.0, y: verticalFlip * height / 2.0)
    //--- Build image
      let r = CGRect (x: 0.0, y: 0.0, width: width, height: height)
      let bp = NSBezierPath (rect: r.insetBy (dx: 0.5, dy: 0.5))
      bp.lineWidth = 1.0
      let shape = EBStrokeBezierPathShape ([bp], NSColor.gray)
      let data = buildPDFimage (frame: r, shape: shape, backgroundColor:NSColor.gray.withAlphaComponent (0.25))
      let image = NSImage (data: data)!
      return image
    }else{
      return NSImage (named: NSImage.Name ("exclamation"))!
    }
  }
  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
