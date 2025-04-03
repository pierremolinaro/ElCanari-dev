//
//  ProjectDocument-import-ses.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 24/07/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

fileprivate let SQUARE_OF_CAPTURE_DISTANCE = 90.0 * 90.0 * 25.4 * 25.4 // Distance: 25.4 µm = 1 mil

//--------------------------------------------------------------------------------------------------

extension AutoLayoutProjectDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func handleSESFileContents (_ inFileContents : String) {
  //--- Build Panel
    let panel = NSPanel (
      contentRect: NSRect (x: 0, y: 0, width: 250, height: 100),
      styleMask: [.titled],
      backing: .buffered,
      defer: false
    )
    panel.hasShadow = true
    let mainView = AutoLayoutHorizontalStackView ().set (margins: .large)
    let leftColumn = AutoLayoutVerticalStackView ()
    _ = leftColumn.appendFlexibleSpace ()
    _ = leftColumn.appendView (AutoLayoutApplicationImage ())
    _ = leftColumn.appendFlexibleSpace ()
    _ = mainView.appendView (leftColumn)
    let rightColumn = AutoLayoutVerticalStackView ()
    let title = AutoLayoutStaticLabel (title: "Importing SES File…", bold: true, size: .regular, alignment: .center)
      .set (alignment: .left)
      .expandableWidth ()
    _ = rightColumn.appendView (title)
    let importSESTextField = AutoLayoutStaticLabel (title: "", bold: false, size: .regular, alignment: .center)
      .set (minWidth: 250)
      .set (alignment: .left)
    _ = rightColumn.appendView (importSESTextField)
    let importSESProgressIndicator = AutoLayoutProgressIndicator ().expandableWidth ()
    _ = rightColumn.appendView (importSESProgressIndicator)
    _ = mainView.appendView (rightColumn)
    panel.setContentView (mainView)
  //--- Display sheet
    importSESTextField.stringValue = "Extracting Tracks…"
    importSESProgressIndicator.minValue = 0.0
    importSESProgressIndicator.doubleValue = 0.0
    importSESProgressIndicator.maxValue = 3.0
    self.windowForSheet?.beginSheet (panel)
    _ = RunLoop.main.run (mode: .default, before: Date ())
  //---
    var errorMessage = ""
  //---
    var routedTracks = [RoutedTrackForSESImporting] ()
    var routedVias = [(BoardConnector, NetInProject)] ()
  //--- Extract nets
    let netComponents = inFileContents.components (separatedBy: "(net ")
  //--- Extract resolution
    var optResolution : Double? = nil
    let resolutionUM = netComponents [0].components (separatedBy: "(resolution um ")
    if resolutionUM.count >= 2 {
      let res = resolutionUM [1].components (separatedBy: ")")
      optResolution = 90.0 / Double (res [0])!
    }else{
      let resolutionMIL = netComponents [0].components (separatedBy: "(resolution mil ")
      if resolutionMIL.count >= 2 {
        let res = resolutionMIL [1].components (separatedBy: ")")
        optResolution = (90.0 * 25.4) / Double (res [0])!
      }else{
        let resolutionMM = netComponents [0].components (separatedBy: "(resolution mm ")
        if resolutionMM.count >= 2 {
          let res = resolutionMM [1].components (separatedBy: ")")
          optResolution = (90.0 * 1000.0) / Double (res [0])!
        }
      }
    }
    if let resolution = optResolution {
      extractTracksAndVias (netComponents, resolution, &routedTracks, &routedVias, &errorMessage)
    //--- Send to canari
      if errorMessage.isEmpty {
        self.enterResults (routedTracks, routedVias, importSESTextField, importSESProgressIndicator)
      }
    }else{
      errorMessage += "\n  - cannot extract resolution from input file"
    }
    self.windowForSheet?.endSheet (panel)
  //---
    if errorMessage.isEmpty {
      self.performERCCheckingAction (nil)
    }else if let window = self.windowForSheet {
      let alert = NSAlert ()
      alert.messageText =  "Cannot Import the .ses File"
      _ = alert.addButton (withTitle: "Ok")
      alert.informativeText = "Cannot Import the .ses File, due to the following errors:\(errorMessage)"
      alert.beginSheetModal (for: window)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func extractTracksAndVias (_ inNetComponents : [String],
                                     _ inResolution : Double,
                                     _ ioRoutedTracks : inout [RoutedTrackForSESImporting],
                                     _ ioRoutedVias : inout [(BoardConnector, NetInProject)],
                                     _ ioErrorMessage : inout String) {
  //--- Extract wires (netComponents [0] is not a valid track description
    for netDescription in Array (inNetComponents [1 ..< inNetComponents.count]) {
      let wireComponents = netDescription.components (separatedBy: "(wire")
    //--- Find net
      var s = wireComponents [0].replacingOccurrences (of: "\n", with: " ")
      while (s.starts (with: " ")) {
        s.removeFirst ()
      }
      let netName : String
      if s.starts (with: "\"") {
        s.removeFirst ()
        netName = s.components (separatedBy: "\"") [0]
      }else{
        netName = s.components (separatedBy: " ") [0]
      }
      var possibleNet : NetInProject? = nil
      for netClass in self.rootObject.mNetClasses.values {
         for net in netClass.mNets.values {
           if net.mNetName == netName {
             possibleNet = net
             break
           }
         }
      }
      // Swift.print ("Net: \"\(netName)\" \((possibleNet == nil) ? "" : "found")")
      if let net = possibleNet {
      //--- Extract tracks (wireComponents [0] is not a valid wire description
        for netDescription in Array (wireComponents [1 ..< wireComponents.count]) {
          let scanner = Scanner (string: netDescription)
          var ok = scanner.scanString ("(path") != nil
          if ok {
            let startScanIndex = scanner.currentIndex
            let layerNames = [FRONT_SIDE_LAYOUT, BACK_SIDE_LAYOUT, INNER1_LAYOUT, INNER2_LAYOUT, INNER3_LAYOUT, INNER4_LAYOUT]
            var idx = 0
            var found = false
            while !found && (idx < layerNames.count) {
              scanner.currentIndex = startScanIndex
              found = scanner.scanString (layerNames [idx]) != nil
              if found {
                let layer : [TrackSide] = [.front, .back, .inner1, .inner2, .inner3, .inner4]
                enterSegments (scanner, layer [idx], &ioRoutedTracks, inResolution, net, &ioErrorMessage)
              }
              idx += 1
            }
            if !found {
              ioErrorMessage += "\n  - invalid track descriptor"
              ok = false
            }
          }
        }
      //--- Extracts vias
        self.extractsVias (netDescription, inResolution, net, &ioRoutedVias, &ioErrorMessage)
      }else{
        ioErrorMessage += "\n  - cannot solve \"\(netName)\" net name"
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func extractsVias (_ netDescription : String,
                             _ inResolution : Double,
                             _ inNet : NetInProject,
                             _ ioRoutedVias : inout [(BoardConnector, NetInProject)],
                             _ ioErrorMessage : inout String) {
    var viaComponents = netDescription.components (separatedBy: "(via viaForClass")
    viaComponents.removeFirst () // First component is not a valid via
    for viaDescription in viaComponents {
      let scanner = Scanner (string: viaDescription)
      let stopSet = CharacterSet (charactersIn: " ")
      if scanner.scanUpToCharacters (from: stopSet) != nil,
         let x = scanner.scanDouble (),
         let y = scanner.scanDouble () {
        if let netClass = inNet.mNetClass {
          let via = BoardConnector (self.undoManager)
          via.mX = Int (x * Double (inResolution))
          via.mY = Int (y * Double (inResolution))
          via.mUsesCustomHoleDiameter = true
          via.mCustomHoleDiameter = netClass.mViaHoleDiameter
          via.mUsesCustomPadDiameter = true
          via.mCustomPadDiameter = netClass.mViaPadDiameter
          ioRoutedVias.append ((via, inNet))
        }else{
          ioErrorMessage += "\n  - cannot find a net class for '\(inNet.mNetName)' net"
        }
      }else{
        ioErrorMessage += "\n  - invalid via description"
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func findOrAddConnector (at inP : CanariPoint,
                                   _ inSide : TrackSide,
                                   _ inViaArray : [(BoardConnector, NetInProject)],
                                   _ ioConnectorArray : inout [BoardConnector],
                                   _ ioAddedObjectArray : inout [BoardObject]) -> BoardConnector {
    for (via, _) in inViaArray {
      let p = via.location!
      let dx = Double (inP.x - p.x)
      let dy = Double (inP.y - p.y)
      let dSquare = dx * dx + dy * dy
      let found = dSquare <= SQUARE_OF_CAPTURE_DISTANCE
      if found {
        return via
      }
    }
    for connector in ioConnectorArray {
      let side = connector.side!
      let ok : Bool
      switch side {
      case .back   : ok = inSide == .back
      case .front  : ok = inSide == .front
      case .inner1 : ok = inSide == .inner1
      case .inner2 : ok = inSide == .inner2
      case .inner3 : ok = inSide == .inner3
      case .inner4 : ok = inSide == .inner4
      case .traversing : ok = true
      }
      if ok {
        let p = connector.location!
        let dx = Double (inP.x - p.x)
        let dy = Double (inP.y - p.y)
        let dSquare = dx * dx + dy * dy
        let found = dSquare <= SQUARE_OF_CAPTURE_DISTANCE
        if found {
          return connector
        }
      }
    }
    let newConnector = BoardConnector (self.undoManager)
    newConnector.mX = inP.x
    newConnector.mY = inP.y
    ioConnectorArray.append (newConnector)
    ioAddedObjectArray.append (newConnector)
    return newConnector
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func enterResults (_ inRoutedTracksArray : [RoutedTrackForSESImporting],
                             _ inRoutedViaArray : [(BoardConnector, NetInProject)],
                             _ importSESTextField : AutoLayoutStaticLabel,
                             _ importSESProgressIndicator : AutoLayoutProgressIndicator) {
  //----------------- Remove Current Tracks and Vias…
    importSESTextField.stringValue = "Remove Current Tracks and Vias…"
    importSESProgressIndicator.doubleValue += 1.0
    _ = RunLoop.main.run (mode: .default, before: Date ())
    self.removeAllViasAndTracks ()
  //----------------- Add Tracks and vias
    importSESTextField.stringValue = "Add Tracks and Vias…"
    importSESProgressIndicator.doubleValue += 1.0
    _ = RunLoop.main.run (mode: .default, before: Date ())
  //----------------- Add Connectors to added object array
    var addedObjectArray = [BoardObject] ()
    for (viaConnector, _) in inRoutedViaArray {
      addedObjectArray.append (viaConnector)
    }
//  //----------------- If via at SMD is allowed, attach via to SMD pad
//    if self.rootObject.mAllowViaAtSMD {
//      for (viaConnector, _) in inRoutedViaArray {
//         let viaLocation = viaConnector.location!
//         for object in self.rootObject.mBoardObjects.values {
//           if let connector = object as? BoardConnector,
//              let connectorLocation = connector.location,
//              let connectorSide = connector.side,
//              (connectorSide == .front) || (connectorSide == .back) {
//             let dx = Double (connectorLocation.x - viaLocation.x)
//             let dy = Double (connectorLocation.y - viaLocation.y)
//             let dSquare = dx * dx + dy * dy
//             let found = dSquare <= SQUARE_OF_CAPTURE_DISTANCE
//             if found {
//               let track = BoardTrack (self.undoManager)
//               track.mSide = (connectorSide == .front) ? .front : .back
//               track.mConnectorP2 = viaConnector
//               track.mConnectorP1 = connector
//               track.mNet = connector.connectedTracksNet ()
//               track.mUsesCustomTrackWidth = true
//               track.mCustomTrackWidth = viaConnector.actualPadDiameter!
//               track.mIsPreservedByAutoRouter = false
//             }
//           }
//         }
//      }
//    }
  //--- Divide tracks for handling tees and crosses
    let routedTracksArray = handleTeesAndCrossesFromRoutedTracks (inRoutedTracksArray, inRoutedViaArray)
  //--- Build connectors attached to pad
    var connectorArray = [BoardConnector] ()
    for object in self.rootObject.mBoardObjects.values {
      if let componentConnector = object as? BoardConnector, let connected = componentConnector.connectedToComponent, connected {
        connectorArray.append (componentConnector)
      }
    }
  //--- Write tracks
    for t in routedTracksArray {
      let track = BoardTrack (self.undoManager)
      let p1 = self.findOrAddConnector (at: t.p1, t.side, inRoutedViaArray, &connectorArray, &addedObjectArray)
      let p2 = self.findOrAddConnector (at: t.p2, t.side, inRoutedViaArray, &connectorArray, &addedObjectArray)
      if p1 !== p2 {
        track.mConnectorP1 = p1
        track.mConnectorP2 = p2
        track.mNet = t.net
        track.mSide = t.side
        track.mUsesCustomTrackWidth = true
        track.mCustomTrackWidth = t.width
        track.mIsPreservedByAutoRouter = t.preservedByRouter
        addedObjectArray.append (track)
      }
    }
  //----------------- If via at SMD is allowed, attach via to SMD pad
    if self.rootObject.mAllowViaAtSMD {
      for (viaConnector, viaNet) in inRoutedViaArray {
         let viaLocation = viaConnector.location!
         for object in self.rootObject.mBoardObjects.values {
           if let componentConnector = object as? BoardConnector,
              let componentConnectorLocation = componentConnector.location,
              let connected = componentConnector.connectedToComponent, connected,
              let componentConnectorSide = componentConnector.side,
              (componentConnectorSide == .front) || (componentConnectorSide == .back) {
             let dx = Double (componentConnectorLocation.x - viaLocation.x)
             let dy = Double (componentConnectorLocation.y - viaLocation.y)
             let dSquare = dx * dx + dy * dy
             let found = dSquare <= SQUARE_OF_CAPTURE_DISTANCE
             if found {
               let track = BoardTrack (self.undoManager)
               track.mSide = (componentConnectorSide == .front) ? .front : .back
               track.mConnectorP1 = viaConnector
               track.mConnectorP2 = componentConnector
//               Swift.print ("viaConnector \(ObjectIdentifier (viaConnector)) componentConnector \(ObjectIdentifier (componentConnector))")
               track.mNet = viaNet // componentConnector.connectedTracksNet ()
//               if viaNet.mNetName != componentConnector.connectedTracksNet ()?.mNetName {
//                 Swift.print ("viaNet.mNetName \(viaNet.mNetName) componentConnector.connectedTracksNet ()?.mNetName \(componentConnector.connectedTracksNet ()?.mNetName)")
//               }
               track.mUsesCustomTrackWidth = true
               track.mCustomTrackWidth = viaConnector.actualPadDiameter!
               track.mIsPreservedByAutoRouter = false
//               let viaConnectorOk = (viaConnector.mTracksP1.count + viaConnector.mTracksP2.count + (viaConnector.connectedToComponent! ? 1 : 0)) >= 2
//               let componentConnectorOk = (componentConnector.mTracksP1.count + componentConnector.mTracksP2.count + (componentConnector.connectedToComponent! ? 1 : 0)) >= 2
//               if !viaConnectorOk || !componentConnectorOk {
//                 Swift.print ("viaConnector \(viaConnector.mTracksP1.count) \(viaConnector.mTracksP2.count) \(viaConnector.connectedToComponent)")
//                 Swift.print ("componentConnector \(componentConnector.mTracksP1.count) \(componentConnector.mTracksP2.count) \(componentConnector.connectedToComponent)")
//               }
               addedObjectArray.append (track)
             }
           }
         }
      }
    }
  //--- Add objects
    let allGraphicObjects = self.rootObject.mBoardObjects.values + addedObjectArray
    self.rootObject.mBoardObjects = EBReferenceArray (allGraphicObjects)
  //--- Build dictionary of all nets
    var netDictionary = [String : NetInProject] ()
    for netClass in self.rootObject.mNetClasses.values {
      for net in netClass.mNets.values {
        netDictionary [net.mNetName] = net
      }
    }
  //--- Arrange object display
    self.sortBoardObjectsFollowingBoardLayersAction (nil)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

fileprivate struct RoutedTrackForSESImporting {
  let p1 : CanariPoint
  let p2 : CanariPoint
  let side : TrackSide
  let width : Int
  let net : NetInProject
  let preservedByRouter : Bool
}

//--------------------------------------------------------------------------------------------------

fileprivate func enterSegments (_ inScanner : Scanner,
                                _ inSide : TrackSide,
                                _ ioRoutedSegments : inout [RoutedTrackForSESImporting],
                                _ inResolution : Double,
                                _ inNet : NetInProject,
                                _ ioErrorMessage : inout String) {
  var wireWidth = 0.0
  var ok = true
  if let d = inScanner.scanDouble (representation: .decimal) {
    wireWidth = d
  }else{
    ok = false
  }
  var routedSegments = [RoutedTrackForSESImporting] ()
  if ok {
    var currentX = 0.0
    var currentY = 0.0
    if let x = inScanner.scanDouble (representation: .decimal), let y = inScanner.scanDouble (representation: .decimal) {
      currentX = x
      currentY = y
    }else{
      ok = false
    }
    var loop = ok
    while loop {
      let idx = inScanner.currentIndex
      loop = inScanner.scanString (")") == nil
      if loop {
        inScanner.currentIndex = idx
        var x = 0.0
        var y = 0.0
        if let xx = inScanner.scanDouble (representation: .decimal), let yy = inScanner.scanDouble (representation: .decimal) {
          x = xx
          y = yy
        }else{
          ok = false
        }
        if ok {
          if (x != currentX) || (y != currentY) {
            let rt = RoutedTrackForSESImporting (
              p1: CanariPoint (x: Int (currentX * inResolution), y: Int (currentY * inResolution)),
              p2: CanariPoint (x: Int (x * inResolution), y: Int (y * inResolution)),
              side: inSide,
              width: Int (wireWidth * inResolution),
              net: inNet,
              preservedByRouter: false
            )
            currentX = x
            currentY = y
            routedSegments.append (rt)
          }else{
           ioErrorMessage += "\n  - track segment with zero length"
          }
        }else{
          loop = false
          ioErrorMessage += "\n  - invalid track segment"
        }
      }
    }
    if ok, inScanner.scanString ("(type protect)") != nil {
      var newRoutedSegments = [RoutedTrackForSESImporting] ()
      for segment in routedSegments {
        let rt = RoutedTrackForSESImporting (
          p1: segment.p1,
          p2: segment.p2,
          side: segment.side,
          width: segment.width,
          net: inNet,
          preservedByRouter: true
        )
        newRoutedSegments.append (rt)
      }
      routedSegments = newRoutedSegments
    }
    ioRoutedSegments += routedSegments
  }else{
    ioErrorMessage += "\n  - invalid track width"
  }
}

//--------------------------------------------------------------------------------------------------

fileprivate struct PointAndNet : Hashable {
  let point : CanariPoint
  let netName : String
}

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate func buildPointSetFromRoutedTracks (_ inRoutedTracksArray : [RoutedTrackForSESImporting],
                                                _ inRoutedViaArray : [(BoardConnector, NetInProject)],
                                                _ inSide : TrackSide) -> Set <PointAndNet> {
  var pointSet = Set <PointAndNet> ()
  for t in inRoutedTracksArray {
    if t.side == inSide {
      pointSet.insert (PointAndNet (point: t.p1, netName: t.net.mNetName))
      pointSet.insert (PointAndNet (point: t.p2, netName: t.net.mNetName))
    }
  }
  for (via, net) in inRoutedViaArray {
    let p = via.location!
    pointSet.insert (PointAndNet (point: p, netName: net.mNetName))
  }
  return pointSet
}

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate func handleTeesAndCrossesFromRoutedTracksOnSide (_ inRoutedTracksArray : [RoutedTrackForSESImporting],
                                                             _ inRoutedViaArray : [(BoardConnector, NetInProject)],
                                                             _ inSide : TrackSide) -> [RoutedTrackForSESImporting] {
  var trackArray = inRoutedTracksArray
  let pointSet = buildPointSetFromRoutedTracks (inRoutedTracksArray, inRoutedViaArray, inSide)
  for p in pointSet {
    let trackArrayCopy = trackArray
    trackArray.removeAll ()
    for t in trackArrayCopy {
      if (t.side != inSide) || (t.net.mNetName != p.netName) {
        trackArray.append (t)
      }else{
        let contains = CanariPoint.segmentStrictlyContainsEBPoint (t.p1, t.p2, p.point)
        if !contains {
          trackArray.append (t)
        }else{
          let t1 = RoutedTrackForSESImporting (p1: t.p1, p2: p.point, side: inSide, width: t.width, net: t.net, preservedByRouter: t.preservedByRouter)
          trackArray.append (t1)
          let t2 = RoutedTrackForSESImporting (p1: t.p2, p2: p.point, side: inSide, width: t.width, net: t.net, preservedByRouter: t.preservedByRouter)
          trackArray.append (t2)
        }
      }
    }
  }
  return trackArray
}

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate func handleTeesAndCrossesFromRoutedTracks (_ inRoutedTracksArray : [RoutedTrackForSESImporting],
                                                       _ inRoutedViaArray : [(BoardConnector, NetInProject)]) -> [RoutedTrackForSESImporting] { // Array of PMClassForConnectorInBoardEntity
  var trackArray = inRoutedTracksArray
  for layer in TrackSide.allCases {
    trackArray = handleTeesAndCrossesFromRoutedTracksOnSide (trackArray, inRoutedViaArray, layer)
  }
  return trackArray
}

//--------------------------------------------------------------------------------------------------
