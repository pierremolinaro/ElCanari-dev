//
//  CanariBoardBoardArchivePopUpButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/07/2018.
//
//
import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CanariBoardBoardArchivePopUpButton) class CanariBoardBoardArchivePopUpButton : EBPopUpButton {

  //····················································································································
  //  format binding
  //····················································································································

  private var mFormatController : Controller_CanariBoardBoardArchivePopUpButton_format?

  func bind_format (_ object:EBReadWriteProperty_BoardArchiveFormat, file:String, line:Int) {
    mFormatController = Controller_CanariBoardBoardArchivePopUpButton_format (object:object, outlet:self, file:file, line:line)
  }

  func unbind_format () {
    mFormatController?.unregister ()
    mFormatController = nil
  }

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariBoardBoardArchivePopUpButton_format
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(Controller_CanariBoardBoardArchivePopUpButton_format)
final class Controller_CanariBoardBoardArchivePopUpButton_format : EBSimpleController {

  private let mObject : EBReadWriteProperty_BoardArchiveFormat
  private let mOutlet : EBPopUpButton

  //····················································································································

  init (object : EBReadWriteProperty_BoardArchiveFormat, outlet : EBPopUpButton, file : String, line : Int) {
    mObject = object
    mOutlet = outlet
    super.init (observedObjects:[object], outlet:outlet)
    mOutlet.target = self
    mOutlet.action = #selector (Controller_CanariBoardBoardArchivePopUpButton_format.updateModel (_:))
  }

  //····················································································································

  override func sendUpdateEvent () {
    switch mObject.prop {
    case .empty :
      mOutlet.enableFromValueBinding (false)
    case .single (let v) :
      mOutlet.enableFromValueBinding (true)
      let result = mOutlet.selectItem (withTag: v.rawValue)
      if !result {
        presentErrorWindow (file: #file, line:#line, errorMessage:"no item with tag: " + String (v.rawValue))
      }
    case .multiple :
      mOutlet.enableFromValueBinding (false)
    }
  }

  //····················································································································

  func updateModel (_ sender : EBPopUpButton) {
    if let v = BoardArchiveFormat (rawValue: mOutlet.selectedTag ()) {
      _ = mObject.validateAndSetProp (v, windowForSheet:sender.window)
    }
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
