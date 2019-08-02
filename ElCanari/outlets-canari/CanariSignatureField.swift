//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariSignatureField : NSTextField, EBUserClassNameProtocol {

  //····················································································································

  required init? (coder : NSCoder) {
    super.init (coder: coder)
    self.isEditable = false
    self.drawsBackground = false
    self.isBordered = false
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame : NSRect) {
    super.init (frame: frame)
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

  private var mController : EBSimpleController? = nil

  //····················································································································

  func bind_signature (_ model : EBReadOnlyProperty_Int, file : String, line : Int) {
    self.mController = EBSimpleController (
      observedObjects: [model],
      callBack: { self.update (from: model) }
    )
  }

  //····················································································································

  func unbind_signature () {
    self.mController?.unregister ()
    self.mController = nil
  }

  //····················································································································

  private func update (from model : EBReadOnlyProperty_Int) {
    switch model.prop {
    case .empty :
      self.stringValue = "—"
    case .single (let v) :
      let uv = UInt32 (v)
      self.stringValue = String (format: "%04X:%04X", arguments: [uv >> 16, uv & 0xFFFF])
    case .multiple :
      self.stringValue = "—"
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
