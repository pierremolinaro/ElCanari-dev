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

  @IBAction func removeAllViasAndTracksAction (_ inUnusedSender : Any?) {
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

  @IBAction func sortBoardObjectsFollowingBoardLayersAction (_ inUnusedSender : Any?) {
    var backTracks = [BoardObject] ()
    var backComponents = [BoardObject] ()
    var others = [BoardObject] ()
    var frontComponents = [BoardObject] ()
    var frontTracks = [BoardObject] ()
    var restrictRectangles = [BoardObject] ()
    var connectors = [BoardObject] ()
    for object in self.rootObject.mBoardObjects {
      if let connector = object as? BoardConnector {
        connectors.append (connector)
      }else if let rr = object as? BoardRestrictRectangle {
        restrictRectangles.append (rr)
      }else if let track = object as? BoardTrack {
        switch track.mSide {
        case .front :
          frontTracks.append (track)
        case .back :
          backTracks.append (track)
        }
      }else if let component = object as? ComponentInProject {
        switch component.mSide {
        case .front :
          frontComponents.append (component)
        case .back :
          backComponents.append (component)
        }
      }else{
        others.append (object)
      }
    }
    self.rootObject.mBoardObjects = backTracks + backComponents + others + frontComponents + frontTracks + restrictRectangles + connectors
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————