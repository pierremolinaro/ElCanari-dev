//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_BoardConnector_netNameAndPadLocation (
       _ self_mComponent_padNetDictionary : PadNetDictionary?,  
       _ self_mComponentPadName : String,                       
       _ self_location : CanariPoint,                           
       _ self_mComponent_componentName : String?
) -> RastnetInfoArray {
//--- START OF USER ZONE 2
       if let netName = self_mComponent_padNetDictionary? [self_mComponentPadName] {
        return [RastnetInfo (netName: netName, location: self_location, componentName: self_mComponent_componentName!)]
       }else{
         return []
       }

//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
