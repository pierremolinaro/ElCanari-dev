//
//  AutoLayoutDroppableImageView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 29/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutDroppableImageView : NSImageView {

  //····················································································································

  private let mImageWidth : CGFloat
  private var mDroppedImageCallBack : Optional < (Data) -> Void> = nil

  //····················································································································

   init (width inWidth : Int) {
    self.mImageWidth = CGFloat (inWidth)
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.registerForDraggedTypes (myPasteboardImageTypes ())
  }

 //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  override var intrinsicContentSize : NSSize {
    let s = super.intrinsicContentSize
    return NSSize (width: self.mImageWidth, height: s.height)
  }


  //····················································································································

  func set (droppedImageCallBack inCallBack : @escaping (Data) -> Void) {
    self.mDroppedImageCallBack = inCallBack
  }

  //····················································································································
  //   Drag destination
  //····················································································································
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

  override func draggingEntered (_ inSender : NSDraggingInfo) -> NSDragOperation {
    var accepts = self.mDroppedImageCallBack != nil
    if accepts {
      let draggingPasteboard = inSender.draggingPasteboard
      accepts = NSImage.canInit (with: draggingPasteboard)
    }
    return accepts ? .copy : []
  }

  //····················································································································

  override func draggingUpdated (_ sender : NSDraggingInfo) -> NSDragOperation {
    return .copy
  }

  //····················································································································

  override func draggingExited (_ sender : NSDraggingInfo?) {
  }

  //····················································································································

  override func prepareForDragOperation (_ sender : NSDraggingInfo) -> Bool {
    return true
  }

  //····················································································································

  override func performDragOperation (_ sender : NSDraggingInfo) -> Bool {
    return true
  }

  //····················································································································

  override func concludeDragOperation (_ inSender : NSDraggingInfo?) {
    if let pboard = inSender?.draggingPasteboard {
      if let pdfData = pboard.data (forType: .pdf) {
        self.mDroppedImageCallBack? (pdfData)
      }else if let pngData = pboard.data (forType: .png) {
        self.mDroppedImageCallBack? (pngData)
      }else if let tiffData = pboard.data (forType: .tiff) {
        self.mDroppedImageCallBack? (tiffData)
      }else if let tiffData = NSImage (pasteboard: pboard)?.tiffRepresentation {
        self.mDroppedImageCallBack? (tiffData)
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// https://forums.developer.apple.com/thread/79144
// https://stackoverflow.com/questions/24343216/drag-and-drop-in-swift-issues-with-registering-for-dragged-types/39330243
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func myPasteboardImageTypes () -> [NSPasteboard.PasteboardType] {
  var result = [NSPasteboard.PasteboardType] ()
  for s in NSImage.imageTypes {
//    NSLog ("image type: \(s)")
    result.append (NSPasteboard.PasteboardType (rawValue: s))
  }
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
