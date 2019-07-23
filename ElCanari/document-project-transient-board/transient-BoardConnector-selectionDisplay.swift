//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func transient_BoardConnector_selectionDisplay (
       _ self_connectedToComponent : Bool,      
       _ self_side : ConnectorSide,             
       _ self_location : CanariPoint
) -> EBShape {
//--- START OF USER ZONE 2
        var shape = EBShape ()
        if !self_connectedToComponent && (self_side == .both) {
          shape.add (knobAt: self_location.cocoaPoint, knobIndex: BOARD_CONNECTOR_KNOB, .rect, 2.0)
        }
        return shape
//--- END OF USER ZONE 2
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————