//
//  extension-AutoLayoutProjectDocument-update-boards-connectors.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/02/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {

  //····················································································································
  //    Update board connectors after object removing in board
  //····················································································································

  func updateBoardConnectors () {
    let boardObjects = self.rootObject.mBoardObjects
    for object in boardObjects.values {
      if let connector = object as? BoardConnector {
        let connectedTrackCount = connector.mTracksP1.count + connector.mTracksP2.count
        if (connector.mComponent == nil) && (connectedTrackCount == 0) {
          connector.mRoot = nil // Remove from board objects
        }
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
