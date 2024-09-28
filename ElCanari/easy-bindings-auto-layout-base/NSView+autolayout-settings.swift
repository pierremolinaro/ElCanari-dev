//
//  NSView-extension.swift
//  essai-gridview
//
//  Created by Pierre Molinaro on 29/10/2023.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension NSView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func pmConfigureForAutolayout (hStretchingResistance inHorizontalStrechingResistance : LayoutStrechingConstraintPriority,
                                       vStrechingResistance inVerticalStrechingResistance : LayoutStrechingConstraintPriority) {
    self.translatesAutoresizingMaskIntoConstraints = false
    self.setContentHuggingPriority (inHorizontalStrechingResistance.cocoaPriority, for: .horizontal)
    self.setContentHuggingPriority (inVerticalStrechingResistance.cocoaPriority, for: .vertical)
    self.setContentCompressionResistancePriority (.defaultHigh, for: .horizontal)
    self.setContentCompressionResistancePriority (.defaultHigh, for: .vertical)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private static let mDefaultViewLayoutSettings = AutoLayoutViewSettings (
    vLayoutInHorizontalContainer: .fill,
    hLayoutInVerticalContainer: .fill
  )

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc var pmLayoutSettings : AutoLayoutViewSettings { Self.mDefaultViewLayoutSettings }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  private static let mDefaultLastBaselineRepresentative = OptionalViewArray ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc var lastBaselineRepresentativeView : NSView? { self }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

//class OptionalViewArray : NSObject {
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  private let mArray : [NSView?]
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  override init () {
//    self.mArray = [nil]
//    super.init ()
//    noteObjectAllocation (self)
//  }
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  init (_ inView : NSView) {
//    self.mArray = [inView]
//    super.init ()
//    noteObjectAllocation (self)
//  }
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  init (_ inViews : [NSView?]) {
//    self.mArray = inViews
//    super.init ()
//    noteObjectAllocation (self)
//  }
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  deinit {
//    noteObjectDeallocation (self)
//  }
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  var last : NSView? { self.mArray.last ?? nil }
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  var count : Int { self.mArray.count }
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  subscript (_ inIndex : Int) -> NSView? { self.mArray [inIndex] }
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//}

//--------------------------------------------------------------------------------------------------
