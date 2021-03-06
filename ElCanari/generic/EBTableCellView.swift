//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    EBTableCellView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class EBTableCellView : NSTableCellView, EBUserClassNameProtocol {
  final var mUnbindFunction : Optional < () -> Void > = nil

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

  override func removeFromSuperview () {
    super.removeFromSuperview ()
    if Thread.isMainThread {
      self.mUnbindFunction? ()
    }else{
      DispatchQueue.main.async { self.mUnbindFunction? () }
    }
  }

  //····················································································································

  override func removeFromSuperviewWithoutNeedingDisplay () {
    super.removeFromSuperviewWithoutNeedingDisplay ()
    if Thread.isMainThread {
      self.mUnbindFunction? ()
    }else{
      DispatchQueue.main.async { self.mUnbindFunction? () }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
