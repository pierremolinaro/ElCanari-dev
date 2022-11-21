//
//  prepend-new-inspector-to-hstack.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 21/11/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func prepend (inspector inInspector : NSView,
                         toHStack inBaseHorizontalStack : AutoLayoutHorizontalStackView) {
  let closeButton = AutoLayoutButton (title: "✖︎", size: .regular)
  closeButton.bezelStyle = .circular
  let header = AutoLayoutHorizontalStackView ()
    .set (margins: 8)
    .appendView (closeButton)
    .appendFlexibleSpace ()
  let verticalSeparator = AutoLayoutHorizontalStackView.VerticalSeparator ()
  let vStack = AutoLayoutVerticalStackView ()
    .appendView (header)
    .appendView (inInspector)
    .appendFlexibleSpace ()
  _ = inBaseHorizontalStack.prependView (verticalSeparator)
  _ = inBaseHorizontalStack.prependView (vStack)
  closeButton.setClosureAction { [weak inBaseHorizontalStack, weak vStack] in
    if let s = vStack {
      inBaseHorizontalStack?.removeView (s)
    }
    inBaseHorizontalStack?.removeView (verticalSeparator)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

