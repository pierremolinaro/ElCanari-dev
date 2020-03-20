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
    if let tiffData = NSImage (pasteboard: NSPasteboard.general)?.tiffRepresentation {
      self.rootObject.mModelImageData = tiffData
      self.rootObject.mModelImageDeltaX = 0
      self.rootObject.mModelImageDeltaY = 0
      self.rootObject.mModelImageFirstPointXOnLock = 0
      self.rootObject.mModelImageFirstPointYOnLock = 0
      self.rootObject.mPointsAreLocked = false
    }else{
      __NSBeep ()
    }
  }

  //····················································································································

  @objc @IBAction func removeModelImageAction (_ sender : NSObject?) {
    self.rootObject.mModelImageData = Data ()
    self.rootObject.mModelImageDeltaX = 0
    self.rootObject.mModelImageDeltaY = 0
    self.rootObject.mModelImageFirstPointXOnLock = 0
    self.rootObject.mModelImageFirstPointYOnLock = 0
    self.rootObject.mPointsAreLocked = false
  }

  //····················································································································

  @objc @IBAction func resetGreenAndBluePointsAction (_ sender : NSObject?) {
  //--- Reset point image
    self.rootObject.mPointsAreLocked = false
    self.rootObject.mModelImageDeltaX = 0
    self.rootObject.mModelImageDeltaY = 0
    self.rootObject.mModelImageFirstPointXOnLock = 0
    self.rootObject.mModelImageFirstPointYOnLock = 0
    self.rootObject.mModelImageFirstPoint = nil
    self.rootObject.mModelImageSecondPoint = nil
    self.rootObject.mModelImageObjects = []
    self.mModelImageView?.set(backgroundImageAffineTransform: .identity)
  //---
    self.buildGreenAndBluePointsIfRequired ()
  }

  //····················································································································

  func buildGreenAndBluePointsIfRequired () {
   //--- Add Model image points
     if self.rootObject.mModelImageFirstPoint == nil {
       let p = PackageModelImagePoint (self.ebUndoManager)
       p.mX = 2_286 * 200 // 200 mils
       p.mY = 2_286 * 200 // 200 mils
       p.mColor = .green
       self.rootObject.mModelImageFirstPoint = p
     }
     if self.rootObject.mModelImageSecondPoint == nil {
       let p = PackageModelImagePoint (self.ebUndoManager)
       p.mX = 2_286 * 400 // 400 mils
       p.mY = 2_286 * 400 // 400 mils
       p.mColor = .blue
       self.rootObject.mModelImageSecondPoint = p
     }
     if self.rootObject.mModelImageObjects.count != 2 {
       self.rootObject.mModelImageObjects = []
       self.rootObject.mModelImageObjects = [self.rootObject.mModelImageFirstPoint!, self.rootObject.mModelImageSecondPoint!]
     }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
