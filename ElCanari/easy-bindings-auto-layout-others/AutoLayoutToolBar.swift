//
//  AutoLayoutToolBar.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 20/08/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class AutoLayoutToolBar : ALB_NSView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mMargins : CGFloat = 8.0
  private let mSpacing : CGFloat = 4.0
  private let mTopRow = ALB_NSView ()
  private let mBottomRow = ALB_NSView ()
  private var mItemArray = [Entry] ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override init () {
    super.init ()
    self.addSubview (self.mTopRow)
    self.addSubview (self.mBottomRow)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init?(coder inCoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func add (title inTitle : String, item inView : NSView) -> Self {
    let label = AutoLayoutStaticLabel (
      title: inTitle,
      bold: false,
      size: .small,
      alignment: .center
    )
//    label.setContentCompressionResistancePriority (.defaultHigh, for: .vertical)
    self.mItemArray.append (Entry (item: inView, label: label))
    self.addSubview (label)
    self.addSubview (inView)
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func addFlexibleSpace () -> Self {
    let f1 = AutoLayoutFlexibleSpace ()
    let f2 = AutoLayoutFlexibleSpace ()
    self.mItemArray.append (Entry (item: f1, label: f2))
    self.addSubview (f1)
    self.addSubview (f2)
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Constraints
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mConstraints = [NSLayoutConstraint] ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func updateConstraints () {
  //--- Remove all constraints
    self.removeConstraints (self.mConstraints)
    self.mConstraints.removeAll (keepingCapacity: true)
  //--- Build row vertical constraints
    self.mConstraints.add (topOf: self, equalToTopOf: self.mTopRow, plus: self.mMargins)
    self.mConstraints.add (bottomOf: self.mTopRow, equalToTopOf: self.mBottomRow, plus: self.mSpacing)
    self.mConstraints.add (bottomOf: self.mBottomRow, equalToBottomOf: self, plus: self.mMargins)
  //--- Build row horizontal constraints
    self.mConstraints.add (leftOf: self.mTopRow, equalToLeftOf: self, plus: self.mMargins)
    self.mConstraints.add (rightOf: self, equalToRightOf: self.mTopRow, plus: self.mMargins)
    self.mConstraints.add (leftOf: self.mBottomRow, equalToLeftOf: self, plus: self.mMargins)
    self.mConstraints.add (rightOf: self, equalToRightOf: self.mBottomRow, plus: self.mMargins)
  //--- Build constraints
    var optionalLastEntry : Entry? = nil
    var optionalLastBaseLineView : NSView? = nil
    for entry in self.mItemArray {
    //--- Vertical item vertical constraints
      self.mConstraints.add (
        verticalConstraintsOf: entry.item,
        inHorizontalContainer: self.mTopRow,
        topMargin: 0.0,
        bottomMargin : 0.0,
        optionalLastBaseLineView: &optionalLastBaseLineView
      )
    //--- Vertical label vertical constraints
      self.mConstraints.add (topOf: self.mBottomRow, equalToTopOf: entry.label)
      self.mConstraints.add (bottomOf: self.mBottomRow, equalToBottomOf: entry.label)
    //--- Horizontal constraints
      if let lastEntry = optionalLastEntry {
        self.mConstraints.add (leftOf: entry.item, equalToRightOf: lastEntry.item, plus: self.mSpacing)
        self.mConstraints.add (leftOf: entry.label, equalToRightOf: lastEntry.label, plus: self.mSpacing)
        self.mConstraints.add (leftOf: entry.item, equalToLeftOf: entry.label)
        self.mConstraints.add (rightOf: lastEntry.item, equalToRightOf: lastEntry.label)
      }else{
        self.mConstraints.add (leftOf: entry.item, equalToLeftOf: self.mTopRow)
        self.mConstraints.add (leftOf: entry.label, equalToLeftOf: self.mBottomRow)
      }
      optionalLastEntry = entry
    }
  //--- Add right constraints for last view
    if let lastEntry = optionalLastEntry {
      self.mConstraints.add (rightOf: self.mBottomRow, equalToRightOf: lastEntry.label)
      self.mConstraints.add (rightOf: self.mTopRow, equalToRightOf: lastEntry.item)
    }
  //--- Apply constaints
    self.addConstraints (self.mConstraints)
  //--- This should the last instruction: call super method
    super.updateConstraints ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate struct Entry {
    let item  : NSView
    let label : NSView
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
