//
//  extension-ProjectDocument-remove-tracks-vias.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 24/07/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa


//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION CustomizedProjectDocument
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedProjectDocument {

  //····················································································································

  @IBAction func removeAllViasAndTracksActions (_ inUnusedSender : Any?) {
  //--- Remove all tracks
    for object in self.rootObject.mBoardObjects {
      if let track = object as? BoardTrack {
        track.mConnectorP1 = nil
        track.mConnectorP2 = nil
        track.mNet = nil
        track.mRoot = nil
      }
    }
  //--- Remove all vias
    for object in self.rootObject.mBoardObjects {
      if let via = object as? BoardConnector {
        if (via.mComponent == nil) && ((via.mTracksP1.count + via.mTracksP2.count) == 0) {
          via.mRoot = nil
        }
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
