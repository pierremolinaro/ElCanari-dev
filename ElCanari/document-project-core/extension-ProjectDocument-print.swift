//
//  extension-ProjectDocument-print.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/04/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let SCHEMATIC_A4_MAX_SIZE_COCOA_UNIT : CGFloat = 842.0
let SCHEMATIC_A4_MIN_SIZE_COCOA_UNIT : CGFloat = 595.0
let SCHEMATIC_LEFT_MARGIN_COCOA_UNIT : CGFloat = 72.0
let SCHEMATIC_RIGHT_MARGIN_COCOA_UNIT : CGFloat = 72.0
let SCHEMATIC_TOP_MARGIN_COCOA_UNIT : CGFloat = 72.0
let SCHEMATIC_BOTTOM_MARGIN_COCOA_UNIT : CGFloat = 72.0
let SCHEMATIC_GUTTER_WIDTH_COCOA_UNIT : CGFloat = 13.0
let SCHEMATIC_GUTTER_HEIGHT_COCOA_UNIT : CGFloat = 13.0

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedProjectDocument {

  //····················································································································

  @objc override func validateMenuItem (_ inMenuItem : NSMenuItem) -> Bool {
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

  @objc override func printDocument (_ inSender : Any?) {
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
      switch self.rootObject.mSchematicSheetOrientation {
      case .a4Horizontal :
        pageWidth = SCHEMATIC_A4_MAX_SIZE_COCOA_UNIT
        pageHeight = SCHEMATIC_A4_MIN_SIZE_COCOA_UNIT
        orientation = .landscape
      case .a4Vertical :
        pageWidth = SCHEMATIC_A4_MIN_SIZE_COCOA_UNIT
        pageHeight = SCHEMATIC_A4_MAX_SIZE_COCOA_UNIT
        orientation = .portrait
      case .custom :
         pageWidth = canariUnitToCocoa (self.rootObject.mSchematicCustomWidth) + SCHEMATIC_LEFT_MARGIN_COCOA_UNIT + SCHEMATIC_RIGHT_MARGIN_COCOA_UNIT + 2.0
         pageHeight = canariUnitToCocoa (self.rootObject.mSchematicCustomHeight) + SCHEMATIC_TOP_MARGIN_COCOA_UNIT + SCHEMATIC_BOTTOM_MARGIN_COCOA_UNIT + 2.0
         orientation = (pageWidth >= pageHeight) ? .landscape : .portrait
      }
    //--- Build print view
      let sheets = self.rootObject.mSheets
      let printWidth = pageWidth - SCHEMATIC_LEFT_MARGIN_COCOA_UNIT - SCHEMATIC_RIGHT_MARGIN_COCOA_UNIT - 1.0
      let printHeight = pageHeight - SCHEMATIC_TOP_MARGIN_COCOA_UNIT - SCHEMATIC_BOTTOM_MARGIN_COCOA_UNIT - 1.0
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
      printInfo.leftMargin = SCHEMATIC_LEFT_MARGIN_COCOA_UNIT
      printInfo.topMargin = SCHEMATIC_TOP_MARGIN_COCOA_UNIT
      printInfo.rightMargin = SCHEMATIC_RIGHT_MARGIN_COCOA_UNIT
      printInfo.bottomMargin = SCHEMATIC_BOTTOM_MARGIN_COCOA_UNIT
      let printOperation = NSPrintOperation (view: printView) //, printInfo: printInfo)
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
    // DispatchQueue.main.async { self.mPrintOperation = nil }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
