//
//  ProjectDocument-generate-product-pdf-files.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 31/07/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {

  //································································································

  func writePDFDrillFile (atPath inPath : String,
                          _ inProductRepresentation : ProductRepresentation,
                          _ inProductData : ProductData) throws {
    self.mProductFileGenerationLogTextView?.appendMessage ("Generating \(inPath.lastPathComponent)…")
    let pdfData = inProductRepresentation.pdf (
      items: .hole,
      mirror: .noMirror,
      backColor: self.rootObject.mPDFBoardBackgroundColor,
      grid: self.rootObject.mPDFProductGrid_property.propval
    )
    try pdfData.write (to: URL (fileURLWithPath: inPath))
    self.mProductFileGenerationLogTextView?.appendSuccess (" Ok\n")
  }

  //································································································

  func writePDFProductFile (atPath inPath : String,
                            _ inDescriptor : ArtworkFileGenerationParameters,
                            _ inLayerConfiguration : LayerConfiguration,
                            _ inProductRepresentation : ProductRepresentation,
                            _ inProductData : ProductData) throws {
    let path = inPath + inDescriptor.fileExtension + ".pdf"
    self.mProductFileGenerationLogTextView?.appendMessage ("Generating \(path.lastPathComponent)…")
    let mirror : ProductHorizontalMirror = inDescriptor.horizontalMirror
      ? .mirror (boardWidth: self.rootObject.boardBoundBox!.size.width)
      : .noMirror
    let pdfData = inProductRepresentation.pdf (
      items: inDescriptor.layerItems,
      mirror: mirror,
      backColor: self.rootObject.mPDFBoardBackgroundColor,
      grid: self.rootObject.mPDFProductGrid_property.propval
    )
    try pdfData.write (to: URL (fileURLWithPath: path))
    self.mProductFileGenerationLogTextView?.appendSuccess (" Ok\n")
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
