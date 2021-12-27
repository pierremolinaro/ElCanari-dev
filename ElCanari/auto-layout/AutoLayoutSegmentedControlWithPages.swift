//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutSegmentedControlWithPages : AutoLayoutBase_NSSegmentedControl {

  //····················································································································

  private var mDocumentView : AutoLayoutAbstractStackView
  private var mPages = [AutoLayoutAbstractStackView] ()

  //····················································································································

  init (documentView inDocumentView : AutoLayoutAbstractStackView,
        equalWidth inEqualWidth : Bool,
        size inSize : EBControlSize) {
    self.mDocumentView = inDocumentView
    super.init (equalWidth: inEqualWidth, size: inSize)

    self.target = self
    self.action = #selector (Self.selectedSegmentDidChange (_:))
  }

  //····················································································································

  required init?(coder inCoder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override func ebCleanUp () {
    self.mSelectedTabIndexController?.unregister ()
    self.mSelectedTabIndexController = nil
    self.mSegmentImageController?.unregister ()
    self.mSegmentImageController = nil
    self.mSegmentTitleController?.unregister ()
    self.mSegmentTitleController = nil
    self.mSelectedSegmentController?.unregister ()
    self.mSelectedSegmentController = nil
    super.ebCleanUp ()
  }

  //····················································································································
  // ADD PAGE
  //····················································································································

  final func addPage (title inTitle : String,
                      tooltip inTooltipString : String,
                      pageView inPageView : AutoLayoutAbstractStackView) -> Self {
    self.segmentCount += 1
    self.setLabel (inTitle, forSegment: self.segmentCount - 1)
    self.setToolTip (inTooltipString, forSegment: self.segmentCount - 1)
    if let segmentedCell = self.cell as? NSSegmentedCell {
      segmentedCell.setToolTip (inTooltipString, forSegment: self.segmentCount - 1)
    }
    self.mPages.append (inPageView)
    self.frame.size = self.intrinsicContentSize

    if self.segmentCount == 1 {
      self.setSelectedSegment (atIndex: 0)
    }
    return self
  }

  //····················································································································

  final func addPage (image inImageName : String,
                      tooltip inTooltipString : String,
                      pageView inPageView : AutoLayoutAbstractStackView) -> Self {
    self.segmentCount += 1
    self.setImage (NSImage (named: inImageName), forSegment: self.segmentCount - 1)
    self.setToolTip (inTooltipString, forSegment: self.segmentCount - 1)
    if let segmentedCell = self.cell as? NSSegmentedCell {
      segmentedCell.setToolTip (inTooltipString, forSegment: self.segmentCount - 1)
    }
    self.mPages.append (inPageView)
    self.frame.size = self.intrinsicContentSize

    if self.segmentCount == 1 {
      self.setSelectedSegment (atIndex: 0)
    }
    return self
  }

  //····················································································································

  func setSelectedSegment (atIndex inIndex : Int) {
    if self.segmentCount > 0 {
      if inIndex < 0 {
        self.selectedSegment = 0
      }else if inIndex >= self.segmentCount {
        self.selectedSegment = self.segmentCount - 1
      }else{
        self.selectedSegment = inIndex
      }
      self.selectedSegmentDidChange (nil)
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
    self.mSelectedSegmentController?.updateModel (self)
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
  //  $segmentImage binding
  //····················································································································

  private var mSegmentImageController : EBObservablePropertyController? = nil
  private var mSegmentImageIndex = 0

  //····················································································································

  final func bind_segmentImage (_ inObject : EBObservableProperty <NSImage>, segmentIndex inSegmentIndex : Int) -> Self {
    self.mSegmentImageIndex = inSegmentIndex
    self.mSegmentImageController = EBObservablePropertyController (
      observedObjects: [inObject],
      callBack: { self.updateImage (from: inObject) }
    )
    return self
  }

  //····················································································································

  fileprivate func updateImage (from inObject : EBObservableProperty <NSImage>) {
    switch inObject.selection {
    case .empty, .multiple :
      self.setImage (nil, forSegment: self.mSegmentImageIndex)
    case .single (let v) :
      self.setImage (v.isValid ? v : nil, forSegment: self.mSegmentImageIndex)
    }
  }

  //····················································································································
  //  $segmentTitle binding
  //····················································································································

  private var mSegmentTitleController : EBObservablePropertyController? = nil
  private var mSegmentTitleIndex = 0

  //····················································································································

  final func bind_segmentTitle (_ inObject : EBObservableProperty <String>, segmentIndex inSegmentIndex : Int) -> Self {
    self.mSegmentTitleIndex = inSegmentIndex
    self.mSegmentTitleController = EBObservablePropertyController (
      observedObjects: [inObject],
      callBack: { self.updateTitle (from: inObject) }
    )
    return self
  }

  //····················································································································

  fileprivate func updateTitle (from inObject : EBObservableProperty <String>) {
    switch inObject.selection {
    case .empty, .multiple :
      self.setLabel ("", forSegment: self.mSegmentTitleIndex)
    case .single (let v) :
      self.setLabel (v, forSegment: self.mSegmentTitleIndex)
    }
  }

  //····················································································································
  //  $selectedSegment binding
  //····················································································································

  private var mSelectedSegmentController : Controller_AutoLayoutSegmentedControl_selectedSegment? = nil

  //····················································································································

  final func bind_selectedSegment (_ inObject : EBReadWriteObservableEnumProtocol) -> Self {
    self.mSelectedSegmentController = Controller_AutoLayoutSegmentedControl_selectedSegment (
      object: inObject,
      outlet: self
    )
    return self
  }

  //····················································································································

  fileprivate func updateSelectedSegment (_ inObject : EBReadWriteObservableEnumProtocol) {
    self.selectedSegment = inObject.rawValue () ?? 0
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_AutoLayoutSegmentedControl_selectedSegment
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate final class Controller_AutoLayoutSegmentedControl_selectedSegment : EBObservablePropertyController {

  private let mObject : EBReadWriteObservableEnumProtocol
  private let mOutlet : AutoLayoutSegmentedControlWithPages

  //····················································································································

  init (object : EBReadWriteObservableEnumProtocol, outlet : AutoLayoutSegmentedControlWithPages) {
    self.mObject = object
    self.mOutlet = outlet
    super.init (observedObjects:[object], callBack: { outlet.updateSelectedSegment (object) })
  }

  //····················································································································

  func updateModel (_ sender : AutoLayoutSegmentedControlWithPages) {
    self.mObject.setFrom (rawValue: self.mOutlet.selectedSegment)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
