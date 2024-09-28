//
//  StackRootProtocol.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/09/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

@MainActor protocol StackRootProtocol : AnyObject {

  func append (_ inView : NSView)

  func prepend (_ inView : NSView)

  func remove (_ inView : NSView)

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
