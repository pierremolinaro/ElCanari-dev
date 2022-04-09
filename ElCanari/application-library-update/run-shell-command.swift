//
//  run-shell-command.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func getRemoteFileData (_ inRelativeFilePath : String,
                        _ ioPossibleAlert : inout NSAlert?,
                        _ inLogTextView : AutoLayoutStaticTextView,
                        _ inProxy : [String]) -> Data? {
  let arguments = [
    "-s", // Silent mode, do not show download progress
    "-k", // Turn off curl's verification of certificate
    "-L", // Follow
    "https://www.pcmolinaro.name/CanariLibrary/" + inRelativeFilePath
  ] + inProxy
  let responseCode = runShellCommandAndGetDataOutput (CURL, arguments, inLogTextView)
  switch responseCode {
  case .error (let errorCode) :
    ioPossibleAlert = NSAlert ()
    ioPossibleAlert?.messageText = "Cannot get file from repository."
    if errorCode == 6 { // See man curl --> Couldn't resolve host. The given remote host was not resolved.
      ioPossibleAlert?.informativeText = "Cannot connect to server."
    }else{
      ioPossibleAlert?.informativeText = "The server returns error \(errorCode) on reading '\(inRelativeFilePath)' file."
    }
    return nil
  case .ok (let data) :
    return data
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   runShellCommandAndGetDataOutput
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

enum ShellCommandStatus {
  case ok (Data)
  case error (Int32)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func runShellCommandAndGetDataOutput (_ command : String,
                                      _ arguments : [String],
                                      _ inLogTextView : AutoLayoutStaticTextView? = nil) -> ShellCommandStatus {
  var commandString = command
  for s in arguments {
    if s.contains ("'") {
     commandString += " '" + s + "'"
    }else{
     commandString += " " + s
    }
  }
  inLogTextView?.appendMessageString ("  Command: ")
  inLogTextView?.appendCodeString (commandString, color: .black)
  inLogTextView?.appendMessageString ("\n")
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
    inLogTextView?.appendMessageString ("  Result code: error \(status)\n")
  }else{
    response = .ok (data)
    inLogTextView?.appendMessageString ("  Result code: ok\n")
  }
  return response
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
