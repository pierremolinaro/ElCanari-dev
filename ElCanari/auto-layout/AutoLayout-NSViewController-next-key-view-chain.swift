//
//  AutoLayout-extension-NSView-responder-chain.swift.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 21/11/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Custom Automatic Key View Chain
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class EBViewController : NSViewController, EBUserClassNameProtocol {

  //····················································································································

  init (_ inView : NSView) {
    super.init (nibName: nil, bundle: nil)
    self.view = inView
    noteObjectAllocation (self)
  }

  //····················································································································

  required init? (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  override func viewDidLayout () {
    super.viewDidLayout ()
    self.triggerNextKeyViewSettingComputation ()
  }

  //····················································································································

  private var mNextKeyViewSettingComputationHasBeenTriggered = false

  //····················································································································

  func triggerNextKeyViewSettingComputation () {
    if !mNextKeyViewSettingComputationHasBeenTriggered {
      self.mNextKeyViewSettingComputationHasBeenTriggered = true
      DispatchQueue.main.async {
        self.mNextKeyViewSettingComputationHasBeenTriggered = false
        var currentView : NSView? = nil
        var optionalLastView : NSView? = nil
        self.buildAutoLayoutKeyViewChain (self.view, &currentView, &optionalLastView)
        if let lastView = optionalLastView {
          _ = self.setAutoLayoutFirstKeyViewInChain (self.view, lastView)
        }
      }
    }
  }

  //····················································································································

  private func buildAutoLayoutKeyViewChain (_ inView : NSView, _ ioCurrentNextKeyView : inout NSView?, _ outLastView : inout NSView?) {
    for view in inView.subviews.reversed () {
      if !view.isHidden {
        if view.acceptsFirstResponder {
          if outLastView == nil {
            outLastView = view
          }
          view.nextKeyView = ioCurrentNextKeyView
          // Swift.print ("Responder of \(view) is \(ioCurrentNextKeyView)")
          ioCurrentNextKeyView = view
        }else{
          self.buildAutoLayoutKeyViewChain (view, &ioCurrentNextKeyView, &outLastView)
        }
      }else{
        view.nextResponder = nil
      }
    }
  }

  //····················································································································

  fileprivate func setAutoLayoutFirstKeyViewInChain (_ inView : NSView, _ inLastView : NSView) -> Bool {
    for view in inView.subviews {
      if !view.isHidden {
        if view.acceptsFirstResponder {
          inLastView.nextKeyView = view
          return true
        }else{
          let found = self.setAutoLayoutFirstKeyViewInChain (view, inLastView)
          if found {
            return true
          }
        }
      }
    }
    return false
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
