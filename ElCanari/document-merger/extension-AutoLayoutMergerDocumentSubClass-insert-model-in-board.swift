//
//  extension-CustomizedMergerDocument-insert-model-in-board.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/07/2018.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutMergerDocumentSubClass {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func buildInsertModelInBoardMenuBuilder (_ mouseDownLocationInView : CanariPoint) -> NSMenu {
    let menu = NSMenu ()
    let allModels = self.mBoardModelController.objects
    if allModels.count > 0 {
      for model in allModels.values {
        menu.addItem (withTitle: "Insert '\(model.name)'", action: #selector (Self.insertModelInBoardAction (_:)), keyEquivalent: "")
        let lastItem = menu.item (at: menu.numberOfItems - 1)
        lastItem?.target = self
        lastItem?.representedObject = (model, mouseDownLocationInView)
      }
      menu.addItem (withTitle: "Insert Array…", action: #selector (Self.insertArrayOfModelsInBoardAction (_:)), keyEquivalent: "")
      let lastItem = menu.item (at: menu.numberOfItems - 1)
      lastItem?.target = self
      lastItem?.representedObject = mouseDownLocationInView
    }
    return menu
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func insertModelInBoardAction (_ inSender : NSMenuItem) {
    if let (boardModel, mouseDownLocationInView) = inSender.representedObject as? (BoardModel, CanariPoint) {
      let rotation = self.rootObject.modelInsertionRotation
      let newBoard = MergerBoardInstance (self.undoManager)
      newBoard.myModel_property.setProp (boardModel)
      newBoard.x = mouseDownLocationInView.x
      newBoard.y = mouseDownLocationInView.y
      newBoard.instanceRotation = rotation
      self.rootObject.boardInstances_property.add (newBoard)
      self.mBoardInstanceController.setSelection ([newBoard])
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func insertArrayOfModelsInBoardAction (_ inSender : NSMenuItem) {
    if let mouseDownLocationInView = inSender.representedObject as? CanariPoint {
    //--- Build model popup button
      let modelPopUpButton = ALB_NSPopUpButton (pullsDown: false, size: .small)
      for model in self.mBoardModelController.objects.values {
        modelPopUpButton.addItem (withTitle: model.name)
        let lastItem = modelPopUpButton.lastItem
        lastItem?.representedObject = model
      }
    //--- X and Y Count
      let xCountTextField = AutoLayoutIntField (minWidth: 56, size: .small).bind_value (self.mInsertArrayOfBoardsXCount, sendContinously: true)
      let yCountTextField = AutoLayoutIntField (minWidth: 56, size: .small).bind_value (self.mInsertArrayOfBoardsYCount, sendContinously: true)
    //--- Orientation
      let orientationSegmentedControl = AutoLayoutCanariOrientationSegmentedControl (size: .small)
        .bind_orientation (self.mInsertArrayOfBoardsOrientation)
    //--- Build panel
      let panel = NSPanel (
        contentRect: NSRect (x: 0, y: 0, width: 400, height: 200),
        styleMask: [.titled],
        backing: .buffered,
        defer: false
      )
      panel.hasShadow = true
      let mainView = AutoLayoutHorizontalStackView ().set (margins: .large)
      _ = mainView.appendViewSurroundedByFlexibleSpaces (AutoLayoutApplicationImage ())
        .appendFlexibleSpace ()
      let rightColumn = AutoLayoutVerticalStackView ()
      _ = rightColumn.appendViewSurroundedByFlexibleSpaces (AutoLayoutStaticLabel (title: "Insert an Array of Boards", bold: true, size: .regular, alignment: .center))
      _ = rightColumn.appendFlexibleSpace ()

      let grid = AutoLayoutVerticalStackView ()
      _ = grid.append (
        left: AutoLayoutStaticLabel (title: "Model", bold: false, size: .small, alignment: .center),
        right: modelPopUpButton
      )
      let hStackXCount = AutoLayoutHorizontalStackView ()
      _ = hStackXCount.appendView (xCountTextField)
      _ = hStackXCount.appendFlexibleSpace ()
      _ = grid.append (
        left: AutoLayoutStaticLabel (title: "X Count", bold: false, size: .small, alignment: .center),
        right: hStackXCount
      )
      let hStackYCount = AutoLayoutHorizontalStackView ()
      _ = hStackYCount.appendView (yCountTextField)
      _ = hStackYCount.appendFlexibleSpace ()
      _ = grid.append (
        left: AutoLayoutStaticLabel (title: "Y Count", bold: false, size: .small, alignment: .center),
        right: hStackYCount
      )
      _ = grid.append (
        left: AutoLayoutStaticLabel (title: "Orientation", bold: false, size: .small, alignment: .center),
        right: orientationSegmentedControl
      )
      _ = rightColumn.appendView (grid)

      _ = rightColumn.appendFlexibleSpace ()
      let lastLine = AutoLayoutHorizontalStackView ()
      let cancelButton = AutoLayoutSheetCancelButton (title: "Cancel", size: .regular)
      _ = lastLine.appendView (cancelButton)
      _ = lastLine.appendFlexibleSpace ()
      let okButton = AutoLayoutSheetDefaultOkButton (title: "Insert", size: .regular, sheet: panel)
      _ = lastLine.appendView (okButton)
      _ = rightColumn.appendView (lastLine)
      _ = mainView.appendViewPreceededByFlexibleSpace (rightColumn)
      panel.setContentView (mainView)
      self.windowForSheet?.beginSheet (panel) { (inResponse : NSApplication.ModalResponse) in
        DispatchQueue.main.async {
          flushOutletEvents ()
          if inResponse == .stop, let boardModel = modelPopUpButton.selectedItem?.representedObject as? BoardModel {
            let xCount = self.mInsertArrayOfBoardsXCount.propval
            let yCount = self.mInsertArrayOfBoardsYCount.propval
            // Swift.print ("xCount \(xCount), yCount \(yCount)")
            let boardModelWidth = boardModel.modelWidth
            let boardModelHeight = boardModel.modelHeight
            let overlapAmount = self.rootObject.overlapingArrangment ? boardModel.modelLimitWidth : 0
            let rotation = self.mInsertArrayOfBoardsOrientation.propval
            var newBoardArray = [MergerBoardInstance] ()
            var y = mouseDownLocationInView.y
            for _ in 0 ..< yCount {
              var x = mouseDownLocationInView.x
              for _ in 0 ..< xCount {
                let newBoard = MergerBoardInstance (self.undoManager)
                newBoard.myModel_property.setProp (boardModel)
                newBoard.instanceRotation = rotation
                newBoard.x = x
                newBoard.y = y
                self.rootObject.boardInstances_property.add (newBoard)
                newBoardArray.append (newBoard)
                switch rotation {
                case .rotation0, .rotation180 :
                  x += boardModelWidth - overlapAmount
                case .rotation90, .rotation270 :
                  x += boardModelHeight - overlapAmount
                }
              }
              switch rotation {
              case .rotation0, .rotation180 :
                y += boardModelHeight - overlapAmount
              case .rotation90, .rotation270 :
                y += boardModelWidth - overlapAmount
              }
            }
            self.mBoardInstanceController.setSelection (newBoardArray)
          }
        }
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
