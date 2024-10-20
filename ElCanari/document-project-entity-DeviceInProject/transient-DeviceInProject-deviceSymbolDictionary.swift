//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_DeviceInProject_deviceSymbolDictionary (
       _ self_mPadAssignments_descriptor : [any DevicePadAssignmentInProject_descriptor],
       _ self_mSymbols_symbolAndTypeName : [any DeviceSymbolInstanceInProject_symbolAndTypeName],
       _ self_mSymbols_filledBezierPath : [any DeviceSymbolInstanceInProject_filledBezierPath],
       _ self_mSymbols_strokeBezierPath : [any DeviceSymbolInstanceInProject_strokeBezierPath]
) -> DeviceSymbolDictionary {
//--- START OF USER ZONE 2
        var pinPadDescriptorArray = [PinPadAssignmentInProject] ()
        for d in self_mPadAssignments_descriptor {
          if let descriptor = d.descriptor {
            pinPadDescriptorArray.append (descriptor)
          }
        }
        var result = DeviceSymbolDictionary ()
        for idx in 0 ..< self_mSymbols_symbolAndTypeName.count {
          let symbolTypeAndName = self_mSymbols_symbolAndTypeName [idx].symbolAndTypeName!
        //--- Compute symbol center
          var minY = Int.max
          var maxY = Int.min
          var minX = Int.max
          var maxX = Int.min
          for descriptor in pinPadDescriptorArray {
            if let pin = descriptor.pin, pin.symbol == symbolTypeAndName {
              minX = min (minX, pin.pinXY.x)
              maxX = max (maxX, pin.pinXY.x)
              minY = min (minY, pin.pinXY.y)
              maxY = max (maxY, pin.pinXY.y)
            }
          }
          let center = CanariPoint (x: (minX + maxX) / 2, y: (minY + maxY) / 2)
          let filledBezierPath = self_mSymbols_filledBezierPath [idx].filledBezierPath!
          let strokeBezierPath = self_mSymbols_strokeBezierPath [idx].strokeBezierPath!
          result [symbolTypeAndName] = DeviceSymbolInfo (
            filledBezierPath: filledBezierPath,
            strokeBezierPath: strokeBezierPath,
            center: center,
            assignments: pinPadDescriptorArray
          )
        }
        return result
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
