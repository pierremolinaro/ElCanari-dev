//
//  CurrentCharacterController.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 17/11/2015.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CurrentCharacterController
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CurrentCharacterController) class CurrentCharacterController : CustomObjectController_PMFontDocument_selectedCharacter {

  private weak var mCharacterArray : ReadOnlyArrayOf_FontCharacterEntity? = nil

  //····················································································································

  override init () {
    super.init ()
    g_Preferences?.currentCharacterCodePoint.addEBObserver (mObjectObserver)
    mObjectObserver.setPostEventFunction ({[weak self] in self?.selectedCharacterDidChange () })
  }
  
  //····················································································································

  deinit {
    g_Preferences?.currentCharacterCodePoint.removeEBObserver (mObjectObserver)
  }

  //····················································································································

  final func setModel (_ object : FontRootEntity) {
    mCharacterArray = object.characters
    mObjectObserver.postEvent ()
  }
  
  //····················································································································

  final func selectedCharacterDidChange () {
//    let possibleIndex : Int? = unicodePointToIndex (g_Preferences?.currentCharacterCodePoint.propval)
    let possibleIndex : Int? = g_Preferences?.currentCharacterCodePoint.propval
    if let index = possibleIndex, let characterArray = mCharacterArray {
      switch characterArray.prop {
      case .noSelection, .multipleSelection :
        mSelectedObject = nil
      case .singleSelection (let array) :
        mSelectedObject = array [index - 32]
      }
    }else{
      mSelectedObject = nil
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
