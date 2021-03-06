//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class EBPopUpButton : NSPopUpButton, EBUserClassNameProtocol {

  //····················································································································

  required init? (coder : NSCoder) {
    super.init (coder: coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame : NSRect) {
    super.init (frame: frame)
    noteObjectAllocation (self)
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  override func sendAction (_ action : Selector?, to : Any?) -> Bool {
    self.mSelectedTagController?.updateModel (sender: self)
    self.mSelectedIndexController?.updateModel (sender: self)
    return super.sendAction (action, to:to)
  }

  //····················································································································
  //  Key down
  //····················································································································

  override func keyDown (with event: NSEvent) {
    if let s = event.charactersIgnoringModifiers?.uppercased () {
      let unicodeScalars = s.unicodeScalars
      let unicodeChar = unicodeScalars [unicodeScalars.startIndex].value
      switch Int (unicodeChar) {
      case NSEvent.SpecialKey.carriageReturn.rawValue, NSEvent.SpecialKey.enter.rawValue :
        super.keyDown (with: event)
      default :
        var idx = 0
        for item in self.itemArray {
          if item.title.uppercased ().starts (with: s) {
            self.selectItem (at: idx)
            break ;
          }
          idx += 1
        }
      }
    }
  }

  //····················································································································
  //  selectedTag binding
  //····················································································································

  private var mSelectedTagController : Controller_EBPopUpButton_selectedTag? = nil

  //····················································································································

  final func bind_selectedTag (_ object : EBReadWriteProperty_Int) {
    self.mSelectedTagController = Controller_EBPopUpButton_selectedTag (object: object, outlet: self)
  }

  //····················································································································

  final func unbind_selectedTag () {
    self.mSelectedTagController?.unregister ()
    self.mSelectedTagController = nil
  }

  //····················································································································
  //  selectedIndex binding
  //····················································································································

  fileprivate func updateOutlet (_ object : EBReadOnlyProperty_Int) {
    switch object.selection {
    case .empty :
      self.enableFromValueBinding (false)
    case .single (let v) :
      self.enableFromValueBinding (true)
      let result = self.selectItem (withTag: v)
      if !result {
        presentErrorWindow (#file, #line, "no item with tag: " + String (v))
      }
    case .multiple :
      self.enableFromValueBinding (false)
    }
  }

  //····················································································································

  fileprivate func updateIndex (_ object : EBReadWriteObservableEnumProtocol) {
    if let v = object.rawValue () {
      self.enableFromValueBinding (true)
      self.selectItem (at: v)
    }else{
      self.enableFromValueBinding (false)
    }
  }

  //····················································································································

  private var mSelectedIndexController : Controller_EBPopUpButton_Index? = nil

  //····················································································································

  final func bind_selectedIndex (_ object : EBReadWriteObservableEnumProtocol) {
    self.mSelectedIndexController = Controller_EBPopUpButton_Index (object: object, outlet: self)
  }

  //····················································································································

  final func unbind_selectedIndex () {
    self.mSelectedIndexController?.unregister ()
    self.mSelectedIndexController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_EBPopUpButton_selectedTag
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_EBPopUpButton_selectedTag : EBReadOnlyPropertyController {

  //····················································································································

  private let mObject : EBReadWriteProperty_Int
  private let mOutlet : EBPopUpButton

  //····················································································································

  init (object : EBReadWriteProperty_Int, outlet : EBPopUpButton) {
    mObject = object
    mOutlet = outlet
    super.init (observedObjects: [object], callBack: { outlet.updateOutlet (object) })
  }

  //····················································································································

  func updateModel (sender : EBPopUpButton) {
    _ = mObject.validateAndSetProp (self.mOutlet.selectedTag (), windowForSheet: sender.window)
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_EBPopUpButton_Index
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_EBPopUpButton_Index : EBReadOnlyPropertyController {

  //····················································································································

  private let mObject : EBReadWriteObservableEnumProtocol
  private let mOutlet : EBPopUpButton

  //····················································································································

  init (object : EBReadWriteObservableEnumProtocol, outlet : EBPopUpButton) {
    mObject = object
    mOutlet = outlet
    super.init (observedObjects:[object], callBack: { outlet.updateIndex (object) } )
  }

  //····················································································································

  func updateModel (sender : EBPopUpButton) {
    self.mObject.setFrom (rawValue: self.mOutlet.indexOfSelectedItem)
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
