//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class AutoLayoutCanariAngleField : ALB_NSTextField {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Properties
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mNumberFormatter = NumberFormatter ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate var mInputIsValid = true {
    didSet {
      if self.mInputIsValid != oldValue {
        self.needsDisplay = true
      }
    }
  }


  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // INIT
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (minWidth inWidth : Int, size inSize : EBControlSize) {
    super.init (optionalWidth: inWidth, bold: true, size: inSize.cocoaControlSize)

    self.delegate = self
    self.target = self
    self.action = #selector (Self.valueDidChangeAction (_:))
  //--- Number formatter
    self.mNumberFormatter.formatterBehavior = .behavior10_4
    self.mNumberFormatter.numberStyle = .decimal
    self.mNumberFormatter.localizesFormat = true
    self.mNumberFormatter.minimumFractionDigits = 3
    self.mNumberFormatter.maximumFractionDigits = 3
    self.mNumberFormatter.isLenient = true
    self.mNumberFormatter.positiveSuffix = "°"
    self.formatter = self.mNumberFormatter
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func draw (_ inDirtyRect : NSRect) {
    if debugAutoLayout () {
      let bp = NSBezierPath (rect: self.bounds)
      bp.lineWidth = 1.0
      bp.lineJoinStyle = .round
      DEBUG_STROKE_COLOR.setStroke ()
      bp.stroke ()
    }
    super.draw (inDirtyRect)
    if !self.mInputIsValid {
      NSColor.systemRed.withAlphaComponent (0.25).setFill ()
      NSBezierPath.fill (self.bounds)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func textDidChange (_ inNotification : Notification) {
    super.textDidChange (inNotification)
    if let inputString = currentEditor()?.string, let numberFormatter = self.formatter as? NumberFormatter {
      let optionalNumber = numberFormatter.number (from: inputString)
      if let number = optionalNumber, self.isContinuous {
        let value = Int ((number.doubleValue * 1000.0).rounded ())
        self.mAngleController?.updateModel (withValue: value)
      }
      self.mInputIsValid = optionalNumber != nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc func valueDidChangeAction (_ sender : Any?) {
    if let outletValueNumber = self.mNumberFormatter.number (from: self.stringValue) {
      let value = Int ((outletValueNumber.doubleValue * 1000.0).rounded ())
      self.mAngleController?.updateModel (withValue: value)
    }else if let v = self.mAngleController?.value {
      self.mInputIsValid = true
      self.doubleValue = Double (v) / 1000.0
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $angle binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mAngleController : EBGenericReadWritePropertyController <Int>? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_angle (_ model : EBObservableMutableProperty <Int>) -> Self {
    self.mAngleController = EBGenericReadWritePropertyController <Int> (
      observedObject: model,
      callBack: { [weak self] in self?.update (from: model) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func update (from model : EBObservableMutableProperty <Int>) {
    self.mInputIsValid = true
    switch model.selection {
    case .empty :
      self.enable (fromValueBinding: false, self.enabledBindingController ())
      self.placeholderString = "No Selection"
      self.stringValue = ""
    case .single (let v) :
      self.enable (fromValueBinding: true, self.enabledBindingController ())
      self.placeholderString = nil
      self.doubleValue = Double (v) / 1000.0
    case .multiple :
      self.enable (fromValueBinding: false, self.enabledBindingController ())
      self.placeholderString = "Multiple Selection"
      self.stringValue = ""
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

