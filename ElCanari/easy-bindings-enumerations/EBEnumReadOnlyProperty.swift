//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EBReadOnlyEnumProperty <T>
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class EBReadOnlyEnumProperty <T : EBEnumProtocol> : EBObservableProperty <T>, EBEnumReadObservableProtocol where T : Equatable {

  //····················································································································

  final func rawValue () -> Int? {
    switch self.selection {
    case .empty, .multiple :
      return nil
    case .single (let v) :
      return v.rawValue
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————