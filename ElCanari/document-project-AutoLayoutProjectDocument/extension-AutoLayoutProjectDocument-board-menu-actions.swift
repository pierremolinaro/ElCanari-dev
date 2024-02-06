//
//  extension-AutoLayoutProjectDocument-board-menu-actions.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 24/07/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION AutoLayoutProjectDocument
//——————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {

  //····················································································································

  @objc func removeAllViasAndTracksAction (_ _ : Any?) {
    self.removeAllViasAndTracks ()
  }

  //····················································································································

  func removeAllViasAndTracks () {
  //--- Remove all tracks
    var conservedObjects = EBReferenceArray <BoardObject> ()
    for object in self.rootObject.mBoardObjects.values {
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
    for object in self.rootObject.mBoardObjects.values {
      if let via = object as? BoardConnector {
        if (via.mComponent == nil) && ((via.mTracksP1.count + via.mTracksP2.count) == 0) {
          via.mRoot = nil
        }
      }
    }
  }

  //····················································································································

  @objc func sortBoardObjectsFollowingBoardLayersAction (_ _ : Any?) {
    var backTracks = EBReferenceArray <BoardObject> ()
    var backComponents = EBReferenceArray <BoardObject> ()
    var others = EBReferenceArray <BoardObject> ()
    var frontComponents = EBReferenceArray <BoardObject> ()
    var inner1Tracks = EBReferenceArray <BoardObject> ()
    var inner2Tracks = EBReferenceArray <BoardObject> ()
    var inner3Tracks = EBReferenceArray <BoardObject> ()
    var inner4Tracks = EBReferenceArray <BoardObject> ()
    var frontTracks = EBReferenceArray <BoardObject> ()
    var restrictRectangles = EBReferenceArray <BoardObject> ()
    var connectors = EBReferenceArray <BoardObject> ()
    for object in self.rootObject.mBoardObjects.values {
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
        case .inner1 :
          inner1Tracks.append (track)
        case .inner2 :
          inner2Tracks.append (track)
        case .inner3 :
          inner3Tracks.append (track)
        case .inner4 :
          inner4Tracks.append (track)
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
    var array = backComponents
    array.append (objects: backTracks)
    array.append (objects: inner4Tracks)
    array.append (objects: inner3Tracks)
    array.append (objects: inner2Tracks)
    array.append (objects: inner1Tracks)
    array.append (objects: frontTracks)
    array.append (objects: frontComponents)
    array.append (objects: restrictRectangles)
    array.append (objects: connectors)
    array.append (objects: others)
    self.rootObject.mBoardObjects = array
  }

  //····················································································································

  @objc func selectAllComponentsAction (_ inSender : Any?) {
    var newSelection = [BoardObject] ()
    for object in self.rootObject.mBoardObjects.values {
      if let component = object as? ComponentInProject {
        newSelection.append (component)
      }
    }
    self.boardObjectsController.setSelection (newSelection)
    _ = self.windowForSheet?.makeFirstResponder (self.mBoardView?.mGraphicView)
  }

  //····················································································································

  @objc func selectAllTracksOfFrontLayerAction (_ inSender : Any?) {
    self.rootObject.displayFrontLayoutForBoard_property.setProp (true)
    var newSelection = [BoardObject] ()
    for object in self.rootObject.mBoardObjects.values {
      if let track = object as? BoardTrack {
        if track.mSide == .front {
          newSelection.append (track)
        }
      }
    }
    self.boardObjectsController.setSelection (newSelection)
    _ = self.windowForSheet?.makeFirstResponder (self.mBoardView?.mGraphicView)
  }

  //····················································································································

  @objc func selectAllTracksOfBackLayerAction (_ inSender : Any?) {
    self.rootObject.displayBackLayoutForBoard_property.setProp (true)
    var newSelection = [BoardObject] ()
    for object in self.rootObject.mBoardObjects.values {
      if let track = object as? BoardTrack {
        if track.mSide == .back {
          newSelection.append (track)
        }
      }
    }
    self.boardObjectsController.setSelection (newSelection)
    _ = self.windowForSheet?.makeFirstResponder (self.mBoardView?.mGraphicView)
  }

  //····················································································································

  @objc func selectAllTracksOfInner1LayerAction (_ inSender : Any?) {
    self.rootObject.displayInner1LayoutForBoard_property.setProp (true)
    var newSelection = [BoardObject] ()
    for object in self.rootObject.mBoardObjects.values {
      if let track = object as? BoardTrack {
        if track.mSide == .inner1 {
          newSelection.append (track)
        }
      }
    }
    self.boardObjectsController.setSelection (newSelection)
    _ = self.windowForSheet?.makeFirstResponder (self.mBoardView?.mGraphicView)
  }

  //····················································································································

  @objc func selectAllTracksOfInner2LayerAction (_ inSender : Any?) {
    self.rootObject.displayInner2LayoutForBoard_property.setProp (true)
    var newSelection = [BoardObject] ()
    for object in self.rootObject.mBoardObjects.values {
      if let track = object as? BoardTrack {
        if track.mSide == .inner2 {
          newSelection.append (track)
        }
      }
    }
    self.boardObjectsController.setSelection (newSelection)
    _ = self.windowForSheet?.makeFirstResponder (self.mBoardView?.mGraphicView)
  }

  //····················································································································

  @objc func selectAllTracksOfInner3LayerAction (_ inSender : Any?) {
    self.rootObject.displayInner3LayoutForBoard_property.setProp (true)
    var newSelection = [BoardObject] ()
    for object in self.rootObject.mBoardObjects.values {
      if let track = object as? BoardTrack {
        if track.mSide == .inner3 {
          newSelection.append (track)
        }
      }
    }
    self.boardObjectsController.setSelection (newSelection)
    _ = self.windowForSheet?.makeFirstResponder (self.mBoardView?.mGraphicView)
  }

  //····················································································································

  @objc func selectAllTracksOfInner4LayerAction (_ inSender : Any?) {
    self.rootObject.displayInner4LayoutForBoard_property.setProp (true)
    var newSelection = [BoardObject] ()
    for object in self.rootObject.mBoardObjects.values {
      if let track = object as? BoardTrack {
        if track.mSide == .inner4 {
          newSelection.append (track)
        }
      }
    }
    self.boardObjectsController.setSelection (newSelection)
    _ = self.windowForSheet?.makeFirstResponder (self.mBoardView?.mGraphicView)
  }

  //····················································································································

  @objc func selectAllTracksOfVisibleLayersAction (_ inSender : Any?) {
    var newSelection = [BoardObject] ()
    for object in self.rootObject.mBoardObjects.values {
      if let track = object as? BoardTrack {
        let isVisible : Bool
        switch track.mSide {
        case .front :
          isVisible = self.rootObject.displayFrontLayoutForBoard_property.propval
        case .inner1 :
          isVisible = self.rootObject.displayInner1LayoutForBoard_property.propval
        case .inner2 :
          isVisible = self.rootObject.displayInner2LayoutForBoard_property.propval
        case .inner3 :
          isVisible = self.rootObject.displayInner3LayoutForBoard_property.propval
        case .inner4 :
          isVisible = self.rootObject.displayInner4LayoutForBoard_property.propval
        case .back :
          isVisible = self.rootObject.displayBackLayoutForBoard_property.propval
        }
        if isVisible {
          newSelection.append (track)
        }
      }
    }
    self.boardObjectsController.setSelection (newSelection)
    _ = self.windowForSheet?.makeFirstResponder (self.mBoardView?.mGraphicView)
  }

  //····················································································································

  @objc func selectAllViasAction (_ inSender : Any?) {
    var newSelection = [BoardObject] ()
    for object in self.rootObject.mBoardObjects.values {
      if let connector = object as? BoardConnector, let isVia = connector.isVia, isVia {
        newSelection.append (connector)
      }
    }
    self.boardObjectsController.setSelection (newSelection)
    _ = self.windowForSheet?.makeFirstResponder (self.mBoardView?.mGraphicView)
  }

  //····················································································································

  @objc func selectAllRestrictRectanglesAction (_ inSender : Any?) {
    var newSelection = [BoardObject] ()
    for object in self.rootObject.mBoardObjects.values {
      if let brr = object as? BoardRestrictRectangle {
        newSelection.append (brr)
      }
    }
    self.boardObjectsController.setSelection (newSelection)
    _ = self.windowForSheet?.makeFirstResponder (self.mBoardView?.mGraphicView)
  }

  //····················································································································

  @objc func selectAllTracksOfSelectedTracksNetsAction (_ inSender : Any?) {
    var netSet = EBReferenceSet <NetInProject> ()
    for object in self.boardObjectsController.selectedArray.values {
      if let track = object as? BoardTrack, let net = track.mNet {
        netSet.insert (net)
      }
    }
    var newSelectedObjects = [BoardObject] ()
    for object in self.rootObject.mBoardObjects.values {
      if let track = object as? BoardTrack, let net = track.mNet, netSet.contains (net) {
        newSelectedObjects.append (object)
      }
    }
    self.boardObjectsController.addToSelection (objects: newSelectedObjects)
    _ = self.windowForSheet?.makeFirstResponder (self.mBoardView?.mGraphicView)
  }

  //····················································································································

  @objc func renameComponentsLeftToRightUpwardsAction (_ inSender : Any?) {
    self.renameComponents (by: compareLefToRightUpwardsComponentLocation)
  }

  //····················································································································

  @objc func renameComponentsLeftToRightDownwardsAction (_ inSender : Any?) {
    self.renameComponents (by: compareLefToRightDownwardsComponentLocation)
  }
  //····················································································································

  fileprivate func renameComponents (by inSortFunction : (CenterAndComponent, CenterAndComponent) -> Bool) {
    var componentLocationArray = [CenterAndComponent] ()
    for component in self.rootObject.mComponents.values {
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

  @objc func addComponentToSelection (_ inSender : NSMenuItem) {
     var objectsToSelect = [BoardObject] ()
     for component in self.rootObject.mComponents.values {
       if let componentName = component.componentName, componentName == inSender.title {
         objectsToSelect.append (component)
       }
     }
     self.boardObjectsController.addToSelection (objects: objectsToSelect)
     _ = self.windowForSheet?.makeFirstResponder (self.mBoardView?.mGraphicView)
  }

  //····················································································································

  @objc func addTracksToSelection (_ inSender : NSMenuItem) {
    var objectsToSelect = [BoardObject] ()
    for object in self.rootObject.mBoardObjects.values {
      if let track = object as? BoardTrack, let net = track.mNet, net.mNetName == inSender.title {
        objectsToSelect.append (object)
      }
    }
    self.boardObjectsController.addToSelection (objects: objectsToSelect)
    _ = self.windowForSheet?.makeFirstResponder (self.mBoardView?.mGraphicView)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————

struct CenterAndComponent {
  let center : NSPoint
  let component : ComponentInProject
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

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


//——————————————————————————————————————————————————————————————————————————————————————————————————

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

//——————————————————————————————————————————————————————————————————————————————————————————————————

