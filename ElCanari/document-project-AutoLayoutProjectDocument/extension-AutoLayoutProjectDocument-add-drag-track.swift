//
//  extension-add-drag-track.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 03/08/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {

  //····················································································································

  func performAddBoardTrackDragOperation (_ inDraggingLocationInDestinationView : NSPoint) {
    let side = self.rootObject.mBoardSideForNewTrack
  //---
    let p1 = inDraggingLocationInDestinationView.canariPoint
    let p2 = CanariPoint (x: p1.x + TRACK_INITIAL_SIZE_CANARI_UNIT, y: p1.y + TRACK_INITIAL_SIZE_CANARI_UNIT)
    let connectorsAt1 = self.rootObject.connectors (at: p1, trackSide: side)
    let connectorsAt2 = self.rootObject.connectors (at: p2, trackSide: side)
  //--- Build connector 1
    let connector1 : BoardConnector
    if connectorsAt1.count == 1 {
      connector1 = connectorsAt1 [0]
    }else{
      connector1 = BoardConnector (self.ebUndoManager)
      connector1.mX = p1.x
      connector1.mY = p1.y
      self.rootObject.mBoardObjects.append (connector1)
    }
    let connector1Net = connector1.connectedTracksNet ()
  //--- Build connector 2
    let connector2 : BoardConnector
    if connectorsAt2.count == 1 {
      let c2 = connectorsAt2 [0]
      if c2.connectedTracksNet () === connector1Net {
        connector2 = c2
      }else{
        connector2 = BoardConnector (self.ebUndoManager)
        connector2.mX = p2.x
        connector2.mY = p2.y
        self.rootObject.mBoardObjects.append (connector2)
      }
    }else{
      connector2 = BoardConnector (self.ebUndoManager)
      connector2.mX = p2.x
      connector2.mY = p2.y
      self.rootObject.mBoardObjects.append (connector2)
    }
  //--- Build Track
    let track = BoardTrack (self.ebUndoManager)
    track.mNet = connector1Net
    track.mSide = side
    track.mConnectorP1 = connector1
    track.mConnectorP2 = connector2
    self.rootObject.mBoardObjects.append (track)
    self.boardObjectsController.setSelection ([track])
  }

  //····················································································································

  internal func startTrackCreationOnOptionMouseDown (at inUnalignedMousePoint : NSPoint) {
    let side = self.rootObject.mBoardSideForNewTrack
    let p1 = inUnalignedMousePoint.canariPoint
    let connectorsAtP1 = self.rootObject.connectors (at: p1, trackSide: side)
  //--- Build connector at mouse click
    let connector1 : BoardConnector
    if connectorsAtP1.count == 1 {
      connector1 = connectorsAtP1 [0]
    }else{
      connector1 = BoardConnector (self.ebUndoManager)
      connector1.mX = p1.x
      connector1.mY = p1.y
      self.rootObject.mBoardObjects.append (connector1)
    }
  //--- Build second connector
    let connector2 = BoardConnector (self.ebUndoManager)
    connector2.mX = p1.x
    connector2.mY = p1.y
    self.rootObject.mBoardObjects.append (connector2)
  //--- Build Track
    let track = BoardTrack (self.ebUndoManager)
    track.mSide = side
    track.mConnectorP1 = connector1
    track.mConnectorP2 = connector2
    track.mNet = connector1.connectedTracksNet ()
    self.rootObject.mBoardObjects.append (track)
    self.boardObjectsController.setSelection ([track])
    self.mTrackCreatedByOptionClick = track
  }

  //····················································································································

  internal func helperStringForTrackCreation (_ inModifierFlags : NSEvent.ModifierFlags) -> String {
    let side = self.rootObject.mBoardSideForNewTrack
    var s : String
    switch (side) {
    case .back : s = "Track Creation on back layer"
    case .front : s = "Track Creation on front layer"
    case .inner1 : s = "Track Creation on inner 1 layer"
    case .inner2 : s = "Track Creation on inner 2 layer"
    case .inner3 : s = "Track Creation on inner 3 layer"
    case .inner4 : s = "Track Creation on inner 4 layer"
    }
    return s
  }

  //····················································································································

  internal func continueTrackCreationOnOptionMouseDragged (at inUnalignedMouseLocation : NSPoint,
                                                           _ inModifierFlags : NSEvent.ModifierFlags) {
    if let connector2 = self.mTrackCreatedByOptionClick?.mConnectorP2, let p1 = self.mTrackCreatedByOptionClick?.mConnectorP1?.location {
      var canariUnalignedMouseLocation = inUnalignedMouseLocation.canariPoint
      switch self.rootObject.mDirectionForNewTrack {
      case .anyAngle :
        ()
      case .octolinear :
        canariUnalignedMouseLocation.constraintToOctolinearDirection (from: p1)
      case .rectilinear :
        canariUnalignedMouseLocation.constraintToRectilinearDirection (from: p1)
      }
//      if !inModifierFlags.contains (.shift), let p1 = self.mTrackCreatedByOptionClick?.mConnectorP1?.location {
//        canariUnalignedMouseLocation.quadrantAligned (from: p1)
//      }
      connector2.mX = canariUnalignedMouseLocation.x
      connector2.mY = canariUnalignedMouseLocation.y
    //--- Update hilite
      self.updateHiliteDuringTrackCreation (inUnalignedMouseLocation)
    }
  }

  //····················································································································

  fileprivate func updateHiliteDuringTrackCreation (_ inUnalignedMouseLocation : NSPoint) {
    var shape : EBShape? = nil
    let newTrackSide : TrackSide = self.rootObject.mBoardSideForNewTrack
    let d = milsToCocoaUnit (CGFloat (self.rootObject.mControlKeyHiliteDiameter))
  //--- Hilite connectors
    if let connector1 = self.mTrackCreatedByOptionClick?.mConnectorP1 {
      if let netName = connector1.netName () {
      //--- Exclude connectors connected to connector 1
        var excludedConnectors = self.findAllConnectorsConnectedTo (connector1, trackSide: newTrackSide)
      //--- Exclude connectors at mouse location
        let connectorsUnderMouse = self.rootObject.connectors (at: inUnalignedMouseLocation.canariPoint, trackSide: newTrackSide)
        for c in connectorsUnderMouse {
          excludedConnectors.append (objects: self.findAllConnectorsConnectedTo (c, trackSide: newTrackSide))
        }
      //--- Build shape
        var bpArray = [EBBezierPath] ()
        for object in self.rootObject.mBoardObjects.values {
          if let connector = object as? BoardConnector,
                !excludedConnectors.contains (connector),
                connector.netNameFromComponentPad == netName {
            connector.buildBezierPathArrayForHilitingOnOptionFlag (
              trackSide: newTrackSide,
              controlKeyHiliteDiameter: d,
              bezierPathArray: &bpArray
            )
          }
        }
        if bpArray.count > 0 {
          if shape == nil {
            shape = EBShape ()
          }
          shape?.add (filled: bpArray, NSColor.white)
        }
      }
    }
  //--- Control key ?
    if NSEvent.modifierFlags.contains (.control), d > 0.0, let boardView = self.mBoardView?.mGraphicView {
      if boardView.frame.contains (inUnalignedMouseLocation) {
        let r = NSRect (
          x: inUnalignedMouseLocation.x - d / 2.0,
          y: inUnalignedMouseLocation.y - d / 2.0,
          width: d,
          height: d
        )
        var bp = EBBezierPath (ovalIn: r)
        bp.lineWidth = 1.0 / boardView.actualScale
        if shape == nil {
          shape = EBShape ()
        }
        shape?.add (filled: [bp], NSColor.lightGray.withAlphaComponent (0.2))
        shape?.add (stroke: [bp], NSColor.green)
      }
    }
  //---
    self.mBoardView?.mGraphicView.mOptionalFrontShape = shape
  }

  //····················································································································

  func abortTrackCreationOnOptionMouseUp () {
    self.mTrackCreatedByOptionClick = nil
  }

  //····················································································································

  func stopTrackCreationOnOptionMouseUp (at inUnalignedMousePoint : NSPoint) -> Bool {
     var accepts = true
     if let track = self.mTrackCreatedByOptionClick {
     //--- Retain track only if distance between P1 and P2 is greater than mControlKeyHiliteDiameterSlider
       let p1 = track.mConnectorP1!.location!.cocoaPoint
       let p2 = track.mConnectorP2!.location!.cocoaPoint
       accepts =  NSPoint.distance (p1, p2) > (milsToCocoaUnit (CGFloat (self.rootObject.mControlKeyHiliteDiameter)) / 2.0)
       if accepts { // Try to connect at mouse up location
         let connectorsAt2 = self.rootObject.connectors (at: p2.canariPoint, trackSide: track.mSide)
         self.tryToConnect (connectorsAt2)
       }
       self.mTrackCreatedByOptionClick = nil
     }
     return accepts
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

