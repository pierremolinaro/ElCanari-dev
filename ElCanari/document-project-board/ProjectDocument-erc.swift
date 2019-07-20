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
    let start = Date ()
    self.mERCLogTextView?.clear ()
    var issues = [CanariIssue] ()
  //--- Checkings
    self.checkPadInsulation (&issues)
    var netConnectorsDictionary = [String : [(BoardConnector, EBBezierPath)]] ()
    self.checkPadConnectivity (&issues, &netConnectorsDictionary)
    self.checkNetConnectivity (&issues, netConnectorsDictionary)
    self.checkTrackInsulation (&issues)
  //--- Set issues
    self.mERCIssueTableView?.setIssues (issues)
    let durationMS = Date ().timeIntervalSince (start) * 100.0
    self.mERCLogTextView?.appendMessageString ("Duration \(durationMS.rounded ()) ms")
  }

  //····················································································································

  fileprivate func checkPadInsulation (_ ioIssues : inout [CanariIssue]) {
    let clearance = self.rootObject.mLayoutClearance
    var frontPads = [PadGeometryForERC] ()
    var backPads = [PadGeometryForERC] ()
    for component in self.rootObject.mComponents {
      if component.mRoot != nil { // Is on board
        let af = component.affineTransformFromPackage ()
        for (_, padDescriptor) in component.packagePadDictionary! {
          let padGeometry = PadGeometryForERC (
            centerX: padDescriptor.center.x,
            centerY: padDescriptor.center.y,
            width: padDescriptor.padSize.width + clearance,
            height: padDescriptor.padSize.height + clearance,
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
              width: slavePad.padSize.width + clearance,
              height: slavePad.padSize.height + clearance,
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
          if !componentSidePadGeometry.isEmpty {
            let componentSideTransformedGeometry = componentSidePadGeometry.transformed (by: af)
            switch component.mSide {
            case .front :
              frontPads.append (componentSideTransformedGeometry)
            case .back :
              backPads.append (componentSideTransformedGeometry)
            }
          }
          if !oppositeSidePadGeometry.isEmpty {
            let oppositeSideTransformedGeometry = oppositeSidePadGeometry.transformed (by: af)
            switch component.mSide {
            case .front :
              backPads.append (oppositeSideTransformedGeometry)
            case .back :
              frontPads.append (oppositeSideTransformedGeometry)
            }
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
          let bp = [padX.bezierPath, padY.bezierPath]
          let issue = CanariIssue (kind: .error, message: "Pad collision, front side", pathes: bp, representativeValue: 0)
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
          let bp = [padX.bezierPath, padY.bezierPath]
          let issue = CanariIssue (kind: .error, message: "Pad collision, back side", pathes: bp, representativeValue: 0)
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

  private func checkTrackInsulation (_ ioIssues : inout [CanariIssue]) {
    self.mERCLogTextView?.appendMessageString ("Track insulation… ")
    var insulationErrorCount = 0
  //--- Track inventory
    var frontTrackNetDictionary = [String : [GeometricOblong]] ()
    var backTrackNetDictionary = [String : [GeometricOblong]] ()
    for object in self.rootObject.mBoardObjects {
      if let track = object as? BoardTrack {
        let netName = track.mNet?.mNetName ?? ""
        let p1 = track.mConnectorP1!.location!.cocoaPoint
        let p2 = track.mConnectorP2!.location!.cocoaPoint
        let w = canariUnitToCocoa (track.actualTrackWidth!)
        let s = GeometricOblong (from: p1, to: p2, width: w)
        switch track.mSide {
        case .front :
          frontTrackNetDictionary [netName] = (frontTrackNetDictionary [netName] ?? []) + [s]
        case .back :
          backTrackNetDictionary [netName] = (backTrackNetDictionary [netName] ?? []) + [s]
        }
      }else if let text = object as? BoardText {
        switch text.mLayer {
        case .legendBack, .legendFront :
          ()
        case .layoutFront :
          let (_, _, _, _, oblongs) = text.displayInfos ()
          frontTrackNetDictionary [""] = (frontTrackNetDictionary [""] ?? []) + oblongs
        case .layoutBack :
          let (_, _, _, _, oblongs) = text.displayInfos ()
          backTrackNetDictionary [""] = (backTrackNetDictionary [""] ?? []) + oblongs
        }
      }
    }
  //--- Track insulation test
    let frontTrackArrayArray = Array (frontTrackNetDictionary.values)
    for idx in 1 ..< frontTrackArrayArray.count {
      let trackArrayX = frontTrackArrayArray [idx]
      for idy in 0 ..< idx {
        let trackArrayY = frontTrackArrayArray [idy]
        for tx in trackArrayX {
          for ty in trackArrayY {
            if tx.intersects (oblong: ty) {
              insulationErrorCount += 1
              let issue = CanariIssue (kind: .error, message: "Front track collision", pathes: [tx.filledBezierPath(), ty.filledBezierPath()])
              ioIssues.append (issue)
            }
          }
        }
      }
    }
  //--- Track insulation test
    let backTrackArrayArray = Array (backTrackNetDictionary.values)
    for idx in 1 ..< backTrackArrayArray.count {
      let trackArrayX = backTrackArrayArray [idx]
      for idy in 0 ..< idx {
        let trackArrayY = backTrackArrayArray [idy]
        for tx in trackArrayX {
          for ty in trackArrayY {
            if tx.intersects (oblong: ty) {
              insulationErrorCount += 1
              let issue = CanariIssue (kind: .error, message: "Back track collision", pathes: [tx.filledBezierPath(), ty.filledBezierPath()])
              ioIssues.append (issue)
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

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
