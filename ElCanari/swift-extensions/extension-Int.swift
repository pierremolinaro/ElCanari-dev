//
//  extension-Int.swift
//  ElCanari-Debug
//
//  Created by Pierre Molinaro on 13/03/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension Int {

  //····················································································································

  var stringWithSeparators : String {
    let formatter = NumberFormatter ()
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = Locale.current.groupingSeparator
    return formatter.string (for: self) ?? "\(self)"
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func compare_Int_properties (_ inLeft : EBObservableProperty <Int>,
                                        _ inAscending : Bool,
                                        _ inRight : EBObservableProperty <Int>) -> ComparisonResult {
  let left  = inAscending ? inLeft  : inRight
  let right = inAscending ? inRight : inLeft
  switch left.selection {
  case .empty :
    switch right.selection {
    case .empty :
      return .orderedSame
    default:
      return .orderedAscending
    }
  case .multiple :
    switch right.selection {
    case .empty :
      return .orderedDescending
    case .multiple :
      return .orderedSame
   case .single (_) :
      return .orderedAscending
   }
 case .single (let currentValue) :
    switch right.selection {
    case .empty, .multiple :
      return .orderedDescending
    case .single (let otherValue) :
      if currentValue < otherValue {
        return .orderedAscending
      }else if currentValue > otherValue {
        return .orderedDescending
      }else{
        return .orderedSame
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————
