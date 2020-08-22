//
//  view-CanariIssueTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 25/07/2018.
//
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   CanariIssueTableView
//----------------------------------------------------------------------------------------------------------------------

class CanariIssueTableView : NSTableView, EBUserClassNameProtocol, NSTableViewDataSource, NSTableViewDelegate {

  //····················································································································
  //   init
  //····················································································································

  required init? (coder : NSCoder) {
    super.init (coder: coder)
    self.customInit ()
  }

  //····················································································································

  override init (frame : NSRect) {
    super.init (frame: frame)
    self.customInit ()
  }
  
  //····················································································································

  private final func customInit () {
    noteObjectAllocation (self)
    self.dataSource = self
    self.delegate = self
  }

  //····················································································································

  override func ebCleanUp () {
    super.ebCleanUp ()
    self.dataSource = nil
    self.delegate = nil
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  //    Segment control item display
  //····················································································································

  private weak var mSegmentedControl : NSSegmentedControl? = nil
  private var mSegmentedControlSegment = 0 // Not used if mSegmentedControl is nil

  //····················································································································

  func register (segmentedControl : NSSegmentedControl?, segment : Int) {
    self.mSegmentedControl = segmentedControl
    self.mSegmentedControlSegment = segment
    self.updateIssueDisplay ()
 }

  //····················································································································
  //    Selected issue display
  //····················································································································

  private weak var mIssueDisplayView : EBGraphicView? = nil

  //····················································································································

  func register (issueDisplayView : EBGraphicView?) {
    self.mIssueDisplayView = issueDisplayView
    self.updateIssueDisplay ()
  }

  //····················································································································

  private func updateIssueDisplay () {
    if self.selectedRow < 0 {
      self.mIssueDisplayView?.setIssue ([], .error)
      self.mHideIssueButton?.isEnabled = false
    }else{
      let selectedIssue = self.mModelArray [self.selectedRow]
      self.mIssueDisplayView?.setIssue (selectedIssue.pathes, selectedIssue.kind)
      self.mHideIssueButton?.isEnabled = true
    }
    var errorCount = 0
    var warningCount = 0
    for issue in self.mModelArray {
      switch issue.kind {
      case .error :
        errorCount += 1
      case .warning :
        warningCount += 1
      }
    }
    var image = NSImage (named: okStatusImageName)
    var title = ""
    if errorCount > 0 {
      image = NSImage (named: errorStatusImageName)
      title = "\(errorCount)"
    }else if warningCount > 0 {
      image = NSImage (named: warningStatusImageName)
      title = "\(warningCount)"
    }
  //---
    self.mSegmentedControl?.setImage (image, forSegment: self.mSegmentedControlSegment)
    self.mSegmentedControl?.setLabel (title, forSegment: self.mSegmentedControlSegment)
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
  //    Issues
  //····················································································································

  fileprivate var mModelArray = [CanariIssue] () {
    didSet {
      self.reloadData ()
      self.updateIssueDisplay ()
    }
  }

  //····················································································································

  func setIssues (_ inIssues : [CanariIssue]) {
    self.mModelArray = inIssues.sorted (by: CanariIssue.displaySortingCompare)
  }

  //····················································································································
  //    Table view data source protocol
  //····················································································································

  func numberOfRows (in tableView: NSTableView) -> Int {
    return self.mModelArray.count
  }

  //····················································································································

  func tableView (_ tableView: NSTableView, objectValueFor inTableColumn: NSTableColumn?, row: Int) -> Any? {
    var result : Any? = nil
    if inTableColumn?.identifier == NSUserInterfaceItemIdentifier ("image") {
      switch self.mModelArray [row].kind {
      case .warning :
        result = NSImage (named: warningStatusImageName)!
      case .error :
        result = NSImage (named: errorStatusImageName)!
      }
    }else if inTableColumn?.identifier == NSUserInterfaceItemIdentifier ("title") {
      result = self.mModelArray [row].message
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

  private var mIssueController : EBSimpleController? = nil

  //····················································································································

  func bind_issues (_ model : EBReadOnlyProperty_CanariIssueArray, file : String, line : Int) {
    self.mIssueController = EBSimpleController (
      observedObjects: [model],
      callBack: { self.update (from: model) }
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
      self.mModelArray = v
    case .multiple :
      self.mModelArray = []
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
