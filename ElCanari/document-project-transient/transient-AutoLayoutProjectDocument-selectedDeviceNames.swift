//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_AutoLayoutProjectDocument_selectedDeviceNames (
       _ self_projectDeviceController_selectedArray_all_symbolAndTypesNames : [any DeviceInProject_symbolAndTypesNames]
) -> StringArray {
//--- START OF USER ZONE 2
        var result = Set <String> ()
        if self_projectDeviceController_selectedArray_all_symbolAndTypesNames.count == 1 {
          if let a = self_projectDeviceController_selectedArray_all_symbolAndTypesNames [0].symbolAndTypesNames {
            for symbolDescriptor in a {
              result.insert (symbolDescriptor.symbolTypeName)
            }
          }
        }
        return Array (result)
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
