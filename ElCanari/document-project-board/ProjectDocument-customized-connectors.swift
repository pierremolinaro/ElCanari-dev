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
    var result = [BoardConnector] ()
    for object in self.rootObject.mBoardObjects {
      if let connector = object as? BoardConnector {
        var ok = connector.location! == inLocation
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
