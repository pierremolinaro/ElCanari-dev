//
//  ProjectDocument-mouse-moved-flags-changed.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/09/2020.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

extension CustomizedProjectDocument {

  //····················································································································

  internal func mouseMovedOrFlagsChangedInBoard (_ inUnalignedMouseLocation : NSPoint) {
    var shape : EBShape? = nil
    let newTrackSide : TrackSide = self.rootObject.mBoardSideForNewTrack
    let maxDistance = milsToCocoaUnit (CGFloat (self.rootObject.mControlKeyHiliteDiameter)) / 2.0
  //--- Option key ?
    if NSEvent.modifierFlags.contains (.option) {
      let connectorsUnderMouse = self.rootObject.connectors (at: inUnalignedMouseLocation.canariPoint, trackSide: newTrackSide)
      if connectorsUnderMouse.count == 1 {
        let connectorUnderMouse = connectorsUnderMouse [0]
        if let netName = connectorUnderMouse.netNameFromComponentPad {
          let connectedConnectors = self.findAllConnectorsConnectedTo (connectorUnderMouse, trackSide: newTrackSide)
          for object in self.rootObject.mBoardObjects {
            if let connector = object as? BoardConnector,
                  !connectedConnectors.contains (connector),
                  connector.netNameFromComponentPad == netName {
              let bp = connector.bezierPathForHilitingOnOptionFlag (trackSide: newTrackSide)
              if shape == nil {
                shape = EBShape ()
              }
              shape?.add (filled: [bp], NSColor.white)
            }
          }
        }
      }
    }
  //--- Control key ?
    if NSEvent.modifierFlags.contains (.control), maxDistance > 0.0, let boardView = self.mBoardView {
      if boardView.frame.contains (inUnalignedMouseLocation) {
        let r = NSRect (
          x: inUnalignedMouseLocation.x - maxDistance,
          y: inUnalignedMouseLocation.y - maxDistance,
          width: maxDistance * 2.0,
          height: maxDistance * 2.0
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
    self.mBoardView?.mOptionalFrontShape = shape
  }

  //····················································································································

  internal func findAllConnectorsConnectedTo (_ inConnector : BoardConnector,
                                              trackSide inTrackSide : TrackSide) -> [BoardConnector] {
    var connectorSet = Set ([inConnector])
    var exploreArray = [inConnector]
    while !exploreArray.isEmpty {
      let c = exploreArray.removeLast ()
      let tracks = c.mTracksP1 + c.mTracksP2
      for t in tracks {
        if let connector1 = t.mConnectorP1, !connectorSet.contains (connector1) {
          connectorSet.insert (connector1)
          exploreArray.append (connector1)
        }
        if let connector2 = t.mConnectorP2, !connectorSet.contains (connector2) {
          connectorSet.insert (connector2)
          exploreArray.append (connector2)
        }
      }
    }
//    Swift.print ("connectorSet \(connectorSet.count)")
    return Array (connectorSet)
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------

extension BoardConnector {

  //····················································································································

//  func bezierPathForHilitingOnOptionFlag (unalignedLocation inUnalignedLocation : NSPoint,
//                                          maxDistance inMaxDistance : CGFloat,
//                                          trackSide inTrackSide : TrackSide) -> EBBezierPath {
//    var bp = EBBezierPath ()
//    if let componentPadDictionary = self.mComponent?.componentPadDictionary,
//       let pad : ComponentPadDescriptor = componentPadDictionary [self.mComponentPadName] {
//       let connectorSide : ConnectorSide
//      switch inTrackSide {
//      case .front :
//        connectorSide = .front
//      case .back :
//        connectorSide = .back
//      }
//      for pad in pad.pads {
//        if (pad.side == .both) || (pad.side == connectorSide) {
//          let padLocation = pad.location
//          if NSPoint.distance (padLocation, inUnalignedLocation) <= inMaxDistance {
//            bp.append (pad.bp)
//          }
//        }
//      }
//    }
//    return bp
//  }

  //····················································································································

  func bezierPathForHilitingOnOptionFlag (trackSide inTrackSide : TrackSide) -> EBBezierPath {
    var bp = EBBezierPath ()
    if let componentPadDictionary = self.mComponent?.componentPadDictionary,
         let pad : ComponentPadDescriptor = componentPadDictionary [self.mComponentPadName] {
      let connectorSide : ConnectorSide
      switch inTrackSide {
      case .front :
        connectorSide = .front
      case .back :
        connectorSide = .back
      }
      for pad in pad.pads {
        if (pad.side == .both) || (pad.side == connectorSide) {
          bp.append (pad.bp)
        }
      }
    }
    return bp
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------

//extension TrackSide {
//
//  func sameSideAs (connector inOptionalConnector : BoardConnector) -> Bool {
//    if let connectorSide = inOptionalConnector.side {
//      switch connectorSide {
//      case .front :
//        return self == .front
//      case .back :
//        return self == .back
//      case .both :
//        return true
//      }
//    }else{
//      return false
//    }
//  }
//
//}

//----------------------------------------------------------------------------------------------------------------------
