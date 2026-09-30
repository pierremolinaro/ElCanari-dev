//
//  AutoLayoutCanariObservedDimensionField.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/02/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------
//   AutoLayoutCanariObservedDimensionField
//--------------------------------------------------------------------------------------------------

final class AutoLayoutCanariObservedDimensionField : ALB_NSTextField {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (size inSize : EBControlSize) {
    super.init (optionalWidth: nil, bold: true, size: inSize.cocoaControlSize)

    self.alignment = .center
    self.isEditable = false
    self.drawsBackground = false
    self.isBezeled = false
    self.isBordered = false
    self.usesSingleLineMode = false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var intrinsicContentSize : NSSize {
    return NSSize (width: 56.0, height: NSView.noIntrinsicMetric)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  value binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func updateOutlet (dimension : EBObservableProperty <CanariLength>, unit : EBObservableProperty <CanariLengthUnit>) {
    switch combine (dimension.selection, unit: unit.selection) {
    case .empty :
      self.placeholderString = "No Selection"
      self.stringValue = ""
      self.enable (fromValueBinding: false, self.enabledBindingController ())
    case .multiple :
      self.placeholderString = "Multiple Selection"
      self.stringValue = ""
      self.enable (fromValueBinding: true, self.enabledBindingController ())
    case .single (let propertyValue) :
      self.placeholderString = nil
      self.doubleValue = propertyValue
      self.enable (fromValueBinding: true, self.enabledBindingController ())
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mController : Controller_AutoLayoutCanariObservedDimensionField_dimensionAndUnit? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_dimensionAndUnit (_ object : EBObservableProperty <CanariLength>,
                                    _ unit : EBObservableProperty <CanariLengthUnit>) -> Self {
    self.mController = Controller_AutoLayoutCanariObservedDimensionField_dimensionAndUnit (dimension: object, unit: unit, outlet: self)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//   Controller Controller_AutoLayoutCanariObservedDimensionField_dimensionAndUnit
//--------------------------------------------------------------------------------------------------

private final class Controller_AutoLayoutCanariObservedDimensionField_dimensionAndUnit : EBObservablePropertyController {

  private var mDimension : EBObservableProperty <CanariLength>
  private var mUnit : EBObservableProperty <CanariLengthUnit>

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (dimension : EBObservableProperty <CanariLength>,
        unit : EBObservableProperty <CanariLengthUnit>,
        outlet inOutlet : AutoLayoutCanariObservedDimensionField) {
    self.mDimension = dimension
    self.mUnit = unit
    super.init (
      observedObjects: [dimension, unit],
      callBack: { [weak inOutlet] in inOutlet?.updateOutlet (dimension: dimension, unit: unit) }
    )
  //--- Number formatter
    let numberFormatter = NumberFormatter ()
    numberFormatter.formatterBehavior = .behavior10_4
    numberFormatter.numberStyle = .decimal
    numberFormatter.localizesFormat = true
    numberFormatter.minimumFractionDigits = 2
    numberFormatter.maximumFractionDigits = 2
    numberFormatter.isLenient = true
    inOutlet.formatter = numberFormatter
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

private func combine (_ dimension : EBSelection <CanariLength>, unit : EBSelection <CanariLengthUnit>) -> EBSelection <Double> {
  switch dimension {
  case .empty :
    return .empty
  case .multiple :
    switch dimension {
    case .empty :
      return .empty
    case .multiple, .single :
      return .multiple
    }
  case .single (let dimensionValue) :
    switch unit {
    case .empty :
      return .empty
    case .multiple :
      return .multiple
    case .single (let unitValue):
      return .single (Double (dimensionValue.cuValue) / Double (unitValue.cuValue))
    }
  }
}

//--------------------------------------------------------------------------------------------------
