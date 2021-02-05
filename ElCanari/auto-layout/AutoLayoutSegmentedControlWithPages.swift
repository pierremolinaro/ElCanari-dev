//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class AutoLayoutSegmentedControlWithPages : NSSegmentedControl, EBUserClassNameProtocol {

  //····················································································································

  private var mDocumentView : AutoLayoutStackView
  private var mPages = [AutoLayoutStackView] ()

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
  // ADD PAGE
  //····················································································································

  func addPage (title inTitle : String, pageView inPageView : AutoLayoutStackView) -> Self {
    self.segmentCount += 1
    self.setLabel (inTitle, forSegment: self.segmentCount - 1)
    self.mPages.append (inPageView)
    return self
  }

  //····················································································································
  // SELECTED TAB DID CHANGE
  //····················································································································

  @objc func selectedSegmentDidChange (_ inSender : Any?) {
    let newPage = self.mPages [self.selectedSegment]
    let allSubViews = self.mDocumentView.subviews
    for view in allSubViews {
      self.mDocumentView.removeView (view) // Do not use view.removeFromSuperview ()
    }
    self.mDocumentView.appendView (newPage)
    _ = self.mSelectedTabIndexController?.updateModel (withCandidateValue: self.selectedSegment, windowForSheet: self.window)
  }

  //····················································································································
  //  $selectedPage binding
  //····················································································································

  private var mSelectedTabIndexController : EBGenericReadWritePropertyController <Int>? = nil

  //····················································································································

  func bind_selectedPage (_ inObject : EBGenericReadWriteProperty <Int>) -> Self {
    self.mSelectedTabIndexController = EBGenericReadWritePropertyController <Int> (
      observedObject: inObject,
      callBack: { [weak self] in self?.update (from: inObject) }
    )
    return self
  }

  //····················································································································

//  func unbind_selectedPage () {
//    self.mSelectedTabIndexController?.unregister ()
//    self.mSelectedTabIndexController = nil
//  }

  //····················································································································

  fileprivate func update (from inObject : EBGenericReadWriteProperty <Int>) {
    switch inObject.selection {
    case .empty :
      ()
    case .single (let v) :
      self.selectedSegment = v
      self.selectedSegmentDidChange (nil)
    case .multiple :
      ()
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
