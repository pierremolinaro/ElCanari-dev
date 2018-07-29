//
//  NSImage-utilities.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 26/07/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

#if swift(>=4)
  let sw34_OnState  = NSControl.StateValue.on
  let sw34_OffState = NSControl.StateValue.off
  let sw34_MixedState = NSControl.StateValue.mixed
#else
  let sw34_OnState  = NSOnState
  let sw34_OffState = NSOffState
  let sw34_MixedState = NSMixedState
#endif

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

#if swift(>=4)
  typealias SW34_NSToolbar_Identifier = NSToolbar.Identifier
#else
  typealias SW34_NSToolbar_Identifier = String
#endif

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

#if swift(>=4)
  typealias SW34_ApplicationModalResponse =  NSApplication.ModalResponse
  let sw34_FileHandlingPanelOKButton = NSApplication.ModalResponse (NSFileHandlingPanelOKButton)
#else
  typealias SW34_ApplicationModalResponse = Int
  let sw34_FileHandlingPanelOKButton = NSFileHandlingPanelOKButton
#endif

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func sw34_imageNamed (_ inName : String) ->  NSImage {
  #if swift(>=4)
    return NSImage (named: NSImage.Name (inName))!
  #else
    return NSImage (named: inName)!
  #endif
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func sw34_columnIdentifier (_ inTableColumn: NSTableColumn) -> String {
  #if swift(>=4)
    return inTableColumn.identifier.rawValue
  #else
    return inTableColumn.identifier
  #endif
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func sw34_isColumn (_ inTableColumn: NSTableColumn?, hasIdentifier inString : String) -> Bool {
  if let columnIdentifier = inTableColumn?.identifier {
    #if swift(>=4)
      return columnIdentifier == NSUserInterfaceItemIdentifier (inString)
    #else
      return columnIdentifier == inString
    #endif
  }else{
    return false
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func sw34_tableColumn (_ inTableView: NSTableView, withIdentifier inKey : String) -> NSTableColumn? {
  #if swift(>=4)
    return inTableView.tableColumn (withIdentifier: NSUserInterfaceItemIdentifier (rawValue: inKey))
  #else
    return inTableView.tableColumn (withIdentifier: inKey)
  #endif
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

#if swift(>=4)
  let sw34_frameDidChangeNotification = NSView.frameDidChangeNotification
#else
  let sw34_frameDidChangeNotification = NSNotification.Name.NSViewFrameDidChange
#endif

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

#if swift(>=4)
  let sw34_AlertSecondButtonReturn = NSApplication.ModalResponse.alertSecondButtonReturn
#else
  let sw34_AlertSecondButtonReturn = NSAlertSecondButtonReturn
#endif

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

#if swift(>=4)
  let sw34_Beep = __NSBeep
#else
  let sw34_Beep = NSBeep
#endif

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

#if swift(>=4)
  let sw34_smallSystemFontSize = NSFont.smallSystemFontSize
#else
  let sw34_smallSystemFontSize = NSFont.smallSystemFontSize ()
#endif

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

#if swift(>=4)
  let sw34_NSModalResponseStop = NSApplication.ModalResponse.stop
#else
  let sw34_NSModalResponseStop = NSModalResponseStop
#endif

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

#if swift(>=4)
  let sw34_ScreenMain = NSScreen.main!
#else
  let sw34_ScreenMain = NSScreen.main ()!
#endif

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
