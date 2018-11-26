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

  fileprivate var mModelArray = [CanariIssue] () {
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
      case .warning :
        result = NSImage (named: NSImage.Name ("orange20"))!
      case .error :
        result = NSImage (named: NSImage.Name ("red20"))!
      }
    }else if inTableColumn?.identifier == NSUserInterfaceItemIdentifier ("title") {
      result = mModelArray [row].mMessage
    }
    return result
  }

  //····················································································································
  //    Table view delegate
  //····················································································································

  func tableViewSelectionDidChange (_ notification: Notification) {
    self.mBoardView?.setIssue ((self.selectedRow < 0) ? nil : self.mModelArray [self.selectedRow].mPath)
  }

  //····················································································································
  //    $issues binding
  //····················································································································

  private var mIssueController : Controller_MergerIssueTableView_issues?

  func bind_issues (_ issues:EBReadOnlyProperty_CanariIssueArray, file:String, line:Int) {
    self.mIssueController = Controller_MergerIssueTableView_issues (issues:issues, outlet:self)
  }

  //····················································································································

  func unbind_issues () {
    self.mIssueController?.unregister ()
    self.mIssueController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_MergerIssueTableView_issues
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class Controller_MergerIssueTableView_issues : EBSimpleController {

  private let mModels : EBReadOnlyProperty_CanariIssueArray
  private let mOutlet : MergerIssueTableView

  //····················································································································

  init (issues : EBReadOnlyProperty_CanariIssueArray, outlet : MergerIssueTableView) {
    mModels = issues
    mOutlet = outlet
    super.init (observedObjects:[issues])
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
