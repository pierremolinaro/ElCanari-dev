//--- START OF USER ZONE 1


//--- END OF USER ZONE 1
//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutPackageDocument {
  @objc func loadModelImageFromPasteboardAction (_ inSender : NSObject?) {
//--- START OF USER ZONE 2
    func buildFrom (data inData : Data) {
      self.mModelImageObjectsController.setBackgroundImageAffineTransform (NSAffineTransform ())
      self.mPackageObjectsController.setBackgroundImageAffineTransform (NSAffineTransform ())
      self.rootObject.mModelImageData = inData
      self.rootObject.reset_mModelImageFirstPointXOnLock_toDefaultValue ()
      self.rootObject.reset_mModelImageFirstPointYOnLock_toDefaultValue ()
      self.rootObject.reset_mModelImageScale_toDefaultValue ()
      self.rootObject.reset_mModelImageRotationInRadians_toDefaultValue ()
      self.rootObject.reset_mPointsAreLocked_toDefaultValue ()
      self.rootObject.reset_mModelPointsCircleRadius_toDefaultValue ()
      self.rootObject.mModelImageDoublePoint = nil
      self.rootObject.mModelImageObjects = EBReferenceArray ()
      let pp = PackageModelImageDoublePoint (self.undoManager)
      self.rootObject.mModelImageDoublePoint = pp
      self.rootObject.mModelImageObjects = EBReferenceArray (pp)
      self.rootObject.mModelImagePageZoom = 0
    }

    // NSLog ("\(NSPasteboard.general.types ?? [])")
    if let pdfData = NSPasteboard.general.data (forType: .pdf) {
      buildFrom (data: pdfData)
    }else if let data = NSPasteboard.general.data (forType: .png) {
      buildFrom (data: data)
    }else if let data = NSPasteboard.general.data (forType: .tiff) {
      buildFrom (data: data)
    }else if let tiffData = NSImage (pasteboard: NSPasteboard.general)?.tiffRepresentation {
      buildFrom (data: tiffData)
    }else if let window = self.windowForSheet {
      NSSound.beep ()
      let alert = NSAlert ()
      alert.messageText = "Cannot paste an image."
      alert.informativeText = "The pasteboard does not contain a valid image."
      alert.beginSheetModal (for: window)
    }
//--- END OF USER ZONE 2
  }
}

//--------------------------------------------------------------------------------------------------
