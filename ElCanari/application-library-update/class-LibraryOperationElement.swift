//
//  class-LibraryOperationElement.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let SLOW_DOWNLOAD = false // When active, downloading is slowed down with sleep (1)

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

enum LibraryOperation {
  case download
  case update
  case delete
  case deleteRegistered
  case downloadError (Int32)
  case downloading (Int)
  case downloaded (Data)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class LibraryOperationElement : EBObject {

  //····················································································································
  //   Properties
  //····················································································································

  let mRelativePath : String
  let mSizeInRepository : Int
  let mLogTextView : NSTextView
  let mProxy : [String]

  var mOperation : LibraryOperation {
    willSet {
      self.willChangeValue (forKey: "actionName")
    }
    didSet {
      self.didChangeValue (forKey: "actionName")
    }
  }

  //····················································································································

  init (relativePath inRelativePath : String,
        sizeInRepository inSizeInRepository : Int,
        operation inOperation : LibraryOperation,
        logTextView inLogTextView: NSTextView,
        proxy inProxy: [String]) {
    mRelativePath = inRelativePath
    mOperation = inOperation
    mSizeInRepository = inSizeInRepository
    mLogTextView = inLogTextView
    mProxy = inProxy
    super.init ()
  }


  //····················································································································
  // Values for progress indicator
  //····················································································································

  var maxIndicatorValue : Double { return Double (self.mSizeInRepository + 10_000) }

  var currentIndicatorValue : Double {
    switch self.mOperation {
    case .download, .update, .delete, .downloadError :
      return 0.0
    case .downloading (let progress) :
      return Double (progress) * self.maxIndicatorValue / 100.0
    case .downloaded (_), .deleteRegistered :
      return self.maxIndicatorValue
    }
  }

  //····················································································································
  // Dynamic properties for Cocoa bindings
  //····················································································································

  @objc dynamic var relativePath : String { return self.mRelativePath }

  @objc dynamic var actionName : String {
    switch self.mOperation {
    case .download :
      return "Download (\(mSizeInRepository) bytes)"
    case .update :
      return "Update (\(mSizeInRepository) bytes)"
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
      inController.elementActionDidEnd (self, 0)
    }else{
      switch mOperation {
      case .download, .update :
        let repositoryCommitSHA = getRepositoryCommitSHA ()!
        self.mOperation = .downloading (0)
        let task = Process ()
        let concurrentQueue = DispatchQueue (label: "Queue \(relativePath)", attributes: .concurrent)
        concurrentQueue.async {
          let arguments = [
            "-s", // Silent mode, do not show download progress
            "-L", // Follow redirections
            "https://raw.githubusercontent.com/pierremolinaro/ElCanariLibrary/\(repositoryCommitSHA)/\(self.mRelativePath)",
          ] + self.mProxy
          DispatchQueue.main.async {
            self.mLogTextView.appendMessageString ("  Download arguments: \(arguments)\n")
          }
        //--- Define task
          task.launchPath = CURL
          task.arguments = arguments
          let pipe = Pipe ()
          task.standardOutput = pipe
          task.standardError = pipe
          let fileHandle = pipe.fileHandleForReading
        //--- Launch
          task.launch ()
          var data = Data ()
          var hasData = true
        //--- Loop until all data is got, or download is cancelled
          while hasData && !inController.shouldCancel {
            let newData = fileHandle.availableData
            hasData = newData.count > 0
            data.append (newData)
            DispatchQueue.main.async {
              self.mOperation = .downloading (data.count * 100 / self.mSizeInRepository)
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
          if inController.shouldCancel || (status != 0) {
            self.mOperation = .downloadError (status)
          }else{
            self.mOperation = .downloaded (data)
          }
          DispatchQueue.main.async { inController.elementActionDidEnd (self, status) }
        }
      case .delete :
        self.mOperation = .deleteRegistered
        inController.elementActionDidEnd (self, 0)
      case .downloadError, .downloaded, .downloading, .deleteRegistered :
        inController.elementActionDidEnd (self, 0)
      }
    }
  }

  //····················································································································

  func commit () throws {
    switch self.mOperation {
    case .download, .update, .downloadError, .downloading, .delete :
      ()
    case .deleteRegistered :
      let fullFilePath = systemLibraryPath() + "/" + self.mRelativePath
      let fm = FileManager ()
      DispatchQueue.main.async {
        self.mLogTextView.appendMessageString ("  Delete file '\(fullFilePath)'\n")
      }
      try fm.removeItem (atPath: fullFilePath)
    case .downloaded (let data) :
      let fullFilePath = systemLibraryPath() + "/" + self.mRelativePath
      let fm = FileManager ()
    //--- Create directory
      let destinationDirectory = fullFilePath.deletingLastPathComponent
      if !fm.fileExists(atPath: destinationDirectory) { // If directory does not exist, create it
        DispatchQueue.main.async {
          self.mLogTextView.appendMessageString ("  Create directory '\(destinationDirectory)'\n")
        }
        try fm.createDirectory (atPath:destinationDirectory, withIntermediateDirectories:true, attributes:nil)
      }else if fm.fileExists (atPath: fullFilePath) { // If file exists, delete it
        try fm.removeItem (atPath:fullFilePath)
      }
    //--- Write file
      DispatchQueue.main.async {
        self.mLogTextView.appendMessageString ("  Write file '\(fullFilePath)'\n")
      }
      try data.write (to: URL (fileURLWithPath: fullFilePath))
    }
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————