//
//  AutoLayoutDoubleObserverField.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 13/09/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutDoubleObserverField
//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutDoubleObserverField : ALB_NSTextField_enabled_hidden_bindings {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mNumberFormatter = NumberFormatter ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (width inWidth : Int, bold inBold : Bool, size inSize : EBControlSize) {
    super.init (optionalWidth: inWidth, bold: inBold, size: inSize.cocoaControlSize)

    self.isBezeled = false
    self.isBordered = false
    self.drawsBackground = false
    self.isEditable = false
  //--- Number formatter
    self.mNumberFormatter.formatterBehavior = .behavior10_4
    self.mNumberFormatter.numberStyle = .decimal
    self.mNumberFormatter.localizesFormat = true
    self.mNumberFormatter.minimumFractionDigits = 2
    self.mNumberFormatter.maximumFractionDigits = 2
    self.mNumberFormatter.isLenient = true
    self.formatter = self.mNumberFormatter
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //MARK:  $value binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mValueController : EBObservablePropertyController? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_observedValue (_ inObject : EBObservableProperty <Double>) -> Self {
    self.mValueController = EBObservablePropertyController (
      observedObjects: [inObject],
      callBack: { [weak self] in self?.update (from: inObject) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func update (from inObject : EBObservableProperty <Double>) {
    let selection = inObject.selection // TOUJOURS lire la sélection
    switch selection {
    case .empty :
//        Swift.print ("updateOutlet, empty")
      self.enable (fromValueBinding: false, self.enabledBindingController)
      self.placeholderString = "No Selection"
      self.stringValue = ""
    case .single (let v) :
//        Swift.print ("updateOutlet, single \(v)")
      self.enable (fromValueBinding: true, self.enabledBindingController)
      self.placeholderString = nil
      self.doubleValue = CGFloat (v)
    case .multiple :
//        Swift.print ("multiple, empty")
      self.enable (fromValueBinding: true, self.enabledBindingController)
      self.placeholderString = "Multiple Selection"
      self.stringValue = ""
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
