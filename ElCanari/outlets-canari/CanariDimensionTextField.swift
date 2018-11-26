import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariDimensionTextField
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CanariDimensionTextField) // Required for an outlet
class CanariDimensionTextField : NSTextField, EBUserClassNameProtocol, NSTextFieldDelegate {

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

  private var mController : Controller_CanariDimensionTextField_dimensionAndUnit?

  func bind_dimensionAndUnit (_ object:EBReadWriteProperty_Int,
                              _ unit:EBReadOnlyProperty_Int,
                              file:String, line:Int) {
    mController = Controller_CanariDimensionTextField_dimensionAndUnit (dimension:object, unit:unit, outlet:self, file:file, line:line)
  }

  func unbind_dimensionAndUnit () {
    mController?.unregister ()
    mController = nil
  }

  //····················································································································

  func controlTextDidChange (_ inNotification : Notification) {
/*    if mSendContinously {
      NSApp.sendAction (self.action, to: self.target, from: self)
    }*/
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller Controller_CanariDimensionTextField_dimensionAndUnit
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(Controller_CanariDimensionTextField_dimensionAndUnit)
final class Controller_CanariDimensionTextField_dimensionAndUnit : EBSimpleController {

  private var mOutlet: CanariDimensionTextField
  private var mDimension : EBReadWriteProperty_Int
  private var mUnit : EBReadOnlyProperty_Int

  //····················································································································

  init (dimension:EBReadWriteProperty_Int,
        unit:EBReadOnlyProperty_Int,
        outlet : CanariDimensionTextField,
        file : String, line : Int) {
    mDimension = dimension
    mUnit = unit
    mOutlet = outlet
    super.init (observedObjects:[dimension, unit])
    mOutlet.target = self
    mOutlet.action = #selector(Controller_CanariDimensionTextField_dimensionAndUnit.action(_:))
    if mOutlet.formatter == nil {
      presentErrorWindow (file: file, line: line, errorMessage: "the CanariDimensionTextField outlet has no formatter")
    }
    self.eventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································
  
  override func unregister () {
    super.unregister ()
    mOutlet.target = nil
    mOutlet.action = nil
  }

  //····················································································································

  private func updateOutlet () {
    switch combine (mDimension.prop, unit:mUnit.prop) {
    case .empty :
      mOutlet.stringValue = "—"
      mOutlet.enableFromValueBinding (false)
    case .multiple :
      mOutlet.stringValue = "—"
      mOutlet.enableFromValueBinding (false)
    case .single (let propertyValue) :
      mOutlet.doubleValue = propertyValue
      mOutlet.enableFromValueBinding (true)
    }
  }

  //····················································································································

  @objc func action (_ sender : CanariDimensionTextField) {
    switch mUnit.prop {
    case .empty, .multiple :
      break
    case .single (let unit) :
      let value : Int = 90 * Int (round (mOutlet.doubleValue * Double (unit) / 90.0))
      _ = mDimension.validateAndSetProp (value, windowForSheet:sender.window)
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
