//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Scalar property String
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

typealias EBReadOnlyProperty_String    = EBObservableProperty <String>
typealias EBTransientProperty_String   = EBGenericTransientProperty <String>
typealias EBReadWriteProperty_String   = EBObservableMutableProperty <String>
typealias EBComputedProperty_String    = EBGenericComputedProperty <String>
typealias EBStoredProperty_String      = EBGenericStoredProperty <String>
typealias EBPreferencesProperty_String = EBGenericPreferenceProperty <String>

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func values_String_are_ordered (_ inLeft : String,
                                _ inAscending : Bool,
                                _ inRight : String) -> Bool {
  let left  = inAscending ? inLeft  : inRight
  let right = inAscending ? inRight : inLeft
  return left.localizedStandardCompare (right) == .orderedAscending
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func compare_String_properties (_ inLeft : EBReadOnlyProperty_String,
                                           _ inAscending : Bool,
                                           _ inRight : EBReadOnlyProperty_String) -> ComparisonResult {
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
      return currentValue.localizedStandardCompare (otherValue)
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————