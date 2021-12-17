//
//  AutoLayoutCanariProjectDeviceTableView.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 13/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutCanariProjectDeviceTableView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariProjectDeviceTableView : AutoLayoutTableView {

  //····················································································································
  // INIT
  //····················································································································

  required init? (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  init (size inSize : EBControlSize) {
    super.init (size: inSize, addControlButtons: false)
    self.configure (
      allowsEmptySelection: true,
      allowsMultipleSelection: false,
      rowCountCallBack: { [weak self] in return self?.mModelArray.count ?? 0 },
      delegate: nil
    )
    self.addColumn_String (
      valueGetterDelegate: { [weak self] (_ inRow : Int) in return self?.mModelArray [inRow] },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (inAscending : Bool) in
        self?.mModelArray.sort { String.numericCompare ($0, inAscending, $1) }
      },
      title: "Symbol Types",
      minWidth: 30,
      maxWidth: 200,
      headerAlignment: .center,
      contentAlignment: .right
    )
  }

  //····················································································································
  //    Table view data source protocol
  //····················································································································

  private var mModelArray = StringArray ()

  //····················································································································

  private func setModel (_ inModel : StringArray) {
  //--- Assignment
    self.mModelArray = inModel
  //--- Tell Table view to reload
    self.sortAndReloadData ()
  }

  //····················································································································
  //    $array binding
  //····················································································································

  private var mArrayController : EBReadOnlyPropertyController? = nil

  final func bind_array (_ model : EBReadOnlyProperty_StringArray) -> Self {
    self.mArrayController = EBReadOnlyPropertyController (
      observedObjects: [model],
      callBack: { [weak self] in self?.update (from: model) }
    )
    return self
  }

  //····················································································································

  final func unbind_array () {
    self.mArrayController?.unregister ()
    self.mArrayController = nil
  }

  //····················································································································

  func update (from model : EBReadOnlyProperty_StringArray) {
    switch model.selection {
    case .empty, .multiple :
      self.setModel ([])
    case .single (let v) :
      self.setModel (v)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
