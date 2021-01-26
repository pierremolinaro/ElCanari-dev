//
//  CanariTabView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 03/12/2020.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class CanariTabView : NSTabView, NSTabViewDelegate, EBUserClassNameProtocol {

  //····················································································································

  required init? (coder : NSCoder) {
    super.init (coder: coder)
    noteObjectAllocation (self)
    self.delegate = self
  }

  //····················································································································

  override init (frame : NSRect) {
    super.init (frame: frame)
    noteObjectAllocation (self)
    self.delegate = self
  }

  //····················································································································

  func tabView (_ tabView : NSTabView, didSelect inOptionalTabViewItem : NSTabViewItem?) {
    if let tabViewItem = inOptionalTabViewItem {
      let index = self.indexOfTabViewItem (tabViewItem)
      if (index >= 0) && (index < self.numberOfTabViewItems) {
        self.mSelectedTabIndexController?.updateModel (index)
      }
    }
  }

  //····················································································································
  //  $selectedTabIndex binding
  //····················································································································

  private var mSelectedTabIndexController : Controller_CanariTabView_selectedTabIndex? = nil

  //····················································································································

  func bind_selectedTabIndex (_ model : EBReadWriteProperty_Int, file : String, line : Int) {
    self.mSelectedTabIndexController = Controller_CanariTabView_selectedTabIndex (
      selectedTabIndex: model,
      outlet: self
    )
  }

  //····················································································································

  func unbind_selectedTabIndex () {
    self.mSelectedTabIndexController?.unregister ()
    self.mSelectedTabIndexController = nil
  }

  //····················································································································

  fileprivate func update (from model : EBReadOnlyProperty_Int) {
    switch model.selection {
    case .empty :
      ()
    case .single (let v) :
      self.selectTabViewItem (at: v)
    case .multiple :
      ()
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
//   Controller Controller_CanariTabView_selectedTabIndex
//----------------------------------------------------------------------------------------------------------------------

final class Controller_CanariTabView_selectedTabIndex : EBReadOnlyPropertyController {

  private var mOutlet : CanariTabView
  private var mSelectedTabIndex  : EBReadWriteProperty_Int

  //····················································································································

  init (selectedTabIndex : EBReadWriteProperty_Int,
        outlet : CanariTabView) {
    self.mSelectedTabIndex = selectedTabIndex
    self.mOutlet = outlet
    super.init (observedObjects: [selectedTabIndex], callBack: { outlet.update (from: selectedTabIndex) } )
  }

  //····················································································································

  func updateModel (_ inNewIndex : Int) {
    _ = self.mSelectedTabIndex.validateAndSetProp (inNewIndex, windowForSheet: self.mOutlet.window)
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
