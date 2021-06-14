//
//  EBButton.swift
//  essai-custom-stack-view
//
//  Created by Pierre Molinaro on 19/10/2019.
//  Copyright © 2019 Pierre Molinaro. All rights reserved.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

final class AutoLayoutButton : NSButton, EBUserClassNameProtocol {

  //····················································································································

  private var mAction : ( () -> Void)? = nil

  //····················································································································

  init (title inTitle : String, small inSmall : Bool) {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false
    self.title = inTitle
    self.controlSize = inSmall ? .small : .regular
    self.bezelStyle = .roundRect
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

  final func makeWidthExpandable () -> Self {
    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .horizontal)
    return self
  }

  //····················································································································

  final func setAction (_ inAction : @escaping () -> Void) -> Self {
    self.mAction = inAction
    self.target = self
    self.action = #selector (AutoLayoutButton.performAction (_:))
    return self
  }

  //····················································································································

  @objc private func performAction (_ inSender : Any?) {
   self.mAction? ()
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
