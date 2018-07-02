//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CanariVersionField) class CanariVersionField : NSTextField, EBUserClassNameProtocol {

  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder:coder)
    self.isEditable = false
    self.drawsBackground = false
    self.isBordered = false
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame:NSRect) {
    super.init (frame:frame)
    self.isEditable = false
    self.drawsBackground = false
    self.isBordered = false
    noteObjectAllocation (self)
  }
  
  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  //  version binding
  //····················································································································

  private var mVersionController : Controller_CanariVersionField_version?

  func bind_version (_ object:EBReadOnlyProperty_Int, file:String, line:Int) {
    mVersionController = Controller_CanariVersionField_version (
      object:object,
      outlet:self,
      file:file,
      line:line
    )
  }

  func unbind_version () {
    mVersionController?.unregister ()
    mVersionController = nil
  }

  //····················································································································
  //  versionShouldChange binding
  //····················································································································

  private var mVersionShouldChangeController : Controller_CanariVersionField_versionShouldChange?

  func bind_versionShouldChange (_ object:EBReadOnlyProperty_Bool, file:String, line:Int) {
    mVersionShouldChangeController = Controller_CanariVersionField_versionShouldChange (
      object:object,
      outlet:self,
      file:file,
      line:line
    )
  }

  func unbind_versionShouldChange () {
    mVersionShouldChangeController?.unregister ()
    mVersionShouldChangeController = nil
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariVersionField_version
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(Controller_CanariVersionField_version)
final class Controller_CanariVersionField_version : EBSimpleController {

  private let mObject : EBReadOnlyProperty_Int
  private let mOutlet : CanariVersionField

  //····················································································································

  init (object : EBReadOnlyProperty_Int, outlet : CanariVersionField, file : String, line : Int) {
    mObject = object
    mOutlet = outlet
    super.init (observedObjects:[object], outlet:outlet)
    if mOutlet.formatter != nil {
      presentErrorWindow (file: file, line:line, errorMessage:"the outlet has a formatter")
    }
  }

  //····················································································································

  override func sendUpdateEvent () {
    switch mObject.prop {
    case .empty :
      mOutlet.enableFromValueBinding (false)
      mOutlet.stringValue = "—"
    case .single (let v) :
      mOutlet.enableFromValueBinding (true)
      mOutlet.stringValue = String (v)
    case .multiple :
      mOutlet.enableFromValueBinding (false)
      mOutlet.stringValue = "—"
    }
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariVersionField_versionShouldChange
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(Controller_CanariVersionField_versionShouldChange)
final class Controller_CanariVersionField_versionShouldChange : EBSimpleController {

  private let mObject : EBReadOnlyProperty_Bool
  private let mOutlet : CanariVersionField

  //····················································································································

  init (object : EBReadOnlyProperty_Bool, outlet : CanariVersionField, file : String, line : Int) {
    mObject = object
    mOutlet = outlet
    super.init (observedObjects:[object], outlet:outlet)
    if mOutlet.formatter != nil {
      presentErrorWindow (file: file, line:line, errorMessage:"the outlet has a formatter")
    }
//    mObject.addEBObserver (self)
  }

  //····················································································································

  override func sendUpdateEvent () {
    switch mObject.prop {
    case .empty, .multiple :
      break
    case .single (let v) :
      mOutlet.textColor = v ? NSColor.red : NSColor.black
    }
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
