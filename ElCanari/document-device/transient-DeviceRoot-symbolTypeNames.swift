//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_DeviceRoot_symbolTypeNames (
       _ self_mSymbolTypes_mTypeName : [any SymbolTypeInDevice_mTypeName]
) -> StringArray {
//--- START OF USER ZONE 2
       var array = [String] ()
       for t in self_mSymbolTypes_mTypeName {
         array.append (t.mTypeName)
       }
       return array
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
