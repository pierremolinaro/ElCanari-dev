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

struct PinQualifiedNameStruct : Hashable {
  let mSymbolName : String
  let mPinName : String

  init (symbolName inSymbolName : String, pinName inPinName : String) {
    mSymbolName = inSymbolName
    mPinName = inPinName
  }
}

//--------------------------------------------------------------------------------------------------
