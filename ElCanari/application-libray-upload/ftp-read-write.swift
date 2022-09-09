//
//  ftp-read-write.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func readRemoteFile (_ inRemotePath : String,
                                url : String,
                                userPwd : String) -> ShellCommandStatus {
  let arguments = [
    "-s", // Silent mode, do not show download progress
    "-k", // Turn off curl's verification of certificate
    "-L", // Follow redirections
    url + "/" + inRemotePath,
    "-u", userPwd
  ]
  return runShellCommandAndGetDataOutput (CURL, arguments, logTextView: nil)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func writeRemoteFile (_ inRemotePath : String,
                                 url : String,
                                 userPwd : String, _ inLocalFullPath : String) -> ShellCommandStatus {
  let arguments = [
    "-s", // Silent mode, do not show download progress
    "-k", // Turn off curl's verification of certificate
    "-L", // Follow redirections
    "--ftp-create-dirs", // Create intermediate directories if needed
    "-T", inLocalFullPath,
    url + "/" + inRemotePath,
    "-u", userPwd
  ]
  return runShellCommandAndGetDataOutput (CURL, arguments, logTextView: nil)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func writeRemoteData (_ inRemotePath : String,
                                 url : String, userPwd : String,
                                 _ inData : Data) -> ShellCommandStatus {
  let tempFilePath = NSTemporaryDirectory () + ProcessInfo ().globallyUniqueString
  try! inData.write (to: URL (fileURLWithPath: tempFilePath))
  return writeRemoteFile (inRemotePath, url: url, userPwd: userPwd, tempFilePath)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
