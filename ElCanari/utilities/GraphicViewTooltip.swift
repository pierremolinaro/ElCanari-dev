//
//  Tooltip.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/05/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

typealias GraphicViewTooltipArray = [GraphicViewTooltip]

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   Tooltip
//——————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor class GraphicViewTooltip : NSObject, NSViewToolTipOwner {

  //································································································
  //   Properties
  //································································································

  let kind : CanariIssueKind
  let message : String
  let rect : NSRect

  //································································································

  init (kind inKind : CanariIssueKind, message inMessage : String, rect inRect : NSRect) {
    self.kind = inKind
    self.message = inMessage
    self.rect = inRect
    super.init ()
    noteObjectAllocation (self)
  }

  //································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //································································································
  //  NSViewToolTipOwner Protocol
  //································································································

  func view (_ view : NSView,
             stringForToolTip tag : NSView.ToolTipTag,
             point : NSPoint,
             userData data : UnsafeMutableRawPointer?) -> String {
    return self.message
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
