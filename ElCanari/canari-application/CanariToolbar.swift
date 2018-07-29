//
//  PMSelectablePrefView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 05/11/2015.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let NAME_IN_PREFS = "CanariSelectedPreferences"


let MERGER_PREFS_INDEX = 8

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CanariToolbar) class CanariToolbar : NSToolbar, EBUserClassNameProtocol {
  @IBOutlet private var mMasterView : NSView?
  private var mCurrentView : NSView?
  private var mWindowDefaultTitle : String = ""

  @IBOutlet private var mTab0 : NSToolbarItem? = nil
  @IBOutlet private var mTab1 : NSToolbarItem? = nil
  @IBOutlet private var mTab2 : NSToolbarItem? = nil
  @IBOutlet private var mTab3 : NSToolbarItem? = nil
  @IBOutlet private var mTab4 : NSToolbarItem? = nil
  @IBOutlet private var mTab5 : NSToolbarItem? = nil
  @IBOutlet private var mTab6 : NSToolbarItem? = nil
  @IBOutlet private var mTab7 : NSToolbarItem? = nil
  @IBOutlet private var mTab8 : NSToolbarItem? = nil

  @IBOutlet private var mView0 : NSView? = nil
  @IBOutlet private var mView1 : NSView? = nil
  @IBOutlet private var mView2 : NSView? = nil
  @IBOutlet private var mView3 : NSView? = nil
  @IBOutlet private var mView4 : NSView? = nil
  @IBOutlet private var mView5 : NSView? = nil
  @IBOutlet private var mView6 : NSView? = nil
  @IBOutlet private var mView7 : NSView? = nil
  @IBOutlet private var mView8 : NSView? = nil

  //····················································································································

  override init (identifier: SW34_NSToolbar_Identifier) {
    super.init (identifier:identifier)
    noteObjectAllocation (self)
  }
  
  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  override func awakeFromNib () {
    if let masterView = mMasterView {
      mWindowDefaultTitle = masterView.window!.title
    }
    mTab0?.target = self
    mTab0?.action = #selector(CanariToolbar.toolbarItemAction(_:))
    mTab1?.target = self
    mTab1?.action = #selector(CanariToolbar.toolbarItemAction(_:))
    mTab2?.target = self
    mTab2?.action = #selector(CanariToolbar.toolbarItemAction(_:))
    mTab3?.target = self
    mTab3?.action = #selector(CanariToolbar.toolbarItemAction(_:))
    mTab4?.target = self
    mTab4?.action = #selector(CanariToolbar.toolbarItemAction(_:))
    mTab5?.target = self
    mTab5?.action = #selector(CanariToolbar.toolbarItemAction(_:))
    mTab6?.target = self
    mTab6?.action = #selector(CanariToolbar.toolbarItemAction(_:))
    mTab7?.target = self
    mTab7?.action = #selector(CanariToolbar.toolbarItemAction(_:))
    mTab8?.target = self
    mTab8?.action = #selector(CanariToolbar.toolbarItemAction(_:))
  //--- Get initially selected tab from preferences
    let df = UserDefaults ()
    let idx = df.integer (forKey: NAME_IN_PREFS) 
    switch idx {
    case 0 : selectProgrammaticallyFromTab (mTab0)
    case 1 : selectProgrammaticallyFromTab (mTab1)
    case 2 : selectProgrammaticallyFromTab (mTab2)
    case 3 : selectProgrammaticallyFromTab (mTab3)
    case 4 : selectProgrammaticallyFromTab (mTab4)
    case 5 : selectProgrammaticallyFromTab (mTab5)
    case 6 : selectProgrammaticallyFromTab (mTab6)
    case 7 : selectProgrammaticallyFromTab (mTab7)
    case 8 : selectProgrammaticallyFromTab (mTab8)
    default : break
    }
  }

  //····················································································································

  func selectProgrammaticallyFromTab (_ possibleTab : NSToolbarItem?) {
    if let tab = possibleTab {
      selectedItemIdentifier = tab.itemIdentifier
      toolbarItemAction (tab)
    }
  }

  //····················································································································

  @objc func toolbarItemAction (_ sender : NSObject) {
    var idx = 0
    if sender == mTab0 {
      selectViewFromSelectedSegmentIndex (mView0, title:mTab0?.label)
    }else if sender == mTab1 {
      idx = 1
      selectViewFromSelectedSegmentIndex (mView1, title:mTab1?.label)
    }else if sender == mTab2 {
      idx = 2
      selectViewFromSelectedSegmentIndex (mView2, title:mTab2?.label)
    }else if sender == mTab3 {
      idx = 3
      selectViewFromSelectedSegmentIndex (mView3, title:mTab3?.label)
    }else if sender == mTab4 {
      idx = 4
      selectViewFromSelectedSegmentIndex (mView4, title:mTab4?.label)
    }else if sender == mTab5 {
      idx = 5
      selectViewFromSelectedSegmentIndex (mView5, title:mTab5?.label)
    }else if sender == mTab6 {
      idx = 6
      selectViewFromSelectedSegmentIndex (mView6, title:mTab6?.label)
    }else if sender == mTab7 {
      idx = 7
      selectViewFromSelectedSegmentIndex (mView7, title:mTab7?.label)
    }else if sender == mTab8 {
      idx = 8
      selectViewFromSelectedSegmentIndex (mView8, title:mTab8?.label)
    }
  //--- Update prefs defaults
    let df = UserDefaults ()
    df.set (idx, forKey: NAME_IN_PREFS)
  }

  //····················································································································

  fileprivate func selectViewFromSelectedSegmentIndex (_ viewToAttach : NSView?, title : String?) {
    if let masterView = mMasterView {
    //--- Remove any view from master view
      let subviews : [NSView] = masterView.subviews
      if subviews.count > 0 {
        let viewToDetach = subviews [0]
        viewToDetach.removeFromSuperview ()
      }
    //--- Attach view
      if let unwViewToAttach = viewToAttach, let unwTitle = title {
        let attachedPageHeight = unwViewToAttach.frame.size.height
        let currentHeight = masterView.frame.size.height
        var r = masterView.window!.frame
        r.size.height += attachedPageHeight - currentHeight ;
        r.origin.y -= attachedPageHeight - currentHeight ;
        masterView.addSubview (unwViewToAttach)
        unwViewToAttach.frame = masterView.bounds
        #if swift(>=4)
          unwViewToAttach.autoresizingMask = [.width, .height]
        #else
          unwViewToAttach.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        #endif
        masterView.window!.title = unwTitle + " " + mWindowDefaultTitle
        masterView.window!.setFrame (r, display:true, animate:true)
      }
    }
  }

  //····················································································································

  func selectViewFromIndex (_ inIndex : Int) {
    switch inIndex {
    case 0 :
      selectProgrammaticallyFromTab (mTab0)
    case 1 :
      selectProgrammaticallyFromTab (mTab1)
    case 2 :
      selectProgrammaticallyFromTab (mTab2)
    case 3 :
      selectProgrammaticallyFromTab (mTab3)
    case 4 :
      selectProgrammaticallyFromTab (mTab4)
    case 5 :
      selectProgrammaticallyFromTab (mTab5)
    case 6 :
      selectProgrammaticallyFromTab (mTab6)
    case 7 :
      selectProgrammaticallyFromTab (mTab7)
    case 8 :
      selectProgrammaticallyFromTab (mTab8)
    default :
      break
    }
  //--- Update prefs defaults
    let df = UserDefaults ()
    df.set (inIndex, forKey: NAME_IN_PREFS)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
