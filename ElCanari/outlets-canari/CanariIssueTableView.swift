//
//  view-CanariIssueTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 25/07/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariIssueTableView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CanariIssueTableView)
class CanariIssueTableView : NSTableView, EBUserClassNameProtocol, NSTableViewDataSource, NSTableViewDelegate {

  //····················································································································
  //   init
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
  //    Selected issue display
  //····················································································································

  private weak var mIssueDisplayView : CanariViewWithZoomAndFlip? = nil

  //····················································································································

  func register (issueDisplayView : CanariViewWithZoomAndFlip?) {
    self.mIssueDisplayView = issueDisplayView
    self.updateIssueDisplay ()
  }

  //····················································································································

  private func updateIssueDisplay () {
    if self.selectedRow < 0 {
      self.mIssueDisplayView?.setIssue (nil, .error)
      self.mHideIssueButton?.isEnabled = false
    }else{
      let selectedIssue = self.mModelArray [self.selectedRow]
      self.mIssueDisplayView?.setIssue (selectedIssue.mPath, selectedIssue.mKind)
      self.mHideIssueButton?.isEnabled = true
    }
  }

  //····················································································································
  //    Hide issue button
  //····················································································································

  private weak var mHideIssueButton : EBButton? = nil

  //····················································································································

  func register (hideIssueButton : EBButton?) {
    self.mHideIssueButton = hideIssueButton
    if let button = self.mHideIssueButton {
      button.target = self
      button.action = #selector (CanariIssueTableView.deselectAll(_:))
    }
    self.updateIssueDisplay ()
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
        result = NSImage (named: NSImage.Name ("NSStatusPartiallyAvailable"))!
      case .error :
        result = NSImage (named: NSImage.Name ("NSStatusUnavailable"))!
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
    self.updateIssueDisplay ()
  }

  //····················································································································
  //    $issues binding
  //····················································································································

  private var mIssueController : EBReadOnlyController_CanariIssueArray? = nil

  //····················································································································

  func bind_issues (_ model : EBReadOnlyProperty_CanariIssueArray, file : String, line : Int) {
    self.mIssueController = EBReadOnlyController_CanariIssueArray (
      models: model,
      callBack: { [weak self] in self?.update (from: model) }
    )
  }

  //····················································································································

  func unbind_issues () {
    self.mIssueController?.unregister ()
    self.mIssueController = nil
  }

  //····················································································································

  private func update (from model : EBReadOnlyProperty_CanariIssueArray) {
    switch model.prop {
    case .empty :
      self.mModelArray = []
    case .single (let v) :
      self.mModelArray = v.mIssues
    case .multiple :
      self.mModelArray = []
    }
    self.updateIssueDisplay ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
