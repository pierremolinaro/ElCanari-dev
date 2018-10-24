//
//  extension-MergerDocument-insert-array-of-boards.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/07/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension MergerDocument {

  //····················································································································

  func insertArrayOfBoards (atX inX : Int, y inY : Int) {
    if let panel = mInsertArrayOfBoardsPanel, let insertArrayOfBoardsPopUpButton = mInsertArrayOfBoardsPopUpButton {
    //--- Build popup button items
      insertArrayOfBoardsPopUpButton.removeAllItems ()
      var idx = 0
      for boardModel in self.rootObject.boardModels_property.propval {
        insertArrayOfBoardsPopUpButton.addItem (withTitle: boardModel.name)
        insertArrayOfBoardsPopUpButton.lastItem!.tag = idx
        idx += 1
      }
    //--- If X count is invalid, set to 1
      let xCount : Int? = Int (mInsertArrayOfBoardsXCountField?.stringValue ?? "")
      if let x = xCount {
        if x < 1 {
          mInsertArrayOfBoardsXCountField?.stringValue = "1"
        }
      }else{
        mInsertArrayOfBoardsXCountField?.stringValue = "1"
      }
    //--- If Y count is invalid, set to 1
      let yCount : Int? = Int (mInsertArrayOfBoardsYCountField?.stringValue ?? "")
      if let y = yCount {
        if y < 1 {
          mInsertArrayOfBoardsYCountField?.stringValue = "1"
        }
      }else{
        mInsertArrayOfBoardsYCountField?.stringValue = "1"
      }
    //--- Display panel
      self.windowForSheet?.beginSheet (panel, completionHandler: { (inResponse : NSApplication.ModalResponse) in
        if inResponse == NSApplication.ModalResponse.stop {
          if let xCount = Int (self.mInsertArrayOfBoardsXCountField?.stringValue ?? ""),
             let yCount = Int (self.mInsertArrayOfBoardsYCountField?.stringValue ?? "") {
            let boardModel = self.rootObject.boardModels_property.propval [insertArrayOfBoardsPopUpButton.selectedTag()]
            let boardModelWidth = boardModel.modelWidth
            let boardModelHeight = boardModel.modelHeight
            let rotation = QuadrantRotation (rawValue: self.mInsertArrayOfBoardsOrientation?.selectedSegment ?? 0)!
            var newBoardArray = [MergerBoardInstance] ()
            var y = inY
            for _ in 0 ..< yCount {
              var x = inX
              for _ in 0 ..< xCount {
                let newBoard = MergerBoardInstance (managedObjectContext: self.managedObjectContext())
                newBoard.myModel_property.setProp (boardModel)
                newBoard.instanceRotation = rotation
                newBoard.x = x
                newBoard.y = y
                self.rootObject.boardInstances_property.add (newBoard)
                newBoardArray.append (newBoard)
                x += boardModelWidth
              }
              y += boardModelHeight
            }
            self.mBoardInstanceController.setSelection (newBoardArray)
          }
        }
      })
    }
  }

  //····················································································································

}


//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
