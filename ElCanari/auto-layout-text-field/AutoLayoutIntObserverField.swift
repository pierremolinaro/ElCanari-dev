//
//  AutoLayoutIntObserverField.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutIntObserverField
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutIntObserverField : AutoLayoutBase_NSTextField {

  //····················································································································

  private let mNumberFormatter = NumberFormatter ()

  //····················································································································

  init (bold inBold : Bool, size inSize : EBControlSize) {
    super.init (optionalWidth: nil, bold: inBold, size: inSize)

    self.isBezeled = false
    self.isBordered = false
    self.drawsBackground = false
    self.isEditable = false
//--- Number formatter
    self.mNumberFormatter.formatterBehavior = .behavior10_4
    self.mNumberFormatter.numberStyle = .decimal
    self.mNumberFormatter.localizesFormat = true
    self.mNumberFormatter.minimumFractionDigits = 0
    self.mNumberFormatter.maximumFractionDigits = 0
    self.mNumberFormatter.isLenient = true
    self.formatter = self.mNumberFormatter
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  final func set (format inFormatString : String) -> Self {
    self.mNumberFormatter.format = inFormatString
    return self
  }

  //····················································································································
  //  observedValue binding
  //····················································································································

  private var mController : EBObservablePropertyController? = nil

  //····················································································································

  final func bind_observedValue (_ inObject : EBObservableProperty <Int>) -> Self {
    self.mController = EBObservablePropertyController (
      observedObjects: [inObject],
      callBack:  { [weak self] in self?.update (from: inObject) }
    )
    return self
  }

  //····················································································································

  private func update (from model : EBObservableProperty <Int>) {
    switch model.selection {
    case .empty :
      self.enable (fromValueBinding: false, self.enabledBindingController)
      self.placeholderString = "—"
      self.stringValue = ""
    case .single (let v) :
      self.enable (fromValueBinding: true, self.enabledBindingController)
      self.placeholderString = nil
      self.intValue = Int32 (v)
    case .multiple :
      self.enable (fromValueBinding: false, self.enabledBindingController)
      self.placeholderString = "Multiple Selection"
      self.stringValue = ""
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
