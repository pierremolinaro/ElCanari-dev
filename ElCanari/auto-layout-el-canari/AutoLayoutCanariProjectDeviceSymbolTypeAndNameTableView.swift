//
//  AutoLayoutCanariProjectDeviceSymbolTypeAndNameTableView.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 13/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutCanariProjectDeviceSymbolTypeAndNameTableView
//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariProjectDeviceSymbolTypeAndNameTableView : AutoLayoutTableView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // INIT
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (size inSize : EBControlSize) {
    super.init (size: inSize, addControlButtons: false)
    self.configure (
      allowsEmptySelection: true,
      allowsMultipleSelection: false,
      rowCountCallBack: { [weak self] in return self?.mModelArray.count ?? 0 },
      delegate: nil
    )
    self.addColumn_String (
      valueGetterDelegate: { [weak self] (_ inRow : Int) in return self?.mModelArray [inRow].left },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (inAscending : Bool) in
        self?.mModelArray.sort { String.numericCompare ($0.left, inAscending, $1.left) }
      },
      title: "Symbol Name",
      minWidth: 30,
      maxWidth: 200,
      headerAlignment: .center,
      contentAlignment: .right
    )
    self.addColumn_String (
      valueGetterDelegate: { [weak self] (_ inRow : Int) in return self?.mModelArray [inRow].right },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (inAscending : Bool) in
        self?.mModelArray.sort { inAscending ? ($0.right < $1.right) : ($0.right > $1.right) }
      },
      title: "Type",
      minWidth: 30,
      maxWidth: 200,
      headerAlignment: .center,
      contentAlignment: .left
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    Table view data source protocol
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mModelArray = TwoStringArray ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func setModel (_ inModel : TwoStringArray) {
  //--- Assignment
    self.mModelArray = inModel
  //--- Tell Table view to reload
    self.sortAndReloadData ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    $array binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mArrayController : EBObservablePropertyController? = nil

  final func bind_array (_ model : EBObservableProperty <TwoStringArray>) -> Self {
    self.mArrayController = EBObservablePropertyController (
      observedObjects: [model],
      callBack: { [weak self] in self?.update (from: model) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func unbind_array () {
//    self.mArrayController?.unregister ()
//    self.mArrayController = nil
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func update (from model : EBObservableProperty <TwoStringArray>) {
    switch model.selection {
    case .empty, .multiple :
      self.setModel ([])
    case .single (let v) :
      self.setModel (v)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
