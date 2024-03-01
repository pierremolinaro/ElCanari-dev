//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutSignatureField : NSTextField {

  //································································································

  init (size inSize : EBControlSize) {
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.isEditable = false
    self.drawsBackground = false
    self.isBordered = false
    self.alignment = .center

    self.controlSize = inSize.cocoaControlSize
    self.font = NSFont.monospacedDigitSystemFont (ofSize: NSFont.systemFontSize (for: self.controlSize), weight: .semibold)
  }

  //································································································

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //································································································

  override var intrinsicContentSize : NSSize {  // Required by ElCapitan
    return NSSize (width: 83, height: 19)
  }

  //································································································
  //  $signature binding
  //································································································

  private var mController : EBObservablePropertyController? = nil

  //································································································

  final func bind_signature (_ model : EBObservableProperty <UInt32>) -> Self {
    self.mController = EBObservablePropertyController (
      observedObjects: [model],
      callBack: { [weak self] in self?.update (from: model) }
    )
    return self
  }

  //································································································

  private func update (from model : EBObservableProperty <UInt32>) {
    switch model.selection {
    case .empty, .multiple :
      self.stringValue = "—"
    case .single (let v) :
      self.stringValue = String (format: "%04X:%04X", v >> 16, v & 0xFFFF)
    }
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
