//
//  CanariObserverSwitch.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 01/08/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariObserverSwitch : NSButton, EBUserClassNameProtocol {

  //····················································································································

  required init? (coder : NSCoder) {
    super.init (coder: coder)
    noteObjectAllocation (self)
    self.setButtonType (.switch)
    self.isEnabled = false
  }

  //····················································································································

  override init (frame : NSRect) {
    super.init (frame: frame)
    noteObjectAllocation (self)
    self.setButtonType (.switch)
    self.isEnabled = false
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  //  value binding
  //····················································································································

  fileprivate func updateValue (_ object : EBReadOnlyProperty_Bool) {
    switch object.prop {
    case .empty :
      self.state = NSControl.StateValue.off
    case .multiple :
      self.state = NSControl.StateValue.mixed
    case .single (let v) :
      self.state = v ? NSControl.StateValue.on : NSControl.StateValue.off
    }
  }

  //····················································································································

  fileprivate var mValueController : EBSimpleController? = nil

  //····················································································································

  func bind_valueObserver (_ object : EBReadOnlyProperty_Bool, file : String, line : Int) {
    self.mValueController = EBSimpleController (observedObjects: [object], callBack: { self.updateValue (object) } )
  }

  //····················································································································

  func unbind_valueObserver () {
    self.mValueController?.unregister ()
    self.mValueController = nil
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
