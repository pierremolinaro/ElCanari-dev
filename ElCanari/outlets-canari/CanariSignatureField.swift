//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CanariSignatureField) class CanariSignatureField : NSTextField, EBUserClassNameProtocol {

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
  //  signatureObserver binding
  //····················································································································

  private var mController : Controller_CanariSignatureField_signature?

  func bind_signature (_ object:EBReadOnlyProperty_Int, file:String, line:Int) {
    mController = Controller_CanariSignatureField_signature (
      object:object,
      outlet:self,
      file:file,
      line:line
    )
  }

  func unbind_signature () {
    mController?.unregister ()
    mController = nil
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariSignatureField_signature
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(Controller_CanariSignatureField_signature)
final class Controller_CanariSignatureField_signature : EBSimpleController {

  private let mObject : EBReadOnlyProperty_Int
  private let mOutlet : CanariSignatureField

  //····················································································································

  init (object : EBReadOnlyProperty_Int, outlet : CanariSignatureField, file : String, line : Int) {
    mObject = object
    mOutlet = outlet
    super.init (observedObjects:[object], outlet:outlet)
    if mOutlet.formatter != nil {
      presentErrorWindow (file: file, line: line, errorMessage: "the outlet has a formatter")
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
      let uv = UInt32 (v)
      mOutlet.stringValue = String (format: "%04X:%04X", arguments: [uv >> 16, uv & 0xFFFF])
    case .multiple :
      mOutlet.enableFromValueBinding (false)
      mOutlet.stringValue = "—"
    }
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
