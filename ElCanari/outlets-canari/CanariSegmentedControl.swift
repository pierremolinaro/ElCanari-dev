import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CanariSegmentedControl) class CanariSegmentedControl : NSSegmentedControl, EBUserClassNameProtocol {

  //····················································································································
  //  init
  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder:coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame : NSRect) {
    super.init (frame: frame)
    noteObjectAllocation (self)
  }
  
  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  //  properties
  //····················································································································

  private weak var mMasterView : NSView? = nil
  private weak var mAttachedView : CanariViewWithKeyView? = nil
  private var mPageViews = [CanariViewWithKeyView?] ()

  //····················································································································

  func register (masterView : NSView?, _ inPageViews : [CanariViewWithKeyView?]) {
    self.mMasterView = masterView
    self.mPageViews = inPageViews
    selectViewFromSelectedSegmentIndex ()
  }

  //····················································································································
  //  selectedSegment
  //····················································································································

  override var selectedSegment : Int {
    didSet {
      if selectedSegment != oldValue {
        selectViewFromSelectedSegmentIndex ()
      }
    }
  }

  //····················································································································
  //  sendAction
  //····················································································································

  override func sendAction (_ inAction : Selector?, to target : Any?) -> Bool {
    selectViewFromSelectedSegmentIndex ()
    mController?.updateModel (self)
    return super.sendAction (inAction, to:target)
  }

  //····················································································································
  //  selectViewFromSelectedSegmentIndex
  //····················································································································

  func selectViewFromSelectedSegmentIndex () {
    if let masterView = mMasterView {
    //--- View to attach
      var possibleViewToAttach : CanariViewWithKeyView? = nil
      if (self.selectedSegment >= 0) && (self.selectedSegment < self.mPageViews.count) {
        possibleViewToAttach = self.mPageViews [self.selectedSegment]
      }
    //--- Attach view
      if let viewToAttach = possibleViewToAttach {
        viewToAttach.frame = masterView.bounds
        viewToAttach.autoresizingMask = [.width, .height]
        if let attachedView = mAttachedView {
          attachedView.saveFirstResponder ()
          masterView.replaceSubview (attachedView, with: viewToAttach)
        }else{
          masterView.addSubview (viewToAttach, positioned: .below, relativeTo: nil)
        }
        mAttachedView = viewToAttach
      //--- Make First Responder
        viewToAttach.restoreFirstResponder ()
      }
    }
  }

  //····················································································································
  //    binding
  //····················································································································

  private var mController : Controller_CanariSegmentedControl_selectedPage?

  func bind_selectedPage (_ object:EBReadWriteProperty_Int, file:String, line:Int) {
    mController = Controller_CanariSegmentedControl_selectedPage (object:object, outlet:self, file:file, line:line)
  }

  func unbind_selectedPage () {
    mController?.unregister ()
    mController = nil
    for view in self.mPageViews {
      view?.saveFirstResponder ()
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariSegmentedControl_selectedPage
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariSegmentedControl_selectedPage : EBSimpleController {

  private let mObject : EBReadWriteProperty_Int
  private let mOutlet : CanariSegmentedControl

  //····················································································································

  init (object : EBReadWriteProperty_Int, outlet : CanariSegmentedControl, file : String, line : Int) {
    mObject = object
    mOutlet = outlet
    super.init (observedObjects:[object])
    self.eventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································

  private func updateOutlet () {
    switch mObject.prop {
    case .empty :
      mOutlet.enableFromValueBinding (false)
    case .single (let v) :
      mOutlet.enableFromValueBinding (true)
      mOutlet.selectedSegment = v
    case .multiple :
      mOutlet.enableFromValueBinding (false)
    }
  }

  //····················································································································

  func updateModel (_ sender : CanariSegmentedControl) {
    _ = mObject.validateAndSetProp (mOutlet.selectedSegment, windowForSheet:sender.window)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
