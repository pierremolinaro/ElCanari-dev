//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func transient_MergerRoot_boardDisplayRect (
       _ self_boardManualWidth : Int,       
       _ self_boardManualHeight : Int,      
       _ self_boardInstances_instanceRect : [MergerBoardInstance_instanceRect]
) -> CanariHorizontalRect {
//--- START OF USER ZONE 2
  //--- All instance rect
    var r = CanariHorizontalRect () // Empty rect
    for board in self_boardInstances_instanceRect {
      if let rect = board.instanceRect {
        r = r.union (rect)
      }
    }
  //--- Add manual size
    let manualBoardRect = CanariHorizontalRect (left:0, bottom:0, width: self_boardManualWidth, height: self_boardManualHeight)
    r = r.union (manualBoardRect)
  //---
    return r
//--- END OF USER ZONE 2
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————