//--------------------------------------------------------------------------------------------------
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//   EBEnumPreferenceProperty <T>
//--------------------------------------------------------------------------------------------------

final class EBEnumPreferenceProperty <T : EBEnumPropertyProtocol> : EBObservableMutableProperty <T>, EBEnumReadWriteObservableProtocol {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mPreferenceKey : String

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (defaultValue inValue : T, prefKey inPreferenceKey : String) {
    self.mPreferenceKey = inPreferenceKey
    self.mValue = inValue
    super.init ()
  //--- Read from preferences
    let possibleValue = UserDefaults.standard.object (forKey: inPreferenceKey)
    if let object = possibleValue as? NSObject {
      let value = T.convertFromNSObject (object: object)
      self.setProp (value)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Value
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mValue : T

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var propval : T { return self.mValue }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var selection : EBSelection <T> { return .single (self.propval) }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func setProp (_ inValue : T) {
    if self.mValue != inValue {
      self.mValue = inValue
      self.currentObjectDidChange ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func currentObjectDidChange () {
    UserDefaults.standard.set (self.propval.convertToNSObject (), forKey: self.mPreferenceKey)
    super.currentObjectDidChange ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func setFrom (rawValue inValue : Int) {
    if let e = T (rawValue: inValue) {
      self.setProp (e)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var rawSelection: EBSelection<Int> { self.mValue.rawValue.selection }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

