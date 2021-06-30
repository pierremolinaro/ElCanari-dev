//
//  AutoLayoutHorizontalSplitView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutHorizontalSplitView : AutoLayoutAbstractSplitView {

  //····················································································································

  init () {
    super.init (dividersAreVertical: true)

    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .horizontal)
    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .vertical)
  }

  //····················································································································

  required init? (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

//  private var mConstraints = [NSLayoutConstraint] ()
//
//  override func updateConstraints () {
//    self.removeConstraints (self.mConstraints)
//    self.mConstraints = []
//    if let leftSubview = self.subviews.first {
//      let c = NSLayoutConstraint (
//        item: self,
//        attribute: .left,
//        relatedBy: .equal,
//        toItem: leftSubview,
//        attribute: .left,
//        multiplier: 1.0,
//        constant: 0.0
//      )
//      self.mConstraints.append (c)
//    }
//    if let rightSubview = self.subviews.last {
//      let c = NSLayoutConstraint (
//        item: self,
//        attribute: .right,
//        relatedBy: .equal,
//        toItem: rightSubview,
//        attribute: .right,
//        multiplier: 1.0,
//        constant: 0.0
//      )
//      self.mConstraints.append (c)
//    }
//    self.addConstraints (self.mConstraints)
//    super.updateConstraints ()
//  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
