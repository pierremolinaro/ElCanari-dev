//
//  AutoLayoutCanariBoardFontPopUpButton.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 16/01/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariBoardFontPopUpButton : AutoLayoutBase_NSPopUpButton {

  //····················································································································

  init () {
    super.init (pullsDown: false, size: .small)
  }

  //····················································································································

  required init?(coder inCoder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································
  // BUILD POPUP
  //····················································································································

  private func buildPopUpButton () {
    self.removeAllItems ()
    for str in self.mFontNames {
      self.addItem (withTitle: str)
      if str == self.mCurrentFontName {
        self.selectItem (at: self.numberOfItems - 1)
      }
    }
  }

  //····················································································································
  //  $currentFontName binding
  //····················································································································

  private var mCurrentFontNameController : EBObservablePropertyController? = nil
  private var mCurrentFontName : String? = nil

  //····················································································································

  final func bind_currentFontName (_ inObject : EBObservableProperty <String>) -> Self {
    self.mCurrentFontNameController = EBObservablePropertyController (
      observedObjects: [inObject],
      callBack: { [weak self] in self?.updateCurrentFontName (from: inObject) }
    )
    return self
  }

  //····················································································································

  fileprivate func updateCurrentFontName (from inObject : EBObservableProperty <String>) {
    switch inObject.selection {
    case .empty, .multiple :
      self.mCurrentFontName = nil
    case .single (let v) :
      self.mCurrentFontName = v
    }
    self.buildPopUpButton ()
  }

  //····················································································································
  //  $currentFontName binding
  //····················································································································

  private var mFontNamesController : EBObservablePropertyController? = nil
  private var mFontNames = [String] ()

  //····················································································································

  final func bind_fontNames (_ inObject : EBObservableProperty <StringArray>) -> Self {
    self.mFontNamesController = EBObservablePropertyController (
      observedObjects: [inObject],
      callBack: { [weak self] in self?.updateFontNames (from: inObject) }
    )
    return self
  }

  //····················································································································

  fileprivate func updateFontNames (from inObject : EBObservableProperty <StringArray>) {
    switch inObject.selection {
    case .empty, .multiple :
      self.mFontNames = []
    case .single (let v) :
      self.mFontNames = v
    }
    self.buildPopUpButton ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
