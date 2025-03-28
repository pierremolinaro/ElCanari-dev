//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_ProjectRoot_unplacedPackages (
       _ self_mComponents : [AnyObject],                
       _ self_mComponents_componentName : [any ComponentInProject_componentName],
       _ self_mComponents_mComponentValue : [any ComponentInProject_mComponentValue],
       _ self_mComponents_componentIsPlacedInBoard : [any ComponentInProject_componentIsPlacedInBoard]
) -> StringTagArray {
//--- START OF USER ZONE 2
        var result = StringTagArray ()
        var idx = 0
        while idx < self_mComponents.count {
          if !self_mComponents_componentIsPlacedInBoard [idx].componentIsPlacedInBoard! {
            var title = self_mComponents_componentName [idx].componentName!
            let value = self_mComponents_mComponentValue [idx].mComponentValue
            if value != "" {
              title += " (" + value + ")"
            }
            let tag = objectIntIdentifier (self_mComponents [idx])
            let st = StringTag (string: title, tag: tag)
            result.append (st)
          }
          idx += 1
        }
        return result
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
