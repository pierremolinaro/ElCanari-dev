#! /usr/bin/swift

//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------

let BOLD    = "\u{1B}[0;1m"
let MAGENTA = "\u{1B}[0;35m"
let RED     = "\u{1B}[0;31m"
let BOLD_MAGENTA = BOLD + MAGENTA
let BOLD_RED = BOLD + RED
let ENDC    = "\u{1B}[0;0m"

//--------------------------------------------------------------------------------------------------
//   runCommand
//--------------------------------------------------------------------------------------------------

func runCommand (_ cmd : String, _ args : [String]) {
  var str = "+ " + cmd
  for s in args {
    str += " " + s
  }
  print (BOLD_MAGENTA + str + ENDC)
  let task = Process.launchedProcess (launchPath: cmd, arguments: args)
  task.waitUntilExit ()
  let status = task.terminationStatus
  if status != 0 {
    print (BOLD_RED + "Command line tool '\(cmd)' returns error \(status)" + ENDC)
    exit (status)
  }
}
//--------------------------------------------------------------------------------------------------

//-------------------- Get script absolute path
let scriptDir = URL (fileURLWithPath: CommandLine.arguments [0]).deletingLastPathComponent ().path
let fm = FileManager ()
fm.changeCurrentDirectoryPath (scriptDir + "/..")

runCommand ("/opt/homebrew/bin/periphery", ["help", "scan"])

let options = [
  "scan", "--retain-objc-accessible",
  "--project", "ElCanari.xcodeproj",
  "--schemes", "ElCanari-Debug",
  "--targets", "ElCanari-Debug"
]
runCommand ("/opt/homebrew/bin/periphery", options)

//--------------------------------------------------------------------------------------------------
