//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class CanariSignatureField : NSTextField, EBUserClassNameProtocol {

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

  private var mController : EBReadOnlyPropertyController? = nil

  //····················································································································

  final func bind_signature (_ model : EBReadOnlyProperty_UInt32) {
    self.mController = EBReadOnlyPropertyController (
      observedObjects: [model],
      callBack: {
        self.update (from: model)
      }
    )
  }

  //····················································································································

  final func unbind_signature () {
    self.mController?.unregister ()
    self.mController = nil
  }

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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//class EBMySimpleController : EBReadOnlyPropertyController {
//
//  //····················································································································
//
//  override func postEvent () {
//    super.postEvent ()
//    Swift.print ("Signature Controller -- post event")
//  }
//
//  //····················································································································
//
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
