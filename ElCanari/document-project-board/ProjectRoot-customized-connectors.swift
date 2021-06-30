//
//  ProjectDocument-customized-connectors.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/07/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ProjectRoot {

  //····················································································································

  internal func connectors (at inLocation : CanariPoint, trackSide inSide : TrackSide) -> [BoardConnector] {
    let distance = Double (milsToCanariUnit (fromDouble: self.mControlKeyHiliteDiameter)) / 2.0
    let squareOfDistance = distance * distance
    var result = [BoardConnector] ()
    for object in self.mBoardObjects {
      if let connector = object as? BoardConnector {
        var ok = CanariPoint.squareOfCanariDistance (connector.location!, inLocation) < squareOfDistance
        if ok {
          switch connector.side! {
          case .front :
            ok = inSide == .front
          case .back :
            ok = inSide == .back
          case .both :
            ()
          }
        }
        if ok {
          result.append (connector)
        }
      }
    }
    return result
  }

  //····················································································································

  internal func connectors (at inLocation : CanariPoint, connectorSide inSide : ConnectorSide) -> [BoardConnector] {
    let distance = Double (milsToCanariUnit (fromDouble: self.mControlKeyHiliteDiameter)) / 2.0
    let squareOfDistance = distance * distance
    var result = [BoardConnector] ()
    for object in self.mBoardObjects {
      if let connector = object as? BoardConnector {
        let ok = (connector.side! == inSide) && CanariPoint.squareOfCanariDistance (connector.location!, inLocation) < squareOfDistance
        if ok {
          result.append (connector)
        }
      }
    }
    return result
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
