//
//  AutoLayoutCanariDeviceDroppableImageView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 29/06/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
// https://stackoverflow.com/questions/44537356/swift-4-nsfilenamespboardtype-not-available-what-to-use-instead-for-registerfo
//----------------------------------------------------------------------------------------------------------------------

final class AutoLayoutCanariDeviceDroppableImageView : AutoLayoutVerticalStackView {

  //····················································································································

  private let mImageView : AutoLayoutDroppableImageView
  private let mRemoveButton = AutoLayoutButton (title: "-", small: true)
  private let mPasteImageButton = AutoLayoutButton (title: "Paste Image", small: true)
  private let mCopyImageButton = AutoLayoutButton (title: "Copy Image", small: true)

  //····················································································································

  init (width inWidth : Int) {
    self.mImageView = AutoLayoutDroppableImageView (width: inWidth)
    super.init ()

    self.mImageView.set (droppedImageCallBack: { [weak self] (_ data : Data) in self?.setModel (data) })
    self.mImageView.imageScaling = .scaleProportionallyUpOrDown
    self.mImageView.imageFrameStyle = .grayBezel

    self.appendView (self.mImageView)
    let hStack = AutoLayoutHorizontalStackView ()
    _ = self.mRemoveButton.bind_run (target: self, selector: #selector (Self.removeImageAction (_:)))
    hStack.appendView (self.mRemoveButton)
    hStack.appendView (self.mPasteImageButton)
    _ = self.mPasteImageButton.bind_run (target: self, selector: #selector (Self.pasteImageAction (_:)))
    hStack.appendView (self.mCopyImageButton)
    _ = self.mCopyImageButton.bind_run (target: self, selector: #selector (Self.copyImageAction (_:)))
    hStack.appendFlexibleSpace ()
    self.appendView (hStack)
  }

 //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  @objc func removeImageAction (_ inUnusedSender : Any?) {
    self.setModel (Data ())
  }

  //····················································································································

  @objc func copyImageAction (_ inUnusedSender : Any?) {
    if let data = self.mModel?.propval {
      let pasteboard = NSPasteboard.general
      pasteboard.clearContents ()
      pasteboard.setData (data, forType: .tiff)
    }
  }

  //····················································································································

  @objc func pasteImageAction (_ inUnusedSender : Any?) {
    if let pdfData = NSPasteboard.general.data (forType: .pdf) {
      self.setModel (pdfData)
    }else if let pngData = NSPasteboard.general.data (forType: .png) {
      self.setModel (pngData)
    }else if let tiffData = NSPasteboard.general.data (forType: .tiff) {
      self.setModel (tiffData)
    }else if let tiffData = NSImage (pasteboard: NSPasteboard.general)?.tiffRepresentation {
      self.setModel (tiffData)
    }else if let window = self.window {
      NSSound.beep ()
      let alert = NSAlert ()
      alert.messageText = "Cannot paste an image."
      alert.informativeText = "The pasteboard does not contain a valid image."
      alert.beginSheetModal (for: window)
    }
  }

  //····················································································································
  //  $imageData binding
  //····················································································································

  func updateImageData (_ object : EBReadOnlyProperty_Data) {
    switch object.selection {
    case .empty, .multiple :
      self.mImageView.image = nil
      self.mRemoveButton.isEnabled = false
    case .single (let data) :
      self.mImageView.image = NSImage (data: data)
      self.mRemoveButton.isEnabled = !data.isEmpty
    }
  }

  //····················································································································

  private var mImageDataController : EBReadOnlyPropertyController? = nil
  private weak var mModel : EBStoredProperty_Data? = nil

  //····················································································································

  private func setModel (_ inData : Data) {
    _ = self.mModel?.setProp (inData)
  }

  //····················································································································

  final func bind_imageData (_ inModel : EBStoredProperty_Data) -> Self {
    self.mModel = inModel
    self.mImageDataController = EBReadOnlyPropertyController (
      observedObjects: [inModel],
      callBack: { [weak self] in self?.updateImageData (inModel) }
     )
     return self
  }

  //····················································································································

  final func unbind_imageData () {
    self.mImageDataController?.unregister ()
    self.mImageDataController = nil
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
