import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   CanariDimensionTextField
//----------------------------------------------------------------------------------------------------------------------

class CanariDimensionTextField : NSTextField, EBUserClassNameProtocol, NSTextFieldDelegate {

  //····················································································································

  required init? (coder : NSCoder) {
    super.init (coder: coder)
    self.delegate = self
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame : NSRect) {
    super.init (frame: frame)
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

  fileprivate func updateOutlet (dimension : EBReadOnlyProperty_Int, unit : EBReadOnlyProperty_Int) {
    switch combine (dimension.prop, unit: unit.prop) {
    case .empty :
      self.stringValue = "—"
      self.enableFromValueBinding (false)
    case .multiple :
      self.stringValue = "multiple"
      self.enableFromValueBinding (true)
    case .single (let propertyValue) :
      self.doubleValue = propertyValue
      self.enableFromValueBinding (true)
    }
  }

  //····················································································································

  private var mController : Controller_CanariDimensionTextField_dimensionAndUnit?

  //····················································································································

  func bind_dimensionAndUnit (_ object:EBReadWriteProperty_Int,
                              _ unit:EBReadOnlyProperty_Int,
                              file:String, line:Int) {
    self.mController = Controller_CanariDimensionTextField_dimensionAndUnit (dimension:object, unit:unit, outlet:self, file:file, line:line)
  }

  //····················································································································

  func unbind_dimensionAndUnit () {
    self.mController?.unregister ()
    self.mController = nil
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
//   Controller Controller_CanariDimensionTextField_dimensionAndUnit
//----------------------------------------------------------------------------------------------------------------------

final class Controller_CanariDimensionTextField_dimensionAndUnit : EBSimpleController {

  private var mOutlet: CanariDimensionTextField
  private var mDimension : EBReadWriteProperty_Int
  private var mUnit : EBReadOnlyProperty_Int

  //····················································································································

  init (dimension : EBReadWriteProperty_Int,
        unit : EBReadOnlyProperty_Int,
        outlet : CanariDimensionTextField,
        file : String,
        line : Int) {
    mDimension = dimension
    mUnit = unit
    mOutlet = outlet
    super.init (
      observedObjects:[dimension, unit],
      callBack: { outlet.updateOutlet (dimension: dimension, unit: unit) }
    )
  //--- Target
    self.mOutlet.target = self
    self.mOutlet.action = #selector(Controller_CanariDimensionTextField_dimensionAndUnit.action(_:))
  //--- Number formatter
    let numberFormatter = NumberFormatter ()
    numberFormatter.formatterBehavior = .behavior10_4
    numberFormatter.numberStyle = .decimal
    numberFormatter.localizesFormat = true
    numberFormatter.minimumFractionDigits = 2
    numberFormatter.maximumFractionDigits = 2
    numberFormatter.isLenient = true
    self.mOutlet.formatter = numberFormatter
  }

  //····················································································································
  
  override func unregister () {
    super.unregister ()
    self.mOutlet.target = nil
    self.mOutlet.action = nil
  }

  //····················································································································

  @objc func action (_ sender : CanariDimensionTextField) {
    switch self.mUnit.prop {
    case .empty, .multiple :
      break
    case .single (let unit) :
      if let formatter = self.mOutlet.formatter as? NumberFormatter, let outletValueNumber = formatter.number (from: self.mOutlet.stringValue) {
        let value = Int ((outletValueNumber.doubleValue * Double (unit)).rounded ())
        _ = self.mDimension.validateAndSetProp (value, windowForSheet: sender.window)
      }else{
        __NSBeep ()
      }
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------

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

//----------------------------------------------------------------------------------------------------------------------
