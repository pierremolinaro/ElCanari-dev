//
//  AutoLayoutTabView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutTabView : AutoLayoutBase_NSView {

  //····················································································································

  private var mDocumentView = MyTabDocumentView ()
  private var mPages = [NSView] ()
  private var mPopUpButton : AutoLayoutBase_NSPopUpButton

  //····················································································································

  init (equalWidth inEqualWidth : Bool,
        size inSize : EBControlSize) {
    self.mPopUpButton = AutoLayoutBase_NSPopUpButton (pullsDown: false, size: inSize)
    super.init ()

    self.addSubview (self.mDocumentView)
    self.addSubview (self.mPopUpButton)

    self.mPopUpButton.target = self
    self.mPopUpButton.action = #selector (Self.selectedItemDidChange (_:))

  //--- Permanent tab view constraints
    var c = NSLayoutConstraint (item: self, attribute: .top, relatedBy: .equal, toItem: self.mPopUpButton, attribute: .top, multiplier: 1.0, constant: 0.0)
    var permanentConstraints = [c]
    c = NSLayoutConstraint (item: self, attribute: .centerX, relatedBy: .equal, toItem: self.mPopUpButton, attribute: .centerX, multiplier: 1.0, constant: 0.0)
    permanentConstraints.append (c)
    c = NSLayoutConstraint (item: self.mDocumentView, attribute: .top, relatedBy: .equal, toItem: self.mPopUpButton, attribute: .centerY, multiplier: 1.0, constant: 0.0)
    permanentConstraints.append (c)
    c = NSLayoutConstraint (item: self.mDocumentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
    permanentConstraints.append (c)
    c = NSLayoutConstraint (item: self.mDocumentView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0)
    permanentConstraints.append (c)
    c = NSLayoutConstraint (item: self.mDocumentView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0)
    permanentConstraints.append (c)
    self.addConstraints (permanentConstraints)
  }

  //····················································································································

  required init?(coder inCoder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································
  // ADD TAB
  //····················································································································

  final func addTab (title inTitle : String,
                     tooltip inTooltipString : String,
                     contentView inPageView : NSView) -> Self {
    self.mPopUpButton.addItem (withTitle: inTitle)
    self.mPages.append (inPageView)
    if self.mPages.count == 1 {
      self.setSelectedSegment (atIndex: 0)
    }
    return self
  }

  //····················································································································

  private var mCurrentTabView : NSView? = nil
  private var mConstraints = [NSLayoutConstraint] ()

  //····················································································································

  func setSelectedSegment (atIndex inIndex : Int) {
    if self.mPopUpButton.numberOfItems > 0 {
      if inIndex < 0 {
        self.mPopUpButton.select (self.mPopUpButton.item (at: 0))
      }else if inIndex >= self.mPopUpButton.numberOfItems {
        self.mPopUpButton.select (self.mPopUpButton.item (at: self.mPopUpButton.numberOfItems - 1))
      }else{
        self.mPopUpButton.select (self.mPopUpButton.item (at: inIndex))
      }
    //---
      self.removeConstraints (self.mConstraints)
      self.mConstraints.removeAll ()
      if let currentTabView = self.mCurrentTabView {
        currentTabView.removeFromSuperview ()
        self.mCurrentTabView = nil
      }
      let view = self.mPages [self.mPopUpButton.indexOfSelectedItem]
      self.mCurrentTabView = view
      self.addSubview (view)
      var c = NSLayoutConstraint (item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
      self.mConstraints.append (c)
      c = NSLayoutConstraint (item: self, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0.0)
      self.mConstraints.append (c)
      c = NSLayoutConstraint (item: self, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0.0)
      self.mConstraints.append (c)
      c = NSLayoutConstraint (item: self.mPopUpButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
      self.mConstraints.append (c)
      self.addConstraints (self.mConstraints)
    }
  }

  //····················································································································
  // SELECTED TAB DID CHANGE
  //····················································································································

  @objc func selectedItemDidChange (_ inSender : Any?) {
    let idx = self.mPopUpButton.indexOfSelectedItem
    if let controller = self.mSelectedTabIndexController {
      controller.updateModel (withValue: idx)
    }else{
      self.setSelectedSegment (atIndex: idx)
    }
  }

  //····················································································································
  //  $selectedPage binding
  //····················································································································

  private var mSelectedTabIndexController : EBGenericReadWritePropertyController <Int>? = nil

  //····················································································································

  final func bind_selectedPage (_ inObject : EBObservableMutableProperty <Int>) -> Self {
    self.mSelectedTabIndexController = EBGenericReadWritePropertyController <Int> (
      observedObject: inObject,
      callBack: { [weak self] in self?.update (from: inObject) }
    )
    return self
  }

  //····················································································································

  fileprivate func update (from inObject : EBObservableMutableProperty <Int>) {
    switch inObject.selection {
    case .empty :
      ()
    case .single (let v) :
      self.setSelectedSegment (atIndex: v)
    case .multiple :
      ()
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate final class MyTabDocumentView : AutoLayoutBase_NSView {

  //····················································································································

  override func draw (_ inDirtyRect: NSRect) {
    NSColor.windowBackgroundColor.setFill ()
    let bp = NSBezierPath (roundedRect: self.bounds, xRadius: 4.0, yRadius: 4.0)
    bp.fill ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
