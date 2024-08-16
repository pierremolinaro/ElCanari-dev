//
//  AutoLayoutBase_WebView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 26/01/2022.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import WebKit

//--------------------------------------------------------------------------------------------------
//   AutoLayoutBase_WebView
//--------------------------------------------------------------------------------------------------

final class AutoLayoutWebView : WKWebView, WKUIDelegate {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (url inURL : String) {
    let webConfiguration = WKWebViewConfiguration ()
    super.init (frame: .zero, configuration: webConfiguration)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    if let url = URL (string: inURL) {
      let myRequest = URLRequest (url: url)
      _ = self.load (myRequest)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
    objectDidDeinit ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mMinHeight : CGFloat? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func set (minHeight inMinHeight : Int) -> Self {
    self.mMinHeight = CGFloat (inMinHeight)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var intrinsicContentSize: NSSize {
    var s = super.intrinsicContentSize
    if let h = self.mMinHeight, s.height < h {
      s.height = h
    }
    return s
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
