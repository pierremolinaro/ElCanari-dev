//
//  window-pdf-doc.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/02/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa
import Quartz

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate let ZoomInToolbarIdentifier = NSToolbarItem.Identifier ("ZoomIn")
fileprivate let ZoomOutToolbarIdentifier = NSToolbarItem.Identifier ("ZoomOut")
fileprivate let NextPageToolbarIdentifier = NSToolbarItem.Identifier ("NextPage")
fileprivate let PreviousPageToolbarIdentifier = NSToolbarItem.Identifier ("PreviousPage")
fileprivate let SaveAsToolbarIdentifier = NSToolbarItem.Identifier ("SaveAs")

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariPDFWindow : EBWindow, NSToolbarDelegate {

  //····················································································································

  private let mPDFView = PDFView (frame: NSRect ())
  private let mData : Data

  //····················································································································

  init (fileName : String, pdfData : Data) {
    mData = pdfData
  //--- Create window
    super.init (
      contentRect: NSRect (x:0, y:0, width:800, height: 600),
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

  func toolbar (_ toolbar: NSToolbar,
                itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
    let toolbarItem = NSToolbarItem (itemIdentifier: itemIdentifier)
    if itemIdentifier == ZoomInToolbarIdentifier {
      toolbarItem.label = "Zoom In"
      toolbarItem.paletteLabel = "Zoom In"
      toolbarItem.toolTip = "Zoom PDF Documentation In"
      toolbarItem.image = NSImage (named: "ZoomInToolbarImage")
      toolbarItem.target = self
      toolbarItem.action = #selector (CanariPDFWindow.zoomIn(_:))
    }else if itemIdentifier == ZoomOutToolbarIdentifier {
      toolbarItem.label = "Zoom Out"
      toolbarItem.paletteLabel = "Zoom Out"
      toolbarItem.toolTip = "Zoom PDF Documentation Out"
      toolbarItem.image = NSImage (named: "ZoomOutToolbarImage")
      toolbarItem.target = self
      toolbarItem.action = #selector (CanariPDFWindow.zoomOut(_:))
    }else if itemIdentifier == NextPageToolbarIdentifier {
      toolbarItem.label = "Next"
      toolbarItem.paletteLabel = "Next"
      toolbarItem.toolTip = "Go To Next Page"
      toolbarItem.image = NSImage (named: "NextToolbarImage")
      toolbarItem.target = self
      toolbarItem.action = #selector (CanariPDFWindow.goToNextPage(_:))
    }else if itemIdentifier == PreviousPageToolbarIdentifier {
      toolbarItem.label = "Previous"
      toolbarItem.paletteLabel = "Previous"
      toolbarItem.toolTip = "Go To Previous Page"
      toolbarItem.image = NSImage (named: "PreviousToolbarImage")
      toolbarItem.target = self
      toolbarItem.action = #selector (CanariPDFWindow.goToPreviousPage(_:))
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
      .separator,
      NextPageToolbarIdentifier,
      PreviousPageToolbarIdentifier,
      .separator,
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
      .separator
    ]
  }

  //····················································································································

//- (BOOL) validateToolbarItem: (NSToolbarItem *)toolbarItem {
//  BOOL enable = NO ;
//  NSString * toolbarIdf = [toolbarItem itemIdentifier] ;
//  if ([toolbarIdf isEqualToString:NextPageToolbarIdentifier]) {
//    enable = [mPDFView canGoToNextPage] ;
//  }else if ([toolbarIdf isEqualToString:PreviousPageToolbarIdentifier]) {
//    enable = [mPDFView canGoToPreviousPage] ;
//  }else if ([toolbarIdf isEqualToString:ZoomInToolbarIdentifier]) {
//    enable = [mPDFView canZoomIn] ;
//  }else if ([toolbarIdf isEqualToString:ZoomOutToolbarIdentifier]) {
//    enable = [mPDFView canZoomOut] ;
//  }else if ([toolbarIdf isEqualToString:SaveAsToolbarIdentifier]) {
//    enable = YES ;
//  }
//  return enable ;
//}

  //····················································································································

  @objc func goToPreviousPage (_ inSender : Any?) {
    self.mPDFView.goToPreviousPage (inSender)
  }

  //····················································································································

  @objc func goToNextPage (_ inSender : Any?) {
    self.mPDFView.goToNextPage (inSender)
  }

  //····················································································································

  @objc func zoomOut (_ inSender : Any?) {
    self.mPDFView.zoomOut (inSender)
  }

  //····················································································································

  @objc func zoomIn (_ inSender : Any?) {
    self.mPDFView.zoomIn (inSender)
  }

  //····················································································································

  @objc func saveDocumentAs (_ inSender : Any?) {
    let savePanel = NSSavePanel ()
    savePanel.allowedFileTypes = ["pdf"]
    savePanel.allowsOtherFileTypes = false
    savePanel.nameFieldStringValue = self.title
    savePanel.beginSheetModal (for: self, completionHandler:  { (_ inResponse : NSApplication.ModalResponse) in
      if inResponse == .OK, let url = savePanel.url {
        try? self.mData.write (to: url)
      }
    })
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
