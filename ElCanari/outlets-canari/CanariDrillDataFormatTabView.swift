import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CanariDrillDataFormatTabView) class CanariDrillDataFormatTabView : NSTabView, EBUserClassNameProtocol {

  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder:coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame:NSRect) {
    super.init (frame:frame)
    noteObjectAllocation (self)
  }
  
  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  //    binding
  //····················································································································

  private var mController : Controller_CanariDrillDataFormatTabView_selectedFormat?

  func bind_selectedFormat (_ object:EBStoredProperty_DrillDataFormatEnum, file:String, line:Int) {
    mController = Controller_CanariDrillDataFormatTabView_selectedFormat (object:object, outlet:self, file:file, line:line)
  }

  func unbind_selectedFormat () {
    mController?.unregister ()
    mController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariDrillDataFormatTabView_selectedFormat
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(Controller_CanariDrillDataFormatTabView_selectedFormat)
final class Controller_CanariDrillDataFormatTabView_selectedFormat : EBSimpleController, NSTabViewDelegate {

  private let mObject : EBStoredProperty_DrillDataFormatEnum
  private let mOutlet : CanariDrillDataFormatTabView

  //····················································································································

  init (object : EBStoredProperty_DrillDataFormatEnum, outlet : CanariDrillDataFormatTabView, file : String, line : Int) {
    mObject = object
    mOutlet = outlet
    super.init (observedObjects:[object], outlet:outlet)
    outlet.delegate = self
  }

  //····················································································································
  
  override func unregister () {
    super.unregister ()
    mOutlet.delegate = nil
  }

  //····················································································································

  override func sendUpdateEvent () {
    switch mObject.prop {
    case .noSelection, .multipleSelection :
      break
    case .singleSelection (let v) :
      mOutlet.selectTabViewItem(at: v.rawValue)
    }
  }

  //····················································································································

  func tabView (_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) { // Delegate method
    if let unwSelectedTabViewItem = tabViewItem {
      let idx : Int = mOutlet.indexOfTabViewItem (unwSelectedTabViewItem)
      let possibleEnumValue : DrillDataFormatEnum? = DrillDataFormatEnum (rawValue: idx)
      if let enumValue = possibleEnumValue {
        mObject.setProp (enumValue)
      }
    }
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
