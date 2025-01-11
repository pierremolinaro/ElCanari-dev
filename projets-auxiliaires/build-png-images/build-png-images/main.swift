//
//  main.swift
//  build-png-images
//
//  Created by Pierre Molinaro on 28/11/2018.
//  Copyright © 2018 Pierre Molinaro. All rights reserved.
//
//--------------------------------------------------------------------------------------------------

import Cocoa
// https://stackoverflow.com/questions/1320988/saving-cgimageref-to-a-png-file

//--------------------------------------------------------------------------------------------------

func writePNGImage (_ image: NSImage, to destinationURL: URL) {
  let size = image.size
  image.lockFocus ()
  let rep = NSBitmapImageRep (focusedViewRect: NSRect (x: 0.0, y: 0.0,width: size.width, height: size.height))
  image.unlockFocus ()
  let data = rep?.representation (using: .png, properties: [:])
  let directoryURL = destinationURL.deletingLastPathComponent ()
  let fm = FileManager ()
  _ = try! fm.createDirectory (at: directoryURL, withIntermediateDirectories: true)
  try! data!.write (to: destinationURL)
}

//--------------------------------------------------------------------------------------------------

//func writeCGImage (_ image: CGImage, to destinationURL: URL) {
//  let destination = CGImageDestinationCreateWithURL (destinationURL as CFURL, kUTTypePNG, 1, nil)!
//  CGImageDestinationAddImage (destination, image, nil)
//  _ = CGImageDestinationFinalize (destination)
//}

//--------------------------------------------------------------------------------------------------

func buildImage_PNG (view inView : NSView, fileName inBaseName : String) {
  let pdfData : Data = inView.dataWithPDF (inside: inView.frame)
  let image = NSImage (data: pdfData)!
  let homeDirURL = FileManager.default.homeDirectoryForCurrentUser
  let url = homeDirURL.appendingPathComponent ("/Desktop/ElCanari/" + inBaseName, conformingTo: .png)
  let directoryURL = url.deletingLastPathComponent ()
  let fm = FileManager ()
  _ = try! fm.createDirectory (at: directoryURL, withIntermediateDirectories: true)
  writePNGImage (image, to: url)
}

//--------------------------------------------------------------------------------------------------

func buildImage_PDF (view inView : NSView, fileName inBaseName : String) {
  let PDFdata : Data = inView.dataWithPDF (inside: inView.frame)
  let homeDirURL = FileManager.default.homeDirectoryForCurrentUser
  let url = homeDirURL.appendingPathComponent ("/Desktop/ElCanari/" + inBaseName, conformingTo: .pdf)
//  let url = URL (fileURLWithPath: fileName + ".pdf")
  try! PDFdata.write (to: url)
}

//--------------------------------------------------------------------------------------------------

let r = NSRect (x: 0, y: 0, width: 40, height: 100)
var statusView = CanariStatusView (frame: r)
statusView.mDrawRed = true
buildImage_PDF (view: statusView, fileName: "canariErrorStatus")
statusView = CanariStatusView (frame: r)
statusView.mDrawOrange = true
buildImage_PDF (view: statusView, fileName: "canariWarningStatus")
statusView = CanariStatusView (frame: r)
statusView.mDrawGreen = true
buildImage_PDF (view: statusView, fileName: "canariOkStatus")
var view : NSView = MagnifyingGlassView (frame: NSRect (x: 0.0, y:0.0, width: 40.0, height: 40.0))
buildImage_PDF (view: view, fileName: "magnifyingGlass")
view = EditorInspectorView (frame: NSRect (x: 0.0, y:0.0, width: 60.0, height: 60.0))
buildImage_PDF (view: view, fileName: "editorInspector")
view = AlignmentCenterView (frame: NSRect (x: 0.0, y:0.0, width: 60.0, height: 60.0))
buildImage_PDF (view: view, fileName: "alignmentCenter")
view = AlignmentLeftView (frame: NSRect (x: 0.0, y:0.0, width: 60.0, height: 60.0))
buildImage_PDF (view: view, fileName: "alignmentLeft")
view = AlignmentRightView (frame: NSRect (x: 0.0, y:0.0, width: 60.0, height: 60.0))
buildImage_PDF (view: view, fileName: "alignmentRight")
view = AlignmentBottomView (frame: NSRect (x: 0.0, y:0.0, width: 60.0, height: 60.0))
buildImage_PDF (view: view, fileName: "alignmentBottom")
view = AlignmentTopView (frame: NSRect (x: 0.0, y:0.0, width: 60.0, height: 60.0))
buildImage_PDF (view: view, fileName: "alignmentTop")
view = AlignmentMiddleView (frame: NSRect (x: 0.0, y:0.0, width: 60.0, height: 60.0))
buildImage_PDF (view: view, fileName: "alignmentMiddle")
view = AlignmentBaselineView (frame: NSRect (x: 0.0, y:0.0, width: 60.0, height: 60.0))
buildImage_PDF (view: view, fileName: "alignmentBaseline")
view = UpDownRightLeftCursor (frame: NSRect (x: 0.0, y:0.0, width: 32.0, height: 32.0))
buildImage_PDF (view: view, fileName: "upDownRightLeftCursor")
view = RotationCursor (frame: NSRect (x: 0.0, y:0.0, width: 32.0, height: 32.0))
buildImage_PDF (view: view, fileName: "rotationCursor")
view = ArtworkView (frame: NSRect (x: 0.0, y:0.0, width: 300.0, height: 150.0))
buildImage_PDF (view: view, fileName: "artwork")
view = NonPlatedHole (frame: NSRect (x: 0, y:0, width: 32, height: 32))
buildImage_PDF (view: view, fileName: "nonPlatedHole")

//--------------------------------------------------------------------------------------------------
