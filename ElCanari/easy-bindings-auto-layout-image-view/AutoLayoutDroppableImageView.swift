//
//  AutoLayoutDroppableImageView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 29/06/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
// https://stackoverflow.com/questions/44537356/swift-4-nsfilenamespboardtype-not-available-what-to-use-instead-for-registerfo
//--------------------------------------------------------------------------------------------------

final class AutoLayoutDroppableImageView : AutoLayoutVerticalStackView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mImageView = AutoLayoutInternalDroppableImageView ()
  private let mRemoveButton : AutoLayoutButton?

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (removeButton inHasRemoveButton : Bool) {
    self.mRemoveButton = inHasRemoveButton
      ? AutoLayoutButton (title: "-", size: .small)
      : nil

    super.init ()

    _ = self.mRemoveButton?.bind_run (target: self, selector: #selector (Self.removeImageAction (_:)))
    self.mImageView.mDroppableImageView = self

    let pasteImageButton = AutoLayoutButton (title: "Paste Image", size: .small)
      .bind_run (target: self, selector: #selector (Self.pasteImageAction (_:)))

    let copyImageButton = AutoLayoutButton (title: "Copy Image", size: .small)
      .bind_run (target: self, selector: #selector (Self.copyImageAction (_:)))


    _ = self.appendView (self.mImageView)

    if let removeButton = self.mRemoveButton {
      let hStack = AutoLayoutHorizontalStackView ()
        .appendView (removeButton)
        .appendFlexibleSpace ()
        .appendView (pasteImageButton)
        .appendView (copyImageButton)
      _ = self.appendView (hStack)
    }else{
      let hStack = AutoLayoutHorizontalStackView ()
        .appendView (pasteImageButton)
        .appendFlexibleSpace ()
        .appendView (copyImageButton)
      _ = self.appendView (hStack)
    }
  }

 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -····················

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func set (maxWidth inMaxWidth : Int) -> Self {
    self.mImageView.set (maxWidth: inMaxWidth)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func set (maxHeight inMaxHeight : Int) -> Self {
    self.mImageView.set (maxHeight: inMaxHeight)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc func removeImageAction (_ _ : Any?) {
    self.setModel (Data ())
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc func copyImageAction (_ _ : Any?) {
    if let data = self.mModel?.optionalValue {
      let pasteboard = NSPasteboard.general
      pasteboard.clearContents ()
      pasteboard.setData (data, forType: .tiff)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc func pasteImageAction (_ _ : Any?) {
    if let pdfData = NSPasteboard.general.data (forType: .pdf) {
      self.setModel (pdfData)
    }else if let pngData = NSPasteboard.general.data (forType: .png) {
      self.setModel (pngData)
    }else if let tiffData = NSPasteboard.general.data (forType: .tiff) {
      self.setModel (tiffData)
    }else if let tiffData = NSImage (pasteboard: NSPasteboard.general)?.tiffRepresentation {
      self.setModel (tiffData)
    }else if let window = unsafe self.window {
      NSSound.beep ()
      let alert = NSAlert ()
      alert.messageText = "Cannot paste an image."
      alert.informativeText = "The pasteboard does not contain a valid image."
      alert.beginSheetModal (for: window)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $imageData binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func updateImageData (_ object : EBObservableProperty <Data>) {
    switch object.selection {
    case .empty, .multiple :
      self.mImageView.image = nil
      self.mRemoveButton?.isEnabled = false
    case .single (let data) :
      self.mImageView.image = NSImage (data: data)
      self.mRemoveButton?.isEnabled = !data.isEmpty
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mImageDataController : EBObservablePropertyController? = nil
  private weak var mModel : EBObservableMutableProperty <Data>? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func setModel (_ inData : Data) {
    _ = self.mModel?.setProp (inData)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_imageData (_ inModel : EBObservableMutableProperty <Data>) -> Self {
    self.mModel = inModel
    self.mImageDataController = EBObservablePropertyController (
      observedObjects: [inModel],
      callBack: { [weak self] in self?.updateImageData (inModel) }
     )
     return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

fileprivate final class AutoLayoutInternalDroppableImageView : ALB_NSImageView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mMaxWidth : CGFloat? = nil
  private var mMaxHeight : CGFloat? = nil
  weak var mDroppableImageView : AutoLayoutDroppableImageView? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override init () {
    super.init ()

    self.imageScaling = .scaleProportionallyUpOrDown
    self.imageFrameStyle = .grayBezel

    self.registerForDraggedTypes (myPasteboardImageTypes ())
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func set (maxWidth inMaxWidth : Int) {
    self.mMaxWidth = CGFloat (inMaxWidth)
    self.invalidateIntrinsicContentSize ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func set (maxHeight inMaxHeight : Int) {
    self.mMaxHeight = CGFloat (inMaxHeight)
    self.invalidateIntrinsicContentSize ()
  }

 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -····················

 override var intrinsicContentSize : NSSize {
   if let imageSize = self.image?.size, (self.mMaxWidth != nil) || (self.mMaxHeight != nil) {
     var s = imageSize
     if let maxWidth = self.mMaxWidth, s.width > maxWidth {
       s = NSSize (width: maxWidth, height: s.height * maxWidth / s.width)
     }
     if let maxHeight = self.mMaxHeight, s.height > maxHeight {
       s = NSSize (width: s.width * maxHeight / s.height, height: maxHeight)
     }
     return s
   }else{
     return super.intrinsicContentSize
   }
 }

 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -····················

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Drag destination
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func draggingEntered (_ inSender : any NSDraggingInfo) -> NSDragOperation {
    var accepts = self.mDroppableImageView != nil
    if accepts {
      let draggingPasteboard = inSender.draggingPasteboard
      accepts = NSImage.canInit (with: draggingPasteboard)
    }
    return accepts ? .copy : []
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func draggingUpdated (_ sender : any NSDraggingInfo) -> NSDragOperation {
    return .copy
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func draggingExited (_ sender : (any NSDraggingInfo)?) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func prepareForDragOperation (_ sender : any NSDraggingInfo) -> Bool {
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func performDragOperation (_ sender : any NSDraggingInfo) -> Bool {
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func concludeDragOperation (_ inSender : (any NSDraggingInfo)?) {
    if let pboard = inSender?.draggingPasteboard {
      if let pdfData = pboard.data (forType: .pdf) {
        self.mDroppableImageView?.setModel (pdfData)
      }else if let pngData = pboard.data (forType: .png) {
        self.mDroppableImageView?.setModel (pngData)
      }else if let tiffData = pboard.data (forType: .tiff) {
        self.mDroppableImageView?.setModel (tiffData)
      }else if let tiffData = NSImage (pasteboard: pboard)?.tiffRepresentation {
        self.mDroppableImageView?.setModel (tiffData)
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
// https://forums.developer.apple.com/thread/79144
// https://stackoverflow.com/questions/24343216/drag-and-drop-in-swift-issues-with-registering-for-dragged-types/39330243
//--------------------------------------------------------------------------------------------------

fileprivate func myPasteboardImageTypes () -> [NSPasteboard.PasteboardType] {
  var result = [NSPasteboard.PasteboardType] ()
  for s in NSImage.imageTypes {
//    NSLog ("image type: \(s)")
    result.append (NSPasteboard.PasteboardType (rawValue: s))
  }
  return result
}

//--------------------------------------------------------------------------------------------------
