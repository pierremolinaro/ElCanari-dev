//
//  CanariBoardBoardArchivePopUpButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/07/2018.
//
//
import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariBoardBoardArchivePopUpButton : EBPopUpButton {

  //····················································································································
  //  format binding
  //····················································································································

  private var mFormatController : Controller_CanariBoardBoardArchivePopUpButton_format?

  //····················································································································

  func bind_format (_ object:EBReadWriteProperty_BoardArchiveFormat, file:String, line:Int) {
    self.mFormatController = Controller_CanariBoardBoardArchivePopUpButton_format (object:object, outlet:self, file:file, line:line)
  }

  //····················································································································

  func unbind_format () {
    self.mFormatController?.unregister ()
    self.mFormatController = nil
  }

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariBoardBoardArchivePopUpButton_format
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariBoardBoardArchivePopUpButton_format : EBSimpleController {

  private let mObject : EBReadWriteProperty_BoardArchiveFormat
  private let mOutlet : EBPopUpButton

  //····················································································································

  init (object : EBReadWriteProperty_BoardArchiveFormat, outlet : EBPopUpButton, file : String, line : Int) {
    mObject = object
    mOutlet = outlet
    super.init (observedObjects:[object])
    self.mOutlet.target = self
    self.mOutlet.action = #selector (Controller_CanariBoardBoardArchivePopUpButton_format.updateModel (_:))
    self.mEventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································

  private func updateOutlet () {
    switch mObject.prop {
    case .empty :
      self.mOutlet.enableFromValueBinding (false)
    case .single (let v) :
      self.mOutlet.enableFromValueBinding (true)
      let result = self.mOutlet.selectItem (withTag: v.rawValue)
      if !result {
        presentErrorWindow (#file, #line, "no item with tag: \(v.rawValue)")
      }
    case .multiple :
      self.mOutlet.enableFromValueBinding (false)
    }
  }

  //····················································································································

  @objc func updateModel (_ sender : EBPopUpButton) {
    if let v = BoardArchiveFormat (rawValue: self.mOutlet.selectedTag ()) {
      _ = self.mObject.validateAndSetProp (v, windowForSheet:sender.window)
    }
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
