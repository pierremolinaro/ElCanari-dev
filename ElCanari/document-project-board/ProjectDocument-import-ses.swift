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
      if inReturnCode == .OK,
         let s = try? String (contentsOf: openPanel.urls [0]),
         let panel = self.mImportSESPanel,
         let textField = self.mImportSESTextField,
         let progressIndicator = self.mImportSESProgressIndicator {
        ud.set (openPanel.directoryURL, forKey: DSN_SES_DIRECTORY_USER_DEFAULT_KEY)
        self.handleSESFileContents (s, panel, textField, progressIndicator)
      }
      openPanel.directoryURL = savedDirectoryURL
    }
  }

  //····················································································································

  private func handleSESFileContents (_ inFileContents : String,
                                      _ inPanel : NSPanel,
                                      _ inTextField : NSTextField,
                                      _ inProgressIndicator : EBProgressIndicator) {
  //--- Display sheet
    inTextField.stringValue = "Extracting Tracks…"
    inProgressIndicator.minValue = 0.0
    inProgressIndicator.doubleValue = 0.0
    inProgressIndicator.maxValue = 5.0
    self.windowForSheet?.beginSheet (inPanel)
  //--- Build net class array
    var netClassArray = [NetClassSESImporting] ()
    for netClass in self.rootObject.mNetClasses {
      let nc = NetClassSESImporting (
        name: netClass.mNetClassName,
        trackWidth: netClass.mTrackWidth,
        viaHoleDiameter: netClass.mViaHoleDiameter,
        viaPadDiameter: netClass.mViaPadDiameter
      )
      netClassArray.append (nc)
    }
  //---
    var errorMessage = ""
  //---
    var routedTracks = [RoutedTrackForSESImporting] ()
    var routedVias = [BoardConnector] ()
  //--- Extract wires
    let components = inFileContents.components (separatedBy: "(wire")
  //--- Extract resolution
    var resolution = 0
    let resolutionUM = components [0].components (separatedBy: "(resolution um ")
    if resolutionUM.count >= 2 {
      let res = resolutionUM [1].components (separatedBy: ")")
      resolution = 90 / Int (res [0])!
    }else{
      let resolutionMIL = components [0].components (separatedBy: "(resolution mil ")
      if resolutionMIL.count >= 2 {
        let res = resolutionMIL [1].components (separatedBy: ")")
        resolution = (90 * 2286) / Int (res [0])!
      }else{
        let resolutionMM = components [0].components (separatedBy: "(resolution mm ")
        if resolutionMM.count >= 2 {
          let res = resolutionMM [1].components (separatedBy: ")")
          resolution = (90 * 1000) / Int (res [0])!
        }
      }
    }
    if 0 == resolution {
      errorMessage += "\n  - cannot extract resolution from input file"
    }else{
    //--- Extract tracks (components [0] is not a valid track description
      for trackDescription in Array (components [1 ..< components.count]) {
        let scanner = Scanner (string: trackDescription)
        var ok = scanner.scanString ("(path", into: nil)
        if ok {
          let scanLocation = scanner.scanLocation
          ok = scanner.scanString (COMPONENT_SIDE, into: nil)
          if ok {
            _ = enterSegments (scanner, .front, &routedTracks, resolution, &errorMessage)
          }else{
            scanner.scanLocation = scanLocation
            ok = scanner.scanString (SOLDER_SIDE, into: nil)
            if ok {
              _ = enterSegments (scanner, .back, &routedTracks, resolution, &errorMessage)
            }
          }
        }
        if !ok {
          errorMessage += "\n  - invalid track descriptor"
        }
      }
    //--- Extract vias
      inTextField.stringValue = "Extracting Vias…"
      inProgressIndicator.doubleValue += 1.0
      _ = RunLoop.main.run (mode: .default, before: Date ())
      if components.count > 0 {
        let stopSet = CharacterSet (charactersIn: " ")
        var viaComponents = inFileContents.components (separatedBy: "(via viaForClass")
      //--- Remove first via component (it is invalid)
        viaComponents = Array (viaComponents [1 ..< viaComponents.count])
        for viaDescription in viaComponents {
          let scanner = Scanner (string: viaDescription)
          var nsNetClassName : NSString? = "" // NSString required for scanUpToCharacters
          var x = 0.0
          var y = 0.0
          let ok = scanner.scanUpToCharacters (from: stopSet, into: &nsNetClassName) && scanner.scanDouble (&x) && scanner.scanDouble (&y)
          if ok, let netClassName = nsNetClassName as String? {
            var foundNetClass : NetClassSESImporting? = nil
            for netClass in netClassArray {
              if netClassName == netClass.name {
                foundNetClass = netClass
                break
              }
            }
            if let netClass = foundNetClass {
              let via = BoardConnector (self.ebUndoManager)
              via.mX = Int (x * Double (resolution))
              via.mY = Int (y * Double (resolution))
              via.mUsesCustomHoleDiameter = true
              via.mCustomHoleDiameter = netClass.viaHoleDiameter
              via.mUsesCustomPadDiameter = true
              via.mCustomPadDiameter = netClass.viaPadDiameter
              routedVias.append (via)
            }else{
              errorMessage += "\n  - cannot find a net class named '\(netClassName)'"
            }
          }else{
            errorMessage += "\n  - invalid via description"
          }
        }
      }
    //--- Send to canari
      if errorMessage == "" {
        self.enterResults (routedTracks, routedVias, inTextField, inProgressIndicator)
      }
    }
    self.windowForSheet?.endSheet (inPanel)
  //---
    if errorMessage == "" {
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

  private func findOrAddConnector (at inP : CanariPoint,
                                   _ inSide : TrackSide,
                                   _ inViaArray : [BoardConnector],
                                   _ ioConnectorArray : inout [BoardConnector],
                                   _ ioAddedObjectArray : inout [BoardObject]) -> BoardConnector {
    for via in inViaArray {
      let p = via.location!
      let dx = Double (inP.x - p.x)
      let dy = Double (inP.y - p.y)
      let dSquare = dx * dx + dy * dy
      let found = dSquare <= (2286.0 * 2286.0 * 2.0)
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
      case .both  : ok = true
      }
      if ok {
        let p = connector.location!
        let dx = Double (inP.x - p.x)
        let dy = Double (inP.y - p.y)
        let dSquare = dx * dx + dy * dy
        let found = dSquare <= (2286.0 * 2286.0 * 2.0)
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
                             _ inRoutedViaArray : [BoardConnector],
                             _ inTextField : NSTextField,
                             _ inProgressIndicator : EBProgressIndicator) {
    inTextField.stringValue = "Remove Current Tracks and Vias…"
    inProgressIndicator.doubleValue += 1.0
    _ = RunLoop.main.run (mode: .default, before: Date ())
    self.removeAllViasAndTracks ()
  //---
    var addedObjectArray = [BoardObject] ()
    addedObjectArray += inRoutedViaArray as [BoardObject]
  //--- Divide tracks for handling tees and crosses
    let routedTracksArray = handleTeesAndCrossesFromRoutedTracks (inRoutedTracksArray, inRoutedViaArray)
  //--- Build connectors attached to pad
    var connectorArray = [BoardConnector] ()
    for object in self.rootObject.mBoardObjects {
      if let connector = object as? BoardConnector {
        connectorArray.append (connector)
      }
    }
  //--- Write tracks
    inTextField.stringValue = "Adding Tracks and Vias…"
    inProgressIndicator.doubleValue += 1.0
    _ = RunLoop.main.run (mode: .default, before: Date ())
    for t in routedTracksArray {
     let track = BoardTrack (self.ebUndoManager)
      track.mConnectorP1 = findOrAddConnector (at: t.p1, t.side, inRoutedViaArray, &connectorArray, &addedObjectArray)
      track.mConnectorP2 = findOrAddConnector (at: t.p2, t.side, inRoutedViaArray, &connectorArray, &addedObjectArray)
      track.mSide = t.side
      track.mUsesCustomTrackWidth = true
      track.mCustomTrackWidth = t.width
      track.mIsPreservedByAutoRouter = t.preservedByRouter
      addedObjectArray.append (track)
    }
  //--- Add objects
    let allGraphicObjects = self.rootObject.mBoardObjects + addedObjectArray
    self.rootObject.mBoardObjects = allGraphicObjects
  //--- Build dictionary of all nets
    var netDictionary = [String : NetInProject] ()
    for netClass in self.rootObject.mNetClasses {
      for net in netClass.mNets {
        netDictionary [net.mNetName] = net
      }
    }
  //--- Propagate net reference from pads to connected tracks
    inTextField.stringValue = "Propagate Net References…"
    inProgressIndicator.doubleValue += 1.0
    _ = RunLoop.main.run (mode: .default, before: Date ())
    for object in self.rootObject.mBoardObjects {
      inProgressIndicator.doubleValue += 1.0
      if let pad = object as? BoardConnector, let component = pad.mComponent {
        let padNetDictionary = component.padNetDictionary!
        if let netName = padNetDictionary [pad.mComponentPadName] {
          let net = netDictionary [netName]!
          var exploredTracks = Set <BoardTrack> (pad.mTracksP1 + pad.mTracksP2)
          var tracksToExplore = Array (exploredTracks)
          while let track = tracksToExplore.last {
            tracksToExplore.removeLast ()
            track.mNet = net
            var t = [BoardTrack] ()
            if let c = track.mConnectorP1 {
              t += c.mTracksP1
              t += c.mTracksP2
            }
            if let c = track.mConnectorP2 {
              t += c.mTracksP1
              t += c.mTracksP2
            }
            for aTrack in t {
              if !exploredTracks.contains (aTrack) {
                exploredTracks.insert (aTrack)
                tracksToExplore.append (aTrack)
              }
            }
          }
        }
      }
    }
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
  let preservedByRouter : Bool
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate struct NetClassSESImporting {
  let name : String
  let trackWidth : Int
  let viaHoleDiameter : Int
  let viaPadDiameter : Int
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func enterSegments (_ inScanner : Scanner,
                                _ inSide : TrackSide,
                                _ ioRoutedSegments : inout [RoutedTrackForSESImporting],
                                _ inResolution : Int,
                                _ ioErrorMessage : inout String) -> Bool {
  var wireWidth = 0
  var ok = inScanner.scanInt (&wireWidth)
  var routedSegments = [RoutedTrackForSESImporting] ()
  if ok {
    var currentX = 0
    var currentY = 0
    ok = inScanner.scanInt (&currentX) && inScanner.scanInt (&currentY)
    var loop = ok
    while loop {
      let location = inScanner.scanLocation
      loop = !inScanner.scanString (")", into: nil)
      if loop {
        inScanner.scanLocation = location
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
    if ok && inScanner.scanString ("(type protect)", into: nil) {
      var newRoutedSegments = [RoutedTrackForSESImporting] ()
      for segment in routedSegments {
        let rt = RoutedTrackForSESImporting (
          p1: segment.p1,
          p2: segment.p2,
          side: segment.side,
          width: segment.width,
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
  return ok
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func buildPointSetFromRoutedTracks (_ inRoutedTracksArray : [RoutedTrackForSESImporting],
                                                _ inRoutedViaArray : [BoardConnector],
                                                _ inSide : TrackSide) -> Set <CanariPoint> {
  var pointSet = Set <CanariPoint> ()
  for t in inRoutedTracksArray {
    if t.side == inSide {
      pointSet.insert (t.p1)
      pointSet.insert (t.p2)
    }
  }
  for via in inRoutedViaArray {
    let p = via.location!
    pointSet.insert (p)
  }
  return pointSet
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func handleTeesAndCrossesFromRoutedTracksOnSide (_ inRoutedTracksArray : [RoutedTrackForSESImporting],
                                                             _ inRoutedViaArray : [BoardConnector],
                                                             _ inSide : TrackSide) -> [RoutedTrackForSESImporting] {
  var trackArray = inRoutedTracksArray
  let pointSet = buildPointSetFromRoutedTracks (inRoutedTracksArray, inRoutedViaArray, inSide)
  for p in pointSet {
    let trackArrayCopy = trackArray
    trackArray.removeAll ()
    for t in trackArrayCopy {
      if t.side != inSide { // 0 : component side, 1 : solder side
        trackArray.append (t)
      }else{
        let contains = CanariPoint.segmentStrictlyContainsEBPoint (t.p1, t.p2, p)
        if !contains {
          trackArray.append (t)
        }else{
          let t1 = RoutedTrackForSESImporting (p1: t.p1, p2: p, side: inSide, width: t.width, preservedByRouter: t.preservedByRouter)
          trackArray.append (t1)
          let t2 = RoutedTrackForSESImporting (p1: t.p2, p2: p, side: inSide, width: t.width, preservedByRouter: t.preservedByRouter)
          trackArray.append (t2)
        }
      }
    }
  }
  return trackArray
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func handleTeesAndCrossesFromRoutedTracks (_ inRoutedTracksArray : [RoutedTrackForSESImporting],
                                                       _ inRoutedViaArray : [BoardConnector]) -> [RoutedTrackForSESImporting] { // Array of PMClassForConnectorInBoardEntity
//--- Handle Tees in component side
  let trackArray1 = handleTeesAndCrossesFromRoutedTracksOnSide (inRoutedTracksArray, inRoutedViaArray, .front)
//--- Handle Tees in solder side
  let trackArray2 = handleTeesAndCrossesFromRoutedTracksOnSide (trackArray1, inRoutedViaArray, .back)
  return trackArray2
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
