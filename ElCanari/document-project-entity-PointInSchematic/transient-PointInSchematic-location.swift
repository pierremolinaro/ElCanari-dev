//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_PointInSchematic_location (
       _ self_mX : Int,                              
       _ self_mY : Int,                              
       _ self_mSymbolPinName : String,               
       _ self_mSymbol_symbolInfo : ComponentSymbolInfo?,
       _ self_mSymbol_mSymbolInstanceName : String?
) -> CanariPoint {
//--- START OF USER ZONE 2
        if let symbolPins = self_mSymbol_symbolInfo?.pins, let symbolInstanceName = self_mSymbol_mSymbolInstanceName {
          for pin in symbolPins {
            if (pin.pinIdentifier.symbol.symbolInstanceName == symbolInstanceName) && (pin.pinIdentifier.pinName == self_mSymbolPinName) {
              return pin.pinLocation
            }
          }
          return CanariPoint (x: self_mX, y: self_mY)
        }else{
          return CanariPoint (x: self_mX, y: self_mY)
        }
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
