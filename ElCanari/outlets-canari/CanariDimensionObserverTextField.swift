//
//  CanariDimensionObserverTextField.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 02/07/2018.
//
//
import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariDimensionObserverTextField
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CanariDimensionObserverTextField) // Required for an outlet
class CanariDimensionObserverTextField : NSTextField, EBUserClassNameProtocol, NSTextFieldDelegate {

  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder:coder)
    self.delegate = self
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame:NSRect) {
    super.init (frame:frame)
    self.delegate = self
    noteObjectAllocation (self)
  }
  
  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  //  value binding
  //····················································································································

  private var mController : Controller_CanariDimensionObserverTextField_dimensionAndUnit?

  func bind_dimensionAndUnit (_ object:EBReadOnlyProperty_Int,
                              _ unit:EBReadOnlyProperty_Int,
                              file:String, line:Int) {
    mController = Controller_CanariDimensionObserverTextField_dimensionAndUnit (dimension:object, unit:unit, outlet:self, file:file, line:line)
  }

  func unbind_dimensionAndUnit () {
    mController?.unregister ()
    mController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller Controller_CanariDimensionObserverTextField_dimensionAndUnit
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(Controller_CanariDimensionObserverTextField_dimensionAndUnit)
final class Controller_CanariDimensionObserverTextField_dimensionAndUnit : EBSimpleController {

  private var mOutlet: CanariDimensionObserverTextField
  private var mDimension : EBReadOnlyProperty_Int
  private var mUnit : EBReadOnlyProperty_Int

  //····················································································································

  init (dimension:EBReadOnlyProperty_Int,
        unit:EBReadOnlyProperty_Int,
        outlet : CanariDimensionObserverTextField,
        file : String, line : Int) {
    mDimension = dimension
    mUnit = unit
    mOutlet = outlet
    super.init (observedObjects:[dimension, unit])
    if self.mOutlet.formatter == nil {
      presentErrorWindow (file: file, line: line, errorMessage: "the CanariDimensionObserverTextField outlet has no formatter")
    }
    self.eventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································

  private func updateOutlet () {
    switch combine (self.mDimension.prop, unit: self.mUnit.prop) {
    case .empty :
      self.mOutlet.stringValue = "—"
      self.mOutlet.enableFromValueBinding (false)
    case .multiple :
      self.mOutlet.stringValue = "—"
      self.mOutlet.enableFromValueBinding (false)
    case .single (let propertyValue) :
      self.mOutlet.doubleValue = propertyValue
      self.mOutlet.enableFromValueBinding (true)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func combine (_ dimension : EBSelection <Int>, unit : EBSelection <Int>) -> EBSelection <Double> {
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
      return .single (Double (dimensionValue) / Double (unitValue))
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
