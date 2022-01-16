//
//  AutoLayoutDragSourceButtonWithMenus.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutDragSourceButtonWithMenus : AutoLayoutBase_NSView {

  //····················································································································

  private var mDragSourceButton : AutoLayoutDragSourceButton

  //····················································································································

  init (tooltip inToolTip : String) {
    self.mDragSourceButton = AutoLayoutDragSourceButton (tooltip: inToolTip)
    super.init ()
  //---
     self.addSubview (self.mDragSourceButton)
  //--- Layout constraints
    var c = NSLayoutConstraint (item: self, attribute: .top, relatedBy: .equal, toItem: self.mDragSourceButton, attribute: .top, multiplier: 1.0, constant: 0.0)
    var constraints = [c]
    c = NSLayoutConstraint (item: self, attribute: .left, relatedBy: .equal, toItem: self.mDragSourceButton, attribute: .left, multiplier: 1.0, constant: 0.0)
    constraints.append (c)
    c = NSLayoutConstraint (item: self, attribute: .right, relatedBy: .equal, toItem: self.mDragSourceButton, attribute: .right, multiplier: 1.0, constant: 0.0)
    constraints.append (c)
    c = NSLayoutConstraint (item: self, attribute: .bottom, relatedBy: .equal, toItem: self.mDragSourceButton, attribute: .bottom, multiplier: 1.0, constant: AutoLayoutMenuButton.size)
    constraints.append (c)
    self.addConstraints (constraints)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  func register (draggedType : NSPasteboard.PasteboardType,
                 draggedObjectFactory : Optional < () -> (EBGraphicManagedObject, NSDictionary)? >,
                 scaleProvider : EBGraphicViewControllerProtocol) {
    self.mDragSourceButton.register (
      draggedType: draggedType,
      draggedObjectFactory: draggedObjectFactory,
      scaleProvider: scaleProvider
    )
  }

  //····················································································································

  func register (draggedType : NSPasteboard.PasteboardType,
                 draggedObjectImage : Optional < () -> EBShape? >,
                 scaleProvider : EBGraphicViewControllerProtocol) {
    self.mDragSourceButton.register (
      draggedType: draggedType,
      draggedObjectImage: draggedObjectImage,
      scaleProvider: scaleProvider
    )
  }

  //····················································································································

  func set (image inImage : NSImage?) {
    self.mDragSourceButton.image = inImage
    self.mDragSourceButton.imageScaling = .scaleProportionallyUpOrDown
  }

  //····················································································································

  func set (leftContextualMenu inMenu : NSMenu) {
    let button = AutoLayoutMenuButton (size: .small, menu: inMenu)
    self.addSubview (button)
    var c = NSLayoutConstraint (item: self, attribute: .left, relatedBy: .equal, toItem: button, attribute: .left, multiplier: 1.0, constant: 0.0)
    var constraints = [c]
    c = NSLayoutConstraint (item: self, attribute: .bottom, relatedBy: .equal, toItem: button, attribute: .bottom, multiplier: 1.0, constant: 0.0)
    constraints.append (c)
    self.addConstraints (constraints)
  }

  //····················································································································

  func set (rightContextualMenu inMenu : NSMenu) {
    let button = AutoLayoutMenuButton (size: .small, menu: inMenu)
    self.addSubview (button)
    var c = NSLayoutConstraint (item: self, attribute: .right, relatedBy: .equal, toItem: button, attribute: .right, multiplier: 1.0, constant: 0.0)
    var constraints = [c]
    c = NSLayoutConstraint (item: self, attribute: .bottom, relatedBy: .equal, toItem: button, attribute: .bottom, multiplier: 1.0, constant: 0.0)
    constraints.append (c)
    self.addConstraints (constraints)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
