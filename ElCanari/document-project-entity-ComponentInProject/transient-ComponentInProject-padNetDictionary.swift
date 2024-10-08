//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_ComponentInProject_padNetDictionary (
       _ self_mSymbols_symbolInfo : [any ComponentSymbolInProject_symbolInfo]
) -> PadNetDictionary {
//--- START OF USER ZONE 2
        var padNetDictionary = PadNetDictionary () // Pad name, net net name
        for symbol in self_mSymbols_symbolInfo {
          if let symbolInfo = symbol.symbolInfo {
            for pin in symbolInfo.pins {
              if pin.netName != "" {
                padNetDictionary [pin.padName] = pin.netName
              }
            }
          }
        }
        return padNetDictionary
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
