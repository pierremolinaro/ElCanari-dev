//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   presentErrorWindow
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func presentErrorWindow (_ file : String,
                         _ line : Int,
                         _ errorMessage : String) {
  if Thread.isMainThread {
    presentErrorWindowInMainThread (file, line, errorMessage)
  }else{
    DispatchQueue.main.async { presentErrorWindowInMainThread (file, line, errorMessage) }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate var gErrorWindows : [NSWindow] = []
fileprivate var gOrigin = NSPoint (x: 20.0, y: 20.0)

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func presentErrorWindowInMainThread (_ file : String,
                                                 _ line : Int,
                                                 _ errorMessage : String) {
  var message = "File: \(file)\n"
  message += "Line: \(line)\n"
  message += "Message: \(errorMessage)\n"
  let r = NSRect (origin: gOrigin, size: NSSize (width: 300.0, height: 200.0))
  gOrigin.x += 20.0
  gOrigin.y += 20.0
  let window = NSWindow (
    contentRect: r,
    styleMask: [.titled, .closable],
    backing: .buffered,
    defer: true
  )
  window.title = "Outlet Error"
  let contentView : NSView = window.contentView!
  let tfRect = NSInsetRect (contentView.bounds, 10.0, 10.0)
  let tf = NSTextField (frame: tfRect)
  tf.isEditable = false
  tf.isSelectable = true
  tf.font = .boldSystemFont (ofSize: 0.0)
  tf.textColor = .red
  tf.stringValue = message
  contentView.addSubview (tf)
  window.makeKeyAndOrderFront (nil)
  gErrorWindows.append (window)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————