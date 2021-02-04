//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class ALPageView : AutoLayoutVerticalStackView {

  //····················································································································

  private let mSegmentedControl = NSSegmentedControl (frame: NSRect ())
  private var mDocumentView : NSView = AutoLayoutFlexibleSpaceView ()
  private var mPages = [AutoLayoutVerticalStackView] ()

  //····················································································································

  init (_ inPlacardContents : () -> Void) {
    super.init (margin: 0)

    let hStack = AutoLayoutHorizontalStackView (margin: 0)
    let vStack = AutoLayoutVerticalStackView (margin: 0).setSpacing (0.0)
    vStack.addView (self.mSegmentedControl, in: .leading)
    vStack.addView (ALLabel ("Page"), in: .leading)
    hStack.addView (vStack, in: .leading)
    hStack.addView (AutoLayoutFlexibleSpaceView (), in: .leading)

    let savedCurrentStack = gCurrentStack
    gCurrentStack = hStack
    inPlacardContents ()
    gCurrentStack = savedCurrentStack

    self.addView (hStack, in: .leading)
    self.addView (ALSeparator (), in: .leading)
    self.addView (self.mDocumentView, in: .leading)

    self.mSegmentedControl.target = self
    self.mSegmentedControl.action = #selector (Self.selectedSegmentDidChange (_:))
  }

  //····················································································································

  required init?(coder inCoder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  @discardableResult static func make (_ inPlacardContents : () -> Void) -> ALPageView {
    let b = ALPageView (inPlacardContents)
    gCurrentStack?.addView (b, in: .leading)
    return b
  }

  //····················································································································
  // ADD PAGE
  //····················································································································

  @discardableResult func addPage (_ inTitle : String, _ inContents : () -> Void) -> Self {
    self.mSegmentedControl.segmentCount += 1
    self.mSegmentedControl.setLabel (inTitle, forSegment: self.mSegmentedControl.segmentCount - 1)
    let newPageView = AutoLayoutVerticalStackView (margin: 0)
    let savedCurrentStack = gCurrentStack
    gCurrentStack = newPageView
    inContents ()
    gCurrentStack = savedCurrentStack
    self.mPages.append (newPageView)
    if self.mSegmentedControl.segmentCount == 1 {
      self.mSegmentedControl.selectedSegment = 0
      self.selectedSegmentDidChange (nil)
    }
    return self
  }

  //····················································································································
  // SELECTED TAB DID CHANGE
  //····················································································································

  @objc func selectedSegmentDidChange (_ inSender : Any?) {
    let newPage = self.mPages [self.mSegmentedControl.selectedSegment]
//    Swift.print ("BEGIN replaceSubview \(self.mDocumentView) by \(newPage)")
    self.replaceSubview (self.mDocumentView, with: newPage)
//    Swift.print ("END replaceSubview")
    self.mDocumentView = newPage
  }

  //····················································································································

//  override var intrinsicContentSize : NSSize {
//    let s = super.intrinsicContentSize
//    Swift.print ("ALPageView.intrinsicContentSize \(s)")
//    return s
//  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
