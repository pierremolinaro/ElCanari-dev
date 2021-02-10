//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class AutoLayoutSegmentedControlWithPages : NSSegmentedControl, EBUserClassNameProtocol {

  //····················································································································

  private var mDocumentView : AutoLayoutStackView
  private var mPages = [AutoLayoutStackView] ()
  private let mEqualWidth : Bool

  //····················································································································

  init (documentView inDocumentView : AutoLayoutStackView, equalWidth inEqualWidth : Bool) {
    self.mDocumentView = inDocumentView
    self.mEqualWidth = inEqualWidth
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.controlSize = .small
    self.segmentStyle = .roundRect
    self.font = NSFont.systemFont (ofSize: NSFont.smallSystemFontSize)
    self.target = self
    self.action = #selector (Self.selectedSegmentDidChange (_:))
  }

  //····················································································································

  required init?(coder inCoder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  override func ebCleanUp () {
    self.mSelectedTabIndexController?.unregister ()
    self.mSelectedTabIndexController = nil
    super.ebCleanUp ()
  }

  //····················································································································
  // ADD PAGE
  //····················································································································

  func addPage (title inTitle : String, pageView inPageView : AutoLayoutStackView) -> Self {
    self.segmentCount += 1
    self.setLabel (inTitle, forSegment: self.segmentCount - 1)
//    let textAttributes : [NSAttributedString.Key : Any] = [
//      NSAttributedString.Key.font : NSFont.systemFont (ofSize: NSFont.smallSystemFontSize)
//    ]
//    let attributedTitle = NSAttributedString (string: inTitle, attributes: textAttributes)
    self.mPages.append (inPageView)
    self.frame.size = self.intrinsicContentSize
    return self
  }

  //····················································································································

  func canHug () -> Self {
    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .horizontal)
    return self
  }

  //····················································································································

  override func resizeSubviews (withOldSize oldSize : NSSize) {
    super.resizeSubviews (withOldSize: oldSize)
    //Swift.print ("\(self.bounds)")
    if self.mEqualWidth, self.segmentCount > 1 {
      let width = self.bounds.size.width / CGFloat (self.segmentCount) - 3.0
      for i in 0 ..< self.segmentCount {
        self.setWidth (width, forSegment: i)
      }
    }
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
