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

  private var mDocumentView = AutoLayoutBase_NSView (backColor: .secondaryLabelColor)
  private var mPages = [NSView] ()
  private var mSegmentedControl : AutoLayoutBase_NSSegmentedControl

  //····················································································································

  init (equalWidth inEqualWidth : Bool,
        size inSize : EBControlSize) {
    self.mSegmentedControl = AutoLayoutBase_NSSegmentedControl (equalWidth: inEqualWidth, size: inSize)
//    self.mSegmentedControl.cell = MySegmentedControlCell ()
//    self.mSegmentedControl.cell?.controlTint = . // setControlTint:NSClearControlTint
    super.init (backColor: .yellow)

//    self.mSegmentedControl.wantsLayer = true
//    self.mSegmentedControl.layer?.backgroundColor = NSColor.red.cgColor

    self.addSubview (self.mDocumentView)
    self.addSubview (self.mSegmentedControl)
//    self.target = self
//    self.action = #selector (Self.selectedSegmentDidChange (_:))
  //--- Permanent tab view constraints
    var c = NSLayoutConstraint (item: self, attribute: .top, relatedBy: .equal, toItem: self.mSegmentedControl, attribute: .top, multiplier: 1.0, constant: 0.0)
    var permanentConstraints = [c]
    c = NSLayoutConstraint (item: self, attribute: .centerX, relatedBy: .equal, toItem: self.mSegmentedControl, attribute: .centerX, multiplier: 1.0, constant: 0.0)
    permanentConstraints.append (c)
    c = NSLayoutConstraint (item: self.mDocumentView, attribute: .top, relatedBy: .equal, toItem: self.mSegmentedControl, attribute: .centerY, multiplier: 1.0, constant: 0.0)
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

//  override func ebCleanUp () {
//    self.mSelectedTabIndexController?.unregister ()
//    self.mSelectedTabIndexController = nil
//    self.mSegmentImageController?.unregister ()
//    self.mSegmentImageController = nil
//    self.mSegmentTitleController?.unregister ()
//    self.mSegmentTitleController = nil
//    self.mSelectedSegmentController?.unregister ()
//    self.mSelectedSegmentController = nil
//    super.ebCleanUp ()
//  }

  //····················································································································
  // ADD PAGE
  //····················································································································

  final func addTab (title inTitle : String,
                     tooltip inTooltipString : String,
                     contentView inPageView : NSView) -> Self {
    self.mSegmentedControl.segmentCount += 1
    self.mSegmentedControl.setLabel (inTitle, forSegment: self.mSegmentedControl.segmentCount - 1)
    self.mSegmentedControl.setToolTip (inTooltipString, forSegment: self.mSegmentedControl.segmentCount - 1)
//    if let segmentedCell = self.mSegmentedControl.cell as? NSSegmentedCell {
//      segmentedCell.setToolTip (inTooltipString, forSegment: self.mSegmentedControl.segmentCount - 1)
//     // segmentedCell.isOpaque = true
////      segmentedCell.backgroundStyle = .raised
//    }
    self.mPages.append (inPageView)
    self.frame.size = self.intrinsicContentSize

    if self.mSegmentedControl.segmentCount == 1 {
      self.setSelectedSegment (atIndex: 0)
    }
    return self
  }

  //····················································································································

  func setSelectedSegment (atIndex inIndex : Int) {
    if self.mSegmentedControl.segmentCount > 0 {
      if inIndex < 0 {
        self.mSegmentedControl.selectedSegment = 0
      }else if inIndex >= self.mSegmentedControl.segmentCount {
        self.mSegmentedControl.selectedSegment = self.mSegmentedControl.segmentCount - 1
      }else{
        self.mSegmentedControl.selectedSegment = inIndex
      }
      self.selectedSegmentDidChange (nil)
    }
  }

  //····················································································································
  // SELECTED TAB DID CHANGE
  //····················································································································

  @objc func selectedSegmentDidChange (_ inSender : Any?) {
//    let newPage = self.mPages [self.selectedSegment]
//    let allSubViews = self.mDocumentView.subviews
//    for view in allSubViews {
//      self.mDocumentView.removeView (view) // Do not use view.removeFromSuperview ()
//    }
//    self.mDocumentView.appendView (newPage)
//    _ = self.mSelectedTabIndexController?.updateModel (withCandidateValue: self.selectedSegment, windowForSheet: self.window)
//    self.mSelectedSegmentController?.updateModel (self)
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

class MySegmentedControlCell : NSSegmentedCell {

  override var isOpaque: Bool { return true }

  override func interiorBackgroundStyle (forSegment segment: Int) -> NSView.BackgroundStyle {
    return .emphasized
  }

}
