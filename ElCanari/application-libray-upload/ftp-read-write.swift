//
//  ftp-read-write.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func readRemoteFile (_ inRemotePath : String, _ url : String, userPwd : String) -> ShellCommandStatus {
  let arguments = [
    "-s", // Silent mode, do not show download progress
    "-L", // Follow redirections
    url + "/" + inRemotePath,
    "-u", userPwd
  ]
  return runShellCommandAndGetDataOutput (CURL, arguments)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func writeRemoteFile (_ inRemotePath : String, _ inData : Data) -> ShellCommandStatus {
  let tempFilePath = NSTemporaryDirectory () + ProcessInfo ().globallyUniqueString
  try! inData.write (to: URL (fileURLWithPath: tempFilePath))
  // Swift.print (tempFilePath)
  let arguments = [
    "-s", // Silent mode, do not show download progress
    "-L", // Follow redirections
    "--ftp-create-dirs", // Create intermediate directories if needed
    "-T", tempFilePath,
    "ftp://ftp.pcmolinaro.name/www/CanariLibrary/" + inRemotePath,
    "-u", "pcmolinaca:gT8amP5e9vSX"
  ]
  return runShellCommandAndGetDataOutput (CURL, arguments)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
