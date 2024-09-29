//
//  VerticalStackHierarchyProtocol.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/09/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

@MainActor protocol VerticalStackHierarchyProtocol : AnyObject {

  func appendInVerticalHierarchy (_ inView : NSView)

  func prependInVerticalHierarchy (_ inView : NSView)

  func removeInVerticalHierarchy (_ inView : NSView)

  func buildConstraintsFor (verticalStackView inVerticalStackView : AutoLayoutVerticalStackView,
                            optionalLastBottomAnchor ioOptionalLastBottomAnchor : inout NSLayoutYAxisAnchor?,
                            flexibleSpaceView ioFlexibleSpaceView : inout VerticalStackFlexibleSpace?,
                            _ ioContraints : inout [NSLayoutConstraint])

  func enumerateLastBaselineViews (_ ioArray : inout [NSView?],
                                   _ ioCurrentLastBaselineView : inout NSView?)

  func alignVerticalGutters (_ ioGutters : inout [HorizontalStackGutter],
                             _ ioContraints : inout [NSLayoutConstraint])

}

//--------------------------------------------------------------------------------------------------
