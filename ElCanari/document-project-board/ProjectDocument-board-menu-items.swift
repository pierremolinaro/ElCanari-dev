//
//  ProjectDocument-board-menu-items.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/09/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ProjectDocument {

  //····················································································································

  @IBAction func selectAllComponentsAction (_ inSender : Any?) {
    var newSelection = [BoardObject] ()
    for object in self.rootObject.mBoardObjects {
      if let component = object as? ComponentInProject {
        newSelection.append (component)
      }
    }
    self.boardObjectsController.setSelection (newSelection)
  }

  //····················································································································

  @IBAction func selectAllTracksAction (_ inSender : Any?) {
    var newSelection = [BoardObject] ()
    for object in self.rootObject.mBoardObjects {
      if let track = object as? BoardTrack {
        newSelection.append (track)
      }
    }
    self.boardObjectsController.setSelection (newSelection)
  }

  //····················································································································

  @IBAction func selectAllViasAction (_ inSender : Any?) {
    var newSelection = [BoardObject] ()
    for object in self.rootObject.mBoardObjects {
      if let connector = object as? BoardConnector, let isVia = connector.isVia, isVia {
        newSelection.append (connector)
      }
    }
    self.boardObjectsController.setSelection (newSelection)
  }

  //····················································································································

  @IBAction func selectAllRestrictRectanglesAction (_ inSender : Any?) {
    var newSelection = [BoardObject] ()
    for object in self.rootObject.mBoardObjects {
      if let brr = object as? BoardRestrictRectangle {
        newSelection.append (brr)
      }
    }
    self.boardObjectsController.setSelection (newSelection)
  }

  //····················································································································

  @IBAction func selectAllTracksOfSelectedTracksNetsAction (_ inSender : Any?) {
    var netSet = Set <NetInProject> ()
    for object in self.boardObjectsController.selectedArray {
      if let track = object as? BoardTrack, let net = track.mNet {
        netSet.insert (net)
      }
    }
    var newSelectedObjects = [BoardObject] ()
    for object in self.rootObject.mBoardObjects {
      if let track = object as? BoardTrack, let net = track.mNet, netSet.contains (net) {
        newSelectedObjects.append (object)
      }
    }
    self.boardObjectsController.addToSelection (objects: newSelectedObjects)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

