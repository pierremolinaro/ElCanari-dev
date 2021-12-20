import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class CanariEnumSegmentedControl : NSSegmentedControl, EBUserClassNameProtocol {

  //····················································································································
  //  init
  //····················································································································

  required init? (coder : NSCoder) {
    super.init (coder:coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame : NSRect) {
    super.init (frame: frame)
    noteObjectAllocation (self)
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  //  sendAction
  //····················································································································

  override func sendAction (_ inAction : Selector?, to target : Any?) -> Bool {
    self.mController?.updateModel (self)
    return super.sendAction (inAction, to: target)
  }

  //····················································································································
  //    binding
  //····················································································································

  fileprivate func updateSelectedSegment (_ object : EBReadObservableEnumProtocol) {
    self.selectedSegment = object.rawValue () ?? 0
  }

  //····················································································································

  private var mController : Controller_CanariEnumSegmentedControl_selectedSegment? = nil

  //····················································································································

  final func bind_selectedSegment (_ object : EBReadWriteObservableEnumProtocol) {
    self.mController = Controller_CanariEnumSegmentedControl_selectedSegment (object:object, outlet:self)
  }

  //····················································································································

  final func unbind_selectedSegment () {
    self.mController?.unregister ()
    self.mController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariEnumSegmentedControl_selectedSegment
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariEnumSegmentedControl_selectedSegment : EBObservablePropertyController {

  private let mObject : EBReadWriteObservableEnumProtocol
  private let mOutlet : CanariEnumSegmentedControl

  //····················································································································

  init (object : EBReadWriteObservableEnumProtocol, outlet : CanariEnumSegmentedControl) {
    mObject = object
    mOutlet = outlet
    super.init (observedObjects:[object], callBack: { outlet.updateSelectedSegment (object) })
  }

  //····················································································································

  func updateModel (_ sender : CanariEnumSegmentedControl) {
    self.mObject.setFrom (rawValue: self.mOutlet.selectedSegment)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
