//
//  run-shell-command.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  https://developer.github.com/v4/guides/forming-calls/
//  https://developer.github.com/v4/guides/migrating-from-rest/
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let personalAccessToken = "6d93d94df92bdcc2cd8addb97c1d49ab668c98d8"

//private let QUERY = """
//{
//  "query": "query { __type(name:Repository) { name kind description fields { name } } }"
//}
//"""
//
//private let QUERY2 = """
//{
//  "query": "query { repository(owner:pierremolinaro, name:ACAN) { object(expression:master) { ... on Commit { history { edges { node { committedDate message oid } } } } } } }"
//}
//"""

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func runGraphqlQuery (_ inString : String, _ inProxy : [String], _ inLogTextView : NSTextView) -> [String : Any]? {
  var result : [String : Any]? = nil
  let queryString = "{\n\"query\":\"query{repository(owner:pierremolinaro, name:ElCanariLibrary){\(inString)}}\"}"
  let arguments = [
    "-s", // Silent mode, do not show download progress
    "-L", // Follow
    "-H", "Authorization: bearer " + personalAccessToken,
    "-X", "POST",
    "-d", queryString,
    "https://api.github.com/graphql"
  ] + inProxy
  let responseCode = runShellCommandAndGetDataOutput (CURL, arguments, inLogTextView)
  var possibleAlert : NSAlert? = nil
  switch responseCode {
  case .error (let errorCode) :
    inLogTextView.appendErrorString ("  Result code means 'Cannot connect to the server'\n")
    possibleAlert = NSAlert ()
    possibleAlert?.messageText = "Cannot connect to the server"
    possibleAlert?.informativeText = (errorCode == 6)
      ? "No network connection"
      : "Server connection error"
  case .ok (let responseData) :
    inLogTextView.appendSuccessString ("  Result code means 'Ok'\n")
    do{
      if let response = try JSONSerialization.jsonObject (with: responseData) as? [String : Any] {
        // Swift.print ("\(String (describing: response))")
        if let responseDictionary = response ["data"]  as? [String : Any] {
          // Swift.print ("\(responseDictionary)")
          result = responseDictionary
        }else{
          inLogTextView.appendErrorString ("  Invalid server response: dictionary has no 'data' field\n")
          possibleAlert = NSAlert ()
          possibleAlert?.messageText = "Invalid server response"
        }
      }else{
        inLogTextView.appendErrorString ("  Invalid server response: data is not a dictionary\n")
        possibleAlert = NSAlert ()
        possibleAlert?.messageText = "Invalid server response"
      }
    }catch let error {
      possibleAlert = NSAlert (error: error)
    }
  }
//--- Display alert ?
  if let alert = possibleAlert {
    _ = alert.runModal ()
  }
//---
  return result
}

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
