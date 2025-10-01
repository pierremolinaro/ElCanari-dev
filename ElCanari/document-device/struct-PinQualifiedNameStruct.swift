//
//  struct-PinQualifiedNameStruct.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 09/04/2019.
//

import Foundation

//--------------------------------------------------------------------------------------------------
//   PinQualifiedNameStruct
//--------------------------------------------------------------------------------------------------

struct PinQualifiedNameStruct : Hashable, CustomStringConvertible {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let mSymbolName : String
  let mPinName : String

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (symbolName inSymbolName : String, pinName inPinName : String) {
    self.mSymbolName = inSymbolName
    self.mPinName = inPinName
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var description : String {
    return "symbolName \(self.mSymbolName) pinName \(self.mPinName)"
  }

}

//--------------------------------------------------------------------------------------------------
