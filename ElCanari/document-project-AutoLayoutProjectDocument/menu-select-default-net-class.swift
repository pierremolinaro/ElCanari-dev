//
//  menu-select-default-net-class.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 24/04/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class CanariSelectDefaultNetClassMenu : NSMenu, EBUserClassNameProtocol {

  //····················································································································

  private var mValue = 0

  //····················································································································
  // INIT
  //····················································································································

  init (size inSize : EBControlSize) {
    super.init (title: "")
    noteObjectAllocation (self)
    let fontSize = NSFont.systemFontSize (for: inSize.cocoaControlSize)
    self.font = NSFont.systemFont (ofSize: fontSize)

    self.autoenablesItems = false

  }

  //····················································································································

  required init (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  // menuItemAction
  //····················································································································

//  @objc private func menuItemAction (_ inSender : NSMenuItem) {
//    let value = self.mValue ^ (1 << inSender.tag)
//    _ = self.mLayersController?.updateModel (withCandidateValue: value, windowForSheet: nil)
//  }

  //····················································································································
  //  $layers binding
  //····················································································································

//  private func updateOutlet (_ object : EBReadOnlyProperty_Int) {
//    switch object.selection {
//    case .empty, .multiple :
//      for item in self.items {
//        item.isEnabled = false
//        item.state = .off
//      }
//    case .single (let value) :
//      self.mValue = value
//      var v = value
//      for item in self.items {
//        let flag = (v & 1) != 0
//        item.state = flag ? .on : .off
//        if value.nonzeroBitCount <= 1 {
//          item.isEnabled = !flag
//        }else{
//          item.isEnabled = true
//        }
//        v >>= 1
//      }
//    }
//  }

  //····················································································································

  private var mController : Controller_CanariDefaultNetClassMenu? = nil

  //····················································································································

  final func bind_netClasses (_ inSelectedNetClassName : EBReadWriteProperty_String,
                              _ inNetClassNames : EBReadOnlyProperty_StringArray) -> Self {
    self.mController = Controller_CanariDefaultNetClassMenu (inSelectedNetClassName, inNetClassNames, self)
    return self
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariDefaultNetClassMenu
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate final class Controller_CanariDefaultNetClassMenu : EBObservablePropertyController {

  private let mObject : EBReadWriteProperty_String
  private weak var mOutlet : CanariSelectDefaultNetClassMenu? = nil

  //····················································································································

  init (_ inSelectedNetClassName : EBReadWriteProperty_String,
        _ inNetClassNames : EBReadOnlyProperty_StringArray,
        _ inOutlet : CanariSelectDefaultNetClassMenu) {
    self.mObject = inSelectedNetClassName
    self.mOutlet = inOutlet
    super.init (
      observedObjects: [inSelectedNetClassName, inNetClassNames],
      callBack: nil // self cannot be captured before init completed
    )
    self.mEventCallBack = { [weak self] in self?.updateOutlet (inSelectedNetClassName, inNetClassNames) }
  }

  //····················································································································

  fileprivate func updateOutlet (_ inSelectedNetClassName : EBReadWriteProperty_String,
                                 _ inNetClassNames : EBReadOnlyProperty_StringArray) {
    if let outlet = self.mOutlet {
      outlet.removeAllItems ()
      switch (inSelectedNetClassName.selection, inNetClassNames.selection) {
      case (.single (let selectedName), .single (let netClassNames)) :
        for name in netClassNames.sorted () {
          let menuItem = outlet.addItem (withTitle: name, action: #selector (Self.nameSelectionAction (_:)), keyEquivalent: "")
          menuItem.tag = 0
          menuItem.target = self
          menuItem.isEnabled = true
          menuItem.state = (name == selectedName) ? .on : .off
//          outlet.addItem (withTitle: name)
//          outlet.lastItem?.target = self
//          outlet.lastItem?.action = #selector (self.nameSelectionAction (_:))
//          outlet.lastItem?.isEnabled = true
//          if name == selectedName {
//            outlet.select (outlet.lastItem)
//          }
        }
     //   outlet.enable (fromValueBinding: true, outlet.enabledBindingController)
      default :
        ()
   //     outlet.enable (fromValueBinding: false, outlet.enabledBindingController)
      }
    }
  }

 //····················································································································

  @objc private func nameSelectionAction (_ inSender : NSMenuItem) {
    _ = self.mObject.validateAndSetProp (inSender.title, windowForSheet: nil)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————