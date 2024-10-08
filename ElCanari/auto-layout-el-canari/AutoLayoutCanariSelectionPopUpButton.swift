//
//  AutoLayoutCanariSelectionPopUpButton.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 27/12/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class AutoLayoutCanariSelectionPopUpButton : ALB_NSPopUpButton {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (size inSize : EBControlSize) {
    super.init (pullsDown: false, size: inSize.cocoaControlSize)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  format binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func updateOutlet (_ inOptionalSelectedName : EBObservableProperty <String>?,
                                 _ inOptionalNameArray : EBObservableProperty <StringArray>?) {
    if let selectedName = inOptionalSelectedName, let nameArray = inOptionalNameArray {
      switch (selectedName.selection, nameArray.selection) {
      case (.single (let selectedName), .single (let netArray)) :
        self.removeAllItems ()
        do{
          self.addItem (withTitle: "—")
          self.lastItem?.target = self
          self.lastItem?.action = #selector (Self.nameSelectionAction (_:))
          self.lastItem?.isEnabled = true
          self.select (self.lastItem)
        }
        let sortedNetArray = netArray.sorted ()
        for name in sortedNetArray {
          self.addItem (withTitle: name)
          self.lastItem?.target = self
          self.lastItem?.action = #selector (Self.nameSelectionAction (_:))
          self.lastItem?.isEnabled = true
          if name == selectedName {
            self.select (self.lastItem)
          }
        }
        self.enable (fromValueBinding: true, self.enabledBindingController ())
      default :
        self.removeAllItems ()
        self.enable (fromValueBinding: false, self.enabledBindingController ())
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func nameSelectionAction (_ inSender : NSMenuItem) {
    self.mController?.updateModelAction (inSender)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   $selectedNameInArray Binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mController : Controller_ElCanariSelectionPopUpButton_selectedNameInArray? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_selectedNameInArray (_ inSelectedName : EBObservableMutableProperty <String>, _ inNameArray : EBObservableProperty <StringArray>) -> Self {
    self.mController = Controller_ElCanariSelectionPopUpButton_selectedNameInArray (
      inSelectedName,
      inNameArray,
      self,
      callBack: { [weak self,  weak inSelectedName, weak inNameArray] in self?.updateOutlet (inSelectedName, inNameArray) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//   Controller_ElCanariSelectionPopUpButton_selectedNameInArray
//--------------------------------------------------------------------------------------------------

final class Controller_ElCanariSelectionPopUpButton_selectedNameInArray : EBObservablePropertyController {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private weak var mSelectedName : EBObservableMutableProperty <String>?

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inSelectedName : EBObservableMutableProperty <String>,
        _ inNameArray : EBObservableProperty <StringArray>,
        _ inOutlet : AutoLayoutCanariSelectionPopUpButton,
        callBack inCallBack : @escaping () -> Void) {
    self.mSelectedName = inSelectedName
    super.init (observedObjects: [inSelectedName, inNameArray], callBack: inCallBack)
    inOutlet.target = self
    inOutlet.action = #selector (Self.updateModelAction (_:))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc func updateModelAction (_ inSender : NSMenuItem) {
    self.mSelectedName?.setProp (inSender.title)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
}

//--------------------------------------------------------------------------------------------------
