//
//  extension-PackageDocument-modelImageActions.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 20/03/2020.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension PackageDocument {

  //····················································································································

  @objc @IBAction func pasteModelImageAction (_ sender : NSObject?) {
    // Swift.print ("\(NSPasteboard.general.types)")
    // Swift.print ("AVAILABLE: \(NSPasteboard.general.availableType (from :[.png, .tiff]))")
    if let tiffData = NSImage (pasteboard: NSPasteboard.general)?.tiffRepresentation {
      self.rootObject.mModelImageData = tiffData
//      self.rootObject.mModelImagePointsDx = 200 * 2_286
//      self.rootObject.mModelImagePointsDy = 200 * 2_286
      self.rootObject.mModelImageFirstPointXOnLock = 0
      self.rootObject.mModelImageFirstPointYOnLock = 0
      self.rootObject.mModelImageScale = 1.0
      self.rootObject.mModelImageRotationInRadians = 0.0
      self.rootObject.mPointsAreLocked = false
      self.buildGreenAndBluePointsIfRequired ()
    }else if let window = self.windowForSheet {
      __NSBeep ()
      let alert = NSAlert ()
      alert.messageText = "Cannot paste an image."
      alert.informativeText = "The pasteboard does not contain a valid image."
      alert.beginSheetModal (for: window)
    }
  }

  //····················································································································

  @objc @IBAction func removeModelImageAction (_ sender : NSObject?) {
    self.rootObject.mModelImageData = Data ()
//    self.rootObject.mModelImagePointsDx = 200 * 2_286
//    self.rootObject.mModelImagePointsDy = 200 * 2_286
    self.rootObject.mModelImageFirstPointXOnLock = 0
    self.rootObject.mModelImageFirstPointYOnLock = 0
    self.rootObject.mModelImageScale = 1.0
    self.rootObject.mModelImageRotationInRadians = 0.0
    self.rootObject.mPointsAreLocked = false
    self.rootObject.mModelImageDoublePoint = nil
    self.rootObject.mModelImageObjects = []
  }

  //····················································································································

  @objc @IBAction func resetGreenAndBluePointsAction (_ sender : NSObject?) {
  //--- Reset point image
    self.rootObject.mPointsAreLocked = false
//    self.rootObject.mModelImagePointsDx = 200 * 2_286
//    self.rootObject.mModelImagePointsDy = 200 * 2_286
    self.rootObject.mModelImageFirstPointXOnLock = 0
    self.rootObject.mModelImageFirstPointYOnLock = 0
//    self.rootObject.mModelImageFirstPoint = nil
//    self.rootObject.mModelImageSecondPoint = nil
    self.rootObject.mModelImageScale = 1.0
    self.rootObject.mModelImageRotationInRadians = 0.0
    self.rootObject.mModelImageDoublePoint = nil
    self.rootObject.mModelImageObjects = []
    self.mModelImageView?.set(backgroundImageAffineTransform: .identity)
    self.mComposedPackageView?.set (backgroundImageAffineTransform: .identity)
  //---
    self.buildGreenAndBluePointsIfRequired ()
  }

  //····················································································································

  func buildGreenAndBluePointsIfRequired () {
    if self.rootObject.mModelImageDoublePoint == nil {
      let pp = PackageModelImageDoublePoint (self.ebUndoManager)
      self.rootObject.mModelImageDoublePoint = pp
      self.rootObject.mModelImageObjects = []
      self.rootObject.mModelImageObjects = [pp]
    }
//   //--- Add Model image points
//     let firstPoint : PackageModelImagePoint
//     if let p = self.rootObject.mModelImageFirstPoint {
//       firstPoint = p
//     }else{
//       let p = PackageModelImagePoint (self.ebUndoManager)
//       p.mX = 2_286 * 200 // 200 mils
//       p.mY = 2_286 * 200 // 200 mils
//       p.mColor = .systemGreen
//       self.rootObject.mModelImageFirstPoint = p
//       firstPoint = p
//     }
//     if self.rootObject.mModelImageSecondPoint == nil {
//       let p = PackageModelImagePoint (self.ebUndoManager)
//       p.mX = firstPoint.mX + self.rootObject.mModelImagePointsDx
//       p.mY = firstPoint.mY + self.rootObject.mModelImagePointsDy
//       p.mColor = .systemBrown
//       self.rootObject.mModelImageSecondPoint = p
//     }
//     if self.rootObject.mModelImageObjects.count != 2 {
//       self.rootObject.mModelImageObjects = []
//       self.rootObject.mModelImageObjects = [self.rootObject.mModelImageFirstPoint!, self.rootObject.mModelImageSecondPoint!]
//     }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
