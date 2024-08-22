//
//  AutoLayoutFlexibleSpace.swift
//  ElCanari-Debug
//
//  Created by Pierre Molinaro on 19/08/2024.
//
//--------------------------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------------------------

@MainActor class AutoLayoutFlexibleSpace : NSView {

  // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

  @MainActor init () {
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.pmConfigureForAutolayout (hStretchingResistance: .lowest, vStrechingResistance: .lowest)
  }

  // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
    objectDidDeinitSoReleaseHiddenControllers ()
  }

  // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

//    override var intrinsicContentSize : NSSize { NSSize () }

  // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

  private static let mFlexibleSpaceLayoutSettings = AutoLayoutViewSettings (
    vLayoutInHorizontalContainer: .weakFill,
    hLayoutInVerticalContainer: .weakFill
  )

  // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

  override var pmLayoutSettings : AutoLayoutViewSettings { Self.mFlexibleSpaceLayoutSettings }

  // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

//  override func draw (_ inDirtyRect : NSRect) {
//    super.draw (inDirtyRect)
//    if debugAutoLayout () && !self.bounds.isEmpty {
//      DEBUG_FLEXIBLE_SPACE_FILL_COLOR.setFill ()
//      NSBezierPath.fill (self.bounds)
//      let bp = NSBezierPath (rect: self.bounds)
//      bp.lineWidth = 1.0
//      bp.lineJoinStyle = .round
//      DEBUG_STROKE_COLOR.setStroke ()
//      bp.stroke ()
//    }
//  }

  // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

}

//--------------------------------------------------------------------------------------------------------------------
