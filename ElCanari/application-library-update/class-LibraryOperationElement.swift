//
//  class-LibraryOperationElement.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let SLOW_DOWNLOAD = false // When active, downloading is slowed down with sleep (1)

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

enum LibraryOperation {
  case download
  case update
  case delete
  case deleteRegistered
  case downloadError (Int32) // Error code
  case downloading (Int) // 0 ... 100, download progress, in %
  case downloaded (Data) // Downloaded data
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class LibraryOperationElement : EBSwiftBaseObject {

  //····················································································································
  //   Properties
  //····················································································································

  let relativePath : String
  let commit : Int
  let sizeInRepository : Int

  //····················································································································

//  private let mFileSHA : String
  private let mLogTextView : AutoLayoutStaticTextView
  private let mProxy : [String]

  //····················································································································

  private var mOperation : LibraryOperation
  var operation : LibraryOperation { return self.mOperation }

  //····················································································································

  init (relativePath inRelativePath : String,
        commit : Int,
        sizeInRepository inSizeInRepository : Int,
//        fileSHA inFileSHA : String,
        operation inOperation : LibraryOperation,
        logTextView inLogTextView: AutoLayoutStaticTextView,
        proxy inProxy: [String]) {
    self.relativePath = inRelativePath
    self.commit = commit
    self.mOperation = inOperation
    self.sizeInRepository = inSizeInRepository
//    self.mFileSHA = inFileSHA
    self.mLogTextView = inLogTextView
    self.mProxy = inProxy
    super.init ()
  }

  //····················································································································
  // Values for progress indicator
  //····················································································································

  var maxIndicatorValue : Double { return Double (self.sizeInRepository + 10_000) }

  var currentIndicatorValue : Double {
    switch self.operation {
    case .download, .update, .delete, .downloadError :
      return 0.0
    case .downloading (let progress) :
      return Double (progress) * self.maxIndicatorValue / 100.0
    case .downloaded (_), .deleteRegistered :
      return self.maxIndicatorValue
    }
  }

  //····················································································································

  var actionName : String {
    switch self.operation {
    case .download :
      return "Download (\(self.sizeInRepository.stringWithSeparators) bytes)"
    case .update :
      return "Update (\(self.sizeInRepository.stringWithSeparators) bytes)"
    case .delete :
      return "Delete"
    case .deleteRegistered :
      return "Delete registered"
    case .downloadError (let errorCode) :
      return "Error \(errorCode)"
    case .downloaded (_) :
      return "Downloaded"
    case .downloading (let progress) :
      return "Downloading… (\(progress)%)"
    }
  }

  //····················································································································

  func beginAction (_ inController : CanariLibraryUpdateController) {
    if inController.shouldCancel {
      DispatchQueue.main.async { inController.elementActionDidEnd (self, 0) }
    }else{
      switch operation {
      case .download, .update :
        self.mOperation = .downloading (0)
        Task {
          let arguments = [
            "-s", // Silent mode, do not show download progress
            "-k", // Turn off curl's verification of certificate
            "-L", // Follow redirections
            "https://www.pcmolinaro.name/CanariLibrary/files/\(self.commit)/\(self.relativePath)",
          ] + self.mProxy
          DispatchQueue.main.async {
            self.mLogTextView.appendMessageString ("  Download arguments: \(arguments)\n")
          }
        //--- Define task
          let task = Process ()
          task.launchPath = CURL
          task.arguments = arguments
          let pipe = Pipe ()
          task.standardOutput = pipe
          task.standardError = pipe
          let fileHandle = pipe.fileHandleForReading
        //--- Launch
          task.launch ()
        //--- Loop until all data is got, or download is cancelled
          var data = Data ()
          var hasData = true
          while hasData && !inController.shouldCancel {
            let newData = fileHandle.availableData
            hasData = newData.count > 0
            data.append (newData)
            let dataCount = data.count
            DispatchQueue.main.async {
              self.mOperation = .downloading (dataCount * 100 / self.sizeInRepository)
              inController.updateProgressIndicator ()
            }
            if SLOW_DOWNLOAD {
              sleep (1)
            }
          }
          if inController.shouldCancel {
            task.terminate ()
          }
        //--- Task completed
          task.waitUntilExit ()
          fileHandle.closeFile ()
          let status = task.terminationStatus
          DispatchQueue.main.async {
            if inController.shouldCancel || (status != 0) {
              self.mOperation = .downloadError (status)
            }else{
              self.mOperation = .downloaded (data)
            }
            inController.elementActionDidEnd (self, status)
          }
        }
      case .delete :
        DispatchQueue.main.async {
          self.mOperation = .deleteRegistered
          inController.elementActionDidEnd (self, 0)
        }
      case .downloadError, .downloaded, .downloading, .deleteRegistered :
        DispatchQueue.main.async { inController.elementActionDidEnd (self, 0) }
      }
    }
  }

  //····················································································································

  func performCommit () throws {
    switch self.operation {
    case .download, .update, .downloadError, .downloading, .delete :
      ()
    case .deleteRegistered :
      let fullFilePath = systemLibraryPath () + "/" + self.relativePath
      let fm = FileManager ()
      self.mLogTextView.appendMessageString ("  Delete file '\(fullFilePath)'\n")
      try fm.removeItem (atPath: fullFilePath)
    case .downloaded (let data) :
      let fullFilePath = systemLibraryPath() + "/" + self.relativePath
      let fm = FileManager ()
    //--- Create directory
      let destinationDirectory = fullFilePath.deletingLastPathComponent
      if !fm.fileExists (atPath: destinationDirectory) { // If directory does not exist, create it
        self.mLogTextView.appendMessageString ("  Create directory '\(destinationDirectory)'\n")
        try fm.createDirectory (atPath: destinationDirectory, withIntermediateDirectories: true, attributes: nil)
      }else if fm.fileExists (atPath: fullFilePath) { // If file exists, delete it
        try fm.removeItem (atPath: fullFilePath)
      }
    //--- Write file
      self.mLogTextView.appendMessageString ("  Write file '\(fullFilePath)'\n")
      try data.write (to: URL (fileURLWithPath: fullFilePath))
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
