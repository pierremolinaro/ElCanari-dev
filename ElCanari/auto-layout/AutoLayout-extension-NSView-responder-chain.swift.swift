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

extension NSView {

  //····················································································································

  func buildAutoLayoutKeyViewChain (_ ioCurrentView : inout NSView?, _ outLastView : inout NSView?) {
    for view in self.subviews.reversed () {
      if !view.isHidden {
        if view.acceptsFirstResponder {
          if outLastView == nil {
            outLastView = view
          }
          view.nextKeyView = ioCurrentView
          // Swift.print ("Responder of \(view) is \(ioCurrentView)")
          ioCurrentView = view
        }else{
          view.buildAutoLayoutKeyViewChain (&ioCurrentView, &outLastView)
        }
      }else{
        view.nextResponder = nil
      }
    }
  }

  //····················································································································

  func setAutoLayoutFirstKeyViewInChain (_ inLastView : NSView) -> Bool {
    for view in self.subviews {
      if !view.isHidden {
        if view.acceptsFirstResponder {
          inLastView.nextKeyView = view
          return true
        }else{
          let found = view.setAutoLayoutFirstKeyViewInChain (inLastView)
          if found {
            return true
          }
        }
      }
    }
    return false
  }

  //····················································································································

//  final func getResponder (following inResponder : NSResponder) -> NSResponder? {
//    var result : NSResponder? = nil
//    var searchForCurrentResponder = true
//    for view in self.subviews {
//      if !searchForCurrentResponder, result == nil, !view.isHidden {
//        result = view
//      }
//      if view === inResponder {
//        searchForCurrentResponder = false
//      }
//    }
//    return result
//  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
