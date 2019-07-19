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
  //--- Pad insulation
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
        let s = NSSize (width: ISSUE_SIZE, height: ISSUE_SIZE)
        let r = NSRect (center: location, size: s)
        let bp = EBBezierPath (ovalIn: r)
        let issue = CanariIssue (kind: .error, message: "Pad collision in front side", path: bp, representativeValue: 0)
        issues.append (issue)
      }
      if padsInBackSide > 1 { // Pad collision in front side
        collisionCount += 1
        let s = NSSize (width: ISSUE_SIZE, height: ISSUE_SIZE)
        let r = NSRect (center: location, size: s)
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
    var frontPads = [PadGeometryForERC] ()
    var backPads = [PadGeometryForERC] ()
    for component in self.rootObject.mComponents {
      if component.mRoot != nil { // Is on board
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
          let bp = PadGeometryForERC (
            centerX: padDescriptor.center.x,
            centerY: padDescriptor.center.y,
            width: padDescriptor.padSize.width,
            height: padDescriptor.padSize.height,
            shape: padDescriptor.shape
          )
          let transformedBP = bp.transformed (by: af)
          switch padDescriptor.style {
          case .surface :
            switch component.mSide {
            case .front :
              frontPads.append (transformedBP)
            case .back :
              backPads.append (transformedBP)
            }
          case .traversing :
            frontPads.append (transformedBP)
            backPads.append (transformedBP)
          }
        }
      }
    }
  //--- Check insulation
    self.mERCLogTextView?.appendMessageString ("Pad insulation… ")
    var collisionCount = 0
    for idx in 1 ..< frontPads.count {
      let padX = frontPads [idx]
      for idy in 0 ..< idx {
        let padY = frontPads [idy]
        if padX.intersects (padY) {
          collisionCount += 1
          var bp = padX.bezierPath
          bp.append (padY.bezierPath)
          bp.windingRule = .nonZero
          let issue = CanariIssue (kind: .error, message: "Pad collision, front side", path: bp, representativeValue: 0)
          ioIssues.append (issue)
        }
      }
    }
    for idx in 1 ..< backPads.count {
      let padX = backPads [idx]
      for idy in 0 ..< idx {
        let padY = backPads [idy]
        if padX.intersects (padY) {
          collisionCount += 1
          var bp = padX.bezierPath
          bp.append (padY.bezierPath)
          bp.windingRule = .nonZero
          let issue = CanariIssue (kind: .error, message: "Pad collision, back side", path: bp, representativeValue: 0)
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
    let shape = EBShape (filled: frontPads.bezierPathes (), .yellow)
    self.mBoardView?.mOverObjectsDisplay = shape
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
