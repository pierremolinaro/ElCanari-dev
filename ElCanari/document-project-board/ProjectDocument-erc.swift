//
//  ProjectDocument-erc.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 17/07/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedProjectDocument {

  //····················································································································

  @IBAction internal func performERCCheckingAction (_ inUnusedSender : Any?) {
    _ = self.performERCChecking ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ProjectDocument {

  //····················································································································

  internal func performERCChecking () -> Bool {
    let start = Date ()
    self.mERCLogTextView?.clear ()
    var issues = [CanariIssue] ()
  //--- Checkings
    self.checkVersusArtwork (&issues)
    var frontPadNetDictionary = [String : [PadGeometryForERC]] ()
    var backPadNetDictionary = [String : [PadGeometryForERC]] ()
    self.checkPadInsulation (&issues, &frontPadNetDictionary, &backPadNetDictionary)
    var netConnectorsDictionary = [String : [(BoardConnector, EBBezierPath)]] ()
    self.checkPadConnectivity (&issues, &netConnectorsDictionary)
    self.checkNetConnectivity (&issues, netConnectorsDictionary)
    self.checkTrackInsulation (&issues, frontPadNetDictionary, backPadNetDictionary)
  //--- Set issues
    self.mERCIssueTableView?.setIssues (issues)
    let durationMS = Date ().timeIntervalSince (start) * 1000.0
    self.mERCLogTextView?.appendMessageString ("Duration \(durationMS.rounded ()) ms")
  //--- Update status
    self.rootObject.mLastERCCheckingIsSuccess = issues.isEmpty
    self.rootObject.mLastERCCheckingSignature = self.rootObject.signatureForERCChecking ?? 0
  //---
    return issues.isEmpty
  }

  //····················································································································

  fileprivate func checkVersusArtwork (_ ioIssues : inout [CanariIssue]) {
    if let artwork = self.rootObject.mArtwork {
    //--- Clearance
      self.mERCLogTextView?.appendMessageString ("Check artwork clearance… ")
      if artwork.minPPTPTTTW <= self.rootObject.mLayoutClearance {
        self.mERCLogTextView?.appendSuccessString ("ok\n")
      }else{
        self.mERCLogTextView?.appendErrorString ("error\n")
        let issue = CanariIssue (kind: .error, message: "Artwork clearance should be lower or equal than router clearance", pathes: [])
        ioIssues.append (issue)
      }
    //--- Board limit width
      self.mERCLogTextView?.appendMessageString ("Check board limits width… ")
      if artwork.minValueForBoardLimitWidth <= self.rootObject.mBoardLimitsWidth {
        self.mERCLogTextView?.appendSuccessString ("ok\n")
      }else{
        self.mERCLogTextView?.appendErrorString ("error\n")
        let issue = CanariIssue (kind: .error, message: "Artwork board limits width should be lower or equal than board limits width", pathes: [])
        ioIssues.append (issue)
      }
    //--- Board OAR and PHD of vias
      self.checkViasOARAndPHD (&ioIssues, artwork.minValueForOARinEBUnit, artwork.minValueForPHDinEBUnit)
    //--- Board OAR and PHD of pads
      self.checkPadsOARAndPHD (&ioIssues, artwork.minValueForOARinEBUnit, artwork.minValueForPHDinEBUnit)

    }else{
      self.mERCLogTextView?.appendMessageString ("No artwork checking: artwork is not set.\n")
    }
  }

  //····················································································································

  fileprivate func checkViasOARAndPHD (_ ioIssues : inout [CanariIssue], _ inOAR : Int, _ inPHD : Int) {
    self.mERCLogTextView?.appendMessageString ("Check vias OAR and PHD… ")
    var errorCount = 0
    for object in self.rootObject.mBoardObjects {
      if let connector = object as? BoardConnector, let isVia = connector.isVia, isVia {
        let viaHoleDiameter = connector.actualHoleDiameter!
        let viaOAR = (connector.actualPadDiameter! - viaHoleDiameter) / 2
        if viaHoleDiameter < inPHD {
          let center = connector.location!.cocoaPoint
          let w = canariUnitToCocoa (connector.actualPadDiameter! + self.rootObject.mLayoutClearance)
          let r = NSRect (center: center, size: NSSize (width: w, height: w))
          let bp = EBBezierPath (ovalIn: r)
          let issue = CanariIssue (kind: .error, message: "Hole diameter should be greater or equal to artwork PHD", pathes: [bp])
          ioIssues.append (issue)
          errorCount += 1
        }
        if viaOAR < inOAR {
          let center = connector.location!.cocoaPoint
          let w = canariUnitToCocoa (connector.actualPadDiameter! + self.rootObject.mLayoutClearance)
          let r = NSRect (center: center, size: NSSize (width: w, height: w))
          let bp = EBBezierPath (ovalIn: r)
          let issue = CanariIssue (kind: .error, message: "Annular ring should be greater or equal to artwork OAR", pathes: [bp])
          ioIssues.append (issue)
          errorCount += 1
        }
      }
    }
    if errorCount == 0 {
      self.mERCLogTextView?.appendSuccessString ("ok\n")
    }else if errorCount == 1 {
      self.mERCLogTextView?.appendErrorString ("1 error\n")
    }else{
      self.mERCLogTextView?.appendErrorString ("\(errorCount) errors\n")
    }
  }

  //····················································································································

  fileprivate func checkPadsOARAndPHD (_ ioIssues : inout [CanariIssue], _ inOAR : Int, _ inPHD : Int) {
    self.mERCLogTextView?.appendMessageString ("Check pads OAR and PHD… ")
    let clearance = self.rootObject.mLayoutClearance
    var errorCount = 0
    for object in self.rootObject.mBoardObjects {
      if let component = object as? ComponentInProject {
        let af = component.affineTransformFromPackage ()
        for (_, padDescriptor) in component.packagePadDictionary! {
          switch padDescriptor.style {
          case .surface :
             ()
          case .traversing :
            let phd = min (padDescriptor.holeSize.width, padDescriptor.holeSize.height)
            if phd < inPHD {
              let bp = EBBezierPath.pad (
                centerX: padDescriptor.center.x,
                centerY: padDescriptor.center.y,
                width: padDescriptor.padSize.width + clearance,
                height: padDescriptor.padSize.height + clearance,
                shape: padDescriptor.shape
              ).transformed (by: af)
              let issue = CanariIssue (kind: .error, message: "Pad hole diameter should be greater or equal to artwork PHD", pathes: [bp])
              ioIssues.append (issue)
              errorCount += 1
            }
            let oar = min (padDescriptor.padSize.width - padDescriptor.holeSize.width, padDescriptor.padSize.height - padDescriptor.holeSize.height) / 2
            if oar < inOAR {
              let bp = EBBezierPath.pad (
                centerX: padDescriptor.center.x,
                centerY: padDescriptor.center.y,
                width: padDescriptor.padSize.width + clearance,
                height: padDescriptor.padSize.height + clearance,
                shape: padDescriptor.shape
              ).transformed (by: af)
              let issue = CanariIssue (kind: .error, message: "Pad OAR should be greater or equal to artwork OAR", pathes: [bp])
              ioIssues.append (issue)
              errorCount += 1
            }
          }
          for slavePad in padDescriptor.slavePads {
            switch slavePad.style {
            case .oppositeSide, .componentSide :
              ()
            case .traversing :
              let phd = min (slavePad.holeSize.width, slavePad.holeSize.height)
              if phd < inPHD {
                let bp = EBBezierPath.pad (
                  centerX: slavePad.center.x,
                  centerY: slavePad.center.y,
                  width: slavePad.padSize.width + clearance,
                  height: slavePad.padSize.height + clearance,
                  shape: slavePad.shape
                ).transformed (by: af)
                let issue = CanariIssue (kind: .error, message: "Pad hole diameter should be greater or equal to artwork PHD", pathes: [bp])
                ioIssues.append (issue)
                errorCount += 1
              }
              let oar = min (slavePad.padSize.width - slavePad.holeSize.width, slavePad.padSize.height - slavePad.holeSize.height) / 2
              if oar < inOAR {
                let bp = EBBezierPath.pad (
                  centerX: slavePad.center.x,
                  centerY: slavePad.center.y,
                  width: slavePad.padSize.width + clearance,
                  height: slavePad.padSize.height + clearance,
                  shape: slavePad.shape
                ).transformed (by: af)
                let issue = CanariIssue (kind: .error, message: "Pad OAR should be greater or equal to artwork OAR", pathes: [bp])
                ioIssues.append (issue)
                errorCount += 1
              }
            }
          }
        }
      }
    }
    if errorCount == 0 {
      self.mERCLogTextView?.appendSuccessString ("ok\n")
    }else if errorCount == 1 {
      self.mERCLogTextView?.appendErrorString ("1 error\n")
    }else{
      self.mERCLogTextView?.appendErrorString ("\(errorCount) errors\n")
    }
  }

  //····················································································································

  fileprivate func checkPadInsulation (_ ioIssues : inout [CanariIssue],
                                       _ ioFrontPadNetDictionary : inout [String : [PadGeometryForERC]],
                                       _ ioBackPadNetDictionary : inout [String : [PadGeometryForERC]]) {
    let clearance = self.rootObject.mLayoutClearance
    for component in self.rootObject.mComponents {
      if component.mRoot != nil { // Is on board
        let padNetDictionary : PadNetDictionary = component.padNetDictionary!
        let af = component.affineTransformFromPackage ()
        for (_, padDescriptor) in component.packagePadDictionary! {
          let padGeometry = PadGeometryForERC (
            centerX: padDescriptor.center.x,
            centerY: padDescriptor.center.y,
            width: padDescriptor.padSize.width,
            height: padDescriptor.padSize.height,
            clearance: clearance,
            shape: padDescriptor.shape
          )
          var componentSidePadGeometry : PadGeometryForERC
          var oppositeSidePadGeometry  : PadGeometryForERC
          switch padDescriptor.style {
          case .surface :
            componentSidePadGeometry = padGeometry
            oppositeSidePadGeometry  = PadGeometryForERC ()
          case .traversing :
            componentSidePadGeometry = padGeometry
            oppositeSidePadGeometry  = padGeometry
          }
          for slavePad in padDescriptor.slavePads {
            let slavePadGeometry = PadGeometryForERC (
              centerX: slavePad.center.x,
              centerY: slavePad.center.y,
              width: slavePad.padSize.width,
              height: slavePad.padSize.height,
              clearance: clearance,
              shape: slavePad.shape
            )
            switch slavePad.style {
            case .oppositeSide :
              oppositeSidePadGeometry = oppositeSidePadGeometry + slavePadGeometry
            case .componentSide :
              componentSidePadGeometry = componentSidePadGeometry + slavePadGeometry
            case .traversing :
              componentSidePadGeometry = componentSidePadGeometry + slavePadGeometry
              oppositeSidePadGeometry = oppositeSidePadGeometry + slavePadGeometry
            }
          }
          let netName = padNetDictionary [padDescriptor.name] ?? ""
          if !componentSidePadGeometry.isEmpty {
            let componentSideTransformedGeometry = componentSidePadGeometry.transformed (by: af)
            switch component.mSide {
            case .front :
              ioFrontPadNetDictionary [netName] = (ioFrontPadNetDictionary [netName] ?? []) + [componentSideTransformedGeometry]
            case .back :
              ioBackPadNetDictionary [netName] = (ioBackPadNetDictionary [netName] ?? []) + [componentSideTransformedGeometry]
            }
          }
          if !oppositeSidePadGeometry.isEmpty {
            let oppositeSideTransformedGeometry = oppositeSidePadGeometry.transformed (by: af)
            switch component.mSide {
            case .front :
              ioBackPadNetDictionary [netName] = (ioBackPadNetDictionary [netName] ?? []) + [oppositeSideTransformedGeometry]
            case .back :
              ioFrontPadNetDictionary [netName] = (ioFrontPadNetDictionary [netName] ?? []) + [oppositeSideTransformedGeometry]
            }
          }
        }
      }
    }
  //---
    var frontPadsArray = [(String, [PadGeometryForERC])] ()
    for (netName, pads) in ioFrontPadNetDictionary {
      frontPadsArray.append ((netName, pads))
    }
    var backPadsArray = [(String, [PadGeometryForERC])] ()
    for (netName, pads) in ioBackPadNetDictionary {
      backPadsArray.append ((netName, pads))
    }
  //--- Check insulation
    self.mERCLogTextView?.appendMessageString ("Pad insulation… ")
    var collisionCount = 0
    if frontPadsArray.count > 0 {
      for idx in 0 ..< frontPadsArray.count {
        let netNameX = frontPadsArray [idx].0
        let frontPadX = frontPadsArray [idx].1
        if self.rootObject.mCheckClearanceBetweenPadsOfSameNets || (netNameX == "") {
          self.checkPadInsulation (inArray: frontPadX, &ioIssues, &collisionCount)
        }
        for idy in idx+1 ..< frontPadsArray.count {
          let frontPadY = frontPadsArray [idy].1
          self.checkPadInsulation (betweenArraies: frontPadX, frontPadY, &ioIssues, &collisionCount)
        }
      }
    }
    if backPadsArray.count > 0 {
      for idx in 0 ..< backPadsArray.count {
        let netNameX = backPadsArray [idx].0
        let frontPadX = backPadsArray [idx].1
        if self.rootObject.mCheckClearanceBetweenPadsOfSameNets || (netNameX == "") {
          self.checkPadInsulation (inArray: frontPadX, &ioIssues, &collisionCount)
        }
        for idy in 0 ..< backPadsArray.count {
          if idy != idx {
            let frontPadY = backPadsArray [idy].1
            self.checkPadInsulation (betweenArraies: frontPadX, frontPadY, &ioIssues, &collisionCount)
          }
        }
      }
    }

//    }
//    if frontPads.count > 1 {
//      for idx in 1 ..< frontPads.count {
//        let padX = frontPads [idx]
//        for idy in 0 ..< idx {
//          let padY = frontPads [idy]
//          if padX.intersects (pad: padY) {
//            collisionCount += 1
//            let bp = [padX.bezierPath, padY.bezierPath]
//            let issue = CanariIssue (kind: .error, message: "Front side pad collision", pathes: bp)
//            ioIssues.append (issue)
//          }
//        }
//      }
//    }
//    if backPads.count > 1 {
//      for idx in 1 ..< backPads.count {
//        let padX = backPads [idx]
//        for idy in 0 ..< idx {
//          let padY = backPads [idy]
//          if padX.intersects (pad: padY) {
//            collisionCount += 1
//            let bp = [padX.bezierPath, padY.bezierPath]
//            let issue = CanariIssue (kind: .error, message: "Back side pad collision", pathes: bp)
//            ioIssues.append (issue)
//          }
//        }
//      }
//    }
    if collisionCount == 0 {
      self.mERCLogTextView?.appendSuccessString ("ok\n")
    }else if collisionCount == 1 {
      self.mERCLogTextView?.appendErrorString ("1 error\n")
    }else{
      self.mERCLogTextView?.appendErrorString ("\(collisionCount) errors\n")
    }
  }

  //····················································································································

  private func checkPadInsulation (betweenArraies inPadArrayX : [PadGeometryForERC],
                                   _ inPadArrayY : [PadGeometryForERC],
                                   _ ioIssues : inout [CanariIssue],
                                   _ ioCollisionCount : inout Int) {
    for padX in inPadArrayX {
      for padY in inPadArrayY {
        if padX.intersects (pad: padY) {
          ioCollisionCount += 1
          let bp = [padX.bezierPath, padY.bezierPath]
          let issue = CanariIssue (kind: .error, message: "Front side pad collision", pathes: bp)
          ioIssues.append (issue)
        }
      }
    }
  }

  //····················································································································

  private func checkPadInsulation (inArray inPadArray : [PadGeometryForERC],
                                   _ ioIssues : inout [CanariIssue],
                                   _ ioCollisionCount : inout Int) {
    if inPadArray.count > 1 {
      for idx in 1 ..< inPadArray.count {
        let padX = inPadArray [idx]
        for idy in 0 ..< idx {
          let padY = inPadArray [idy]
          if padX.intersects (pad: padY) {
            ioCollisionCount += 1
            let bp = [padX.bezierPath, padY.bezierPath]
            let issue = CanariIssue (kind: .error, message: "Front side pad collision", pathes: bp)
            ioIssues.append (issue)
          }
        }
      }
    }
  }

  //····················································································································

  private func checkPadConnectivity (_ ioIssues : inout [CanariIssue],
                                     _ ioNetConnectorsDictionary : inout [String : [(BoardConnector, EBBezierPath)]]) {
    self.mERCLogTextView?.appendMessageString ("Pad connection… ")
    var connectionErrorCount = 0
    for component in self.rootObject.mComponents {
      if component.mRoot != nil { // Placed on board
        let af = component.affineTransformFromPackage ()
        let padNetDictionary : PadNetDictionary = component.padNetDictionary!
        for connector in component.mConnectors {
          let masterPadName = connector.mComponentPadName
          let padDescriptor = component.packagePadDictionary! [masterPadName]!
          if let netName = padNetDictionary [masterPadName] {  // Pad should be connected
            let bp = padDescriptor.bezierPath (index: connector.mPadIndex).transformed (by: af)
            if (connector.mTracksP1.count + connector.mTracksP2.count) == 0 {
              let issue = CanariIssue (kind: .error, message: "Pad should be connected", pathes: [bp])
              ioIssues.append (issue)
              connectionErrorCount += 1
            }else{
              ioNetConnectorsDictionary [netName] = (ioNetConnectorsDictionary [netName] ?? []) + [(connector, bp)]
              self.checkPadSizeVersusConnectedTracksSide (&ioIssues, connector, af, &connectionErrorCount)
            }
          }else if (connector.mTracksP1.count + connector.mTracksP2.count) != 0 { // Pad without connection
            let bp = padDescriptor.bezierPath (index: connector.mPadIndex).transformed (by: af)
            let issue = CanariIssue (kind: .error, message: "Pad should be nc", pathes: [bp])
            ioIssues.append (issue)
            connectionErrorCount += 1
          }
        }
      }
    }
    if connectionErrorCount == 0 {
      self.mERCLogTextView?.appendSuccessString ("ok\n")
    }else if connectionErrorCount == 1 {
      self.mERCLogTextView?.appendErrorString ("1 error\n")
    }else{
      self.mERCLogTextView?.appendErrorString ("\(connectionErrorCount) errors\n")
    }
  }

  //····················································································································

  private func checkPadSizeVersusConnectedTracksSide (_ ioIssues : inout [CanariIssue],
                                                      _ inConnector : BoardConnector,
                                                      _ inAffineTransform : AffineTransform,
                                                      _ ioConnectionErrorCount : inout Int) {
    if let component = inConnector.mComponent {
      let clearance = self.rootObject.mLayoutClearance
      let masterPadName = inConnector.mComponentPadName
      let padDescriptor = component.packagePadDictionary! [masterPadName]!
      if inConnector.mPadIndex == 0 { // Master pad
        var connectorOnFrontSide = false
        var connectorOnBackSide = false
        switch padDescriptor.style {
        case .traversing :
          connectorOnFrontSide = true
          connectorOnBackSide = true
        case .surface :
          switch component.mSide {
          case .front :
            connectorOnFrontSide = true
          case .back :
            connectorOnBackSide = true
          }
        }
        for track in inConnector.mTracksP1 + inConnector.mTracksP2 {
          switch track.mSide {
          case .front :
            if !connectorOnFrontSide {
              let bp = padDescriptor.bezierPath (index: 0, extraWidth: clearance).transformed (by: inAffineTransform)
              let bp2 = track.bezierPath (extraWidth: clearance)
              let issue = CanariIssue (kind: .error, message: "Pad in back side, track in front side", pathes: [bp, bp2])
              ioIssues.append (issue)
              ioConnectionErrorCount += 1
            }
          case .back :
            if !connectorOnBackSide {
              let bp = padDescriptor.bezierPath (index: 0, extraWidth: clearance).transformed (by: inAffineTransform)
              let bp2 = track.bezierPath (extraWidth: clearance)
              let issue = CanariIssue (kind: .error, message: "Pad in front side, track in back side", pathes: [bp, bp2])
              ioIssues.append (issue)
              ioConnectionErrorCount += 1
            }
          }
        }
      }else{ // Slave pad
        let slavePad = padDescriptor.slavePads [inConnector.mPadIndex - 1]
        var connectorOnFrontSide = false
        var connectorOnBackSide = false
        switch slavePad.style {
        case .traversing :
          connectorOnFrontSide = true
          connectorOnBackSide = true
        case .componentSide :
          switch component.mSide {
          case .front :
            connectorOnFrontSide = true
          case .back :
            connectorOnBackSide = true
          }
        case .oppositeSide :
          switch component.mSide {
          case .front :
            connectorOnBackSide = true
          case .back :
            connectorOnFrontSide = true
          }
        }
        for track in inConnector.mTracksP1 + inConnector.mTracksP2 {
          switch track.mSide {
          case .front :
            if !connectorOnFrontSide {
              let bp = padDescriptor.bezierPath (index: inConnector.mPadIndex, extraWidth: clearance).transformed (by: inAffineTransform)
              let bp2 = track.bezierPath (extraWidth: clearance)
              let issue = CanariIssue (kind: .error, message: "Pad in back side, track in front side", pathes: [bp, bp2])
              ioIssues.append (issue)
              ioConnectionErrorCount += 1
            }
          case .back :
            if !connectorOnBackSide {
              let bp = padDescriptor.bezierPath (index: inConnector.mPadIndex, extraWidth: clearance).transformed (by: inAffineTransform)
              let bp2 = track.bezierPath (extraWidth: clearance)
              let issue = CanariIssue (kind: .error, message: "Pad in front side, track in back side", pathes: [bp, bp2])
              ioIssues.append (issue)
              ioConnectionErrorCount += 1
            }
          }
        }
      }
    }
  }

  //····················································································································

  private func checkNetConnectivity (_ ioIssues : inout [CanariIssue],
                                     _ inNetConnectorsDictionary : [String : [(BoardConnector, EBBezierPath)]]) {
    self.mERCLogTextView?.appendMessageString ("Net connection… ")
    var connectivityErrorCount = 0
    for (netName, padConnectors) in inNetConnectorsDictionary {
      //Swift.print ("net '\(netName)' : \(connectors.count) connectors")
      var connectorExploreArray = [padConnectors [0].0]
      var connectorExploredSet = Set (connectorExploreArray)
      var exploredTrackSet = Set <BoardTrack> ()
    //--- Iterative exploration of net
      while let connector = connectorExploreArray.last {
        connectorExploreArray.removeLast ()
        for track in connector.mTracksP1 {
          if !exploredTrackSet.contains (track) {
            exploredTrackSet.insert (track)
            if !connectorExploredSet.contains (track.mConnectorP2!) {
              connectorExploredSet.insert (track.mConnectorP2!)
              connectorExploreArray.append (track.mConnectorP2!)
            }
          }
        }
        for track in connector.mTracksP2 {
          if !exploredTrackSet.contains (track) {
            exploredTrackSet.insert (track)
            if !connectorExploredSet.contains (track.mConnectorP1!) {
              connectorExploredSet.insert (track.mConnectorP1!)
              connectorExploreArray.append (track.mConnectorP1!)
            }
          }
        }
      }
    //--- Check all pads are accessibles
      for connector in padConnectors {
        if !connectorExploredSet.contains (connector.0) {
          connectivityErrorCount += 1
          let issue = CanariIssue (kind: .error, message: "Net \(netName): inaccessible pad", pathes: [connector.1])
          ioIssues.append (issue)
        }
      }
    }
    if connectivityErrorCount == 0 {
      self.mERCLogTextView?.appendSuccessString ("ok\n")
    }else if connectivityErrorCount == 1 {
      self.mERCLogTextView?.appendErrorString ("1 error\n")
    }else{
      self.mERCLogTextView?.appendErrorString ("\(connectivityErrorCount) errors\n")
    }
  }

  //····················································································································

  private func checkTrackInsulation (_ ioIssues : inout [CanariIssue],
                                     _ inFrontPadNetDictionary : [String : [PadGeometryForERC]],
                                     _ inBackPadNetDictionary  : [String : [PadGeometryForERC]]) {
    let clearance = canariUnitToCocoa (self.rootObject.mLayoutClearance)
  //--- Track inventory
    var frontTrackNetDictionary = [String : [GeometricOblong]] ()
    var backTrackNetDictionary = [String : [GeometricOblong]] ()
    var frontSideRestrictRectangles = [GeometricRect] ()
    var backSideRestrictRectangles = [GeometricRect] ()
    var viaDictionary = [String : [GeometricCircle]] ()
    for object in self.rootObject.mBoardObjects {
      if let track = object as? BoardTrack {
        let netName = track.mNet?.mNetName ?? ""
        let p1 = track.mConnectorP1!.location!.cocoaPoint
        let p2 = track.mConnectorP2!.location!.cocoaPoint
        let w = canariUnitToCocoa (track.actualTrackWidth!) + clearance
        let s = GeometricOblong (from: p1, to: p2, width: w)
        switch track.mSide {
        case .front :
          frontTrackNetDictionary [netName] = (frontTrackNetDictionary [netName] ?? []) + [s]
        case .back :
          backTrackNetDictionary [netName] = (backTrackNetDictionary [netName] ?? []) + [s]
        }
      }else if let via = object as? BoardConnector {
        var isVia = via.mComponent == nil
        if isVia {
          var hasFrontSideTrack = false
          var hasBackSideTrack = false
          for track in via.mTracksP1 + via.mTracksP2 {
            switch track.mSide {
            case .back  : hasBackSideTrack  = true
            case .front : hasFrontSideTrack = true
            }
          }
          isVia = hasFrontSideTrack && hasBackSideTrack
        }
        if isVia {
          let p = via.location!.cocoaPoint
          let radius = (canariUnitToCocoa (via.actualPadDiameter!) + clearance) / 2.0
          let c = GeometricCircle (center: p, radius: radius)
          let netName = via.netNameFromTracks!
          viaDictionary [netName] = (viaDictionary [netName] ?? []) + [c]
        }
      }else if let restrictRect = object as? BoardRestrictRectangle {
        let canariRect = CanariRect (left: restrictRect.mX, bottom: restrictRect.mY, width: restrictRect.mWidth, height: restrictRect.mHeight)
        let r = GeometricRect (rect: canariRect.cocoaRect)
        if restrictRect.mIsInFrontLayer {
          frontSideRestrictRectangles.append (r)
        }
        if restrictRect.mIsInBackLayer {
          backSideRestrictRectangles.append (r)
        }
      }else if let text = object as? BoardText {
        switch text.mLayer {
        case .legendBack, .legendFront :
          ()
        case .layoutFront :
          let (_, _, _, _, oblongs) = text.displayInfos (extraWidth: clearance)
          frontTrackNetDictionary [""] = (frontTrackNetDictionary [""] ?? []) + oblongs
        case .layoutBack :
          let (_, _, _, _, oblongs) = text.displayInfos (extraWidth: clearance)
          backTrackNetDictionary [""] = (backTrackNetDictionary [""] ?? []) + oblongs
        }
      }
    }
  //---
    var allKeys = Set (frontTrackNetDictionary.keys)
    allKeys.formUnion (backTrackNetDictionary.keys)
    allKeys.formUnion (inFrontPadNetDictionary.keys)
    allKeys.formUnion (inBackPadNetDictionary.keys)
    var frontLayout = [([GeometricOblong], [PadGeometryForERC], [GeometricCircle])] () // Tracks, pads, vias
    var backLayout  = [([GeometricOblong], [PadGeometryForERC], [GeometricCircle])] () // Tracks, pads, vias
    for key in Array (allKeys).sorted () {
      frontLayout.append ((frontTrackNetDictionary [key] ?? [], inFrontPadNetDictionary [key] ?? [], viaDictionary [key] ?? []))
      backLayout.append ((backTrackNetDictionary [key] ?? [], inBackPadNetDictionary [key] ?? [], viaDictionary [key] ?? []))
    }
  //--- Insulation tests
    self.checkTrackTrackInsulation (&ioIssues, "Front", frontLayout)
    self.checkTrackTrackInsulation (&ioIssues, "Back", backLayout)
    self.checkTrackPadInsulation (&ioIssues, "Front", frontLayout)
    self.checkTrackPadInsulation (&ioIssues, "Back", backLayout)
    self.checkPadRestrictRectInsulation (&ioIssues, "Front", frontLayout, frontSideRestrictRectangles)
    self.checkPadRestrictRectInsulation (&ioIssues, "Back", backLayout, backSideRestrictRectangles)
    self.checkTrackRestrictRectInsulation (&ioIssues, "Front", frontLayout, frontSideRestrictRectangles)
    self.checkTrackRestrictRectInsulation (&ioIssues, "Back", backLayout, backSideRestrictRectangles)
    self.checkPadViaInsulation (&ioIssues, "Front", frontLayout)
    self.checkPadViaInsulation (&ioIssues, "Back", backLayout)
    self.checkTrackViaInsulation (&ioIssues, "Front", frontLayout)
    self.checkTrackViaInsulation (&ioIssues, "Back", backLayout)
    self.checkViaRestrictRectInsulation (&ioIssues, "Front", frontLayout, frontSideRestrictRectangles)
    self.checkViaRestrictRectInsulation (&ioIssues, "Back", backLayout, backSideRestrictRectangles)
    self.checkViaViaInsulation (&ioIssues, viaDictionary)
  }

  //····················································································································

  private func checkViaViaInsulation (_ ioIssues : inout [CanariIssue],
                                      _ inViaDictionary : [String : [GeometricCircle]]) {
    self.mERCLogTextView?.appendMessageString ("Via vs via… ")
    var insulationErrorCount = 0
    var allVias = [GeometricCircle] ()
    for (_, vias) in inViaDictionary {
      allVias += vias
    }
    if allVias.count > 1 {
      for idx in 1 ..< allVias.count {
        let viaX = allVias [idx]
        for idy in 0 ..< idx {
          let viaY = allVias [idy]
          if viaY.intersects (circle: viaX) {
            insulationErrorCount += 1
            let issue = CanariIssue (kind: .error, message: "via collision", pathes: [viaX.bezierPath, viaY.bezierPath])
            ioIssues.append (issue)
          }
        }
      }
    }
    if insulationErrorCount == 0 {
      self.mERCLogTextView?.appendSuccessString ("ok\n")
    }else if insulationErrorCount == 1 {
      self.mERCLogTextView?.appendErrorString ("1 error\n")
    }else{
      self.mERCLogTextView?.appendErrorString ("\(insulationErrorCount) errors\n")
    }
  }

  //····················································································································

  private func checkTrackTrackInsulation (_ ioIssues : inout [CanariIssue],
                                          _ inSide : String,
                                          _ inLayout : [([GeometricOblong], [PadGeometryForERC], [GeometricCircle])]) {
    self.mERCLogTextView?.appendMessageString (inSide + " track vs track… ")
    var insulationErrorCount = 0
    if inLayout.count > 1 {
      for idx in 1 ..< inLayout.count {
        let trackArrayX = inLayout [idx].0
        for idy in 0 ..< idx {
          let trackArrayY = inLayout [idy].0
          for tx in trackArrayX {
            for ty in trackArrayY {
              if tx.intersects (oblong: ty) {
                insulationErrorCount += 1
                let issue = CanariIssue (kind: .error, message: inSide + " track collision", pathes: [tx.bezierPath, ty.bezierPath])
                ioIssues.append (issue)
              }
            }
          }
        }
      }
    }
    if insulationErrorCount == 0 {
      self.mERCLogTextView?.appendSuccessString ("ok\n")
    }else if insulationErrorCount == 1 {
      self.mERCLogTextView?.appendErrorString ("1 error\n")
    }else{
      self.mERCLogTextView?.appendErrorString ("\(insulationErrorCount) errors\n")
    }
  }

  //····················································································································

  private func checkTrackPadInsulation (_ ioIssues : inout [CanariIssue],
                                          _ inSide : String,
                                          _ inLayout : [([GeometricOblong], [PadGeometryForERC], [GeometricCircle])]) {
    self.mERCLogTextView?.appendMessageString (inSide + " track vs pad… ")
    var insulationErrorCount = 0
    if inLayout.count > 1 {
      for idx in 1 ..< inLayout.count {
        let trackArrayX = inLayout [idx].0
        for idy in 0 ..< idx {
          let padArrayY = inLayout [idy].1
          for tx in trackArrayX {
            for py in padArrayY {
              if py.intersects (oblong: tx) {
                insulationErrorCount += 1
                let issue = CanariIssue (kind: .error, message: inSide + " track vs pad collision", pathes: [tx.bezierPath, py.bezierPath])
                ioIssues.append (issue)
              }
            }
          }
        }
      }
    }
    if insulationErrorCount == 0 {
      self.mERCLogTextView?.appendSuccessString ("ok\n")
    }else if insulationErrorCount == 1 {
      self.mERCLogTextView?.appendErrorString ("1 error\n")
    }else{
      self.mERCLogTextView?.appendErrorString ("\(insulationErrorCount) errors\n")
    }
  }

 //····················································································································

  private func checkPadViaInsulation (_ ioIssues : inout [CanariIssue],
                                      _ inSide : String,
                                      _ inLayout : [([GeometricOblong], [PadGeometryForERC], [GeometricCircle])]) {
    self.mERCLogTextView?.appendMessageString (inSide + " pad vs via… ")
    var insulationErrorCount = 0
    if inLayout.count > 1 {
      for idx in 1 ..< inLayout.count {
        let padArrayX = inLayout [idx].1
        for idy in 0 ..< idx {
          let viaArrayY = inLayout [idy].2
          for pad in padArrayX {
            for via in viaArrayY {
              if pad.intersects (circle: via) {
                insulationErrorCount += 1
                let issue = CanariIssue (kind: .error, message: inSide + " track vs via collision", pathes: [pad.bezierPath, via.bezierPath])
                ioIssues.append (issue)
              }
            }
          }
        }
      }
    }
    if insulationErrorCount == 0 {
      self.mERCLogTextView?.appendSuccessString ("ok\n")
    }else if insulationErrorCount == 1 {
      self.mERCLogTextView?.appendErrorString ("1 error\n")
    }else{
      self.mERCLogTextView?.appendErrorString ("\(insulationErrorCount) errors\n")
    }
  }

 //····················································································································

  private func checkTrackViaInsulation (_ ioIssues : inout [CanariIssue],
                                          _ inSide : String,
                                          _ inLayout : [([GeometricOblong], [PadGeometryForERC], [GeometricCircle])]) {
    self.mERCLogTextView?.appendMessageString (inSide + " track vs via… ")
    var insulationErrorCount = 0
    if inLayout.count > 1 {
      for idx in 1 ..< inLayout.count {
        let trackArrayX = inLayout [idx].0
        for idy in 0 ..< idx {
          let viaArrayY = inLayout [idy].2
          for tx in trackArrayX {
            for via in viaArrayY {
              if tx.intersects (circle: via) {
                insulationErrorCount += 1
                let issue = CanariIssue (kind: .error, message: inSide + " track vs via collision", pathes: [tx.bezierPath, via.bezierPath])
                ioIssues.append (issue)
              }
            }
          }
        }
      }
    }
    if insulationErrorCount == 0 {
      self.mERCLogTextView?.appendSuccessString ("ok\n")
    }else if insulationErrorCount == 1 {
      self.mERCLogTextView?.appendErrorString ("1 error\n")
    }else{
      self.mERCLogTextView?.appendErrorString ("\(insulationErrorCount) errors\n")
    }
  }

  //····················································································································

  private func checkTrackRestrictRectInsulation (_ ioIssues : inout [CanariIssue],
                                                 _ inSide : String,
                                                 _ inLayout : [([GeometricOblong], [PadGeometryForERC], [GeometricCircle])],
                                                 _ inRestrictRectangles : [GeometricRect]) {
    self.mERCLogTextView?.appendMessageString (inSide + " track vs restrict rect… ")
    var insulationErrorCount = 0
    for (tracks, _, _) in inLayout {
      for track in tracks {
        for rr in inRestrictRectangles {
          if track.intersects (rect: rr) {
            insulationErrorCount += 1
            let issue = CanariIssue (kind: .error, message: inSide + " track vs restrict rect collision", pathes: [track.bezierPath, rr.bezierPath])
            ioIssues.append (issue)
          }
        }
      }
    }
    if insulationErrorCount == 0 {
      self.mERCLogTextView?.appendSuccessString ("ok\n")
    }else if insulationErrorCount == 1 {
      self.mERCLogTextView?.appendErrorString ("1 error\n")
    }else{
      self.mERCLogTextView?.appendErrorString ("\(insulationErrorCount) errors\n")
    }
  }

  //····················································································································

  private func checkPadRestrictRectInsulation (_ ioIssues : inout [CanariIssue],
                                               _ inSide : String,
                                               _ inLayout : [([GeometricOblong], [PadGeometryForERC], [GeometricCircle])],
                                               _ inRestrictRectangles : [GeometricRect]) {
    self.mERCLogTextView?.appendMessageString (inSide + " pad vs restrict rect… ")
    var insulationErrorCount = 0
    for (_, pads, _) in inLayout {
      for pad in pads {
        for rr in inRestrictRectangles {
          if pad.intersects (rect: rr) {
            insulationErrorCount += 1
            let issue = CanariIssue (kind: .error, message: inSide + " track vs restrict rect collision", pathes: [pad.bezierPath, rr.bezierPath])
            ioIssues.append (issue)
          }
        }
      }
    }
    if insulationErrorCount == 0 {
      self.mERCLogTextView?.appendSuccessString ("ok\n")
    }else if insulationErrorCount == 1 {
      self.mERCLogTextView?.appendErrorString ("1 error\n")
    }else{
      self.mERCLogTextView?.appendErrorString ("\(insulationErrorCount) errors\n")
    }
  }

  //····················································································································

  private func checkViaRestrictRectInsulation (_ ioIssues : inout [CanariIssue],
                                               _ inSide : String,
                                               _ inLayout : [([GeometricOblong], [PadGeometryForERC], [GeometricCircle])],
                                               _ inRestrictRectangles : [GeometricRect]) {
    self.mERCLogTextView?.appendMessageString (inSide + " restrict rect vs via… ")
    var insulationErrorCount = 0
    for (_, _, vias) in inLayout {
      for via in vias {
        for rr in inRestrictRectangles {
          if via.intersects (rect: rr) {
            insulationErrorCount += 1
            let issue = CanariIssue (kind: .error, message: inSide + " via vs restrict rect collision", pathes: [via.bezierPath, rr.bezierPath])
            ioIssues.append (issue)
          }
        }
      }
    }
    if insulationErrorCount == 0 {
      self.mERCLogTextView?.appendSuccessString ("ok\n")
    }else if insulationErrorCount == 1 {
      self.mERCLogTextView?.appendErrorString ("1 error\n")
    }else{
      self.mERCLogTextView?.appendErrorString ("\(insulationErrorCount) errors\n")
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
