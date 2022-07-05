//
//  extension-ProjectDocument-print.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/04/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let PAPER_A4_MAX_SIZE_COCOA_UNIT   : CGFloat = 842.0
let PAPER_A4_MIN_SIZE_COCOA_UNIT   : CGFloat = 595.0
let PAPER_LEFT_MARGIN_COCOA_UNIT   : CGFloat =  72.0
let PAPER_RIGHT_MARGIN_COCOA_UNIT  : CGFloat =  72.0
let PAPER_TOP_MARGIN_COCOA_UNIT    : CGFloat =  72.0
let PAPER_BOTTOM_MARGIN_COCOA_UNIT : CGFloat =  72.0
let PAPER_GUTTER_WIDTH_COCOA_UNIT  : CGFloat =  13.0
let PAPER_GUTTER_HEIGHT_COCOA_UNIT : CGFloat =  13.0

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocumentSubClass {

  //····················································································································

  @objc override func validateMenuItem (_ inMenuItem : NSMenuItem) -> Bool {
    let validate : Bool
    if inMenuItem.action == #selector (Self.printDocument(_:)) {
      validate = (self.rootObject.mSelectedPageIndex == 2) || (self.rootObject.mSelectedPageIndex == 6) // Schematics, Board
    }else{
      validate = super.validateMenuItem (inMenuItem)
    }
    return validate
  }

  //····················································································································

  @objc override func printDocument (_ inSender : Any?) {
    if self.rootObject.mSelectedPageIndex == 2 {
      self.printSchematics ()
    }else if self.rootObject.mSelectedPageIndex == 6 {
      self.printBoard ()
    }
  }

  //····················································································································

  private func printSchematics () {
    if let schematicsView = self.mSchematicsView?.mGraphicView {
      let orientation : NSPrintInfo.PaperOrientation
      let pageWidth  : CGFloat
      let pageHeight : CGFloat
      switch self.rootObject.mSchematicSheetOrientation {
      case .a4Horizontal :
        pageWidth = PAPER_A4_MAX_SIZE_COCOA_UNIT
        pageHeight = PAPER_A4_MIN_SIZE_COCOA_UNIT
        orientation = .landscape
      case .a4Vertical :
        pageWidth = PAPER_A4_MIN_SIZE_COCOA_UNIT
        pageHeight = PAPER_A4_MAX_SIZE_COCOA_UNIT
        orientation = .portrait
      case .custom :
         pageWidth = canariUnitToCocoa (self.rootObject.mSchematicCustomWidth) + PAPER_LEFT_MARGIN_COCOA_UNIT + PAPER_RIGHT_MARGIN_COCOA_UNIT + 2.0
         pageHeight = canariUnitToCocoa (self.rootObject.mSchematicCustomHeight) + PAPER_TOP_MARGIN_COCOA_UNIT + PAPER_BOTTOM_MARGIN_COCOA_UNIT + 2.0
         orientation = (pageWidth >= pageHeight) ? .landscape : .portrait
      }
    //--- Build print view
      let sheets = self.rootObject.mSheets
      let printWidth = pageWidth - PAPER_LEFT_MARGIN_COCOA_UNIT - PAPER_RIGHT_MARGIN_COCOA_UNIT - 2.0
      let printHeight = pageHeight - PAPER_TOP_MARGIN_COCOA_UNIT - PAPER_BOTTOM_MARGIN_COCOA_UNIT - 2.0
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
      for sheet in sheets.values {
        self.rootObject.mSelectedSheet = sheet
        flushOutletEvents ()
        let data = schematicsView.dataWithPDF (inside: r)
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
      printInfo.leftMargin = PAPER_LEFT_MARGIN_COCOA_UNIT
      printInfo.topMargin = PAPER_TOP_MARGIN_COCOA_UNIT
      printInfo.rightMargin = PAPER_RIGHT_MARGIN_COCOA_UNIT
      printInfo.bottomMargin = PAPER_BOTTOM_MARGIN_COCOA_UNIT
      let printOperation = NSPrintOperation (view: printView)
      let title = self.windowForSheet!.title.deletingPathExtension + ".schematics"
      printOperation.jobTitle = title
      self.mPrintOperation = printOperation // It seems that printOperation should be retained
      printOperation.showsPrintPanel = true
      let printPanel = printOperation.printPanel
      printPanel.options = [printPanel.options, .showsPaperSize, .showsOrientation, .showsScaling, .showsCopies]
    //---
      self.runModalPrintOperation (
        printOperation,
        delegate: self,
        didRun: #selector (Self.documentDidRunModalPrintOperation (_:success:contextInfo:)),
        contextInfo: nil
      )
    }
  }

  //····················································································································

  private func printBoard () {
    if let boardView = self.mBoardView?.mGraphicView {
      let orientation : NSPrintInfo.PaperOrientation
      let pageWidth  : CGFloat
      let pageHeight : CGFloat
  //--- Board Bound box
      let printViewFrame : NSRect = boardView.contentsBoundingBox
      if printViewFrame.size.width > printViewFrame.size.height {
        pageWidth = PAPER_A4_MAX_SIZE_COCOA_UNIT
        pageHeight = PAPER_A4_MIN_SIZE_COCOA_UNIT
        orientation = .landscape
      }else{
        pageWidth = PAPER_A4_MIN_SIZE_COCOA_UNIT
        pageHeight = PAPER_A4_MAX_SIZE_COCOA_UNIT
        orientation = .portrait
      }
    //--- Draw Board
      let data = boardView.dataWithPDF (inside: printViewFrame)
      let imageView = NSImageView (frame: printViewFrame)
      imageView.image = NSImage (data: data)
    //--- Scaling factor
      let printableWidth = pageWidth - PAPER_LEFT_MARGIN_COCOA_UNIT - PAPER_RIGHT_MARGIN_COCOA_UNIT - 2.0
      let printableHeight = pageHeight - PAPER_BOTTOM_MARGIN_COCOA_UNIT - PAPER_TOP_MARGIN_COCOA_UNIT - 2.0
      let scalingFactor = min (1.0, printableWidth / printViewFrame.size.width, printableHeight / printViewFrame.size.height)
    //---
      let printInfo = NSPrintInfo.shared
//     Swift.print ("\(printInfo.imageablePageBounds)")
//     Swift.print ("\(printInfo.leftMargin) \(printInfo.topMargin) \(printInfo.rightMargin) \(printInfo.bottomMargin)")
      printInfo.orientation = orientation
      printInfo.paperSize = NSSize (width: pageWidth, height: pageHeight)
      printInfo.horizontalPagination = .automatic
      printInfo.verticalPagination = .automatic
      printInfo.scalingFactor = scalingFactor
      printInfo.isHorizontallyCentered = true
      printInfo.isVerticallyCentered = true
      printInfo.leftMargin = PAPER_LEFT_MARGIN_COCOA_UNIT
      printInfo.topMargin = PAPER_TOP_MARGIN_COCOA_UNIT
      printInfo.rightMargin = PAPER_RIGHT_MARGIN_COCOA_UNIT
      printInfo.bottomMargin = PAPER_BOTTOM_MARGIN_COCOA_UNIT
      let printOperation = NSPrintOperation (view: imageView)
      let title = self.windowForSheet!.title.deletingPathExtension + ".board"
      printOperation.jobTitle = title
      self.mPrintOperation = printOperation // It seems that printOperation should be retained
      printOperation.showsPrintPanel = true
      let printPanel = printOperation.printPanel
      printPanel.options = [printPanel.options, .showsPaperSize, .showsOrientation, .showsScaling, .showsCopies]
   //---
      self.runModalPrintOperation (
        printOperation,
        delegate: self,
        didRun: #selector (Self.documentDidRunModalPrintOperation (_:success:contextInfo:)),
        contextInfo: nil
      )
    }
  }

  //····················································································································

  @objc private func documentDidRunModalPrintOperation (_ inDocument : NSDocument,
                                                        success inSuccess : Bool,
                                                        contextInfo inUnusedContextInfo : Any?) {
     //    self.mPrintOperation = nil // Crash !
    DispatchQueue.main.async { self.mPrintOperation = nil }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
