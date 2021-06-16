//
//  AutoLayoutIntObserverField.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/06/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   AutoLayoutIntObserverField
//----------------------------------------------------------------------------------------------------------------------

final class AutoLayoutIntObserverField : NSTextField, EBUserClassNameProtocol {

  //····················································································································

//  private let mWidth : CGFloat
  private let mNumberFormatter = NumberFormatter ()

  //····················································································································

  init (small inSmall : Bool) {
 //   self.mWidth = CGFloat (inWidth)
    super.init (frame: NSRect ())
//    self.delegate = self
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.controlSize = inSmall ? .small : .regular
    self.font = NSFont.boldSystemFont (ofSize: inSmall ? NSFont.smallSystemFontSize : NSFont.systemFontSize)
    self.alignment = .center
    self.isBezeled = false
    self.isBordered = false
    self.drawsBackground = false
    self.isEditable = false
//--- Number formatter
    self.mNumberFormatter.formatterBehavior = .behavior10_4
    self.mNumberFormatter.numberStyle = .decimal
    self.mNumberFormatter.localizesFormat = true
    self.mNumberFormatter.minimumFractionDigits = 0
    self.mNumberFormatter.maximumFractionDigits = 0
    self.mNumberFormatter.isLenient = true
    self.formatter = self.mNumberFormatter
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

//  override var intrinsicContentSize : NSSize {
//    return NSSize (width: self.mWidth, height: 19.0)
//  }

  //····················································································································

  override func ebCleanUp () {
    self.mController?.unregister ()
    self.mController = nil
    super.ebCleanUp ()
  }

  //····················································································································

//  final func set (min inMin : Int) -> Self {
//    self.mNumberFormatter.minimum = NSNumber (value: inMin)
//    return self
//  }

  //····················································································································

//  final func set (max inMax : Int) -> Self {
//    self.mNumberFormatter.maximum = NSNumber (value: inMax)
//    return self
//  }

  //····················································································································

  final func set (format inFormatString : String) -> Self {
    self.mNumberFormatter.format = inFormatString
    return self
  }

  //····················································································································
  //    NSTextFieldDelegate delegate function
  //····················································································································

//  func controlTextDidChange (_ inUnusedNotification : Notification) {
//    if self.isContinuous {
//      if let inputString = currentEditor()?.string {
//        // NSLog ("inputString %@", inputString)
//        let numberFormatter = self.formatter as! NumberFormatter
//        let number = numberFormatter.number (from: inputString)
//        if number == nil {
//          _ = control (
//            self,
//            didFailToFormatString: inputString,
//            errorDescription: "The “\(inputString)” value is invalid."
//          )
//        }else{
//          NSApp.sendAction (self.action!, to: self.target, from: self)
//        }
//      }
//    }
//  }

  //····················································································································
  //    NSTextFieldDelegate delegate function
  //····················································································································

//  func control (_ control : NSControl,
//                didFailToFormatString string : String,
//                errorDescription error : String?) -> Bool {
//    let alert = NSAlert ()
//    if let window = control.window {
//      alert.messageText = error!
//      alert.informativeText = "Please provide a valid value."
//      alert.addButton (withTitle: "Ok")
//      alert.addButton (withTitle: "Discard Change")
//      alert.beginSheetModal (
//        for: window,
//        completionHandler: { (response : NSApplication.ModalResponse) -> Void in
//          if response == NSApplication.ModalResponse.alertSecondButtonReturn { // Discard Change
// //         self.integerValue = self.myIntegerValue.0
//          }
//        }
//      )
//    }
//    return false
//  }

  //····················································································································

//  @objc fileprivate func valueDidChangeAction (_ inSender : Any?) {
//    __NSBeep ()
//    if let formatter = self.formatter as? NumberFormatter, let outletValueNumber = formatter.number (from: self.stringValue) {
//      let value = Int (outletValueNumber.doubleValue.rounded ())
//      _ = self.mController?.updateModel (withCandidateValue: value, windowForSheet: self.window)
//    }
//  }

  //····················································································································
  //  observedValue binding
  //····················································································································

  private var mController : EBReadOnlyPropertyController? = nil

  //····················································································································

  final func bind_observedValue (_ inObject : EBReadOnlyProperty_Int) -> Self {
    self.mController = EBReadOnlyPropertyController (
      observedObjects: [inObject],
      callBack:  { [weak self] in self?.update (from: inObject) }
    )
    return self
  }

  //····················································································································

  private func update (from model : EBReadOnlyProperty_Int) {
    switch model.selection {
    case .empty :
      self.enable (fromValueBinding: false)
      self.placeholderString = "No Selection"
      self.stringValue = ""
    case .single (let v) :
      self.enable (fromValueBinding: true)
      self.placeholderString = nil
      self.intValue = Int32 (v)
    case .multiple :
      self.enable (fromValueBinding: false)
      self.placeholderString = "Multiple Selection"
      self.stringValue = ""
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
