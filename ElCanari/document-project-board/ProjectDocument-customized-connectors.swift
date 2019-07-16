//
//  ProjectDocument-customized-connectors.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/07/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedProjectDocument {

  //····················································································································

  internal func connectors (at inLocation : CanariPoint, side inSide : TrackSide) -> [BoardConnector] {
    let distance = Double (milsToCanariUnit (Int (self.rootObject.mControlKeyHiliteDiameter))) / 2.0
    let squareOfDistance = distance * distance
    var result = [BoardConnector] ()
    for object in self.rootObject.mBoardObjects {
      if let connector = object as? BoardConnector {
        var ok = CanariPoint.squareOfDistance (connector.location!, inLocation) < squareOfDistance
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

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
