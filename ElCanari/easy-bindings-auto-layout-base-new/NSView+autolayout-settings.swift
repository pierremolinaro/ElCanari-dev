//
//  NSView-extension.swift
//  essai-gridview
//
//  Created by Pierre Molinaro on 29/10/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension NSView {

  //--------------------------------------------------------------------------------------------------------------------

  final func pmConfigureForAutolayout (hStretchingResistance inHorizontalStrechingResistance : PMLayoutStrechingConstraintPriority,
                                       vStrechingResistance inVerticalStrechingResistance : PMLayoutStrechingConstraintPriority) {
    self.translatesAutoresizingMaskIntoConstraints = false
    self.setContentHuggingPriority (inHorizontalStrechingResistance.cocoaPriority, for: .horizontal)
    self.setContentHuggingPriority (inVerticalStrechingResistance.cocoaPriority, for: .vertical)
    self.setContentCompressionResistancePriority (.defaultHigh, for: .horizontal)
    self.setContentCompressionResistancePriority (.defaultHigh, for: .vertical)
  }

  //--------------------------------------------------------------------------------------------------------------------

  private static let mDefaultViewLayoutSettings = AutoLayoutViewSettings (
    vLayoutInHorizontalContainer: .fill,
    hLayoutInVerticalContainer: .fill
  )

  //--------------------------------------------------------------------------------------------------------------------

  @objc var pmLayoutSettings : AutoLayoutViewSettings { Self.mDefaultViewLayoutSettings }

  //--------------------------------------------------------------------------------------------------------------------

  @objc var pmLastBaselineRepresentativeView : NSView? { nil }

  //--------------------------------------------------------------------------------------------------------------------

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
