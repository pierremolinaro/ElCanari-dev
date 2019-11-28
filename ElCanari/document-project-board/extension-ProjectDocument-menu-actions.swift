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
    self.removeAllViasAndTracks ()
  }

  //····················································································································

  internal func removeAllViasAndTracks () {
  //--- Remove all tracks
    var conservedObjects = [BoardObject] ()
    for object in self.rootObject.mBoardObjects {
      if let track = object as? BoardTrack {
        let optionalNet = track.mNet
        track.mConnectorP1 = nil
        track.mConnectorP2 = nil
        track.mNet = nil
        if let net = optionalNet, net.mPoints.count == 0, net.mTracks.count == 0 {
          net.mNetClass = nil // Remove net
        }
      }else{
        conservedObjects.append (object)
      }
    }
    self.rootObject.mBoardObjects = conservedObjects
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
    self.windowForSheet?.makeFirstResponder (self.mBoardView)
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
    self.windowForSheet?.makeFirstResponder (self.mBoardView)
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
    self.windowForSheet?.makeFirstResponder (self.mBoardView)
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
    self.windowForSheet?.makeFirstResponder (self.mBoardView)
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
    self.windowForSheet?.makeFirstResponder (self.mBoardView)
  }

  //····················································································································

  @IBAction func renameComponentsLeftToRightUpwardsAction (_ inSender : Any?) {
    self.renameComponents (by: compareLefToRightUpwardsComponentLocation)
  }

  //····················································································································

  @IBAction func renameComponentsLeftToRightDownwardsAction (_ inSender : Any?) {
    self.renameComponents (by: compareLefToRightDownwardsComponentLocation)
  }
  //····················································································································

  fileprivate func renameComponents (by inSortFunction : (CenterAndComponent, CenterAndComponent) -> Bool) {
    var componentLocationArray = [CenterAndComponent] ()
    for component in self.rootObject.mComponents {
      if let padRect = component.selectedPackagePadsRect () {
        componentLocationArray.append (CenterAndComponent (center: padRect.center, component: component))
      }else{
        componentLocationArray.append (CenterAndComponent (center: NSPoint (), component: component))
      }
    }
  //--- Sort
    componentLocationArray.sort (by: inSortFunction)
  //--- Rename
    let countedSet = NSCountedSet ()
    for object in componentLocationArray {
      let prefix = object.component.mNamePrefix
      countedSet.add (prefix)
      object.component.mNameIndex = countedSet.count (for: prefix)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct CenterAndComponent {
  let center : NSPoint
  let component : ComponentInProject
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func compareLefToRightUpwardsComponentLocation (_ inLeft : CenterAndComponent, inRight : CenterAndComponent) -> Bool {
  if (inLeft.center.x < inRight.center.x) {
    return true
  }else if (inLeft.center.x > inRight.center.x) {
    return false
  }else if (inLeft.center.y < inRight.center.y) {
    return true
  }else{
    return false
  }
}


//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func compareLefToRightDownwardsComponentLocation (_ inLeft : CenterAndComponent, inRight : CenterAndComponent) -> Bool {
  if (inLeft.center.x < inRight.center.x) {
    return true
  }else if (inLeft.center.x > inRight.center.x) {
    return false
  }else if (inLeft.center.y > inRight.center.y) {
    return true
  }else{
    return false
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

