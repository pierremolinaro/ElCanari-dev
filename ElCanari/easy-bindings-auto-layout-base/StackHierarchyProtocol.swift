//
//  StackHierarchyProtocol.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/09/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

@MainActor protocol StackHierarchyProtocol : AnyObject {

  func appendInHierarchy (_ inView : NSView)

  func prependInHierarchy (_ inView : NSView)

  func removeInHierarchy (_ inView : NSView)

  func buildConstraintsFor (verticalStackView inVerticalStackView : AutoLayoutVerticalStackView,
                            optionalLastBottomView ioOptionalLastBottomView : inout NSView?,
                            flexibleSpaceView ioFlexibleSpaceView : inout AutoLayoutFlexibleSpace?,
                            _ ioContraints : inout [NSLayoutConstraint])

  func buildConstraintsFor (horizontalStackView inHorizontalStackView : AutoLayoutHorizontalStackView,
                            optionalLastRightView ioOptionalLastRightView : inout NSView?,
                            flexibleSpaceView ioFlexibleSpaceView : inout AutoLayoutFlexibleSpace?,
                            _ ioContraints : inout [NSLayoutConstraint])

}

//--------------------------------------------------------------------------------------------------
