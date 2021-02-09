//----------------------------------------------------------------------------------------------------------------------
//
//  Created by Pierre Molinaro on 09/02/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   AutoLayoutIntField
//----------------------------------------------------------------------------------------------------------------------

class AutoLayoutIntField : NSTextField, EBUserClassNameProtocol, NSTextFieldDelegate {

  //····················································································································

  let mWidth : CGFloat

  //····················································································································

  init (width inWidth : Int) {
    self.mWidth = CGFloat (inWidth)
    super.init (frame: NSRect ())
    self.delegate = self
    noteObjectAllocation (self)
    self.controlSize = .small
    self.font = NSFont.boldSystemFont (ofSize: NSFont.smallSystemFontSize)
    self.alignment = .center
  //--- Target
    self.target = self
    self.action = #selector (Self.valueDidChangeAction (_:))
  //--- Number formatter
    let numberFormatter = NumberFormatter ()
    numberFormatter.formatterBehavior = .behavior10_4
    numberFormatter.numberStyle = .decimal
    numberFormatter.localizesFormat = true
    numberFormatter.minimumFractionDigits = 0
    numberFormatter.maximumFractionDigits = 0
    numberFormatter.isLenient = true
    self.formatter = numberFormatter
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override var intrinsicContentSize : NSSize {
    return NSSize (width: self.mWidth, height: 19.0)
  }

  //····················································································································

  override func ebCleanUp () {
    self.mController?.unregister ()
    self.mController = nil
    super.ebCleanUp ()
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

  @objc fileprivate func valueDidChangeAction (_ inSender : Any?) {
    __NSBeep ()
    if let formatter = self.formatter as? NumberFormatter, let outletValueNumber = formatter.number (from: self.stringValue) {
      let value = Int (outletValueNumber.doubleValue.rounded ())
      _ = self.mController?.updateModel (withCandidateValue: value, windowForSheet: self.window)
    }
  }

  //····················································································································
  //  value binding
  //····················································································································

  private var mController : EBGenericReadWritePropertyController <Int>? = nil

  //····················································································································

  func bind_value (_ inObject : EBReadWriteProperty_Int, sendContinously : Bool) -> Self {
    self.cell?.sendsActionOnEndEditing = false
    self.isContinuous = sendContinously
    self.mController = EBGenericReadWritePropertyController <Int> (
      observedObject: inObject,
      callBack:  { [weak self] in self?.update (from: inObject) }
    )
    return self
  }

  //····················································································································

  private func update (from model : EBReadOnlyProperty_Int) {
    switch model.selection {
    case .empty :
      self.enableFromValueBinding (false)
      self.placeholderString = "No Selection"
      self.stringValue = ""
    case .single (let v) :
      self.enableFromValueBinding (true)
      self.placeholderString = nil
      self.intValue = Int32 (v)
    case .multiple :
      self.enableFromValueBinding (false)
      self.placeholderString = "Multipe Selection"
      self.stringValue = ""
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
