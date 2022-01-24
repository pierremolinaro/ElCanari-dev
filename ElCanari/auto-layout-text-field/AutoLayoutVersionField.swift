//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutVersionField : AutoLayoutBase_NSTextField {

  //····················································································································

  init (size inSize : EBControlSize) {
    super.init (optionalWidth: nil, bold: false, size: inSize)

    self.isEditable = false
    self.isEnabled = true
    self.drawsBackground = false
    self.isBordered = false
    self.alignment = .center

//    self.controlSize = inSize.cocoaControlSize
    self.font = NSFont.monospacedDigitSystemFont (ofSize: NSFont.systemFontSize (for: self.controlSize), weight: .semibold)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override var intrinsicContentSize : NSSize { // Required by ElCapitan
    return NSSize (width: 42, height: 19)
  }

  //····················································································································
  //  version binding
  //····················································································································

  private var mVersionController : EBObservablePropertyController? = nil

  //····················································································································

  final func bind_version (_ inObject : EBReadOnlyProperty_Int) -> Self {
    self.mVersionController = EBObservablePropertyController (
      observedObjects: [inObject],
      callBack: { [weak self] in self?.updateVersion (from: inObject) }
    )
     return self
  }

  //····················································································································

  private func updateVersion (from inObject : EBReadOnlyProperty_Int) {
    switch inObject.selection {
    case .empty, .multiple :
      self.enable (fromValueBinding: false, self.enabledBindingController)
      self.stringValue = "—"
    case .single (let v) :
      self.enable (fromValueBinding: true, self.enabledBindingController)
      self.stringValue = String (v)
    }
  }

  //····················································································································
  //  versionShouldChange binding
  //····················································································································

  private var mVersionShouldChangeController : EBObservablePropertyController? = nil

  //····················································································································

  final func bind_versionShouldChange (_ inObject : EBReadOnlyProperty_Bool) -> Self {
    self.mVersionShouldChangeController = EBObservablePropertyController (
      observedObjects: [inObject],
      callBack: { [weak self] in self?.updateVersionShouldChange (from: inObject) }
    )
    return self
  }

  //····················································································································
  // NSColor.systemBlue is not defined in 10.9
  //····················································································································

  private func updateVersionShouldChange (from inObject : EBReadOnlyProperty_Bool) {
    switch inObject.selection {
    case .empty, .multiple :
      break
    case .single (let v) :
      self.textColor = v ? .systemBlue : .black
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
