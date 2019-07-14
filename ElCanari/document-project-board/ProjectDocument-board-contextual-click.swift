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
    self.appendConnectInBoard (toMenu: menu, inUnalignedMouseDownPoint, .front)
    self.appendConnectInBoard (toMenu: menu, inUnalignedMouseDownPoint, .back)
  //--- Disconnect ?
    self.appendDisconnectInBoard (toMenu: menu, inUnalignedMouseDownPoint, .front)
    self.appendDisconnectInBoard (toMenu: menu, inUnalignedMouseDownPoint, .back)
  //---
    return menu
  }

  //····················································································································
  // Connect
  //····················································································································

  private func appendConnectInBoard (toMenu menu : NSMenu, _ inUnalignedMouseDownPoint : CanariPoint, _ inSide : TrackSide) {
    let alignedMouseDownPoint = inUnalignedMouseDownPoint.point (alignedOnGrid: self.rootObject.mBoardGridStep)
    let connectors = self.connectors (at: alignedMouseDownPoint, side: inSide)
    if connectors.count > 1 {
      let title : String
      switch inSide {
      case .front : title = "Connect in Front Side"
      case .back  : title = "Connect in Back Side"
      }
      let menuItem = NSMenuItem (title: title, action: #selector (CustomizedProjectDocument.connectInBoardAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = connectors
      menu.addItem (menuItem)
    }
  }

  //····················································································································

  @objc private func connectInBoardAction (_ inMenuItem : NSMenuItem) {
    if let connectors = inMenuItem.representedObject as? [BoardConnector] {
      let nets = self.findAllNetsConnectedToPad (connectors)
      if nets.count <= 1 {
      //--- How many connectors connected to a pad ?
        var connectorsConnectedToAPad = [BoardConnector] ()
        for c in connectors {
          if c.mComponent != nil {
            connectorsConnectedToAPad.append (c)
          }
        }
      //---
        if connectorsConnectedToAPad.count == 0 {
          let retainedConnector = connectors [0]
          self.performConnection (retainedConnector, connectors, nets.first)
        }else if connectorsConnectedToAPad.count == 1 {
          let retainedConnector = connectorsConnectedToAPad [0]
          self.performConnection (retainedConnector, connectors, nets.first)
        }else{
          __NSBeep ()
        }
      }
    }
  }

  //····················································································································

  private func performConnection (_ inRetainedConnector : BoardConnector, _ inOtherConnectors : [BoardConnector], _ inNet : NetInProject?) {
    for c in inOtherConnectors {
      if ObjectIdentifier (c) != ObjectIdentifier (inRetainedConnector) {
        let tracksP1 = c.mTracksP1
        c.mTracksP1 = []
        inRetainedConnector.mTracksP1 += tracksP1
        let tracksP2 = c.mTracksP2
        c.mTracksP2 = []
        inRetainedConnector.mTracksP2 += tracksP2
        c.mRoot = nil // Remove from board objects
      }
    }
  //--- Propagate net from retained connector
    var exploredTracks = Set <BoardTrack> (inRetainedConnector.mTracksP1 + inRetainedConnector.mTracksP2)
    var tracksToExplore = Array (exploredTracks)
    while let track = tracksToExplore.last {
      tracksToExplore.removeLast ()
      track.mNet = inNet
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

  //····················································································································

  internal func findAllNetsConnectedToPad (_ inConnectors : [BoardConnector]) -> Set <NetInProject> {
    var netNameSet = Set <String>  ()
    var connectorsToExplore = inConnectors
    var exploredConnectors = Set (inConnectors)
    while let connector = connectorsToExplore.last {
      connectorsToExplore.removeLast ()
      if let net = connector.mComponent?.padNetDictionary? [connector.mComponentPadName] {
        netNameSet.insert (net)
      }
      for track in connector.mTracksP1 {
        if let c = track.mConnectorP2, !exploredConnectors.contains (c) {
          connectorsToExplore.append (c)
          exploredConnectors.insert (c)
        }
      }
      for track in connector.mTracksP2 {
        if let c = track.mConnectorP1, !exploredConnectors.contains (c) {
          connectorsToExplore.append (c)
          exploredConnectors.insert (c)
        }
      }
    }
  //---
    var result = Set <NetInProject> ()
    for netClass in self.rootObject.mNetClasses {
      for net in netClass.mNets {
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
    let connectors = self.connectors (at: alignedMouseDownPoint, side: inSide)
    var connectedConnectors = [BoardConnector] ()
    for c in connectors {
      var isConnected = (c.mTracksP1.count + c.mTracksP2.count) >= 2
      if !isConnected {
        isConnected = (c.mComponent != nil) && (c.mTracksP1.count + c.mTracksP2.count) >= 1
      }
      if isConnected {
        connectedConnectors.append (c)
      }
    }
    if connectedConnectors.count > 0 {
      let title : String
      switch inSide {
      case .front : title = "Disconnect in Front Side"
      case .back  : title = "Disconnect in Back Side"
      }
      let menuItem = NSMenuItem (title: title, action: #selector (CustomizedProjectDocument.disconnectInBoardAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = connectedConnectors
      menu.addItem (menuItem)
    }
  }

  //····················································································································

  @objc private func disconnectInBoardAction (_ inMenuItem : NSMenuItem) {
    if let connectors = inMenuItem.representedObject as? [BoardConnector] {
      for c in connectors {
        let location = c.location!
        let tracksP1 = c.mTracksP1
        c.mTracksP1 = []
        for track in tracksP1 {
          let newConnector = BoardConnector (self.ebUndoManager)
          newConnector.mRoot = self.rootObject
          newConnector.mX = location.x
          newConnector.mY = location.y
          newConnector.mTracksP1 = [track]
        }
        let tracksP2 = c.mTracksP2
        c.mTracksP2 = []
        for track in tracksP2 {
          let newConnector = BoardConnector (self.ebUndoManager)
          newConnector.mRoot = self.rootObject
          newConnector.mX = location.x
          newConnector.mY = location.y
          newConnector.mTracksP2 = [track]
        }
        if c.mComponent == nil {
          c.mRoot = nil // Remove from board objects
        }
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
