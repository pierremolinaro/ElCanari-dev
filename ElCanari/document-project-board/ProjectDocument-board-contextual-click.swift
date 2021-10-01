//
//  ProjectDocument-board-contextual-click.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/07/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedProjectDocument {

  //····················································································································

  internal func populateContextualClickOnBoard (_ inUnalignedMouseDownPoint : CanariPoint) -> NSMenu {
    let menu = NSMenu ()
  //--- Connect
    self.appendConnectInBoard (toMenu: menu, inUnalignedMouseDownPoint)
  //--- Disconnect ?
    self.appendDisconnectInBoard (toMenu: menu, inUnalignedMouseDownPoint, .front)
    self.appendDisconnectInBoard (toMenu: menu, inUnalignedMouseDownPoint, .back)
  //--- Merge Tracks ?
    self.mergeTracksInBoard (toMenu: menu, inUnalignedMouseDownPoint, .front)
    self.mergeTracksInBoard (toMenu: menu, inUnalignedMouseDownPoint, .back)
  //--- Split Track ?
    self.splitTrackInBoard (toMenu: menu, inUnalignedMouseDownPoint, .front)
    self.splitTrackInBoard (toMenu: menu, inUnalignedMouseDownPoint, .back)
  //---
    return menu
  }

  //····················································································································
  // Connect
  //····················································································································

  private func appendConnectInBoard (toMenu menu : NSMenu, _ inUnalignedMouseDownPoint : CanariPoint) {
    let connectorsFrontSide = self.rootObject.connectors (at: inUnalignedMouseDownPoint, trackSide: .front)
    let connectorsBackSide  = self.rootObject.connectors (at: inUnalignedMouseDownPoint, trackSide: .back)
    if connectorsFrontSide.count > 1 {
      let menuItem = NSMenuItem (title: "Connect in Front Side", action: #selector (Self.connectInBoardAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = connectorsFrontSide
      menu.addItem (menuItem)
    }
    if connectorsBackSide.count > 1 {
      let menuItem = NSMenuItem (title: "Connect in Back Side", action: #selector (Self.connectInBoardAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = connectorsBackSide
      menu.addItem (menuItem)
    }
    let connectorsBothSides = Array (EBReferenceSet (connectorsBackSide + connectorsFrontSide).values)
    if connectorsBothSides.count > 1 {
      let menuItem = NSMenuItem (title: "Connect in both Sides", action: #selector (Self.connectInBoardAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = connectorsBothSides
      menu.addItem (menuItem)
    }
  }

  //····················································································································

  @objc private func connectInBoardAction (_ inMenuItem : NSMenuItem) {
    if let connectors = inMenuItem.representedObject as? [BoardConnector] {
      self.tryToConnect (connectors)
    }
  }

  //····················································································································

  internal func tryToConnect (_ inConnectors : [BoardConnector]) {
    let nets = self.findAllNetsConnectedToPad (inConnectors)
    if nets.count <= 1 {
    //--- How many connectors connected to a pad ?
      var connectorsConnectedToAPad = [BoardConnector] ()
      for c in inConnectors {
        if c.mComponent != nil {
          connectorsConnectedToAPad.append (c)
        }
      }
    //---
      if connectorsConnectedToAPad.count == 0 {
        let retainedConnector = inConnectors [0]
        self.performConnection (retainedConnector, inConnectors, nets.first)
      }else if connectorsConnectedToAPad.count == 1 {
        let retainedConnector = connectorsConnectedToAPad [0]
        self.performConnection (retainedConnector, inConnectors, nets.first)
      }else{
        __NSBeep ()
      }
    }
  }

  //····················································································································

  private func performConnection (_ inRetainedConnector : BoardConnector, _ inOtherConnectors : [BoardConnector], _ inNet : NetInProject?) {
    for c in inOtherConnectors {
      if ObjectIdentifier (c) != ObjectIdentifier (inRetainedConnector) {
        let tracksP1 = c.mTracksP1
        c.mTracksP1 = EBReferenceArray ()
        inRetainedConnector.mTracksP1.append (objects: tracksP1)
        let tracksP2 = c.mTracksP2
        c.mTracksP2 = EBReferenceArray ()
        inRetainedConnector.mTracksP2.append (objects: tracksP2)
        c.mRoot = nil // Remove from board objects
      }
    }
  //--- Propagate net from retained connector
    var exploredTracks = EBReferenceSet <BoardTrack> (inRetainedConnector.mTracksP1.values + inRetainedConnector.mTracksP2.values)
    var tracksToExplore = Array (exploredTracks.values)
    while let track = tracksToExplore.last {
      tracksToExplore.removeLast ()
      track.mNet = inNet
      var t = EBReferenceArray <BoardTrack> ()
      if let c = track.mConnectorP1 {
        t.append (objects: c.mTracksP1)
        t.append (objects: c.mTracksP2)
      }
      if let c = track.mConnectorP2 {
        t.append (objects: c.mTracksP1)
        t.append (objects: c.mTracksP2)
      }
      for aTrack in t.values {
        if !exploredTracks.contains (aTrack) {
          exploredTracks.insert (aTrack)
          tracksToExplore.append (aTrack)
        }
      }
    }
  }

  //····················································································································

  internal func findAllNetsConnectedToPad (_ inConnectors : [BoardConnector]) -> EBReferenceSet <NetInProject> {
    var netNameSet = Set <String>  ()
    var connectorsToExplore = inConnectors
    var exploredConnectors = EBReferenceSet (inConnectors)
    while let connector = connectorsToExplore.last {
      connectorsToExplore.removeLast ()
      if let net = connector.mComponent?.padNetDictionary? [connector.mComponentPadName] {
        netNameSet.insert (net)
      }
      for track in connector.mTracksP1.values {
        if let c = track.mConnectorP2, !exploredConnectors.contains (c) {
          connectorsToExplore.append (c)
          exploredConnectors.insert (c)
        }
      }
      for track in connector.mTracksP2.values {
        if let c = track.mConnectorP1, !exploredConnectors.contains (c) {
          connectorsToExplore.append (c)
          exploredConnectors.insert (c)
        }
      }
    }
  //---
    var result = EBReferenceSet <NetInProject> ()
    for netClass in self.rootObject.mNetClasses.values {
      for net in netClass.mNets.values {
        if netNameSet.contains (net.mNetName) {
          result.insert (net)
        }
      }
    }
  //---
    return result
  }

  //····················································································································
  // Disconnect
  //····················································································································

  private func appendDisconnectInBoard (toMenu menu : NSMenu, _ inUnalignedMouseDownPoint : CanariPoint, _ inSide : TrackSide) {
    let alignedMouseDownPoint = inUnalignedMouseDownPoint.point (alignedOnGrid: self.rootObject.mBoardGridStep)
    let connectors = self.rootObject.connectors (at: alignedMouseDownPoint, trackSide: inSide)
    var connectedConnectors = [BoardConnector] ()
    for c in connectors {
      var isConnected = (c.mTracksP1.count + c.mTracksP2.count) >= 2
      if !isConnected {
        isConnected = (c.mComponent != nil) && (c.mTracksP1.count + c.mTracksP2.count) >= 1
      }
      if isConnected {
        isConnected = false
        for track in c.mTracksP1.values + c.mTracksP2.values {
          if track.mSide == inSide {
            isConnected = true
          }
        }
      }
      if isConnected {
        connectedConnectors.append (c)
      }
    }
    if connectedConnectors.count > 0 {
      let title : String
      switch inSide {
      case .front : title = "Disconnect in Front Layer"
      case .back  : title = "Disconnect in Back Layer"
      case .inner1  : title = "Disconnect in Inner 1 Layer"
      case .inner2  : title = "Disconnect in Inner 2 Layer"
      case .inner3  : title = "Disconnect in Inner 3 Layer"
      case .inner4  : title = "Disconnect in Inner 4 Layer"
      }
      let menuItem = NSMenuItem (title: title, action: #selector (CustomizedProjectDocument.disconnectInBoardAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = (connectedConnectors, inSide)
      menu.addItem (menuItem)
    }
  }

  //····················································································································

  @objc private func disconnectInBoardAction (_ inMenuItem : NSMenuItem) {
    if let (connectors, side) = inMenuItem.representedObject as? ([BoardConnector], TrackSide) {
      for c in connectors {
        let location = c.location!
        for track in c.mTracksP1.values {
          if track.mSide == side {
            track.mConnectorP1 = nil
            let newConnector = BoardConnector (self.ebUndoManager)
            newConnector.mRoot = self.rootObject
            newConnector.mX = location.x
            newConnector.mY = location.y
            newConnector.mTracksP1 = EBReferenceArray (track)
          }
        }
        for track in c.mTracksP2.values {
          if track.mSide == side {
            track.mConnectorP2 = nil
            let newConnector = BoardConnector (self.ebUndoManager)
            newConnector.mRoot = self.rootObject
            newConnector.mX = location.x
            newConnector.mY = location.y
            newConnector.mTracksP2 = EBReferenceArray (track)
          }
        }
        if (c.mComponent == nil) && (c.mTracksP1.count == 0) && (c.mTracksP2.count == 0) {
          c.mRoot = nil // Remove from board objects
        }
      }
    }
  }

  //····················································································································
  //  Merge Tracks
  //····················································································································

  private func mergeTracksInBoard (toMenu menu : NSMenu, _ inUnalignedMouseDownPoint : CanariPoint, _ inSide : TrackSide) {
    let connectorsUnderMouse = self.rootObject.connectors (at: inUnalignedMouseDownPoint, trackSide: inSide)
    if connectorsUnderMouse.count == 1 {
      let connector = connectorsUnderMouse [0]
      let connectionCount = connector.mTracksP1.count + connector.mTracksP2.count
      if connectionCount == 2 {
        let title : String
        switch inSide {
        case .front : title = "Merge Tracks in Front Layer"
        case .back  : title = "Merge Tracks in Back Layer"
        case .inner1  : title = "Merge Tracks in Inner 1 Layer"
        case .inner2  : title = "Merge Tracks in Inner 2 Layer"
        case .inner3  : title = "Merge Tracks in Inner 3 Layer"
        case .inner4  : title = "Merge Tracks in Inner 4 Layer"
        }
        let menuItem = NSMenuItem (title: title, action: #selector (CustomizedProjectDocument.mergeTracksInBoardAction), keyEquivalent: "")
        menuItem.target = self
        menuItem.representedObject = (connector, inSide)
        menu.addItem (menuItem)
      }
    }
  }

  //····················································································································

  @objc private func mergeTracksInBoardAction (_ inMenuItem : NSMenuItem) {
    if let (connector, side) = inMenuItem.representedObject as? (BoardConnector, TrackSide) {
      var retainedConnectors = [BoardConnector] ()
      var tracksToRemove = [BoardTrack] ()
      for track in connector.mTracksP1.values {
        if let c = track.mConnectorP2, c !== connector {
          retainedConnectors.append (c)
          tracksToRemove.append (track)
        }
      }
      for track in connector.mTracksP2.values {
        if let c = track.mConnectorP1, c !== connector {
          retainedConnectors.append (c)
          tracksToRemove.append (track)
        }
      }
      if retainedConnectors.count == 2 {
      //--- Remove Tracks
        for track in tracksToRemove {
          track.mConnectorP1 = nil
          track.mConnectorP2 = nil
          track.mNet = nil
          track.mRoot = nil
        }
      //--- Remove connector
        connector.mRoot = nil
      //--- Build Track
        let track = BoardTrack (self.ebUndoManager)
        track.mSide = side
        track.mConnectorP1 = retainedConnectors [0]
        track.mConnectorP2 = retainedConnectors [1]
        track.mNet = retainedConnectors [0].connectedTracksNet ()
        self.rootObject.mBoardObjects.append (track)
      }
    }
  }

  //····················································································································
  //  Split Track
  //····················································································································

  private func splitTrackInBoard (toMenu menu : NSMenu, _ inUnalignedMouseDownPoint : CanariPoint, _ inSide : TrackSide) {
    let tracksUnderMouse = self.rootObject.tracks (at: inUnalignedMouseDownPoint, trackSide: inSide)
    if tracksUnderMouse.count == 1 {
      let title : String
      switch inSide {
      case .front : title = "Split Track in Front Layer"
      case .back  : title = "Split Track in Back Layer"
      case .inner1  : title = "Split Track in Inner 1 Layer"
      case .inner2  : title = "Split Track in Inner 2 Layer"
      case .inner3  : title = "Split Track in Inner 3 Layer"
      case .inner4  : title = "Split Track in Inner 4 Layer"
      }
      let menuItem = NSMenuItem (title: title, action: #selector (CustomizedProjectDocument.splitTrackInBoardAction), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = (tracksUnderMouse [0], inUnalignedMouseDownPoint)
      menu.addItem (menuItem)
    }
  }

  //····················································································································

  @objc private func splitTrackInBoardAction (_ inMenuItem : NSMenuItem) {
    if let (track, mouseLocation) = inMenuItem.representedObject as? (BoardTrack, CanariPoint),
       let connector1 = track.mConnectorP1,
       let connector2 = track.mConnectorP2 {
      let net = track.mNet
      let side = track.mSide
    //--- Remove track
      track.mConnectorP1 = nil
      track.mConnectorP2 = nil
      track.mNet = nil
      track.mRoot = nil
    //--- New connector
      let newConnector = BoardConnector (self.ebUndoManager)
      newConnector.mX = mouseLocation.x
      newConnector.mY = mouseLocation.y
      self.rootObject.mBoardObjects.append (newConnector)
    //--- Add First frack
      let track1 = BoardTrack (self.ebUndoManager)
      track1.mSide = side
      track1.mConnectorP1 = connector1
      track1.mConnectorP2 = newConnector
      track1.mNet = net
      self.rootObject.mBoardObjects.append (track1)
    //--- Add Second frack
      let track2 = BoardTrack (self.ebUndoManager)
      track2.mSide = side
      track2.mConnectorP1 = newConnector
      track2.mConnectorP2 = connector2
      track2.mNet = net
      self.rootObject.mBoardObjects.append (track2)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
