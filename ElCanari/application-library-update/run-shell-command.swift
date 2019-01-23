//
//  run-shell-command.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   runShellCommandAndGetDataOutput
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

enum ShellCommandStatus {
  case ok (Data)
  case error (Int32)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func runShellCommandAndGetDataOutput (_ command : String, _ arguments : [String], _ inLogTextView : NSTextView) -> ShellCommandStatus {
  var commandString = command
  for s in arguments {
    commandString += " " + s
  }
  inLogTextView.appendMessageString ("  Command: \(commandString)\n")
//--- Define task
  let task = Process ()
  task.launchPath = command
  task.arguments = arguments
  let pipe = Pipe ()
  task.standardOutput = pipe
  task.standardError = pipe
  let fileHandle = pipe.fileHandleForReading
//--- Launch
  task.launch ()
  var data = Data ()
  var hasData = true
  while hasData {
    let newData = fileHandle.availableData
    // print ("  \(newData.count)")
    hasData = newData.count > 0
    data.append (newData)
  }
  task.waitUntilExit ()
//--- Task completed
  fileHandle.closeFile ()
  let status = task.terminationStatus
  let response : ShellCommandStatus
  if status != 0 {
    response = .error (status)
  }else{
    response = .ok (data)
  }
  inLogTextView.appendMessageString ("  Result code: \(response)\n")
  return response
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
