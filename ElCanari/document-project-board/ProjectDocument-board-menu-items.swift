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
      if let inBoard = component.isPlacedInBoard, inBoard, let padDictionary = component.packagePadDictionary {
         let af = component.packageToComponentAffineTransform ()
         var padCenters = [NSPoint] ()
         for (_, masterPad) in padDictionary {
           padCenters.append (af.transform (masterPad.center.cocoaPoint))
           for slavePad in masterPad.slavePads {
             padCenters.append (af.transform (slavePad.center.cocoaPoint))
           }
         }
         let r = NSRect (points: padCenters)
         componentLocationArray.append (CenterAndComponent (center: r.center, component: component))
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

