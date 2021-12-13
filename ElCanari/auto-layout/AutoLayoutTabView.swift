//
//  AutoLayoutTabView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 12/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutTabView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutTabView : NSTabView, EBUserClassNameProtocol, NSTabViewDelegate {

  //····················································································································

  init (size inSize : EBControlSize) {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false
    self.delegate = self

    self.controlSize = inSize.cocoaControlSize
    self.font = NSFont.systemFont (ofSize: NSFont.systemFontSize (for: self.controlSize))
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

  func addTab (title inTitle : String, contents inView : NSView) -> Self {
    let tabViewItem = NSTabViewItem (identifier: nil) // self.numberOfTabViewItems)
    tabViewItem.label = inTitle
    tabViewItem.view = inView
    self.addTabViewItem (tabViewItem)
    return self
  }

  //····················································································································

//  override func updateConstraints () {
//    Swift.print ("AutoLayoutTabView.updateConstraints")
//    super.updateConstraints ()
//  }
//
//  fileprivate var mConstraints = [NSLayoutConstraint] ()
//
//  func tabView (_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
//    self.removeConstraints (self.mConstraints)
//    self.mConstraints.removeAll ()
//    if let view = tabViewItem?.view {
//      var c = NSLayoutConstraint (item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0)
//      self.mConstraints.append (c)
////      c = NSLayoutConstraint (item: view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0)
////      self.mConstraints.append (c)
////      c = NSLayoutConstraint (item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
////      self.mConstraints.append (c)
////      c = NSLayoutConstraint (item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
////      self.mConstraints.append (c)
//    }
//    self.addConstraints (self.mConstraints)
//    self.needsUpdateConstraints = true
//  }

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
