//
//  window-pdf-doc.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/02/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Quartz

//----------------------------------------------------------------------------------------------------------------------

fileprivate let ZoomInToolbarIdentifier = NSToolbarItem.Identifier ("ZoomIn")
fileprivate let ZoomOutToolbarIdentifier = NSToolbarItem.Identifier ("ZoomOut")
fileprivate let NextPageToolbarIdentifier = NSToolbarItem.Identifier ("NextPage")
fileprivate let PreviousPageToolbarIdentifier = NSToolbarItem.Identifier ("PreviousPage")
fileprivate let SaveAsToolbarIdentifier = NSToolbarItem.Identifier ("SaveAs")

//----------------------------------------------------------------------------------------------------------------------

class CanariPDFWindow : EBWindow, NSToolbarDelegate {

  //····················································································································

  private let mPDFView = PDFView (frame: NSRect ())
  private let mData : Data

  //····················································································································

  init (fileName : String, pdfData : Data) {
    mData = pdfData
  //--- Create window
    super.init (
      contentRect: NSRect (x: 0.0, y: 0.0, width: 800.0, height: 600.0),
      styleMask: [.titled, .closable, .resizable],
      backing: .buffered,
      defer: false
    )
    self.isReleasedWhenClosed = false
  //--- Title
    self.title = fileName
  //--- Set PDF view
    self.mPDFView.frame = self.contentView!.frame
    self.mPDFView.document = PDFDocument (data: pdfData)
    self.contentView = self.mPDFView
//--- Build toolbar
    let toolbar = NSToolbar (identifier: "PMPDFDocViewToolbar")
    toolbar.allowsUserCustomization = true
    toolbar.autosavesConfiguration = true
    toolbar.displayMode = .iconAndLabel
    toolbar.delegate = self
    self.toolbar = toolbar
  }

  //····················································································································
  //   TOOL BAR
  //····················································································································

  func toolbar (_ toolbar : NSToolbar,
                itemForItemIdentifier itemIdentifier : NSToolbarItem.Identifier,
                willBeInsertedIntoToolbar flag : Bool) -> NSToolbarItem? {
    let toolbarItem = NSToolbarItem (itemIdentifier: itemIdentifier)
    if itemIdentifier == ZoomInToolbarIdentifier {
      toolbarItem.label = "Zoom In"
      toolbarItem.paletteLabel = "Zoom In"
      toolbarItem.toolTip = "Zoom PDF Documentation In"
      toolbarItem.image = NSImage (named: "ZoomInToolbarImage")
      toolbarItem.target = self.mPDFView
      toolbarItem.action = #selector (PDFView.zoomIn(_:))
    }else if itemIdentifier == ZoomOutToolbarIdentifier {
      toolbarItem.label = "Zoom Out"
      toolbarItem.paletteLabel = "Zoom Out"
      toolbarItem.toolTip = "Zoom PDF Documentation Out"
      toolbarItem.image = NSImage (named: "ZoomOutToolbarImage")
      toolbarItem.target = self.mPDFView
      toolbarItem.action = #selector (PDFView.zoomOut(_:))
    }else if itemIdentifier == NextPageToolbarIdentifier {
      toolbarItem.label = "Next"
      toolbarItem.paletteLabel = "Next"
      toolbarItem.toolTip = "Go To Next Page"
      toolbarItem.image = NSImage (named: "NextToolbarImage")
      toolbarItem.target = self.mPDFView
      toolbarItem.action = #selector (PDFView.goToNextPage(_:))
    }else if itemIdentifier == PreviousPageToolbarIdentifier {
      toolbarItem.label = "Previous"
      toolbarItem.paletteLabel = "Previous"
      toolbarItem.toolTip = "Go To Previous Page"
      toolbarItem.image = NSImage (named: "PreviousToolbarImage")
      toolbarItem.target = self.mPDFView
      toolbarItem.action = #selector (PDFView.goToPreviousPage(_:))
    }else if itemIdentifier == SaveAsToolbarIdentifier {
      toolbarItem.label = "Save As..."
      toolbarItem.paletteLabel = "Save As..."
      toolbarItem.toolTip = "Save PDF Documentation In a File"
      toolbarItem.image = NSImage (named: "SaveAsToolbarImage")
      toolbarItem.target = self
      toolbarItem.action = #selector (CanariPDFWindow.saveDocumentAs(_:))
    }
    return toolbarItem
  }

  //····················································································································

  func toolbarDefaultItemIdentifiers (_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return [
      SaveAsToolbarIdentifier,
      .flexibleSpace,
      NextPageToolbarIdentifier,
      PreviousPageToolbarIdentifier,
      .flexibleSpace,
      ZoomInToolbarIdentifier,
      ZoomOutToolbarIdentifier
    ]
  }

  //····················································································································

  func toolbarAllowedItemIdentifiers (_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return [
      SaveAsToolbarIdentifier,
      NextPageToolbarIdentifier,
      PreviousPageToolbarIdentifier,
      ZoomInToolbarIdentifier,
      ZoomOutToolbarIdentifier,
      .flexibleSpace
    ]
  }

  //····················································································································

  @objc func saveDocumentAs (_ inSender : Any?) {
    let savePanel = NSSavePanel ()
    savePanel.allowedFileTypes = ["pdf"]
    savePanel.allowsOtherFileTypes = false
    savePanel.nameFieldStringValue = self.title
    savePanel.beginSheetModal (for: self) { inResponse in
      if inResponse == .OK, let url = savePanel.url {
        try? self.mData.write (to: url)
      }
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
