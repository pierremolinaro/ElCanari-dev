//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class AutoLayoutSegmentedControlWithPages : NSSegmentedControl, EBUserClassNameProtocol {

  //····················································································································

  private var mDocumentView : AutoLayoutStackView
  private var mPages = [NSView] ()

  //····················································································································

  init (documentView inDocumentView : AutoLayoutStackView) {
    self.mDocumentView = inDocumentView
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.target = self
    self.action = #selector (Self.selectedSegmentDidChange (_:))
  }

  //····················································································································

  required init?(coder inCoder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  @discardableResult static func make (documentView inDocumentView : AutoLayoutStackView) -> AutoLayoutSegmentedControlWithPages {
    let b = AutoLayoutSegmentedControlWithPages (documentView: inDocumentView)
    gCurrentStack?.addView (b, in: .leading)
    return b
  }

  //····················································································································
  // ADD PAGE
  //····················································································································

  @discardableResult func addPage (title inTitle : String, pageView inPageView : NSView) -> Self {
    self.segmentCount += 1
    self.setLabel (inTitle, forSegment: self.segmentCount - 1)
    self.mPages.append (inPageView)
    if self.segmentCount == 1 {
      self.selectedSegment = 0
      self.selectedSegmentDidChange (nil)
    }
    return self
  }

  //····················································································································
  // SELECTED TAB DID CHANGE
  //····················································································································

  @objc func selectedSegmentDidChange (_ inSender : Any?) {
    let newPage = self.mPages [self.selectedSegment]
    let allSubViews = self.mDocumentView.subviews
    for view in allSubViews {
      view.removeFromSuperview ()
    }
    self.mDocumentView.addView (newPage, in: .leading)
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
