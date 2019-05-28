//
//  view-CanariNetInfoTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/04/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// NOTE: CanariNetInfoTableView is view based
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariNetInfoTableView : EBTableView, NSTableViewDataSource, NSTableViewDelegate {

  //····················································································································

  @IBOutlet var mSubnetTableView : StringArrayTableView? = nil

  //····················································································································

  override func awakeFromNib () {
    super.awakeFromNib ()
    self.dataSource = self // NSTableViewDataSource protocol
    self.delegate = self // NSTableViewDelegate protocol
  }

  //····················································································································
  //   NSTableViewDataSource protocol
  //····················································································································

  func numberOfRows (in tableView: NSTableView) -> Int {
    return self.mDataSource.count
  }

  //····················································································································

  func tableView (_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
    self.reloadDataSource (self.mDataSource)
  }

  //····················································································································
  //   NSTableViewDelegate protocol
  //····················································································································

  func tableView (_ tableView : NSTableView,
                  viewFor inTableColumn : NSTableColumn?,
                  row inRowIndex : Int) -> NSView? {
    var result : NSTableCellView? = nil
    if let columnIdentifier = inTableColumn?.identifier {
      result = tableView.makeView (withIdentifier: columnIdentifier, owner: self) as? NSTableCellView
      if !reuseTableViewCells () {
        result?.identifier = nil // So result cannot be reused, will be freed
      }
      if columnIdentifier.rawValue == "netname" {
        result?.textField?.stringValue = self.mDataSource [inRowIndex].netName
      }else if columnIdentifier.rawValue == "netclass" {
        result?.textField?.stringValue = self.mDataSource [inRowIndex].netClassName
      }else if columnIdentifier.rawValue == "pincount" {
        result?.textField?.stringValue = "\(self.mDataSource [inRowIndex].pinCount)"
      }else if columnIdentifier.rawValue == "labelcount" {
        result?.textField?.stringValue = "\(self.mDataSource [inRowIndex].labelCount)"
      }
    }
    return result
  }

  //····················································································································

  func tableViewSelectionDidChange (_ notification: Notification) {
    var a = [String] ()
    if self.selectedRow >= 0 {
      a = self.computeSubnets (self.mDataSource [self.selectedRow].points)
    }
    self.mSubnetTableView?.reloadDataSource (a)
  }

  //····················································································································
  //  DATA SOURCE
  //····················································································································

  private var mDataSource = NetInfoArray ()

  //····················································································································

  func reloadDataSource (_ inDataSource : NetInfoArray) {
  //--- Note selected rows
    var selectedRowContents = Set <NetInfo> ()
    let currentSelectedRowIndexes = self.selectedRowIndexes
    for idx in currentSelectedRowIndexes {
      if idx < self.mDataSource.count {
        selectedRowContents.insert (self.mDataSource [idx])
      }
    }
  //--- Sort
    self.mDataSource = inDataSource
    for s in self.sortDescriptors.reversed () {
      if let key = s.key {
        if key == "netname" {
          if s.ascending {
            self.mDataSource.sort { $0.netName < $1.netName }
          }else{
            self.mDataSource.sort { $0.netName > $1.netName }
          }
        }else if key == "netclass" {
          if s.ascending {
            self.mDataSource.sort { $0.netClassName < $1.netClassName }
          }else{
            self.mDataSource.sort { $0.netClassName > $1.netClassName }
          }
        }else if key == "pincount" {
          if s.ascending {
            self.mDataSource.sort { $0.pinCount < $1.pinCount }
          }else{
            self.mDataSource.sort { $0.pinCount > $1.pinCount }
          }
        }else if key == "labelcount" {
          if s.ascending {
            self.mDataSource.sort { $0.labelCount < $1.labelCount }
          }else{
            self.mDataSource.sort { $0.labelCount > $1.labelCount }
          }
        }else{
          NSLog ("Key '\(key)' unknown in \(#file):\(#line)")
        }
      }
    }
    self.reloadData ()
  //--- Restore selection
    var newSelectedRowIndexes = IndexSet ()
    var idx = 0
    while idx < self.mDataSource.count {
      if selectedRowContents.contains (self.mDataSource [idx]) {
        newSelectedRowIndexes.insert (idx)
      }
      idx += 1
    }
    if (newSelectedRowIndexes.count == 0) && (self.mDataSource.count > 0) {
      if let firstIndex : Int = currentSelectedRowIndexes.first {
        if firstIndex < self.mDataSource.count {
          newSelectedRowIndexes.insert (firstIndex)
        }else{
          newSelectedRowIndexes.insert (self.mDataSource.count - 1)
        }
      }else{
        newSelectedRowIndexes.insert (0)
      }
    }
    self.selectRowIndexes (newSelectedRowIndexes, byExtendingSelection: false)
  }

  //····················································································································

  func update (from inModel : EBReadOnlyProperty_NetInfoArray) {
    switch inModel.prop {
    case .empty, .multiple :
      self.reloadDataSource ([])
    case .single (let unconnectedPadArray) :
      self.reloadDataSource (unconnectedPadArray)
    }
  }

  //····················································································································

  func object (at inIndex : Int) -> NetInfo {
    return self.mDataSource [inIndex]
  }

  //····················································································································
  //  $netInfo binding
  //····················································································································

  private var mController : EBSimpleController? = nil

  //····················································································································

  func bind_netInfo (_ model : EBReadOnlyProperty_NetInfoArray, file : String, line : Int) {
    self.mController = EBSimpleController (
      observedObjects: [model],
      callBack: { [weak self] in self?.update (from: model) }
    )
  }

  //····················································································································

  func unbind_netInfo () {
    self.mController?.unregister ()
    self.mController = nil
  }

  //····················································································································
  //  COMPUTE SUB NETS
  //····················································································································

  private func computeSubnets (_ inPointArray : NetInfoPointArray) -> StringArray {
  //--- Wire dictionary (for compute subnet accessibility)
    var wireDictionary = [Int : NetInfoPointArray] ()
    for point in inPointArray {
      for wire in point.wires {
        if let v = wireDictionary [wire] {
          wireDictionary [wire] = v + [point]
        }else{
          wireDictionary [wire] = [point]
        }
      }
    }
  //---
    var result = StringArray ()
    var unExploredPointSet = Set (inPointArray)
    while let aPoint = unExploredPointSet.first {
      unExploredPointSet.removeFirst ()
      var currentPointSet = Set <NetInfoPoint> ([aPoint])
      var exploreArray = [aPoint]
      var exploreWireSet = Set <Int> ()
      while let p = exploreArray.last {
        exploreArray.remove (at: exploreArray.count - 1)
        for wire in p.wires {
          if !exploreWireSet.contains (wire) {
            exploreWireSet.insert (wire)
            if let pts = wireDictionary [wire] {
              for pp in pts {
                if !currentPointSet.contains(pp) {
                  currentPointSet.insert (pp)
                  exploreArray.append (pp)
                  unExploredPointSet.remove (pp)
                }
              }
            }
          }
        }

      }
    //--- Build subnet description string
      var subnetDescription = ""
      for p in currentPointSet {
        if let pinName = p.pin {
          subnetDescription += " " + pinName
        }
      }
      for p in currentPointSet {
        for label in p.labels {
          subnetDescription += " " + label
        }
      }
      result.append (subnetDescription)
    }
  //---
    return result
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
