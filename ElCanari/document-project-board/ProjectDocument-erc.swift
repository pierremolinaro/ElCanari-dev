//
//  ProjectDocument-erc.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 17/07/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate let ISSUE_SIZE : CGFloat = 10.0

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedProjectDocument {

  //····················································································································

  @IBAction internal func performERCCheckingAction (_ inUnusedSender : Any?) {
    self.mERCLogTextView?.clear ()
    var issues = [CanariIssue] ()
    self.checkPadInsulation (&issues)
  //--- Pad inventory
    var padLocationNetDict = [NSPoint : [(String, ConnectorSide)]] ()
    for component in self.rootObject.mComponents {
    //--- Package coordinates transformation
      let packagePadDictionary : PackageMasterPadDictionary = component.packagePadDictionary!
      let padRect = packagePadDictionary.padsRect
      let center = padRect.center.cocoaPoint
      var af = AffineTransform ()
      af.translate (x: canariUnitToCocoa (component.mX), y: canariUnitToCocoa (component.mY))
      af.rotate (byDegrees: CGFloat (component.mRotation) / 1000.0)
      if component.mSide == .back {
        af.scale (x: -1.0, y: 1.0)
      }
      af.translate (x: -center.x, y: -center.y)
    //---
      let padNetDictionary : PadNetDictionary = component.padNetDictionary!
      for (_, padDescriptor) in packagePadDictionary {
        let p = af.transform (padDescriptor.center.cocoaPoint)
        let side : ConnectorSide
        switch padDescriptor.style {
        case .traversing :
          side = .both
        case .surface :
          switch component.mSide {
          case .front :
            side = .front
          case .back :
            side = .back
          }
        }
        let netName = padNetDictionary [padDescriptor.name] ?? ""
        padLocationNetDict [p] = (padLocationNetDict [p] ?? []) + [(netName, side)]
      }
    }
  //--- Connector inventory
    var connectorLocationDictionary = [CanariPoint : [BoardConnector]] ()
    for object in self.rootObject.mBoardObjects {
      if let connector = object as? BoardConnector {
        let p = connector.location!
        connectorLocationDictionary [p] = (connectorLocationDictionary [p] ?? []) + [connector]
      }
    }
  //--- Check no collision between pads
    self.mERCLogTextView?.appendMessageString ("Pad collision… ")
    var collisionCount = 0
    for (location, pads) in padLocationNetDict {
      var padsInFrontSide = 0
      var padsInBackSide = 0
      for (_, side) in pads {
        switch side {
        case .front :
          padsInFrontSide += 1
        case .back :
          padsInBackSide += 1
        case .both :
          padsInFrontSide += 1
          padsInBackSide += 1
        }
      }
      if padsInFrontSide > 1 { // Pad collision in front side
        collisionCount += 1
        let r = NSRect (center: location, size: ISSUE_SIZE)
        let bp = EBBezierPath (ovalIn: r)
        let issue = CanariIssue (kind: .error, message: "Pad collision in front side", path: bp, representativeValue: 0)
        issues.append (issue)
      }
      if padsInBackSide > 1 { // Pad collision in front side
        collisionCount += 1
        let r = NSRect (center: location, size: ISSUE_SIZE)
        let bp = EBBezierPath (ovalIn: r)
        let issue = CanariIssue (kind: .error, message: "Pad collision in back side", path: bp, representativeValue: 0)
        issues.append (issue)
      }
    }
    if collisionCount == 0 {
      self.mERCLogTextView?.appendSuccessString ("none, ok\n")
    }else if collisionCount == 1 {
      self.mERCLogTextView?.appendErrorString ("1 collision\n")
    }else{
      self.mERCLogTextView?.appendErrorString ("\(collisionCount) collisions\n")
    }
  }

  //····················································································································

  fileprivate func checkPadInsulation (_ ioIssues : inout [CanariIssue]) {
    var pads = [PadGeometryForERC] ()
    for component in self.rootObject.mComponents {
      let packagePadDictionary : PackageMasterPadDictionary = component.packagePadDictionary!
    //--- Package coordinates transformation
      let padRect = packagePadDictionary.padsRect
      let center = padRect.center.cocoaPoint
      var af = AffineTransform ()
      af.translate (x: canariUnitToCocoa (component.mX), y: canariUnitToCocoa (component.mY))
      let rotation = CGFloat (component.mRotation) / 1000.0
      af.rotate (byDegrees: rotation)
      if component.mSide == .back {
        af.scale (x: -1.0, y: 1.0)
      }
      af.translate (x: -center.x, y: -center.y)
    //---
      for (_, padDescriptor) in packagePadDictionary {
        let center = padDescriptor.center.cocoaPoint
        let transformedCenter = af.transform (center)
        let size = padDescriptor.padSize.cocoaSize
        var rectangles = [RectForERC] ()
        var circles = [CircleForERC] ()
        switch padDescriptor.shape {
        case .rect :
          rectangles.append (RectForERC (center: transformedCenter, size: size, angle: rotation))
        case .round :
          if size.width < size.height {
            let delta = (size.height - size.width) / 2.0
            let ph = af.transform (NSPoint (x: center.x, y: center.y + delta))
            circles.append (CircleForERC (center: ph, radius: size.width / 2.0))
            let pb = af.transform (NSPoint (x: center.x, y: center.y - delta))
            circles.append (CircleForERC (center: pb, radius: size.width / 2.0))
            let s = NSSize (width: size.width, height: delta * 2.0)
            rectangles.append (RectForERC (center: transformedCenter, size: s, angle: rotation))
          }else if size.width > size.height {
            let delta = (size.width - size.height) / 2.0
            let ph = af.transform (NSPoint (x: center.x + delta, y: center.y))
            circles.append (CircleForERC (center: ph, radius: size.width / 2.0))
            let pb = af.transform (NSPoint (x: center.x - delta, y: center.y))
            circles.append (CircleForERC (center: pb, radius: size.width / 2.0))
            let s = NSSize (width: delta * 2.0, height: size.height)
            rectangles.append (RectForERC (center: transformedCenter, size: s, angle: rotation))
          }else{
            circles.append (CircleForERC (center: transformedCenter, radius: size.width / 2.0))
          }
        case .octo :
          ()
        }
        pads.append (PadGeometryForERC (circles: circles, rectangles: rectangles))
      }
    }
  //--- Check insulation
    self.mERCLogTextView?.appendMessageString ("Pad insulation… ")
    var collisionCount = 0
    for idx in 1 ..< pads.count {
      let padX = pads [idx]
      for idy in 0 ..< idx {
        let padY = pads [idy]
        if let issue = padX.checkInsulationWith (padY) {
          collisionCount += 1
          ioIssues.append (issue)
        }
      }
    }
    if collisionCount == 0 {
      self.mERCLogTextView?.appendSuccessString ("ok\n")
    }else if collisionCount == 1 {
      self.mERCLogTextView?.appendErrorString ("1 collision\n")
    }else{
      self.mERCLogTextView?.appendErrorString ("\(collisionCount) collisions\n")
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct RectForERC {
  let center : NSPoint
  let size : NSSize
  let angle : CGFloat // In degrees

  //····················································································································

  func intersects (_ inOther : RectForERC) -> Bool {
    let centerDistance = NSPoint.distance (self.center, inOther.center)
    let circumRadius = (self.size.width * self.size.width + self.size.height * self.size.height).squareRoot ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct CircleForERC {
  let center : NSPoint
  let radius : CGFloat
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct PadGeometryForERC {
  let circles : [CircleForERC]
  let rectangles : [RectForERC]

  //····················································································································

  func checkInsulationWith (_ inOther : PadGeometryForERC) -> CanariIssue? {
    var ok = true
  //--- Check circle - circle insulation
    for c1 in self.circles {
      for c2 in inOther.circles {
        if NSPoint.distance (c1.center, c2.center) < (c1.radius + c2.radius) {
          ok = false
          break
        }
      }
    }
  //--- Check rectangle - rectangle insulation
    for r1 in self.rectangles {
      for r2 in inOther.rectangles {
        if r1.intersects (r2) {
          ok = false
          break
        }
      }
    }
 //---
   return ok ? nil : CanariIssue (kind: .error, message: "Pad Collision", path: EBBezierPath (), representativeValue: 0)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
