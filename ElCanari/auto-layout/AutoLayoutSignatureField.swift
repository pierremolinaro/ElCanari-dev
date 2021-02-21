//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class AutoLayoutSignatureField : NSTextField, EBUserClassNameProtocol {

  //····················································································································

  init () {
    super.init (frame: NSRect (x: 0, y: 14, width: 83, height: 19))  // Required by ElCapitan
//    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false
    self.isEditable = false
    self.drawsBackground = false
    self.isBordered = false
    self.font = NSFont.userFixedPitchFont (ofSize: NSFont.systemFontSize)
    self.controlSize = .small
    self.alignment = .center
  }

  //····················································································································

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  override var intrinsicContentSize : NSSize {  // Required by ElCapitan
    return NSSize (width: 83, height: 19)
  }

  //····················································································································

  override func ebCleanUp () {
    self.mController?.unregister ()
    self.mController = nil
    super.ebCleanUp ()
  }

  //····················································································································
  //  $signature binding
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

  private func update (from model : EBReadOnlyProperty_UInt32) {
    switch model.selection {
    case .empty, .multiple :
      self.stringValue = "—"
    case .single (let v) :
      self.stringValue = String (format: "%04X:%04X", v >> 16, v & 0xFFFF)
//      Swift.print ("Signature Display -- \(self.stringValue)")
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
