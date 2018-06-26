import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CanariSegmentedControl) class CanariSegmentedControl : NSSegmentedControl, EBUserClassNameProtocol {
  @IBOutlet private weak var mMasterView : NSView?
  @IBOutlet private weak var mView0 : CanariViewWithKeyView?
  @IBOutlet private weak var mView1 : CanariViewWithKeyView?
  @IBOutlet private weak var mView2 : CanariViewWithKeyView?
  @IBOutlet private weak var mView3 : CanariViewWithKeyView?
  @IBOutlet private weak var mView4 : CanariViewWithKeyView?
  @IBOutlet private weak var mView5 : CanariViewWithKeyView?
  @IBOutlet private weak var mView6 : CanariViewWithKeyView?
  @IBOutlet private weak var mView7 : CanariViewWithKeyView?

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
  
  override func awakeFromNib() {
    selectViewFromSelectedSegmentIndex ()
    super.awakeFromNib ()
  }

  //····················································································································

  override var selectedSegment : Int {
    didSet {
      if selectedSegment != oldValue {
        selectViewFromSelectedSegmentIndex ()
      }
    }
  }

  //····················································································································

  override func sendAction (_ inAction : Selector?, to target : Any?) -> Bool {
    selectViewFromSelectedSegmentIndex ()
    mController?.updateModel (self)
    return super.sendAction (inAction, to:target)
  }

  //····················································································································

  func selectViewFromSelectedSegmentIndex () {
    if let masterView = mMasterView {
    //--- Remove any view from master view
      let subviews : [NSView] = masterView.subviews
      if subviews.count > 0 {
        let viewToDetach = subviews [0] as! CanariViewWithKeyView
      //--- Look for first responder in order to save it
        viewToDetach.saveFirstResponder ()
      //--- Remove from master view
        viewToDetach.removeFromSuperview ()
      }
    //--- View to attach
      let viewToAttach : CanariViewWithKeyView?
      switch self.selectedSegment {
      case 0 : viewToAttach = mView0
      case 1 : viewToAttach = mView1
      case 2 : viewToAttach = mView2
      case 3 : viewToAttach = mView3
      case 4 : viewToAttach = mView4
      case 5 : viewToAttach = mView5
      case 6 : viewToAttach = mView6
      case 7 : viewToAttach = mView7
      default : viewToAttach = nil
      }
    //--- Attach view
      if let unwViewToAttach = viewToAttach {
        masterView.addSubview (unwViewToAttach)
        unwViewToAttach.frame = masterView.bounds
        unwViewToAttach.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
      //--- Make First Responder
        unwViewToAttach.restoreFirstResponder ()
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
    mView0?.saveFirstResponder ()
    mView1?.saveFirstResponder ()
    mView2?.saveFirstResponder ()
    mView3?.saveFirstResponder ()
    mView4?.saveFirstResponder ()
    mView5?.saveFirstResponder ()
    mView6?.saveFirstResponder ()
    mView7?.saveFirstResponder ()
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
    super.init (observedObjects:[object], outlet:outlet)
//    mObject.addEBObserver (self)
  }

  //····················································································································
  
  override func unregister () {
    super.unregister ()
    mOutlet.removeFromEnabledFromValueDictionary ()
  }

  //····················································································································

  override func sendUpdateEvent () {
    switch mObject.prop {
    case .noSelection :
      mOutlet.enableFromValue (false)
    case .singleSelection (let v) :
      mOutlet.enableFromValue (true)
      mOutlet.selectedSegment = v
    case .multipleSelection :
      mOutlet.enableFromValue (false)
    }
    mOutlet.updateEnabledState ()
  }

  //····················································································································

  func updateModel (_ sender : CanariSegmentedControl) {
    _ = mObject.validateAndSetProp (mOutlet.selectedSegment, windowForSheet:sender.window)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
