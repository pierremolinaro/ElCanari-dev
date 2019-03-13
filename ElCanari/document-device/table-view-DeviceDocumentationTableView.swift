//
//  table-view-DeviceDocumentationTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/02/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//extension ArrayController_DeviceDocument_mDocumentationController {
//
//  func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
//
//      if dropOperation == .above {
//          return .move
//      }
//      return .all
//  }
//
//  func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
//    return true
//  }
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  NSPasteboard.PasteboardType.fileURL is available from 10.13

private let myFileURL =  NSPasteboard.PasteboardType (kUTTypeFileURL as String)

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  https://stackoverflow.com/questions/38840942/drag-and-dropping-on-a-string-images-nstableview-swift

class DeviceDocumentationTableView : EBTableView {

  //····················································································································
  // MARK: -
  //····················································································································

  private weak var mDocument : DeviceDocument? = nil

  //····················································································································

  func registerDraggedTypesAnd (document inDocument : DeviceDocument) {
    self.mDocument = inDocument
    self.registerForDraggedTypes ([myFileURL])
  }

  //····················································································································
  // MARK: -
  //····················································································································

  override func draggingEntered (_ inSender : NSDraggingInfo) -> NSDragOperation {
    var dragOperation : NSDragOperation = []
    if let array = inSender.draggingPasteboard.readObjects (forClasses: [NSURL.self]) as? [URL] {
      var idx = 0
      while (idx < array.count) && (dragOperation == []) {
        if array [idx].pathExtension == "pdf" {
          dragOperation = .copy
        }
        idx += 1
      }
    }
    return dragOperation
  }

  //····················································································································

  override func draggingUpdated (_ inSender : NSDraggingInfo) -> NSDragOperation {
    return self.draggingEntered (inSender)
  }

  //····················································································································

  override func draggingExited (_ inSender : NSDraggingInfo?) {
  }

  //····················································································································

  override func prepareForDragOperation (_ inSender : NSDraggingInfo) -> Bool {
    return true
  }

  //····················································································································

  override func performDragOperation (_ inSender : NSDraggingInfo) -> Bool {
    return self.draggingEntered (inSender) == .copy
  }

  //····················································································································

  override func concludeDragOperation (_ inSender : NSDraggingInfo?) {
    if let array = inSender?.draggingPasteboard.readObjects (forClasses: [NSURL.self]) as? [URL] {
      for sourceFileURL in array {
        if sourceFileURL.pathExtension == "pdf", let data = try? Data (contentsOf: sourceFileURL) {
          // NSLog ("sourceFileURL \(sourceFileURL), size \(data.count.stringWithSeparator) bytes") ;
          let doc = DeviceDocumentation (self.mDocument?.ebUndoManager)
          doc.mFileData = data
          doc.mFileName = sourceFileURL.path.lastPathComponent.deletingPathExtension
          self.mDocument?.rootObject.mDocs_property.add (doc)
        }
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
