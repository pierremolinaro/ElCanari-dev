//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EBObservableMutableProperty <T> (abstract class)
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class EBObservableMutableProperty <T> : EBObservableProperty <T> {

  //····················································································································

  func setProp (_ value : T) { } // Abstract method

  //····················································································································

  func validateAndSetProp (_ inCandidateValue : T, windowForSheet inWindow : NSWindow?) -> Bool {
    return false
  } // Abstract method

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————