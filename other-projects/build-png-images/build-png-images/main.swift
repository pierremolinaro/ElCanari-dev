//
//  main.swift
//  build-png-images
//
//  Created by Pierre Molinaro on 28/11/2018.
//  Copyright © 2018 Pierre Molinaro. All rights reserved.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa
// https://stackoverflow.com/questions/1320988/saving-cgimageref-to-a-png-file

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func writePNGImage(_ image: NSImage, to destinationURL: URL) {
  let size = image.size
  image.lockFocus ()
  let rep = NSBitmapImageRep (focusedViewRect: NSRect (x: 0.0, y: 0.0,width: size.width, height: size.height))
  image.unlockFocus ()
  let data = rep?.representation (using: .png, properties: [:])
  try! data!.write (to: destinationURL)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func writeCGImage(_ image: CGImage, to destinationURL: URL) {
  let destination = CGImageDestinationCreateWithURL (destinationURL as CFURL, kUTTypePNG, 1, nil)!
  CGImageDestinationAddImage (destination, image, nil)
  _ = CGImageDestinationFinalize (destination)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func buildImage (view inView : NSView, fileName : String) {
  let PDFdata : Data = inView.dataWithPDF (inside: inView.frame)
  let image = NSImage (data: PDFdata)!
  let url = URL (fileURLWithPath: fileName + ".png")
  writePNGImage (image, to: url)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let r = NSRect (x: 0.0, y:0.0, width: 40.0, height: 100.0)
var statusView = CanariStatusView (frame: r)
statusView.mDrawRed = true
buildImage (view: statusView, fileName: "canariErrorStatus")
statusView = CanariStatusView (frame: r)
statusView.mDrawOrange = true
buildImage (view: statusView, fileName: "canariWarningStatus")
statusView = CanariStatusView (frame: r)
statusView.mDrawGreen = true
buildImage (view: statusView, fileName: "canariOkStatus")
var view : NSView = MagnifyingGlassView (frame: NSRect (x: 0.0, y:0.0, width: 40.0, height: 40.0))
buildImage (view: view, fileName: "magnifyingGlass")
view = EditorInspectorView (frame: NSRect (x: 0.0, y:0.0, width: 60.0, height: 60.0))
buildImage (view: view, fileName: "editorInspector")
view = AlignmentCenterView (frame: NSRect (x: 0.0, y:0.0, width: 60.0, height: 60.0))
buildImage (view: view, fileName: "alignmentCenter")
view = AlignmentLeftView (frame: NSRect (x: 0.0, y:0.0, width: 60.0, height: 60.0))
buildImage (view: view, fileName: "alignmentLeft")
view = AlignmentRightView (frame: NSRect (x: 0.0, y:0.0, width: 60.0, height: 60.0))
buildImage (view: view, fileName: "alignmentRight")
view = AlignmentBottomView (frame: NSRect (x: 0.0, y:0.0, width: 60.0, height: 60.0))
buildImage (view: view, fileName: "alignmentBottom")
view = AlignmentTopView (frame: NSRect (x: 0.0, y:0.0, width: 60.0, height: 60.0))
buildImage (view: view, fileName: "alignmentTop")
view = AlignmentMiddleView (frame: NSRect (x: 0.0, y:0.0, width: 60.0, height: 60.0))
buildImage (view: view, fileName: "alignmentMiddle")
view = AlignmentBaselineView (frame: NSRect (x: 0.0, y:0.0, width: 60.0, height: 60.0))
buildImage (view: view, fileName: "alignmentBaseline")
