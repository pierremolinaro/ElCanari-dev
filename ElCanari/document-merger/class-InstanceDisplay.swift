//
//  class-InstanceDisplay.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 21/07/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    InstanceDisplay
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class InstanceDisplay : Hashable, EBUserClassNameProtocol {

  //····················································································································
  //   Properties
  //····················································································································

  let image : NSImage
  let center : NSPoint
  let rotation : CGFloat

  //····················································································································
  //   Init
  //····················································································································

  init (_ inImage : NSImage, _ inCenter : NSPoint, _ inRotation : CGFloat) {
    image = inImage
    center = inCenter
    rotation = inRotation
    noteObjectAllocation (self)
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  // Equatable protocol
  //····················································································································

  public static func == (lhs: InstanceDisplay, rhs: InstanceDisplay) -> Bool {
    return (lhs.rotation == rhs.rotation) && (lhs.center == rhs.center) && (lhs.image == rhs.image)
  }

  //····················································································································
  // Hashable protocol
  //····················································································································

  public var hashValue: Int {
    return self.rotation.hashValue ^ self.center.x.hashValue ^ self.center.y.hashValue ^ self.image.hashValue
  }

  //····················································································································
  // rect
  //····················································································································

  var boundingBox : NSRect {
    let imageWidth  = self.image.size.width
    let imageHeight = self.image.size.height
    let width  = abs ( imageWidth * cos (self.rotation) + imageHeight * sin (self.rotation))
    let height = abs (-imageWidth * sin (self.rotation) + imageHeight * cos (self.rotation))
    let originX = self.center.x - width  / 2.0
    let originY = self.center.y - height / 2.0
    return NSRect (origin: NSPoint (x: originX, y:originY), size: NSSize (width: width, height: height))
  }
  
  //····················································································································
  // draw
  //····················································································································

  func draw (_ inDirtyRect: NSRect) {
    if self.boundingBox.intersects (inDirtyRect) {
      let at = NSAffineTransform ()
      let imageWidth  = self.image.size.width
      let imageHeight = self.image.size.height
      at.translateX (by: self.center.x, yBy: self.center.y)
      at.rotate (byRadians: self.rotation)
      at.concat ()
      self.image.draw (in:NSRect (origin: NSPoint (x: -imageWidth / 2.0, y: -imageHeight / 2.0), size: self.image.size))
      at.invert ()
      at.concat ()
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    InstanceDisplayArray
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class InstanceDisplayArray : EBUserClassNameProtocol {

  //····················································································································
  //   Properties
  //····················································································································

  let objects : [InstanceDisplay]

  //····················································································································
  //   Init
  //····················································································································

  init (_ inObjects : [InstanceDisplay]) {
    objects = inObjects
    noteObjectAllocation (self)
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  // Equatable protocol
  //····················································································································

  public static func == (lhs: InstanceDisplayArray, rhs: InstanceDisplayArray) -> Bool {
    if lhs.objects.count != rhs.objects.count {
      return false
    }else{
      var idx = 0
      while idx < lhs.objects.count {
        if lhs.objects [idx] != rhs.objects [idx] {
          return false
        }
        idx += 1
      }
      return true
    }
  }

  //····················································································································
  // Hashable protocol
  //····················································································································

  public var hashValue: Int {
    var h = 0
    for object in objects {
      h ^= object.hashValue
    }
    return h
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
