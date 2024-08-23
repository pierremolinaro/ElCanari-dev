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
  private let mSpacing : CGFloat = 8.0

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mItemArray = [Entry] ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func add (title inTitle : String, item inView : NSView) -> Self {
    let label = AutoLayoutStaticLabel (
      title: inTitle,
      bold: false,
      size: .small,
      alignment: .center
    )
    inView.setContentHuggingPriority (.defaultHigh, for: .vertical) // §
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
  //--- Build constraints
    var optionalLastEntry : Entry? = nil
    var optionalLastBaseLineView : NSView? = nil
    for entry in self.mItemArray {
    //--- Vertical constraints
      switch entry.item.pmLayoutSettings.vLayoutInHorizontalContainer {
      case .center :
        self.mConstraints.add (topOf: self, greaterThanOrEqualToTopOf: entry.item, plus: self.mMargins)
        self.mConstraints.add (bottomOf: entry.item, greaterThanOrEqualToBottomOf: self, plus: self.mMargins)
        self.mConstraints.add (centerYOf: entry.item, equalToCenterYOf: self)
      case .fill, .weakFill :
        self.mConstraints.add (topOf: self, equalToTopOf: entry.item, plus: self.mMargins)
        self.mConstraints.add (bottomOf: entry.item, equalToBottomOf: self, plus: self.mMargins)
      case .weakFillIgnoringMargins :
        self.mConstraints.add (topOf: self, equalToTopOf: entry.item)
        self.mConstraints.add (bottomOf: entry.item, equalToBottomOf: self)
      case .bottom :
        self.mConstraints.add (topOf: self, greaterThanOrEqualToTopOf: entry.item, plus: self.mMargins)
        self.mConstraints.add (bottomOf: entry.item, equalToBottomOf: self, plus: self.mMargins)
      case .top :
        self.mConstraints.add (topOf: self, equalToTopOf: entry.item, plus: self.mMargins)
        self.mConstraints.add (bottomOf: entry.item, greaterThanOrEqualToBottomOf: self, plus: self.mMargins)
      case .lastBaseline :
        if let viewLastBaselineRepresentativeView = entry.item.pmLastBaselineRepresentativeView {
          self.mConstraints.add (topOf: self, greaterThanOrEqualToTopOf: entry.item, plus: self.mMargins)
          self.mConstraints.add (bottomOf: entry.item, greaterThanOrEqualToBottomOf: self, plus: self.mMargins)
          self.mConstraints.add (topOf: self, equalToTopOf: entry.item, plus: self.mMargins, withStretchingResistancePriorityOf: .secondView)
          self.mConstraints.add (bottomOf: entry.item, equalToBottomOf: self, plus: self.mMargins, withStretchingResistancePriorityOf: .firstView)
          if let lastBaselineRepresentativeView = optionalLastBaseLineView {
            self.mConstraints.add (lastBaselineOf: viewLastBaselineRepresentativeView, equalToLastBaselineOf: lastBaselineRepresentativeView)
          }else{
            optionalLastBaseLineView = viewLastBaselineRepresentativeView
          }
        }else{
          self.mConstraints.add (topOf: self, equalToTopOf: entry.item, plus: self.mMargins)
          self.mConstraints.add (bottomOf: entry.item, equalToBottomOf: self, plus: self.mMargins)
        }
      }
    //--- Horizontal constraints
     if let lastEntry = optionalLastEntry {
        self.mConstraints.add (leftOf: entry.label, equalToRightOf: lastEntry.label, plus: self.mSpacing)
        self.mConstraints.add (leftOf: entry.item, equalToRightOf: lastEntry.item, plus: self.mSpacing)
        self.mConstraints.add (leftOf: entry.item, equalToLeftOf: entry.label)
        self.mConstraints.add (rightOf: lastEntry.item, equalToRightOf: lastEntry.label)
     }else{
        self.mConstraints.add (leftOf: entry.label, equalToLeftOf: self, plus: self.mMargins)
        self.mConstraints.add (leftOf: entry.item, equalToLeftOf: self, plus: self.mMargins)
      }
      optionalLastEntry = entry
    }
  //--- Add right constraints for last view
    if let lastEntry = optionalLastEntry {
      self.mConstraints.add (rightOf: self, equalToRightOf: lastEntry.label, plus: self.mMargins)
      self.mConstraints.add (rightOf: self, equalToRightOf: lastEntry.item, plus: self.mMargins)
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
