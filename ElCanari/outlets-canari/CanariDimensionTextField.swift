import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariDimensionTextField                                                                                          *
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CanariDimensionTextField) class CanariDimensionTextField : NSTextField, EBUserClassNameProtocol, NSTextFieldDelegate {

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
  //  value binding                                                                                                    *
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

  override func controlTextDidChange (_ inNotification : Notification) {
/*    if mSendContinously {
      NSApp.sendAction (self.action, to: self.target, from: self)
    }*/
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller Controller_CanariDimensionTextField_dimensionAndUnit                                                   *
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
    super.init (observedObjects:[dimension, unit], outlet:outlet)
    mOutlet.target = self
    mOutlet.action = #selector(Controller_CanariDimensionTextField_dimensionAndUnit.action(_:))
    if mOutlet.formatter == nil {
      presentErrorWindow (file: file, line: line, errorMessage: "the CanariDimensionTextField outlet has no formatter")
    }
//    dimension.addEBObserver (self)
//    unit.addEBObserver (self)
  }

  //····················································································································
  
  override func unregister () {
    super.unregister ()
    mOutlet.target = nil
    mOutlet.action = nil
//    mDimension.removeEBObserver (self)
//    mUnit.removeEBObserver (self)
    mOutlet.removeFromEnabledFromValueDictionary ()
  }

  //····················································································································

  override func sendUpdateEvent () {
    switch combine (mDimension.prop, unit:mUnit.prop) {
    case .noSelection :
      mOutlet.stringValue = "—"
      mOutlet.enableFromValue (false)
    case .multipleSelection :
      mOutlet.stringValue = "—"
      mOutlet.enableFromValue (false)
    case .singleSelection (let propertyValue) :
      mOutlet.doubleValue = propertyValue
      mOutlet.enableFromValue (true)
    }
    mOutlet.updateEnabledState ()
  }

  //····················································································································

  func action (_ sender : CanariDimensionTextField) {
    switch mUnit.prop {
    case .noSelection, .multipleSelection :
      break
    case .singleSelection (let unit) :
      let value : Int = 90 * Int (round (mOutlet.doubleValue * Double (unit) / 90.0))
      _ = mDimension.validateAndSetProp (value, windowForSheet:sender.window)
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func combine (_ dimension : EBProperty <Int>, unit : EBProperty <Int>) -> EBProperty <Double> {
  switch dimension {
  case .noSelection :
    return .noSelection
  case .multipleSelection :
    switch dimension {
    case .noSelection :
      return .noSelection
    case .multipleSelection, .singleSelection :
      return .multipleSelection
    }
  case .singleSelection (let dimensionValue) :
    switch unit {
    case .noSelection :
      return .noSelection
    case .multipleSelection :
      return .multipleSelection
    case .singleSelection (let unitValue):
      return .singleSelection (Double (dimensionValue) / Double (unitValue))
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
