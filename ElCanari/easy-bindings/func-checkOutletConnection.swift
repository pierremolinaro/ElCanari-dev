//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   checkOutletConnection
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func checkOutletConnection (_ inOutlet : NSObject?,
                                       _ inOutletName : String,
                                       _ inOutletType : NSObject.Type,
                                       _ inFile : String,
                                       _ inLine : Int) {
  if let outlet : NSObject = inOutlet {
    if !(outlet.isKind (of: inOutletType.self)) {
      presentErrorWindow (inFile, inLine, "the '\(inOutletName)' outlet is not an instance of '\(inOutletType.self)'")
    }
  }else{
    presentErrorWindow (inFile, inLine, "the '\(inOutletName)' outlet is nil")
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————