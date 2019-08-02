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

  fileprivate func updateOutlet (_ object : EBReadOnlyProperty_BoardArchiveFormat) {
    switch object.prop {
    case .empty :
      self.enableFromValueBinding (false)
    case .single (let v) :
      self.enableFromValueBinding (true)
      let result = self.selectItem (withTag: v.rawValue)
      if !result {
        presentErrorWindow (#file, #line, "no item with tag: \(v.rawValue)")
      }
    case .multiple :
      self.enableFromValueBinding (false)
    }
  }

  //····················································································································

  private var mFormatController : Controller_CanariBoardBoardArchivePopUpButton_format?

  //····················································································································

  func bind_format (_ object : EBReadWriteProperty_BoardArchiveFormat, file:String, line:Int) {
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
  private let mOutlet : CanariBoardBoardArchivePopUpButton

  //····················································································································

  init (object : EBReadWriteProperty_BoardArchiveFormat, outlet : CanariBoardBoardArchivePopUpButton, file : String, line : Int) {
    mObject = object
    mOutlet = outlet
    super.init (observedObjects: [object], callBack: { outlet.updateOutlet (object) })
    self.mOutlet.target = self
    self.mOutlet.action = #selector (Controller_CanariBoardBoardArchivePopUpButton_format.updateModel (_:))
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
