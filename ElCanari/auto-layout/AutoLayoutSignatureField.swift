//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class AutoLayoutSignatureField : NSTextField, EBUserClassNameProtocol {

  //····················································································································

  init () {
    super.init (frame: NSRect ())
    self.isEditable = false
    self.drawsBackground = false
    self.isBordered = false
    self.font = NSFont.userFixedPitchFont (ofSize: NSFont.systemFontSize)
    noteObjectAllocation (self)
  }

  //····················································································································

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································
  //  signatureObserver binding
  //····················································································································

  private var mController : EBReadOnlyPropertyController? = nil

  //····················································································································

  func bind_signature (_ model : EBReadOnlyProperty_UInt32) -> Self {
    self.mController = EBReadOnlyPropertyController (
      observedObjects: [model],
      callBack: { [weak self] in self?.update (from: model) }
    )
    return self
  }

  //····················································································································

//  func unbind_signature () {
//    self.mController?.unregister ()
//    self.mController = nil
//  }

  //····················································································································

  private func update (from model : EBReadOnlyProperty_UInt32) {
    switch model.selection {
    case .empty :
      self.stringValue = "—"
    case .single (let v) :
      self.stringValue = String (format: "%04X:%04X", v >> 16, v & 0xFFFF)
//      Swift.print ("Signature Display -- \(self.stringValue)")
    case .multiple :
      self.stringValue = "—"
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
