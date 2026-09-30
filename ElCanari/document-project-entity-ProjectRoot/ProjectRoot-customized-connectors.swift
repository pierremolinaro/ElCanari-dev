//
//  ProjectDocument-customized-connectors.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/07/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

extension ProjectRoot {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func connectors (at inLocation : CanariPoint, trackSide inSide : TrackSide) -> [BoardConnector] {
    let distance = CanariLength.mil (self.mControlKeyHiliteDiameter) / 2.0
    let squareOfDistance = distance * distance
    var result = [BoardConnector] ()
    for object in self.mBoardObjects.values {
      if let connector = object as? BoardConnector {
        var ok = inLocation.squareOfDistance (to: connector.location!) < squareOfDistance
        if ok {
          switch connector.side! {
          case .front :
            ok = inSide == .front
          case .back :
            ok = inSide == .back
          case .inner1 :
            ok = inSide == .inner1
          case .inner2 :
            ok = inSide == .inner2
          case .inner3 :
            ok = inSide == .inner3
          case .inner4 :
            ok = inSide == .inner4
          case .traversing :
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
