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
  private weak var mAttachedView : CanariViewWithKeyView?

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
    //--- View to attach
      let possibleViewToAttach : CanariViewWithKeyView?
      switch self.selectedSegment {
      case 0 : possibleViewToAttach = mView0
      case 1 : possibleViewToAttach = mView1
      case 2 : possibleViewToAttach = mView2
      case 3 : possibleViewToAttach = mView3
      case 4 : possibleViewToAttach = mView4
      case 5 : possibleViewToAttach = mView5
      case 6 : possibleViewToAttach = mView6
      case 7 : possibleViewToAttach = mView7
      default : possibleViewToAttach = nil
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
