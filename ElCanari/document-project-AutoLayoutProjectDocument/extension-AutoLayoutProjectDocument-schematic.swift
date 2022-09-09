//
//  extension-AutoLayoutProjectDocument-schematic.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 15/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {

  //····················································································································
  //    Update points and net
  //····················································································································

  func updateSchematicPointsAndNets () {
    var errorList = [String] ()
    self.rootObject.mSelectedSheet?.removeUnusedSchematicsPoints (&errorList)
    self.removeUnusedWires (&errorList)
    self.removeUnusedNets ()
    self.updateSelectedNetForRastnetDisplay ()
    self.invalidateERC ()
    if errorList.count > 0, let window = self.windowForSheet {
      let panel = NSPanel (
        contentRect: NSRect (x: 0, y: 0, width: 600, height: 300),
        styleMask: [.titled],
        backing: .buffered,
        defer: false
      )
      panel.hasShadow = true
      let mainView = AutoLayoutHorizontalStackView ().set (margins: 12)
      mainView.appendViewSurroundedByFlexibleSpaces (AutoLayoutApplicationImage ())
      let rightColumn = AutoLayoutVerticalStackView ()
      let title = AutoLayoutStaticLabel (title: "Schematic Internal Error", bold: true, size: .regular, alignment: .center)
        .set (alignment: .left)
        .setTextColor (.red)
        .expandableWidth ()
      _ = rightColumn.appendView (title)
      let text = AutoLayoutTextObserverView ().expandableWidth ()
      _ = rightColumn.appendView (text)
      let okButton = AutoLayoutSheetDefaultOkButton (
        title: "Perform Undo to restore consistent state",
        size: .regular,
        sheet: panel
      )
      rightColumn.appendViewPreceededByFlexibleSpace (okButton)
      _ = mainView.appendView (rightColumn)
      panel.contentView = AutoLayoutWindowContentView (view: mainView)
      let message = errorList.joined (separator: "\n")
      text.string = message
      window.beginSheet (panel) { [weak self] (inModalResponse) in self?.ebUndoManager.undo () }
    }
  }

  //····················································································································
  // Remove unused wires
  //····················································································································

  func removeUnusedWires (_ ioErrorList : inout [String]) {
    for object in self.rootObject.mSelectedSheet!.mObjects.values {
      if let wire = object as? WireInSchematic {
        if let p1 = wire.mP1, p1.mSheet == nil {
          wire.mP1 = nil
          wire.mP2 = nil
        }else if let p2 = wire.mP2, p2.mSheet == nil {
          wire.mP1 = nil
          wire.mP2 = nil
        }
        if (wire.mP1 == nil) && (wire.mP2 == nil) { // Useless wire, delete
          wire.mSheet = nil
        }else if (wire.mP1 == nil) != (wire.mP2 == nil) { // Invalid wire
          ioErrorList.append ("Invalid wire: mP1 \(wire.mP1?.objectIndex ?? 0), mP2 \(wire.mP2?.objectIndex ?? 0)")
        }
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
