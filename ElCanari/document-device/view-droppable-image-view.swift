//
//  view-droppable-image-view.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 26/02/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// https://forums.developer.apple.com/thread/79144
// https://stackoverflow.com/questions/24343216/drag-and-drop-in-swift-issues-with-registering-for-dragged-types/39330243
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func myPasteboardImageTypes () -> [NSPasteboard.PasteboardType] {
  var result = [NSPasteboard.PasteboardType] ()
  for s in NSImage.imageTypes {
    // NSLog ("\(s)")
    result.append (NSPasteboard.PasteboardType (rawValue: s))
  }
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// https://stackoverflow.com/questions/44537356/swift-4-nsfilenamespboardtype-not-available-what-to-use-instead-for-registerfo

//extension NSPasteboard.PasteboardType {
//  static let fileURL =  NSPasteboard.PasteboardType ("public.file-url")
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class DeviceDroppableImageView : NSImageView, EBUserClassNameProtocol {

  //····················································································································
  // MARK: -
  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder:coder)
    noteObjectAllocation (self)
    self.registerDraggedTypes ()
  }

  //····················································································································

  override init (frame:NSRect) {
    super.init (frame:frame)
    noteObjectAllocation (self)
    self.registerDraggedTypes ()
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  private func registerDraggedTypes () {
    self.registerForDraggedTypes (myPasteboardImageTypes ())
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
    let draggingPasteboard = inSender.draggingPasteboard
    return NSImage.canInit (with: draggingPasteboard) ? .copy : []
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
    if let pboard = inSender?.draggingPasteboard, let tiffData = NSImage (pasteboard: pboard)?.tiffRepresentation {
      self.mImageDataController?.setModel (tiffData)
    }
 //     self.image = NSImage (pasteboard: pboard)
  }

  //····················································································································
  //  $imageData binding
  //····················································································································

  private var mImageDataController : Controller_DeviceDroppableImageView_imageData? = nil

  //····················································································································

  func bind_imageData (_ model : EBStoredProperty_Data, file : String, line : Int) {
    self.mImageDataController = Controller_DeviceDroppableImageView_imageData (
      object: model,
      outlet: self
     )
  }

  //····················································································································

  func unbind_imageData () {
    self.mImageDataController?.unregister ()
    self.mImageDataController = nil
  }

  //····················································································································

}


//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller Controller_DeviceDroppableImageView_imageData
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_DeviceDroppableImageView_imageData : EBSimpleController {

  private let mOutlet : DeviceDroppableImageView
  private let mObject : EBStoredProperty_Data

  //····················································································································

  init (object : EBStoredProperty_Data, outlet : DeviceDroppableImageView) {
    mObject = object
    mOutlet = outlet
    super.init (observedObjects:[object])
    self.mEventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································

  private func updateOutlet () {
    switch mObject.prop {
    case .empty, .multiple :
      mOutlet.image = nil
    case .single (let data) :
      mOutlet.image = NSImage (data: data)
    }
  }

  //····················································································································

  func setModel (_ data : Data) {
    _ = mObject.validateAndSetProp (data, windowForSheet: nil)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
