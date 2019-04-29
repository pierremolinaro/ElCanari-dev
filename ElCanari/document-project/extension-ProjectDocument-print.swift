//
//  extension-ProjectDocument-print.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/04/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let A4MaxSize : CGFloat = 842.0
let A4MinSize : CGFloat = 595.0
let SCHEMATICS_LEFT_MARGIN : CGFloat = 72.0
let SCHEMATICS_RIGHT_MARGIN : CGFloat = 72.0
let SCHEMATICS_TOP_MARGIN : CGFloat = 72.0
let SCHEMATICS_BOTTOM_MARGIN : CGFloat = 72.0

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedProjectDocument {

  //····················································································································

  override func validateMenuItem (_ inMenuItem : NSMenuItem) -> Bool {
    let validate : Bool
    let action = inMenuItem.action
    if action == #selector (ProjectDocument.printDocument(_:)) {
      validate = self.rootObject.mSelectedPageIndex == 2 // Schematics
    }else{
      validate = super.validateMenuItem (inMenuItem)
    }
    return validate
  }

  //····················································································································

  override func printDocument (_ inSender : Any?) {
    if self.rootObject.mSelectedPageIndex == 2 {
      self.printSchematics ()
    }
  }

  //····················································································································

  internal func printSchematics () {
    if let schematicsView = self.mSchematicsView {
      let orientation : NSPrintInfo.PaperOrientation
      let pageWidth  : CGFloat
      let pageHeight : CGFloat
      switch self.rootObject.mSchematicsSheetOrientation {
      case .horizontal :
        pageWidth = A4MaxSize
        pageHeight = A4MinSize
        orientation = .landscape
      case .vertical :
        pageWidth = A4MinSize
        pageHeight = A4MaxSize
        orientation = .portrait
      }
    //--- Build print view
      let sheets = self.rootObject.mSheets
      let printWidth = pageWidth - SCHEMATICS_LEFT_MARGIN - SCHEMATICS_RIGHT_MARGIN - 1.0
      let printHeight = pageHeight - SCHEMATICS_TOP_MARGIN - SCHEMATICS_BOTTOM_MARGIN - 1.0
      let printViewFrame = NSRect (
        x: 0.0,
        y: 0.0,
        width:  printWidth,
        height: printHeight * CGFloat (sheets.count)
      )
      let printView = NSView (frame: printViewFrame)
      let r = NSRect (
        x: 0.0,
        y: 0.0,
        width: printWidth,
        height: printHeight
      )
    //--- Draw sheets
      var yOffset : CGFloat = printHeight * CGFloat (sheets.count - 1)
      self.ebUndoManager.disableUndoRegistration ()
      let currentSelectedSheet = self.rootObject.mSelectedSheet
      for sheet in sheets {
        self.rootObject.mSelectedSheet = sheet
        flushOutletEvents ()
        let data = schematicsView.dataWithPDF (inside:r)
        let imageView = NSImageView (frame: r)
        imageView.image = NSImage (data: data)
        imageView.frame.origin.y += yOffset
        printView.addSubview (imageView)
        yOffset -= printHeight
      }
      self.rootObject.mSelectedSheet = currentSelectedSheet
      self.ebUndoManager.enableUndoRegistration ()
    //---
      let printInfo = NSPrintInfo.shared
 //     Swift.print ("\(printInfo.imageablePageBounds)")
 //     Swift.print ("\(printInfo.leftMargin) \(printInfo.topMargin) \(printInfo.rightMargin) \(printInfo.bottomMargin)")
      printInfo.orientation = orientation
      printInfo.paperSize = NSSize (width: pageWidth, height: pageHeight)
      printInfo.horizontalPagination = .automatic
      printInfo.verticalPagination = .automatic
      printInfo.scalingFactor = 1.0
      printInfo.isHorizontallyCentered = true
      printInfo.isVerticallyCentered = true
      printInfo.leftMargin = SCHEMATICS_LEFT_MARGIN
      printInfo.topMargin = SCHEMATICS_TOP_MARGIN
      printInfo.rightMargin = SCHEMATICS_RIGHT_MARGIN
      printInfo.bottomMargin = SCHEMATICS_BOTTOM_MARGIN
      let printOperation = NSPrintOperation (view: printView, printInfo: printInfo)
      self.mPrintOperation = printOperation // It seems that printOperation should be retained
      printOperation.showsPrintPanel = true
      let printPanel = printOperation.printPanel
      printPanel.options = [printPanel.options, .showsPaperSize, .showsOrientation, .showsScaling, .showsCopies]
    //---
//      self.runModalPrintOperation (printOperation, delegate: nil, didRun: nil, contextInfo: nil)
      self.runModalPrintOperation (
        printOperation,
        delegate: self,
        didRun: #selector (CustomizedProjectDocument.documentDidRunModalPrintOperation (_:success:contextInfo:)),
        contextInfo: nil
      )
    }
  }

  //····················································································································

  @objc func documentDidRunModalPrintOperation (_ inDocument : NSDocument,
                                                success inSuccess : Bool,
                                                contextInfo inUnusedContextInfo : Any?) {
     //    self.mPrintOperation = nil // Crash !
     DispatchQueue.main.async { self.mPrintOperation = nil }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
