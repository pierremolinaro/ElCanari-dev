//
//  CanariBoardTextFontPopUpButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 18/06/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariBoardTextFontPopUpButton
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariBoardTextFontPopUpButton : NSPopUpButton, EBUserClassNameProtocol {

  //····················································································································

  required init? (coder : NSCoder) {
    super.init (coder: coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame : NSRect) {
    super.init (frame: frame)
    noteObjectAllocation (self)
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  // MARK: -
  //····················································································································

  private var mFontsModel : StoredArrayOf_FontInProject? = nil
  private var mSelectionController : SelectionController_ProjectDocument_boardTextSelectionController? = nil
  private var mObserver : EBOutletEvent? = nil

  //····················································································································

  func register (fontsModel inFontsModel : StoredArrayOf_FontInProject,
                 selectionController inSelectionController : SelectionController_ProjectDocument_boardTextSelectionController) {
    self.mFontsModel = inFontsModel
    self.mSelectionController = inSelectionController
    let observer = EBOutletEvent ()
    self.mObserver = observer
    observer.mEventCallBack = { self.buildPopUpButton () }
    inFontsModel.addEBObserverOf_mFontName (observer)
    inSelectionController.selectedArray_property.addEBObserverOf_fontName (observer)
  }

  //····················································································································

  func unregister () {
    if let observer = self.mObserver {
      observer.mEventCallBack = nil
      self.mFontsModel?.removeEBObserverOf_mFontName (observer)
      self.mSelectionController?.selectedArray_property.removeEBObserverOf_fontName (observer)
      self.mObserver = nil
    }
    self.mFontsModel = nil
    self.mSelectionController = nil
  }

  //····················································································································

  private func buildPopUpButton () {
    //Swift.print ("buildPopUpButton")
    var fontNameSet = Set <String> ()
    if let selectedTexts = self.mSelectionController?.selectedArray {
      for text in selectedTexts {
        if let fontName = text.fontName {
          fontNameSet.insert (fontName)
        }
      }
      //Swift.print ("fontNameSet \(fontNameSet), selectedTexts \(selectedTexts.count)")
    }
  //---
    self.removeAllItems ()
    if let fontsModel = self.mFontsModel?.propval {
      for font in fontsModel {
        self.addItem (withTitle: font.mFontName)
        self.lastItem?.representedObject = font
        self.lastItem?.target = self
        self.lastItem?.action = #selector (CanariBoardTextFontPopUpButton.changeFontAction (_:))
        self.lastItem?.isEnabled = true
        if fontNameSet.contains (font.mFontName) {
          self.select (self.lastItem)
          let attributes : [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font : NSFont.boldSystemFont (ofSize: NSFont.smallSystemFontSize)
          ]
          let attributedString = NSAttributedString (string: font.mFontName, attributes: attributes)
          self.lastItem?.attributedTitle = attributedString
        }
      }
    }
  }

  //····················································································································

  @objc private func changeFontAction (_ inSender : NSMenuItem) {
    if let selectedTexts = self.mSelectionController?.selectedArray, let font = inSender.representedObject as? FontInProject {
      for text in selectedTexts {
        text.mFont = font
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
