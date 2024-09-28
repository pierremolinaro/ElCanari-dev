//
//  HorizontalStackHierarchyProtocol.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/09/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

@MainActor protocol HorizontalStackHierarchyProtocol : AnyObject {

  func appendInHorizontalHierarchy (_ inView : NSView)

  func prependInHorizontalHierarchy (_ inView : NSView)

  func removeInHorizontalHierarchy (_ inView : NSView)

  func buildConstraintsFor (horizontalStackView inHorizontalStackView : AutoLayoutHorizontalStackView,
                            optionalLastRightView ioOptionalLastRightView : inout NSView?,
                            flexibleSpaceView ioFlexibleSpaceView : inout HorizontalStackFlexibleSpace?,
                            _ ioContraints : inout [NSLayoutConstraint])

  func alignHorizontalGutters (_ ioGutters : inout [VerticalStackGutter],
                               _ ioContraints : inout [NSLayoutConstraint])

}

//--------------------------------------------------------------------------------------------------
