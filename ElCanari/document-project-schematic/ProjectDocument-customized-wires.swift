//
//  ProjectDocument-customized-wires.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 24/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedProjectDocument {

  //····················································································································
  // Remove unused wires
  //····················································································································

  internal func removeUnusedWires (_ ioErrorList : inout [String]) {
    for object in self.rootObject.mSelectedSheet!.mObjects {
      if let wire = object as? WireInSchematic {
        if (wire.mP1 == nil) && (wire.mP2 == nil) { // Useless wire, delete
          wire.mSheet = nil
        }else if (wire.mP1 == nil) != (wire.mP2 == nil) { // Invalid wire
          ioErrorList.append ("Invalid wire: mP1 \(string (wire.mP1)), mP2 \(string (wire.mP2))")
        }
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
