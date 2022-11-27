//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutSegmentedControlWithPages : AutoLayoutBase_NSSegmentedControl {

  //····················································································································

  private var mDocumentView : AutoLayoutBase_NSStackView
  private var mPages = [AutoLayoutBase_NSStackView] ()

  //····················································································································

  init (documentView inDocumentView : AutoLayoutBase_NSStackView,
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
  // ADD PAGE
  //····················································································································

  final func addPage (title inTitle : String,
                      tooltip inTooltipString : String,
                      pageView inPageView : AutoLayoutBase_NSStackView) -> Self {
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
                      pageView inPageView : AutoLayoutBase_NSStackView) -> Self {
    let n = self.segmentCount
    self.segmentCount += 1
 //   self.setLabel ("", forSegment: n)
 //   self.setAlignment (.center, forSegment: n)
    self.setImage (NSImage (named: inImageName), forSegment: n)
    self.setImageScaling (.scaleProportionallyUpOrDown, forSegment: n)

    self.setToolTip (inTooltipString, forSegment: n)
    if let segmentedCell = self.cell as? NSSegmentedCell {
      segmentedCell.setToolTip (inTooltipString, forSegment: n)
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
    _ = self.mDocumentView.appendView (newPage)
    self.mSelectedTabIndexController?.updateModel (withValue: self.selectedSegment)
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

  private var mSegmentImageController = [Int : EBObservablePropertyController] ()

  //····················································································································

  final func bind_segmentImage (_ inObject : EBObservableProperty <NSImage>, segmentIndex inSegmentIndex : Int) -> Self {
    self.mSegmentImageController [inSegmentIndex] = EBObservablePropertyController (
      observedObjects: [inObject],
      callBack: { [weak self] in self?.updateImage (from: inObject, segmentIndex: inSegmentIndex) }
    )
    return self
  }

  //····················································································································

  fileprivate func updateImage (from inObject : EBObservableProperty <NSImage>, segmentIndex inSegmentIndex : Int) {
    switch inObject.selection {
    case .empty, .multiple :
      self.setImage (nil, forSegment: inSegmentIndex)
    case .single (let v) :
      self.setImage (v.isValid ? v : nil, forSegment: inSegmentIndex)
    }
  }

  //····················································································································
  //  $segmentTitle binding
  //····················································································································

  private var mSegmentTitleController = [Int : EBObservablePropertyController] ()

  //····················································································································

  final func bind_segmentTitle (_ inObject : EBObservableProperty <String>, segmentIndex inSegmentIndex : Int) -> Self {
    self.mSegmentTitleController [inSegmentIndex] = EBObservablePropertyController (
      observedObjects: [inObject],
      callBack: { [weak self] in self?.updateTitle (from: inObject, segmentIndex: inSegmentIndex) }
    )
    return self
  }

  //····················································································································

  fileprivate func updateTitle (from inObject : EBObservableProperty <String>, segmentIndex inSegmentIndex : Int) {
    switch inObject.selection {
    case .empty, .multiple :
      self.setLabel ("", forSegment: inSegmentIndex)
    case .single (let v) :
      self.setLabel (v, forSegment: inSegmentIndex)
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
  private weak var mOutlet : AutoLayoutSegmentedControlWithPages? = nil

  //····················································································································

  init (object : EBReadWriteObservableEnumProtocol, outlet inOutlet : AutoLayoutSegmentedControlWithPages) {
    self.mObject = object
    self.mOutlet = inOutlet
    super.init (observedObjects: [object], callBack: { [weak inOutlet] in inOutlet?.updateSelectedSegment (object) })
  }

  //····················································································································

  func updateModel (_ sender : AutoLayoutSegmentedControlWithPages) {
    if let outlet = self.mOutlet {
      self.mObject.setFrom (rawValue: outlet.selectedSegment)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
