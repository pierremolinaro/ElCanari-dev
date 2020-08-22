import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class CanariSegmentedControl : NSSegmentedControl, EBUserClassNameProtocol {

  //····················································································································
  //  properties
  //····················································································································

  private var mMasterView : NSView? = nil
  private var mAttachedView : CanariViewWithKeyView? = nil
  private var mPageViews = [CanariViewWithKeyView?] ()

  //····················································································································
  //  init
  //····················································································································

  required init? (coder : NSCoder) {
    super.init (coder: coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame : NSRect) {
    super.init (frame: frame)
    noteObjectAllocation (self)
  }

  //····················································································································

  override func ebCleanUp () {
    super.ebCleanUp ()
    self.mPageViews.removeAll ()
    self.mAttachedView = nil
    self.mMasterView = nil
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  func register (masterView : NSView?, _ inPageViews : [CanariViewWithKeyView?]) {
    self.mMasterView = masterView
    self.mPageViews = inPageViews
    self.selectViewFromSelectedSegmentIndex ()
  }

  //····················································································································
  //  selectedSegment
  //····················································································································

  override var selectedSegment : Int {
    didSet {
      if self.selectedSegment != oldValue {
        // NSLog ("self.selectedSegment \(self.selectedSegment), oldValue \(oldValue)")
        self.selectViewFromSelectedSegmentIndex ()
      }
    }
  }

  //····················································································································
  //  sendAction
  //····················································································································

  override func sendAction (_ inAction : Selector?, to target : Any?) -> Bool {
    self.selectViewFromSelectedSegmentIndex ()
    self.mController?.updateModel (self)
    return super.sendAction (inAction, to: target)
  }

  //····················································································································
  //  selectViewFromSelectedSegmentIndex
  //····················································································································

  func selectViewFromSelectedSegmentIndex () {
    // NSLog ("selectViewFromSelectedSegmentIndex")
    if let masterView = self.mMasterView {
    //--- View to attach
      var possibleViewToAttach : CanariViewWithKeyView? = nil
      if (self.selectedSegment >= 0) && (self.selectedSegment < self.mPageViews.count) {
        possibleViewToAttach = self.mPageViews [self.selectedSegment]
      }
    //--- Attach view
      if let viewToAttach = possibleViewToAttach {
        viewToAttach.frame = masterView.bounds
        viewToAttach.autoresizingMask = [.width, .height]
        if let attachedView = self.mAttachedView {
          attachedView.saveFirstResponder ()
          masterView.replaceSubview (attachedView, with: viewToAttach)
        }else{
          masterView.addSubview (viewToAttach, positioned: .below, relativeTo: nil)
        }
        self.mAttachedView = viewToAttach
      //--- Make First Responder
        viewToAttach.restoreFirstResponder ()
      }
    }
  }

  //····················································································································
  //    binding
  //····················································································································

  fileprivate func updateSelectedSegment (_ object : EBReadOnlyProperty_Int) {
    switch object.prop {
    case .empty :
      self.enableFromValueBinding (false)
    case .single (let v) :
      self.enableFromValueBinding (true)
      self.selectedSegment = v
    case .multiple :
      self.enableFromValueBinding (false)
    }
  }

  //····················································································································

  private var mController : Controller_CanariSegmentedControl_selectedPage? = nil

  //····················································································································

  func bind_selectedPage (_ object : EBReadWriteProperty_Int, file : String, line : Int) {
    self.mController = Controller_CanariSegmentedControl_selectedPage (object: object, outlet: self)
  }

  //····················································································································

  func unbind_selectedPage () {
    self.mController?.unregister ()
    self.mController = nil
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
//   Controller_CanariSegmentedControl_selectedPage
//----------------------------------------------------------------------------------------------------------------------

final class Controller_CanariSegmentedControl_selectedPage : EBSimpleController {

  private let mObject : EBReadWriteProperty_Int
  private let mOutlet : CanariSegmentedControl

  //····················································································································

  init (object : EBReadWriteProperty_Int, outlet : CanariSegmentedControl) {
    mObject = object
    mOutlet = outlet
    super.init (observedObjects: [object], callBack: { outlet.updateSelectedSegment (object) })
  }

  //····················································································································

  func updateModel (_ sender : CanariSegmentedControl) {
    _ = self.mObject.validateAndSetProp (self.mOutlet.selectedSegment, windowForSheet: sender.window)
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
