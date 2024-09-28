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
                            optionalLastBottomView ioOptionalLastBottomView : inout NSView?,
                            flexibleSpaceView ioFlexibleSpaceView : inout VerticalStackFlexibleSpace?,
                            _ ioContraints : inout [NSLayoutConstraint])

}

//--------------------------------------------------------------------------------------------------
