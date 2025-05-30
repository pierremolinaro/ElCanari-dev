//
//  AutoLayoutTabView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 7/1/2023.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class AutoLayoutTabView : ALB_NSView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mDocumentView = MyTabDocumentView ()
  private var mPages = [NSView] ()
  private var mSegmentedControl : ALB_NSSegmentedControl

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (size inSize : EBControlSize) {
    self.mSegmentedControl = ALB_NSSegmentedControl (equalWidth: false, size: inSize.cocoaControlSize)
    super.init ()

    self.addSubview (self.mDocumentView)
    self.addSubview (self.mSegmentedControl)

    self.mSegmentedControl.target = self
    self.mSegmentedControl.action = #selector (Self.selectedItemDidChange (_:))

  //--- Permanent tab view constraints
    var permanentConstraints = [NSLayoutConstraint] ()
    permanentConstraints.add (y: self.topAnchor, equalTo: self.mSegmentedControl.topAnchor)
    permanentConstraints.add (x: self.centerXAnchor, equalTo: self.mSegmentedControl.centerXAnchor)
//    let c = NSLayoutConstraint (item: self.mDocumentView, attribute: .top, relatedBy: .equal, toItem: self.mSegmentedControl, attribute: .centerY, multiplier: 1.0, constant: 0.0)
//    permanentConstraints.append (c)
    permanentConstraints.add (y: self.mDocumentView.topAnchor, equalTo: self.mDocumentView.centerYAnchor)
    permanentConstraints.add (y: self.bottomAnchor, equalTo: self.mDocumentView.bottomAnchor)
    permanentConstraints.add (x: self.leftAnchor, equalTo: self.mDocumentView.leftAnchor)
    permanentConstraints.add (x: self.rightAnchor, equalTo: self.mDocumentView.rightAnchor)
    self.addConstraints (permanentConstraints)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init?(coder inCoder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // ADD TAB
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func addTab (title inTitle : String,
                     image inImage : NSImage? = nil,
                     tooltip inTooltipString : String,
                     contentView inPageView : NSView) -> Self {
    let n = self.mSegmentedControl.segmentCount
    self.mSegmentedControl.segmentCount = n + 1
    self.mSegmentedControl.setLabel (inTitle, forSegment: n)
    self.mSegmentedControl.setImage (inImage, forSegment: n)
    self.mSegmentedControl.setToolTip (inTooltipString, forSegment: n)
    self.mPages.append (inPageView)
    if n == 0 {
      self.selectTab (atIndex: 0)
    }
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mCurrentTabView : NSView? = nil
  private var mConstraints = [NSLayoutConstraint] ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func selectTab (atIndex inIndex : Int) {
    if self.mSegmentedControl.segmentCount > 0 {
      if inIndex < 0 {
        self.mSegmentedControl.selectedSegment = 0
      }else if inIndex >= self.mSegmentedControl.segmentCount {
        self.mSegmentedControl.selectedSegment = self.mSegmentedControl.segmentCount - 1
      }else{
        self.mSegmentedControl.selectedSegment = inIndex
      }
    //---
      self.removeConstraints (self.mConstraints)
      self.mConstraints.removeAll ()
      if let currentTabView = self.mCurrentTabView {
        currentTabView.removeFromSuperview ()
        self.mCurrentTabView = nil
      }
      let view = self.mPages [self.mSegmentedControl.indexOfSelectedItem]
      self.mCurrentTabView = view
      self.addSubview (view)
      var c = NSLayoutConstraint (item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
      self.mConstraints.append (c)
      c = NSLayoutConstraint (item: self, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0.0)
      self.mConstraints.append (c)
      c = NSLayoutConstraint (item: self, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0.0)
      self.mConstraints.append (c)
      c = NSLayoutConstraint (item: self.mSegmentedControl, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
      self.mConstraints.append (c)
      self.addConstraints (self.mConstraints)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // SELECTED TAB DID CHANGE
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc func selectedItemDidChange (_ inSender : Any?) {
    let idx = self.mSegmentedControl.selectedSegment
    if let controller = self.mSelectedTabIndexController {
      controller.updateModel (withValue: idx)
    }else{
      self.selectTab (atIndex: idx)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var indexOfSelectedItem : Int {
    return self.mSegmentedControl.indexOfSelectedItem
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $segmentImage binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mSegmentImageController = [Int : EBObservablePropertyController] ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_segmentImage (_ inObject : EBObservableProperty <NSImage>,
                                tabIndex inTabIndex : Int) -> Self {
    self.mSegmentImageController [inTabIndex] = EBObservablePropertyController (
      observedObjects: [inObject],
      callBack: { [weak self, inTabIndex] in self?.updateImage (from: inObject, tabIndex: inTabIndex) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func updateImage (from inObject : EBObservableProperty <NSImage>, tabIndex inTabIndex : Int) {
    switch inObject.selection {
    case .empty, .multiple :
      self.mSegmentedControl.setImage (nil, forSegment: inTabIndex)
    case .single (let v) :
      self.mSegmentedControl.setImage (v.isValid ? v : nil, forSegment: inTabIndex)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $selectedTab binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mSelectedTabIndexController : EBGenericReadWritePropertyController <Int>? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_selectedTab (_ inObject : EBObservableMutableProperty <Int>) -> Self {
    self.mSelectedTabIndexController = EBGenericReadWritePropertyController <Int> (
      observedObject: inObject,
      callBack: { [weak self] in self?.update (from: inObject) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func update (from inObject : EBObservableMutableProperty <Int>) {
    switch inObject.selection {
    case .empty :
      ()
    case .single (let v) :
      self.selectTab (atIndex: v)
    case .multiple :
      ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

fileprivate final class MyTabDocumentView : ALB_NSView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func draw (_ inDirtyRect: NSRect) {
    NSColor.windowBackgroundColor.setFill ()
    let bp = NSBezierPath (roundedRect: self.bounds, xRadius: 8.0, yRadius: 8.0)
    bp.fill ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
