//
//  ProjectDocument-import-ses.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 24/07/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedProjectDocument {

  //····················································································································

  @IBAction internal func importSESFileAction (_ inUnusedSender : Any?) {
    let openPanel = NSOpenPanel ()
  //--- Default directory
    let savedDirectoryURL = openPanel.directoryURL
    let ud = UserDefaults.standard
    if let url = ud.url (forKey: DSN_SES_DIRECTORY_USER_DEFAULT_KEY) {
      openPanel.directoryURL = url
    }
    openPanel.allowsMultipleSelection = false
    openPanel.canChooseDirectories = false
    openPanel.canChooseFiles = true
    openPanel.allowedFileTypes = ["ses"]
    openPanel.beginSheetModal (for: self.windowForSheet!) { (inReturnCode) in
      openPanel.orderOut (nil)
      if inReturnCode == .OK, let s = try? String (contentsOf: openPanel.urls [0]) {
        ud.set (openPanel.directoryURL, forKey: DSN_SES_DIRECTORY_USER_DEFAULT_KEY)
        self.handleSESFileContents (s)
      }
      openPanel.directoryURL = savedDirectoryURL
    }
  }

  //····················································································································

  internal func handleSESFileContents (_ inFileContents : String) {
  //--- Build Panel
    let panel = NSPanel (
      contentRect: NSRect (x: 0, y: 0, width: 250, height: 100),
      styleMask: [.titled],
      backing: .buffered,
      defer: false
    )
    panel.hasShadow = true
    let mainView = AutoLayoutHorizontalStackView ().set (margins: 12)
    let leftColumn = AutoLayoutVerticalStackView ()
    leftColumn.appendFlexibleSpace ()
    leftColumn.appendView (AutoLayoutApplicationImage ())
    leftColumn.appendFlexibleSpace ()
    mainView.appendView (leftColumn)
    let rightColumn = AutoLayoutVerticalStackView ()
    let title = AutoLayoutStaticLabel (title: "Importing SES File…", bold: true, size: .regular)
      .set (alignment: .left)
      .expandableWidth ()
    rightColumn.appendView (title)
    let importSESTextField = AutoLayoutStaticLabel (title: "", bold: false, size: .regular)
      .set (width: 250)
      .set (alignment: .left)
    rightColumn.appendView (importSESTextField)
    let importSESProgressIndicator = AutoLayoutProgressIndicator ().expandableWidth ()
    rightColumn.appendView (importSESProgressIndicator)
    mainView.appendView (rightColumn)
    panel.contentView = AutoLayoutWindowContentView (view: mainView)
  //--- Display sheet
    importSESTextField.stringValue = "Extracting Tracks…"
    importSESProgressIndicator.minValue = 0.0
    importSESProgressIndicator.doubleValue = 0.0
    importSESProgressIndicator.maxValue = 3.0
    self.windowForSheet?.beginSheet (panel)
  //---
    var errorMessage = ""
  //---
    var routedTracks = [RoutedTrackForSESImporting] ()
    var routedVias = [(BoardConnector, NetInProject)] ()
  //--- Extract nets
    let netComponents = inFileContents.components (separatedBy: "(net ")
  //--- Extract resolution
    var resolution = 0
    let resolutionUM = netComponents [0].components (separatedBy: "(resolution um ")
    if resolutionUM.count >= 2 {
      let res = resolutionUM [1].components (separatedBy: ")")
      resolution = 90 / Int (res [0])!
    }else{
      let resolutionMIL = netComponents [0].components (separatedBy: "(resolution mil ")
      if resolutionMIL.count >= 2 {
        let res = resolutionMIL [1].components (separatedBy: ")")
        resolution = (90 * 2286) / Int (res [0])!
      }else{
        let resolutionMM = netComponents [0].components (separatedBy: "(resolution mm ")
        if resolutionMM.count >= 2 {
          let res = resolutionMM [1].components (separatedBy: ")")
          resolution = (90 * 1000) / Int (res [0])!
        }
      }
    }
    if 0 == resolution {
      errorMessage += "\n  - cannot extract resolution from input file"
    }else{
      extractTracksAndVias (netComponents, resolution, &routedTracks, &routedVias, &errorMessage)
    //--- Send to canari
      if errorMessage.isEmpty {
        self.enterResults (routedTracks, routedVias, importSESTextField, importSESProgressIndicator)
      }
    }
    self.windowForSheet?.endSheet (panel)
  //---
    if errorMessage.isEmpty {
      self.performERCCheckingAction (nil)
    }else{
      let alert = NSAlert ()
      alert.messageText =  "Cannot Import the .ses File"
      alert.addButton (withTitle: "Ok")
      alert.informativeText = "Cannot Import the .ses File, due to the following errors:\(errorMessage)"
      alert.beginSheetModal (for: self.windowForSheet!) { (response) in }
    }
  }

  //····················································································································

  private func extractTracksAndVias (_ inNetComponents : [String],
                                     _ inResolution : Int,
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
            let startScanLocation = scanner.scanLocation
       //     let startScanIndex = scanner.currentIndex
            let layerNames = [FRONT_SIDE_LAYOUT, BACK_SIDE_LAYOUT, INNER1_LAYOUT, INNER2_LAYOUT, INNER3_LAYOUT, INNER4_LAYOUT]
            var idx = 0
            var found = false
            while !found && (idx < layerNames.count) {
//              scanner.currentIndex = startScanIndex
              scanner.scanLocation = startScanLocation
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
        var viaComponents = netDescription.components (separatedBy: "(via viaForClass")
        viaComponents.removeFirst () // First component is not a valid via
        for viaDescription in viaComponents {
          let scanner = Scanner (string: viaDescription)
//          var x = 0.0
//          var y = 0.0
          let stopSet = CharacterSet (charactersIn: " ")
          if scanner.scanUpToCharacters (from: stopSet, into: nil),
//          if scanner.scanUpToCharacters (from: stopSet) != nil,
             let x = scanner.scanDouble (),
             let y = scanner.scanDouble () {
    //      if ok {
            if let netClass = net.mNetClass {
              let via = BoardConnector (self.ebUndoManager)
              via.mX = Int (x * Double (inResolution))
              via.mY = Int (y * Double (inResolution))
              via.mUsesCustomHoleDiameter = true
              via.mCustomHoleDiameter = netClass.mViaHoleDiameter
              via.mUsesCustomPadDiameter = true
              via.mCustomPadDiameter = netClass.mViaPadDiameter
              ioRoutedVias.append ((via, net))
            }else{
              ioErrorMessage += "\n  - cannot find a net class for '\(netName)' net"
            }
          }else{
            ioErrorMessage += "\n  - invalid via description"
          }
        }
      }else{
        ioErrorMessage += "\n  - cannot solve \"\(netName)\" net name"
      }
    }
  }

  //····················································································································

  private func findOrAddConnector (at inP : CanariPoint,
                                   _ inNet : NetInProject,
                                   _ inSide : TrackSide,
                                   _ inTrackWidthInCanariUnit : Int,
                                   _ inViaArray : [(BoardConnector, NetInProject)],
                                   _ ioConnectorArray : inout [BoardConnector],
                                   _ ioAddedObjectArray : inout [BoardObject]) -> BoardConnector {
    let squareOfDistance = 90.0 * 90.0 * 16.0 // Distance: 4 µm
    for (via, _) in inViaArray {
      let p = via.location!
      let dx = Double (inP.x - p.x)
      let dy = Double (inP.y - p.y)
      let dSquare = dx * dx + dy * dy
      let found = dSquare <= squareOfDistance
      if found {
        return via
      }
    }
    for connector in ioConnectorArray {
      let side = connector.side!
      let ok : Bool
      switch side {
      case .back  : ok = inSide == .back
      case .front : ok = inSide == .front
      case .inner1 : ok = inSide == .inner1
      case .inner2 : ok = inSide == .inner2
      case .inner3 : ok = inSide == .inner3
      case .inner4 : ok = inSide == .inner4
      case .traversing  : ok = true
      }
      if ok {
        let p = connector.location!
        let dx = Double (inP.x - p.x)
        let dy = Double (inP.y - p.y)
        let dSquare = dx * dx + dy * dy
        let found = dSquare <= squareOfDistance
        if found {
          return connector
        }
      }
    }
    let newConnector = BoardConnector (self.ebUndoManager)
    newConnector.mX = inP.x
    newConnector.mY = inP.y
    ioConnectorArray.append (newConnector)
    ioAddedObjectArray.append (newConnector)
    return newConnector
  }

  //····················································································································

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
  //---
    var addedObjectArray = [BoardObject] ()
    for (connector, _) in inRoutedViaArray {
      addedObjectArray.append (connector)
    }
  //--- Divide tracks for handling tees and crosses
    let routedTracksArray = handleTeesAndCrossesFromRoutedTracks (inRoutedTracksArray, inRoutedViaArray)
  //--- Build connectors attached to pad
    var connectorArray = [BoardConnector] ()
    for object in self.rootObject.mBoardObjects.values {
      if let connector = object as? BoardConnector {
        connectorArray.append (connector)
      }
    }
  //--- Write tracks
    for t in routedTracksArray {
     let track = BoardTrack (self.ebUndoManager)
      let p1 = self.findOrAddConnector (at: t.p1, t.net, t.side, t.width, inRoutedViaArray, &connectorArray, &addedObjectArray)
      let p2 = self.findOrAddConnector (at: t.p2, t.net, t.side, t.width, inRoutedViaArray, &connectorArray, &addedObjectArray)
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

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate struct RoutedTrackForSESImporting {
  let p1 : CanariPoint
  let p2 : CanariPoint
  let side : TrackSide
  let width : Int
  let net : NetInProject
  let preservedByRouter : Bool
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func enterSegments (_ inScanner : Scanner,
                                _ inSide : TrackSide,
                                _ ioRoutedSegments : inout [RoutedTrackForSESImporting],
                                _ inResolution : Int,
                                _ inNet : NetInProject,
                                _ ioErrorMessage : inout String) {
  var wireWidth = 0
  var ok = inScanner.scanInt (&wireWidth)
  var routedSegments = [RoutedTrackForSESImporting] ()
  if ok {
    var currentX = 0
    var currentY = 0
    ok = inScanner.scanInt (&currentX) && inScanner.scanInt (&currentY)
    var loop = ok
    while loop {
      let idx = inScanner.scanLocation
//      let idx = inScanner.currentIndex
   //   loop = !inScanner.scanString (")", into: nil)
      loop = inScanner.scanString (")") == nil
      if loop {
        inScanner.scanLocation = idx
//        inScanner.currentIndex = idx
        var x = 0
        var y = 0
        ok = inScanner.scanInt (&x) && inScanner.scanInt (&y)
        if ok {
          if (x != currentX) || (y != currentY) {
            let rt = RoutedTrackForSESImporting (
              p1: CanariPoint (x: currentX * inResolution, y: currentY * inResolution),
              p2: CanariPoint (x: x * inResolution, y: y * inResolution),
              side: inSide,
              width: wireWidth * inResolution,
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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate struct PointAndNet : Hashable {
  let point : CanariPoint
  let netName : String
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func buildPointSetFromRoutedTracks (_ inRoutedTracksArray : [RoutedTrackForSESImporting],
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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func handleTeesAndCrossesFromRoutedTracksOnSide (_ inRoutedTracksArray : [RoutedTrackForSESImporting],
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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func handleTeesAndCrossesFromRoutedTracks (_ inRoutedTracksArray : [RoutedTrackForSESImporting],
                                                       _ inRoutedViaArray : [(BoardConnector, NetInProject)]) -> [RoutedTrackForSESImporting] { // Array of PMClassForConnectorInBoardEntity
  var trackArray = inRoutedTracksArray
  for layer in TrackSide.allCases {
    trackArray = handleTeesAndCrossesFromRoutedTracksOnSide (trackArray, inRoutedViaArray, layer)
  }
  return trackArray
//--- Handle Tees in component side
//  let trackArray1 = handleTeesAndCrossesFromRoutedTracksOnSide (inRoutedTracksArray, inRoutedViaArray, .front)
////--- Handle Tees in solder side
//  let trackArray2 = handleTeesAndCrossesFromRoutedTracksOnSide (trackArray1, inRoutedViaArray, .back)
//  return trackArray2
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
