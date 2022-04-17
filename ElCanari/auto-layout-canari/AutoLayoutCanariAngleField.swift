//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariAngleField : AutoLayoutBase_NSTextField {

  //····················································································································
  // Property
  //····················································································································

  private let mNumberFormatter = NumberFormatter ()

  //····················································································································
  // INIT
  //····················································································································

  init (minWidth inWidth : Int, size inSize : EBControlSize) {
    super.init (optionalWidth: inWidth, bold: true, size: inSize)

    self.delegate = self
    self.target = self
    self.action = #selector (Self.action (_:))
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

  //····················································································································

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
    if debugAutoLayout () {
//      DEBUG_FILL_COLOR.setFill ()
//      NSBezierPath.fill (inDirtyRect)
      let bp = NSBezierPath (rect: self.bounds)
      bp.lineWidth = 1.0
      bp.lineJoinStyle = .round
      DEBUG_STROKE_COLOR.setStroke ()
      bp.stroke ()
    }
    super.draw (inDirtyRect)
  }

  //····················································································································
  //  $angle binding
  //····················································································································

  private var mAngleController : EBGenericReadWritePropertyController <Int>? = nil

  //····················································································································

  final func bind_angle (_ model : EBReadWriteProperty_Int) -> Self {
    self.mAngleController = EBGenericReadWritePropertyController <Int> (
      observedObject: model,
      callBack: { [weak self] in self?.update (from: model) }
    )
    return self
  }

  //····················································································································

  private func update (from model : EBReadWriteProperty_Int) {
    switch model.selection {
    case .empty :
      self.enable (fromValueBinding: false, self.enabledBindingController)
      self.placeholderString = "No Selection"
      self.stringValue = ""
    case .single (let v) :
      self.enable (fromValueBinding: true, self.enabledBindingController)
      self.placeholderString = nil
      self.doubleValue = Double (v) / 1000.0
    case .multiple :
      self.enable (fromValueBinding: false, self.enabledBindingController)
      self.placeholderString = "Multiple Selection"
      self.stringValue = ""
    }
  }

  //····················································································································
  //    NSTextFieldDelegate delegate function
  //····················································································································

  func controlTextDidChange (_ inUnusedNotification : Notification) {
    if self.isContinuous {
      if let inputString = currentEditor()?.string {
        // NSLog ("inputString %@", inputString)
        let numberFormatter = self.formatter as! NumberFormatter
        let number = numberFormatter.number (from: inputString)
        if number == nil {
          _ = control (
            self,
            didFailToFormatString: inputString,
            errorDescription: "The “\(inputString)” value is invalid."
          )
        }else{
          NSApp.sendAction (self.action!, to: self.target, from: self)
        }
      }
    }
  }

  //····················································································································
  //    NSTextFieldDelegate delegate function
  //····················································································································

  func control (_ control : NSControl,
                didFailToFormatString string : String,
                errorDescription error : String?) -> Bool {
    let alert = NSAlert ()
    if let window = control.window {
      alert.messageText = error!
      alert.informativeText = "Please provide a valid value."
      alert.addButton (withTitle: "Ok")
      alert.addButton (withTitle: "Discard Change")
      alert.beginSheetModal (
        for: window,
        completionHandler: { (response : NSApplication.ModalResponse) -> Void in
          if response == NSApplication.ModalResponse.alertSecondButtonReturn { // Discard Change
 //         self.integerValue = self.myIntegerValue.0
          }
        }
      )
    }
    return false
  }

  //····················································································································

  @objc func action (_ sender : Any?) {
    if let outletValueNumber = self.mNumberFormatter.number (from: self.stringValue) {
      let value = Int ((outletValueNumber.doubleValue * 1000.0).rounded ())
      _ = self.mAngleController?.updateModel (withCandidateValue: value, windowForSheet: self.window)
    }else{
      NSSound.beep ()
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

