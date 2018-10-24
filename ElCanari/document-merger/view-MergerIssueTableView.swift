//
//  view-MergerIssueTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 25/07/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   MergerIssueTableView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(MergerIssueTableView)
class MergerIssueTableView : NSTableView, EBUserClassNameProtocol, NSTableViewDataSource, NSTableViewDelegate {

  //····················································································································
  //   Outlet
  //····················································································································

  @IBOutlet private weak var mBoardView : CanariViewWithZoomAndFlip? = nil

  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder:coder)
    self.customInit ()
  }

  //····················································································································

  override init (frame:NSRect) {
    super.init (frame:frame)
    self.customInit ()
  }
  
  //····················································································································

  private final func customInit () {
    noteObjectAllocation (self)
    self.dataSource = self
    self.delegate = self
  }
  
  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  //    Table view data source protocol
  //····················································································································

  fileprivate var mModelArray = [InstanceIssue] () {
    didSet {
      self.reloadData ()
    }
  }

  //····················································································································

  func numberOfRows (in tableView: NSTableView) -> Int {
    return mModelArray.count
  }

  //····················································································································

  func tableView (_ tableView: NSTableView, objectValueFor inTableColumn: NSTableColumn?, row: Int) -> Any? {
    var result : Any? = nil
    if inTableColumn?.identifier == NSUserInterfaceItemIdentifier ("image") {
      switch mModelArray [row].mKind {
      case .gap :
        result = NSImage (named: NSImage.Name ("orange20"))!
      case .intersecting, .outside :
        result = NSImage (named: NSImage.Name ("red20"))!
      }
    }else if inTableColumn?.identifier == NSUserInterfaceItemIdentifier ("title") {
      switch mModelArray [row].mKind {
      case .gap :
        result = "Gap"
      case .intersecting :
        result = "Intersection"
      case .outside :
        result = "Outside"
      }
    }
    return result
  }

  //····················································································································
  //    Table view delegate
  //····················································································································

  func tableViewSelectionDidChange (_ notification: Notification) {
    mBoardView?.setIssue ((self.selectedRow < 0) ? EBShape () : self.mModelArray [self.selectedRow].mShapes)
  }

  //····················································································································
  //    $issues binding
  //····················································································································

  private var mIssueController : Controller_MergerIssueTableView_issues?

  func bind_issues (_ issues:EBReadOnlyProperty_InstanceIssueArray, file:String, line:Int) {
    mIssueController = Controller_MergerIssueTableView_issues (issues:issues, outlet:self)
  }

  //····················································································································

  func unbind_issues () {
    mIssueController?.unregister ()
    mIssueController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_MergerIssueTableView_issues
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class Controller_MergerIssueTableView_issues : EBSimpleController {

  private let mModels : EBReadOnlyProperty_InstanceIssueArray
  private let mOutlet : MergerIssueTableView

  //····················································································································

  init (issues : EBReadOnlyProperty_InstanceIssueArray, outlet : MergerIssueTableView) {
    mModels = issues
    mOutlet = outlet
    super.init (observedObjects:[issues], outlet:outlet)
    self.eventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································

  private func updateOutlet () {
    switch mModels.prop {
    case .empty :
      mOutlet.mModelArray = []
    case .single (let v) :
      mOutlet.mModelArray = v.mIssues
    case .multiple :
      mOutlet.mModelArray = []
    }
  }

  //····················································································································

}


//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
