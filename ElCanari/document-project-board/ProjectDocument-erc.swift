//
//  ProjectDocument-erc.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 17/07/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct SideAndNetName : Hashable {
  let side : TrackSide
  let netName : String
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedProjectDocument {

  //····················································································································

  @IBAction internal func performERCCheckingAction (_ inUnusedSender : Any?) {
  //--- ERC Checking
    let ok = self.performERCChecking ()
    if !ok && (self.rootObject.mBoardSelectedInspector != 5) {
      let alert = NSAlert ()
      alert.messageText =  "ERC Checking error."
      alert.addButton (withTitle: "Close")
      alert.addButton (withTitle: "Select ERC Inspector")
      alert.informativeText = "ERC checking has detected error(s)."
      alert.beginSheetModal (for: self.windowForSheet!) { (response : NSApplication.ModalResponse) in
        if response == .alertSecondButtonReturn {
          self.rootObject.mBoardSelectedInspector = 5
        }
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ProjectDocument {

  //····················································································································

  func invalidateERC () {
    self.rootObject.mLastERCCheckingSignature = 0 
  }

  //····················································································································

  internal func performERCChecking () -> Bool {
    self.mERCLogTextView?.clear ()
    var issues = [CanariIssue] ()
  //--- Checkings
    self.checkVersusArtwork (&issues)
    if let artwork = self.rootObject.mArtwork {
      var padNetDictionary = [SideAndNetName : [PadGeometryForERC]] ()
      var padID = 0
      self.checkTracksLayer (&issues, artworkClearance: artwork.minPPTPTTTW)
      self.buildPadNetDictionary (&issues, &padID, &padNetDictionary, artworkClearance: artwork.minPPTPTTTW)
      var netConnectorsDictionary = [String : [(BoardConnector, EBBezierPath)]] ()
      self.checkPadConnectivity (&issues, &netConnectorsDictionary, artworkClearance: artwork.minPPTPTTTW)
      self.checkNetConnectivity (&issues, netConnectorsDictionary)
      self.checkTrackInsulation (&issues, padNetDictionary, artworkClearance: artwork.minPPTPTTTW)
    }
  //--- Update status
    self.rootObject.mLastERCCheckingIsSuccess = issues.isEmpty
    self.rootObject.mLastERCCheckingSignature = self.rootObject.signatureForERCChecking ?? 0
  //--- Set issues
    self.mERCIssueTableView?.setIssues (issues)
  //---
    return issues.isEmpty
  }

  //····················································································································

  fileprivate func checkVersusArtwork (_ ioIssues : inout [CanariIssue]) {
    if let artwork = self.rootObject.mArtwork {
      self.mERCLogTextView?.appendMessageString ("Check artwork… ")
      var errorCount = 0
    //--- Layer configuration
      if artwork.layerConfiguration != self.rootObject.mLayerConfiguration {
        let issue = CanariIssue (kind: .error, message: "Layer configuration should be equal to Artwork layer configuration", pathes: [])
        ioIssues.append (issue)
        errorCount += 1
      }
    //--- Clearance
      if artwork.minPPTPTTTW > self.rootObject.mLayoutClearance {
        let issue = CanariIssue (kind: .error, message: "Router clearance should be greater or equal to Artwork clearance", pathes: [])
        ioIssues.append (issue)
        errorCount += 1
      }
    //--- Board limit width
      if artwork.minValueForBoardLimitWidth > self.rootObject.mBoardLimitsWidth {
        let issue = CanariIssue (kind: .error, message: "Board limits width should be greater or equal to Artwork board limits", pathes: [])
        ioIssues.append (issue)
        errorCount += 1
      }
      if errorCount == 0 {
        self.mERCLogTextView?.appendSuccessString ("ok\n")
      }else if errorCount == 1 {
        self.mERCLogTextView?.appendErrorString ("1 error\n")
      }else{
        self.mERCLogTextView?.appendErrorString ("\(errorCount) errors\n")
      }
    //--- Board OAR and PHD of vias
      self.checkViasOARAndPHD (&ioIssues, OAR: artwork.minValueForOARinEBUnit, PHD: artwork.minValueForPHDinEBUnit, artworkClearance: artwork.minPPTPTTTW)
    //--- Board OAR and PHD of pads
      self.checkPadsOARAndPHD (&ioIssues, OAR: artwork.minValueForOARinEBUnit, PHD: artwork.minValueForPHDinEBUnit, artworkClearance: artwork.minPPTPTTTW)
    }else{
      self.mERCLogTextView?.appendWarningString ("No checking: artwork is not set.\n")
      let issue = CanariIssue (kind: .warning, message: "No checking: artwork is not set.", pathes: [])
      ioIssues.append (issue)
    }
  }

  //····················································································································

  private func checkTracksLayer (_ ioIssues : inout [CanariIssue],
                                 artworkClearance inArtworkClearance : Int) {
    self.mERCLogTextView?.appendMessageString ("Check tracks layer… ")
    var errorCount = 0
    let layerConfiguration = self.rootObject.mLayerConfiguration
    for object in self.rootObject.mBoardObjects {
      if let track = object as? BoardTrack {
        switch track.mSide {
        case .back, .front :
          () // Always accepted
        case .inner1 :
          if layerConfiguration == .twoLayers {
            let bp = track.bezierPath (extraWidth: inArtworkClearance)
            let issue = CanariIssue (kind: .error, message: "track in inner 1 layer", pathes: [bp])
            ioIssues.append (issue)
            errorCount += 1
          }
        case .inner2 :
          if layerConfiguration == .twoLayers {
            let bp = track.bezierPath (extraWidth: inArtworkClearance)
            let issue = CanariIssue (kind: .error, message: "track in inner 2 layer", pathes: [bp])
            ioIssues.append (issue)
            errorCount += 1
          }
        case .inner3 :
          if layerConfiguration != .sixLayers {
            let bp = track.bezierPath (extraWidth: inArtworkClearance)
            let issue = CanariIssue (kind: .error, message: "track in inner 3 layer", pathes: [bp])
            ioIssues.append (issue)
            errorCount += 1
          }
        case .inner4 :
          if layerConfiguration != .sixLayers {
            let bp = track.bezierPath (extraWidth: inArtworkClearance)
            let issue = CanariIssue (kind: .error, message: "track in inner 4 layer", pathes: [bp])
            ioIssues.append (issue)
            errorCount += 1
          }
        }
      //--- Check if net class allow track on this layer
        if let netClass = track.mNet?.mNetClass {
          switch track.mSide {
          case .front :
            if !netClass.mAllowTracksOnFrontSide {
              let bp = track.bezierPath (extraWidth: inArtworkClearance)
              let issue = CanariIssue (kind: .error, message: "net class forbids track in front side", pathes: [bp])
              ioIssues.append (issue)
              errorCount += 1
            }
          case .back :
            if !netClass.mAllowTracksOnBackSide {
              let bp = track.bezierPath (extraWidth: inArtworkClearance)
              let issue = CanariIssue (kind: .error, message: "net class forbids track in back side", pathes: [bp])
              ioIssues.append (issue)
              errorCount += 1
            }
          case .inner1 :
            if !netClass.mAllowTracksOnInner1Layer {
              let bp = track.bezierPath (extraWidth: inArtworkClearance)
              let issue = CanariIssue (kind: .error, message: "net class forbids track in inner 1 layer", pathes: [bp])
              ioIssues.append (issue)
              errorCount += 1
            }
          case .inner2 :
            if !netClass.mAllowTracksOnInner2Layer {
              let bp = track.bezierPath (extraWidth: inArtworkClearance)
              let issue = CanariIssue (kind: .error, message: "net class forbids track in inner 2 layer", pathes: [bp])
              ioIssues.append (issue)
              errorCount += 1
            }
          case .inner3 :
            if !netClass.mAllowTracksOnInner3Layer {
              let bp = track.bezierPath (extraWidth: inArtworkClearance)
              let issue = CanariIssue (kind: .error, message: "net class forbids track in inner 3 layer", pathes: [bp])
              ioIssues.append (issue)
              errorCount += 1
            }
          case .inner4 :
            if !netClass.mAllowTracksOnInner4Layer{
              let bp = track.bezierPath (extraWidth: inArtworkClearance)
              let issue = CanariIssue (kind: .error, message: "net class forbids track in inner 4 layer", pathes: [bp])
              ioIssues.append (issue)
              errorCount += 1
            }
          }
        }
      }
    }
  //---
    if errorCount == 0 {
      self.mERCLogTextView?.appendSuccessString ("ok\n")
    }else if errorCount == 1 {
      self.mERCLogTextView?.appendErrorString ("1 error\n")
    }else{
      self.mERCLogTextView?.appendErrorString ("\(errorCount) errors\n")
    }
  }

  //····················································································································

  fileprivate func checkViasOARAndPHD (_ ioIssues : inout [CanariIssue],
                                       OAR inOAR : Int,
                                       PHD inPHD : Int,
                                       artworkClearance inArtworkClearance : Int) {
    self.mERCLogTextView?.appendMessageString ("Check vias OAR and PHD… ")
    var errorCount = 0
    for object in self.rootObject.mBoardObjects {
      if let connector = object as? BoardConnector, let isVia = connector.isVia, isVia {
        let viaHoleDiameter = connector.actualHoleDiameter!
        let viaOAR = (connector.actualPadDiameter! - viaHoleDiameter) / 2
        if viaHoleDiameter < inPHD {
          let center = connector.location!.cocoaPoint
          let w = canariUnitToCocoa (connector.actualPadDiameter! + inArtworkClearance)
          let r = NSRect (center: center, size: NSSize (width: w, height: w))
          let bp = EBBezierPath (ovalIn: r)
          let issue = CanariIssue (kind: .error, message: "Hole diameter should be greater or equal to artwork PHD", pathes: [bp])
          ioIssues.append (issue)
          errorCount += 1
        }
        if viaOAR < inOAR {
          let center = connector.location!.cocoaPoint
          let w = canariUnitToCocoa (connector.actualPadDiameter! + inArtworkClearance)
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

  fileprivate func checkPadsOARAndPHD (_ ioIssues : inout [CanariIssue],
                                       OAR inOAR : Int,
                                       PHD inPHD : Int,
                                       artworkClearance inArtworkClearance : Int) {
    self.mERCLogTextView?.appendMessageString ("Check pads OAR and PHD… ")
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
                width: padDescriptor.padSize.width + inArtworkClearance,
                height: padDescriptor.padSize.height + inArtworkClearance,
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
                width: padDescriptor.padSize.width + inArtworkClearance,
                height: padDescriptor.padSize.height + inArtworkClearance,
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
                  width: slavePad.padSize.width + inArtworkClearance,
                  height: slavePad.padSize.height + inArtworkClearance,
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
                  width: slavePad.padSize.width + inArtworkClearance,
                  height: slavePad.padSize.height + inArtworkClearance,
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

  fileprivate func buildPadNetDictionary (_ ioIssues : inout [CanariIssue],
                                          _ ioPadID : inout Int,
                                          _ ioPadNetDictionary : inout [SideAndNetName : [PadGeometryForERC]],
                                          artworkClearance inArtworkClearance : Int) {
    for component in self.rootObject.mComponents {
      if component.mRoot != nil { // Is on board
        let padNetDictionary : PadNetDictionary = component.padNetDictionary!
        let af = component.affineTransformFromPackage ()
        for (_, padDescriptor) in component.packagePadDictionary! {
          let padGeometry = PadGeometryForERC (
            id: ioPadID,
            centerX: padDescriptor.center.x,
            centerY: padDescriptor.center.y,
            width: padDescriptor.padSize.width,
            height: padDescriptor.padSize.height,
            clearance: inArtworkClearance,
            shape: padDescriptor.shape
          )
          ioPadID += 1
          var optionalComponentSidePadGeometry : PadGeometryForERC? = nil
          var optionalOppositeSidePadGeometry : PadGeometryForERC? = nil
          var optionalInnerLayersPadGeometry  : PadGeometryForERC? = nil
          switch padDescriptor.style {
          case .surface :
            optionalComponentSidePadGeometry = padGeometry
          case .traversing :
            optionalComponentSidePadGeometry = padGeometry
            optionalOppositeSidePadGeometry = padGeometry
            optionalInnerLayersPadGeometry = padGeometry
          }
          var componentSideSlavePadGeometryArray = [PadGeometryForERC] ()
          var oppositeSideSlavePadGeometryArray = [PadGeometryForERC] ()
          var innerLayersSlavePadGeometryArray  = [PadGeometryForERC] ()
          for slavePad in padDescriptor.slavePads {
            let slavePadGeometry = PadGeometryForERC (
              id: ioPadID,
              centerX: slavePad.center.x,
              centerY: slavePad.center.y,
              width: slavePad.padSize.width,
              height: slavePad.padSize.height,
              clearance: inArtworkClearance,
              shape: slavePad.shape
            )
            switch slavePad.style {
            case .oppositeSide :
              oppositeSideSlavePadGeometryArray.append (slavePadGeometry)
            case .componentSide :
              componentSideSlavePadGeometryArray.append (slavePadGeometry)
            case .traversing :
              oppositeSideSlavePadGeometryArray.append (slavePadGeometry)
              componentSideSlavePadGeometryArray.append (slavePadGeometry)
              innerLayersSlavePadGeometryArray.append (slavePadGeometry)
            }
          }
          ioPadID += 1
          let netName = padNetDictionary [padDescriptor.name] ?? ""
          if let componentSidePadGeometry = optionalComponentSidePadGeometry {
            let componentSideTransformedGeometry = componentSidePadGeometry.transformed (by: af)
            switch component.mSide {
            case .front :
              let key = SideAndNetName (side: .front, netName: netName)
              ioPadNetDictionary [key] = (ioPadNetDictionary [key] ?? []) + [componentSideTransformedGeometry]
            case .back :
              let key = SideAndNetName (side: .back, netName: netName)
              ioPadNetDictionary [key] = (ioPadNetDictionary [key] ?? []) + [componentSideTransformedGeometry]
            }
          }
          if let oppositeSidePadGeometry = optionalOppositeSidePadGeometry{
            let oppositeSideTransformedGeometry = oppositeSidePadGeometry.transformed (by: af)
            switch component.mSide {
            case .front :
              let key = SideAndNetName (side: .back, netName: netName)
              ioPadNetDictionary [key] = (ioPadNetDictionary [key] ?? []) + [oppositeSideTransformedGeometry]
            case .back :
              let key = SideAndNetName (side: .front, netName: netName)
              ioPadNetDictionary [key] = (ioPadNetDictionary [key] ?? []) + [oppositeSideTransformedGeometry]
            }
          }
          if let innerLayersPadGeometry = optionalInnerLayersPadGeometry {
            let innerLayersTransformedGeometry = innerLayersPadGeometry.transformed (by: af)
            for side in TrackSide.allCases {
              if (side != .front) && (side != .back) {
                let key = SideAndNetName (side: side, netName: netName)
                ioPadNetDictionary [key] = (ioPadNetDictionary [key] ?? []) + [innerLayersTransformedGeometry]
              }
            }
          }
          let slavePadNetName = component.mSlavePadsShouldBeRouted ? netName : ""
          for slavePadGeometry in componentSideSlavePadGeometryArray {
            let componentSideTransformedGeometry = slavePadGeometry.transformed (by: af)
            switch component.mSide {
            case .front :
              let key = SideAndNetName (side: .front, netName: slavePadNetName)
              ioPadNetDictionary [key] = (ioPadNetDictionary [key] ?? []) + [componentSideTransformedGeometry]
            case .back :
              let key = SideAndNetName (side: .back, netName: slavePadNetName)
              ioPadNetDictionary [key] = (ioPadNetDictionary [key] ?? []) + [componentSideTransformedGeometry]
            }
          }
          for slavePadGeometry in oppositeSideSlavePadGeometryArray {
            let oppositeSideTransformedGeometry = slavePadGeometry.transformed (by: af)
            switch component.mSide {
            case .front :
              let key = SideAndNetName (side: .back, netName: slavePadNetName)
              ioPadNetDictionary [key] = (ioPadNetDictionary [key] ?? []) + [oppositeSideTransformedGeometry]
            case .back :
              let key = SideAndNetName (side: .front, netName: slavePadNetName)
              ioPadNetDictionary [key] = (ioPadNetDictionary [key] ?? []) + [oppositeSideTransformedGeometry]
            }
          }
          for slavePadGeometry in innerLayersSlavePadGeometryArray {
            let innerLayersTransformedGeometry = slavePadGeometry.transformed (by: af)
            for side in TrackSide.allCases {
              if (side != .front) && (side != .back) {
                let key = SideAndNetName (side: side, netName: slavePadNetName)
                ioPadNetDictionary [key] = (ioPadNetDictionary [key] ?? []) + [innerLayersTransformedGeometry]
              }
            }
          }
        }
      }
    }
  //--- Check insulation
    self.mERCLogTextView?.appendMessageString ("Pad insulation… ")
    var padsArrayDictionary = [TrackSide : [(String, [PadGeometryForERC])]] ()
    for (key, pads) in ioPadNetDictionary {
      padsArrayDictionary [key.side] = (padsArrayDictionary [key.side] ?? []) + [(key.netName, pads)]
    }
    var collisionCount = 0
    for side in padsArrayDictionary.keys {
      let padArray = padsArrayDictionary [side] ?? []
      if padArray.count > 0 {
        for idx in 0 ..< padArray.count {
          let netNameX = padArray [idx].0
          let frontPadX = padArray [idx].1
          if self.rootObject.mCheckClearanceBetweenPadsOfSameNet || (netNameX == "") {
            self.checkPadInsulation (inArray: frontPadX, side.descriptionForExplorer(), &ioIssues, &collisionCount)
          }
          for idy in idx+1 ..< padArray.count {
            let frontPadY = padArray [idy].1
            self.checkPadInsulation (betweenArraies: (frontPadX, frontPadY), side.descriptionForExplorer(), &ioIssues, &collisionCount)
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
  }

  //····················································································································

  private func checkPadInsulation (betweenArraies inPadArray : ([PadGeometryForERC], [PadGeometryForERC]),
                                   _ inLayerName : String,
                                   _ ioIssues : inout [CanariIssue],
                                   _ ioCollisionCount : inout Int) {
    for padX in inPadArray.0 {
      for padY in inPadArray.1 {
        if padX.intersects (pad: padY) {
          ioCollisionCount += 1
          let bp = [padX.bezierPath, padY.bezierPath]
          let issue = CanariIssue (kind: .error, message: "pad collision in \(inLayerName) layer", pathes: bp)
          ioIssues.append (issue)
        }
      }
    }
  }

  //····················································································································

  private func checkPadInsulation (inArray inPadArray : [PadGeometryForERC],
                                   _ inLayerName : String,
                                   _ ioIssues : inout [CanariIssue],
                                   _ ioCollisionCount : inout Int) {
    if inPadArray.count > 1 {
      for idx in 1 ..< inPadArray.count {
        let padX = inPadArray [idx]
        for idy in 0 ..< idx {
          let padY = inPadArray [idy]
          if (padX.id != padY.id) && padX.intersects (pad: padY) {
            ioCollisionCount += 1
            let bp = [padX.bezierPath, padY.bezierPath]
            let issue = CanariIssue (kind: .error, message: "pad collision in \(inLayerName) layer", pathes: bp)
            ioIssues.append (issue)
          }
        }
      }
    }
  }

  //····················································································································

  private func checkPadConnectivity (_ ioIssues : inout [CanariIssue],
                                     _ ioNetConnectorsDictionary : inout [String : [(BoardConnector, EBBezierPath)]],
                                     artworkClearance inArtworkClearance : Int) {
    self.mERCLogTextView?.appendMessageString ("Pad connection… ")
    var connectionErrorCount = 0
    for component in self.rootObject.mComponents {
      if component.mRoot != nil { // Placed on board
        let af = component.affineTransformFromPackage ()
        let padNetDictionary : PadNetDictionary = component.padNetDictionary!
        let slavePadsShouldBeRouted = component.mSlavePadsShouldBeRouted
        for connector in component.mConnectors {
          let masterPadName = connector.mComponentPadName
          let padDescriptor = component.packagePadDictionary! [masterPadName]!
          let padShouldBeConnected = (connector.mPadIndex == 0) || slavePadsShouldBeRouted
          if let netName = padNetDictionary [masterPadName], padShouldBeConnected {  // Pad should be connected
            let bp = padDescriptor.bezierPath (index: connector.mPadIndex).transformed (by: af)
            if (connector.mTracksP1.count + connector.mTracksP2.count) == 0 {
              let issue = CanariIssue (kind: .error, message: "Pad should be connected", pathes: [bp])
              ioIssues.append (issue)
              connectionErrorCount += 1
            }else{
              ioNetConnectorsDictionary [netName] = (ioNetConnectorsDictionary [netName] ?? []) + [(connector, bp)]
              self.checkPadSizeVersusConnectedTracksSide (&ioIssues, connector, af, &connectionErrorCount, artworkClearance: inArtworkClearance)
            }
          }else if (connector.mTracksP1.count + connector.mTracksP2.count) != 0 { // NC Pad with connection
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
                                                      _ ioConnectionErrorCount : inout Int,
                                                      artworkClearance inArtworkClearance : Int) {
    if let component = inConnector.mComponent {
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
          case .inner1, .inner2, .inner3, .inner4 :
             if !connectorOnFrontSide || !connectorOnBackSide {
              let bp = padDescriptor.bezierPath (index: 0, extraWidth: inArtworkClearance).transformed (by: inAffineTransform)
              let bp2 = track.bezierPath (extraWidth: inArtworkClearance)
              let issue = CanariIssue (kind: .error, message: "Pad not in both side, track in inner layer", pathes: [bp, bp2])
              ioIssues.append (issue)
              ioConnectionErrorCount += 1
            }
         case .front :
            if !connectorOnFrontSide {
              let bp = padDescriptor.bezierPath (index: 0, extraWidth: inArtworkClearance).transformed (by: inAffineTransform)
              let bp2 = track.bezierPath (extraWidth: inArtworkClearance)
              let issue = CanariIssue (kind: .error, message: "Pad in back side, track in front side", pathes: [bp, bp2])
              ioIssues.append (issue)
              ioConnectionErrorCount += 1
            }
          case .back :
            if !connectorOnBackSide {
              let bp = padDescriptor.bezierPath (index: 0, extraWidth: inArtworkClearance).transformed (by: inAffineTransform)
              let bp2 = track.bezierPath (extraWidth: inArtworkClearance)
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
          case .inner1, .inner2, .inner3, .inner4 :
             if !connectorOnFrontSide || !connectorOnBackSide {
              let bp = padDescriptor.bezierPath (index: 0, extraWidth: inArtworkClearance).transformed (by: inAffineTransform)
              let bp2 = track.bezierPath (extraWidth: inArtworkClearance)
              let issue = CanariIssue (kind: .error, message: "Pad not in both side, track in inner layer", pathes: [bp, bp2])
              ioIssues.append (issue)
              ioConnectionErrorCount += 1
            }
          case .front :
            if !connectorOnFrontSide {
              let bp = padDescriptor.bezierPath (index: inConnector.mPadIndex, extraWidth: inArtworkClearance).transformed (by: inAffineTransform)
              let bp2 = track.bezierPath (extraWidth: inArtworkClearance)
              let issue = CanariIssue (kind: .error, message: "Pad in back side, track in front side", pathes: [bp, bp2])
              ioIssues.append (issue)
              ioConnectionErrorCount += 1
            }
          case .back :
            if !connectorOnBackSide {
              let bp = padDescriptor.bezierPath (index: inConnector.mPadIndex, extraWidth: inArtworkClearance).transformed (by: inAffineTransform)
              let bp2 = track.bezierPath (extraWidth: inArtworkClearance)
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
                                     _ inPadNetDictionary : [SideAndNetName : [PadGeometryForERC]],
                                     artworkClearance inArtworkClearance : Int) {
    let clearance = canariUnitToCocoa (inArtworkClearance)
  //--- Track inventory
    var trackSideNetDictionary = [SideAndNetName : [GeometricOblong]] ()
    var restrictRectangles = [TrackSide : [GeometricRect]] ()

    var viaDictionary = [String : [GeometricCircle]] ()
    for object in self.rootObject.mBoardObjects {
      if let track = object as? BoardTrack {
        let netName = track.mNet?.mNetName ?? ""
        let p1 = track.mConnectorP1!.location!.cocoaPoint
        let p2 = track.mConnectorP2!.location!.cocoaPoint
        let w = canariUnitToCocoa (track.actualTrackWidth!) + clearance
        let s = GeometricOblong (p1: p1, p2: p2, width: w)
        let key = SideAndNetName (side: track.mSide, netName: netName)
        trackSideNetDictionary [key] = (trackSideNetDictionary [key] ?? []) + [s]
      }else if let via = object as? BoardConnector {
        var isVia = via.mComponent == nil
        if isVia {
          var layerSet = Set <TrackSide> ()
          for track in via.mTracksP1 + via.mTracksP2 {
            layerSet.insert (track.mSide)
          }
          isVia = layerSet.count > 1
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
          restrictRectangles [.front] = (restrictRectangles [.front] ?? []) + [r]
        }
        if restrictRect.mIsInBackLayer {
          restrictRectangles [.back] = (restrictRectangles [.back] ?? []) + [r]
        }
      }else if let text = object as? BoardText {
        switch text.mLayer {
        case .legendBack, .legendFront :
          ()
        case .layoutFront :
          let (_, _, _, _, oblongs) = text.displayInfos (extraWidth: clearance)
          let key = SideAndNetName (side: .front, netName: "")
          trackSideNetDictionary [key] = (trackSideNetDictionary [key] ?? []) + oblongs
        case .layoutBack :
          let (_, _, _, _, oblongs) = text.displayInfos (extraWidth: clearance)
          let key = SideAndNetName (side: .back, netName: "")
          trackSideNetDictionary [key] = (trackSideNetDictionary [key] ?? []) + oblongs
        }
      }
    }
  //---
    var allNetNames = Set <String> ()
    for (key, _) in trackSideNetDictionary {
      allNetNames.insert (key.netName)
    }
    for (key, _) in inPadNetDictionary {
      allNetNames.insert (key.netName)
    }
    var layout = [TrackSide : [([GeometricOblong], [PadGeometryForERC], [GeometricCircle])]] () // Tracks, pads, vias
    for netName in Array (allNetNames).sorted () {
      for side in TrackSide.allCases {
        let key = SideAndNetName (side: side, netName: netName)
        let tracks = trackSideNetDictionary [key] ?? []
        let pads = inPadNetDictionary [key] ?? []
        let vias = viaDictionary [netName] ?? []
        layout [side] = (layout [side] ?? []) + [(tracks, pads, vias)]
      }
    }
  //--- Insulation tests
    for side in TrackSide.allCases {
      self.checkTrackTrackInsulation (&ioIssues, side.descriptionForExplorer(), layout [side])
    }
    for side in TrackSide.allCases {
      self.checkTrackPadInsulation (&ioIssues, side.descriptionForExplorer(), layout [side])
    }
    for side in TrackSide.allCases {
      self.checkPadRestrictRectInsulation (&ioIssues, side.descriptionForExplorer(), layout [side], restrictRectangles [side])
    }

    for side in TrackSide.allCases {
      self.checkTrackRestrictRectInsulation (&ioIssues, side.descriptionForExplorer(), layout [side], restrictRectangles [side])
    }
    for side in TrackSide.allCases {
      self.checkPadViaInsulation (&ioIssues, side.descriptionForExplorer(), layout [side])
    }
    for side in TrackSide.allCases {
      self.checkTrackViaInsulation (&ioIssues, side.descriptionForExplorer(), layout [side])
    }
    for side in TrackSide.allCases {
      self.checkViaRestrictRectInsulation (&ioIssues, side.descriptionForExplorer(), layout [side], restrictRectangles [side])
    }
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
                                          _ inLayout : [([GeometricOblong], [PadGeometryForERC], [GeometricCircle])]?) {
    if let layout = inLayout, layout.count > 1 {
      self.mERCLogTextView?.appendMessageString (inSide.capitalizingFirstLetter () + " track vs track… ")
      var insulationErrorCount = 0
      for idx in 1 ..< layout.count {
        let trackArrayX = layout [idx].0
        for idy in 0 ..< idx {
          let trackArrayY = layout [idy].0
          for tx in trackArrayX {
            for ty in trackArrayY {
              if tx.intersects (oblong: ty) {
                insulationErrorCount += 1
                let issue = CanariIssue (kind: .error, message: inSide.capitalizingFirstLetter () + " track collision", pathes: [tx.bezierPath, ty.bezierPath])
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
  }

  //····················································································································

  private func checkTrackPadInsulation (_ ioIssues : inout [CanariIssue],
                                        _ inSide : String,
                                        _ inLayout : [([GeometricOblong], [PadGeometryForERC], [GeometricCircle])]?) {
    if let layout = inLayout, layout.count > 1 {
      self.mERCLogTextView?.appendMessageString (inSide.capitalizingFirstLetter () + " track vs pad… ")
      var insulationErrorCount = 0
      for idx in 0 ..< layout.count {
        let trackArrayX = layout [idx].0
        for idy in 0 ..< layout.count {
          if idx != idy {
            let padArrayY = layout [idy].1
            for tx in trackArrayX {
              for py in padArrayY {
                if py.intersects (oblong: tx) {
                  insulationErrorCount += 1
                  let issue = CanariIssue (kind: .error, message: inSide.capitalizingFirstLetter () + " track vs pad collision", pathes: [tx.bezierPath, py.bezierPath])
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
  }

 //····················································································································

  private func checkPadViaInsulation (_ ioIssues : inout [CanariIssue],
                                      _ inSide : String,
                                      _ inLayout : [([GeometricOblong], [PadGeometryForERC], [GeometricCircle])]?) {
    if let layout = inLayout, layout.count > 1 {
      self.mERCLogTextView?.appendMessageString (inSide.capitalizingFirstLetter () + " pad vs via… ")
      var insulationErrorCount = 0
      for idx in 1 ..< layout.count {
        let padArrayX = layout [idx].1
        for idy in 0 ..< idx {
          let viaArrayY = layout [idy].2
          for pad in padArrayX {
            for via in viaArrayY {
              if pad.intersects (circle: via) {
                insulationErrorCount += 1
                let issue = CanariIssue (kind: .error, message: inSide.capitalizingFirstLetter () + " track vs via collision", pathes: [pad.bezierPath, via.bezierPath])
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
  }

 //····················································································································

  private func checkTrackViaInsulation (_ ioIssues : inout [CanariIssue],
                                        _ inSide : String,
                                        _ inLayout : [([GeometricOblong], [PadGeometryForERC], [GeometricCircle])]?) {
    if let layout = inLayout, layout.count > 1 {
      self.mERCLogTextView?.appendMessageString (inSide.capitalizingFirstLetter () + " track vs via… ")
      var insulationErrorCount = 0
      for idx in 1 ..< layout.count {
        let trackArrayX = layout [idx].0
        for idy in 0 ..< idx {
          let viaArrayY = layout [idy].2
          for tx in trackArrayX {
            for via in viaArrayY {
              if tx.intersects (circle: via) {
                insulationErrorCount += 1
                let issue = CanariIssue (kind: .error, message: inSide.capitalizingFirstLetter () + " track vs via collision", pathes: [tx.bezierPath, via.bezierPath])
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
  }

  //····················································································································

  private func checkTrackRestrictRectInsulation (_ ioIssues : inout [CanariIssue],
                                                 _ inSide : String,
                                                 _ inLayout : [([GeometricOblong], [PadGeometryForERC], [GeometricCircle])]?,
                                                 _ inRestrictRectangles : [GeometricRect]?) {
    if let layout = inLayout, let restrictRectangles = inRestrictRectangles {
      self.mERCLogTextView?.appendMessageString (inSide.capitalizingFirstLetter () + " track vs restrict rect… ")
      var insulationErrorCount = 0
      for (tracks, _, _) in layout {
        for track in tracks {
          for rr in restrictRectangles {
            if track.intersects (rect: rr) {
              insulationErrorCount += 1
              let issue = CanariIssue (kind: .error, message: inSide.capitalizingFirstLetter () + " track vs restrict rect collision", pathes: [track.bezierPath, rr.bezierPath])
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
  }

  //····················································································································

  private func checkPadRestrictRectInsulation (_ ioIssues : inout [CanariIssue],
                                               _ inSide : String,
                                               _ inLayout : [([GeometricOblong], [PadGeometryForERC], [GeometricCircle])]?,
                                               _ inRestrictRectangles : [GeometricRect]?) {
    if let layout = inLayout, let restrictRectangles = inRestrictRectangles {
      self.mERCLogTextView?.appendMessageString (inSide.capitalizingFirstLetter () + " pad vs restrict rect… ")
      var insulationErrorCount = 0
      for (_, pads, _) in layout {
        for pad in pads {
          for rr in restrictRectangles {
            if pad.intersects (rect: rr) {
              insulationErrorCount += 1
              let issue = CanariIssue (kind: .error, message: inSide.capitalizingFirstLetter () + " track vs restrict rect collision", pathes: [pad.bezierPath, rr.bezierPath])
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
  }

  //····················································································································

  private func checkViaRestrictRectInsulation (_ ioIssues : inout [CanariIssue],
                                               _ inSide : String,
                                               _ inLayout : [([GeometricOblong], [PadGeometryForERC], [GeometricCircle])]?,
                                               _ inRestrictRectangles : [GeometricRect]?) {
    if let layout = inLayout, let restrictRectangles = inRestrictRectangles {
      self.mERCLogTextView?.appendMessageString (inSide.capitalizingFirstLetter () + " restrict rect vs via… ")
      var insulationErrorCount = 0
      for (_, _, vias) in layout {
        for via in vias {
          for rr in restrictRectangles {
            if via.intersects (rect: rr) {
              insulationErrorCount += 1
              let issue = CanariIssue (kind: .error, message: inSide.capitalizingFirstLetter () + " via vs restrict rect collision", pathes: [via.bezierPath, rr.bezierPath])
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
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
