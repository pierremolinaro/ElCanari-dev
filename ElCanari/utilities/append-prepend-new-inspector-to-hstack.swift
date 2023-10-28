//
//  prepend-new-inspector-to-hstack.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 21/11/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func append (inspector inInspector : NSView,
                        toHStack inBaseHorizontalStack : AutoLayoutHorizontalStackView) {
  let c = NSLayoutConstraint (item: inInspector, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: 250.0)
  inInspector.addConstraint (c)
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
  _ = inBaseHorizontalStack.appendView (verticalSeparator).appendView (vStack)
  closeButton.setClosureAction { [weak inBaseHorizontalStack, weak vStack] in
    if let s = vStack {
      inBaseHorizontalStack?.removeView (s)
    }
    inBaseHorizontalStack?.removeView (verticalSeparator)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func prepend (inspector inInspector : NSView,
                         toHStack inBaseHorizontalStack : AutoLayoutHorizontalStackView) {
  let c = NSLayoutConstraint (item: inInspector, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: 250.0)
  inInspector.addConstraint (c)
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
  _ = inBaseHorizontalStack.prependView (verticalSeparator).prependView (vStack)
  closeButton.setClosureAction { [weak inBaseHorizontalStack, weak vStack] in
    if let s = vStack {
      inBaseHorizontalStack?.removeView (s)
    }
    inBaseHorizontalStack?.removeView (verticalSeparator)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

