//
//  AutoLayoutWebView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 26/01/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa
import WebKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutWebView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutWebView : WKWebView, EBUserClassNameProtocol, WKUIDelegate {

  //····················································································································

  init (url inURL : String) {
    let webConfiguration = WKWebViewConfiguration ()
    super.init (frame: .zero, configuration: webConfiguration)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    if let url = URL (string: inURL) {
      let myRequest = URLRequest (url: url)
      self.load (myRequest)
    }
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

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
