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

  internal func performERCChecking () -> Bool {
    let start = Date ()
    self.mERCLogTextView?.clear ()
    var issues = [CanariIssue] ()
  //--- Checkings
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
    self.rootObject.mERCStatus = issues.isEmpty ? .success : .error
  //---
    return issues.isEmpty
  }

  //····················································································································

  fileprivate func checkPadInsulation (_ ioIssues : inout [CanariIssue],
                                       _ ioFrontPadNetDictionary : inout [String : [PadGeometryForERC]],
                                       _ ioBackPadNetDictionary : inout [String : [PadGeometryForERC]]) {
    let clearance = self.rootObject.mLayoutClearance
    var frontPads = [PadGeometryForERC] ()
    var backPads = [PadGeometryForERC] ()
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
            case .bottomSide :
              oppositeSidePadGeometry = oppositeSidePadGeometry + slavePadGeometry
            case .topSide :
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
              frontPads.append (componentSideTransformedGeometry)
              ioFrontPadNetDictionary [netName] = (ioFrontPadNetDictionary [netName] ?? []) + [componentSideTransformedGeometry]
            case .back :
              backPads.append (componentSideTransformedGeometry)
              ioBackPadNetDictionary [netName] = (ioBackPadNetDictionary [netName] ?? []) + [componentSideTransformedGeometry]
            }
          }
          if !oppositeSidePadGeometry.isEmpty {
            let oppositeSideTransformedGeometry = oppositeSidePadGeometry.transformed (by: af)
            switch component.mSide {
            case .front :
              backPads.append (oppositeSideTransformedGeometry)
              ioBackPadNetDictionary [netName] = (ioBackPadNetDictionary [netName] ?? []) + [oppositeSideTransformedGeometry]
            case .back :
              frontPads.append (oppositeSideTransformedGeometry)
              ioFrontPadNetDictionary [netName] = (ioFrontPadNetDictionary [netName] ?? []) + [oppositeSideTransformedGeometry]
            }
          }
        }
      }
    }
  //--- Check insulation
    self.mERCLogTextView?.appendMessageString ("Pad insulation… ")
    var collisionCount = 0
    if frontPads.count > 1 {
      for idx in 1 ..< frontPads.count {
        let padX = frontPads [idx]
        for idy in 0 ..< idx {
          let padY = frontPads [idy]
          if padX.intersects (pad: padY) {
            collisionCount += 1
            let bp = [padX.bezierPath, padY.bezierPath]
            let issue = CanariIssue (kind: .error, message: "Front side pad collision", pathes: bp, representativeValue: 0)
            ioIssues.append (issue)
          }
        }
      }
    }
    if backPads.count > 1 {
      for idx in 1 ..< backPads.count {
        let padX = backPads [idx]
        for idy in 0 ..< idx {
          let padY = backPads [idy]
          if padX.intersects (pad: padY) {
            collisionCount += 1
            let bp = [padX.bezierPath, padY.bezierPath]
            let issue = CanariIssue (kind: .error, message: "Back side pad collision", pathes: bp, representativeValue: 0)
            ioIssues.append (issue)
          }
        }
      }
    }
    if collisionCount == 0 {
      self.mERCLogTextView?.appendSuccessString ("ok\n")
    }else if collisionCount == 1 {
      self.mERCLogTextView?.appendErrorString ("1 error\n")
    }else{
      self.mERCLogTextView?.appendErrorString ("\(collisionCount) errors\n")
    }
//    let shape = EBShape (filled: frontPads.bezierPathes (), .yellow)
//    self.mBoardView?.mOverObjectsDisplay = shape
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
            }
          }else{ // Pad without connection
            if (connector.mTracksP1.count + connector.mTracksP2.count) != 0 {
              let bp = padDescriptor.bezierPath (index: connector.mPadIndex).transformed (by: af)
              let issue = CanariIssue (kind: .error, message: "Pad should be nc", pathes: [bp])
              ioIssues.append (issue)
              connectionErrorCount += 1
            }
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
