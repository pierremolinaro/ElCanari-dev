//
//  extension-AutoLayoutProjectDocument-board-drag-buttons.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 26/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {

  //····················································································································

  func boardTrackImageFactory () -> EBShape? {
    let p1 = BoardConnector (nil)
    p1.mX = 0
    p1.mY = 0
    let p2 = BoardConnector (nil)
    p2.mX = TRACK_INITIAL_SIZE_CANARI_UNIT
    p2.mY = TRACK_INITIAL_SIZE_CANARI_UNIT
    let track = BoardTrack (nil)
    track.mConnectorP1 = p1
    track.mConnectorP2 = p2
    return track.objectDisplay
  }

  //····················································································································

  func boardTextImageFactory () -> EBShape? {
    var result : EBShape? = nil
    if let font = self.rootObject.mFonts.first {
      self.ebUndoManager.disableUndoRegistration ()
      do{
        let boardText = BoardText (nil)
        boardText.mLayer = self.rootObject.mBoardLayerForNewText
        boardText.mFont = font
        result = boardText.objectDisplay
        boardText.mFont = nil
      }
      self.ebUndoManager.enableUndoRegistration ()
    }else{
      let alert = NSAlert ()
      alert.messageText = "Cannot Currently Add a Text: first, you need to add a Font."
      alert.informativeText = "This project does not embed any font. A font is needed for displaying texts in board."
      alert.addButton (withTitle: "Add Font")
      alert.addButton (withTitle: "Cancel")
      alert.beginSheetModal (for: self.windowForSheet!) { (inReturnCode) in
        if (inReturnCode == .alertFirstButtonReturn) {
          self.addFont (postAction: nil)
        }
      }
    }
    return result
  }


  //····················································································································

}