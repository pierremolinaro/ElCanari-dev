
import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// Comment est effectuée la mise à jour de la librairie des composants ElCanari
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//
// Cette librairie est contenue dans le repository https://github.com/pierremolinaro/ElCanari-Library
//
//--------------- ① Savoir si une mise à jour est disponible
// On cherche les infos de la branche master :
//   curl -L https://api.github.com/repos/pierremolinaro/ElCanari-Library/branches
// La réponse est du style :
//[
//  {
//    "name": "master",
//    "commit": {
//      "sha": "910e061c5202ce9904f1ee2e464ee5354869bb2a",
//      "url": "https://api.github.com/repos/pierremolinaro/ElCanari-Library/commits/910e061c5202ce9904f1ee2e464ee5354869bb2a"
//    }
//  }
//]
// Le champ sha donne l'identité du dernier commit.
//
// On peut faire mieux (https://developer.github.com/v3/?#conditional-requests) : d'abord récupérer l'Etag du dernier
// commit (l'option -i affiche le header HTTP) :
//   curl -i -L https://api.github.com/repos/pierremolinaro/ElCanari-Library/branches
// La réponse :
//   HTTP/1.1 200 OK
// ·····
//   Status: 200 OK
// ·····
//   ETag: "e00f8fbc5829aa5e29c64688276e9f4f"
// ·····
//   après une ligne vide, la réponse au format json
//
// Ensuite, si on relance la commande :
//   curl -i -H 'If-None-Match:"e00f8fbc5829aa5e29c64688276e9f4f"' https://api.github.com/repos/pierremolinaro/ElCanari-Library/branches
// La réponse :
//   HTTP/1.1 304 Not Modified
// ·····
//   Status: 304 Not Modified
// ·····
//   ETag: "e00f8fbc5829aa5e29c64688276e9f4f"
// ·····
//   et pas de réponse au format json
// L'intérêt de cette méthode est que l'appel n'est pas comptabilisé dans le décompte des appels (max : 60 / h) si la réponse est 304.
//
//--------------- ② Connaître les fichiers à remettre à jour
// On télécharge la liste des fichiers correspondant au commit
//   curl -i -H "Accept:application/vnd.github.v3+json" https://api.github.com/repos/pierremolinaro/ElCanari-Library/git/trees/910e061c5202ce9904f1ee2e464ee5354869bb2a?recursive=1
// La réponse est la liste des fichiers au format JSON
//{
//  "sha": "910e061c5202ce9904f1ee2e464ee5354869bb2a",
//  "url": "https://api.github.com/repos/pierremolinaro/ElCanari-Library/git/trees/910e061c5202ce9904f1ee2e464ee5354869bb2a",
//  "tree": [
//    ················
//    {
//      "path": "artworks/electro_dragon.ElCanariArtwork",
//      "mode": "100644",
//      "type": "blob",
//      "sha": "038e85b12174cbcaca0c5c7f1b5885903446fb73",
//      "size": 5854,
//      "url": "https://api.github.com/repos/pierremolinaro/ElCanari-Library/git/blobs/038e85b12174cbcaca0c5c7f1b5885903446fb73"
//    },
//    ················
// Le champ intéressant est "path", qui contient le chemin relatif des fichiers. Attention, "sha" n'est pas le sha du
// fichier, mais celle de son blog ; idem pour "url". Mais on peut utiliser la valeur de "sha" pour savoir si le fichier
// a changé.
//
//--------------- ③ Récupérer le contenu d'un fichier
// Pour chaque fichier à récupérer
//   curl -H "Accept:application/vnd.github.v3+json" https://raw.githubusercontent.com/pierremolinaro/ElCanari-Library/910e061c5202ce9904f1ee2e464ee5354869bb2a/artworks/electro_dragon.ElCanariArtwork
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let LOG_LIBRARY_UPDATES = true

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let parallelDownloadCount = 4

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private var gLibraryUpdateWindow : EBWindow? = nil // nil if background search
private let repositoryDescriptionFile = "repository-description.plist"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   LIBRARY UPDATE ENTRY POINT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func performLibraryUpdate (_ inWindow : EBWindow?) {
  if LOG_LIBRARY_UPDATES {
    print ("---- performLibraryUpdate BEGIN (window \(inWindow))")
  }
  gLibraryUpdateWindow = inWindow
  gLibraryUpdateWindow?.makeKeyAndOrderFront (nil)
//-------- We start by checking if a repository did change using etag
  if let etag = getRepositoryCurrentETag () {
    performLibraryUpdateUsingEtag (etag)
  }else{
    performLibraryUpdateNoEtag ()
  }
  if LOG_LIBRARY_UPDATES {
    print ("---- performLibraryUpdate DONE")
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func performLibraryUpdateUsingEtag (_ etag : String) {
  let response = runShellCommandAndGetDataOutput ([
    "/usr/bin/curl",
    "-s", // Silent mode, do not show download progress
    "-i", // Add response header in output
    "-L", // Follow
    "-H", "If-None-Match:\"\(etag)\"",
    "https://api.github.com/repos/pierremolinaro/ElCanari-Library/branches"
  ])
  switch response {
  case .error (let errorCode) :
    if let libraryUpdateWindow = gLibraryUpdateWindow {
      let alert = NSAlert ()
      alert.messageText = "Cannot connect to the server"
      alert.addButton (withTitle: "Ok")
      alert.informativeText = (errorCode == 6)
        ? "No network connection"
        : "Server connection error"
      alert.beginSheetModal (
        for: libraryUpdateWindow,
        completionHandler: { (response : Int) in libraryUpdateWindow.orderOut (nil) }
      )
    }
  case .ok (let responseData) :
    if let response = String (data: responseData, encoding: .utf8) {
      //print ("\(response)")
      let c0 = response.components (separatedBy: "Status: ")
      let c1 = c0 [1].components (separatedBy: " ")
      //print ("C1 \(c1 [0])")
      if let status = Int (c1 [0]) {
        if LOG_LIBRARY_UPDATES {
          print ("HTTP status \(status)")
        }
        if status == 304 { // Status 304 --> not modified, use current repository description file
          performLibraryUpdateWithCurrentRepositoryDescriptionFile ()
        }else if status == 200 { // Status 200 --> Ok, modified
          writeRepositoryDescriptionFile (withResponse: response)
        }
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func performLibraryUpdateNoEtag () {
  let response = runShellCommandAndGetDataOutput ([
    "/usr/bin/curl",
    "-s", // Silent mode, do not show download progress
    "-i", // Add response header in output
    "-L", // Follow
    "https://api.github.com/repos/pierremolinaro/ElCanari-Library/branches"
  ])
  switch response {
  case .error (let errorCode) :
    if let libraryUpdateWindow = gLibraryUpdateWindow {
      let alert = NSAlert ()
      alert.messageText = "Cannot connect to the server"
      alert.addButton (withTitle: "Ok")
      alert.informativeText = (errorCode == 6)
        ? "No network connection"
        : "Server connection error"
      alert.beginSheetModal (
        for: libraryUpdateWindow,
        completionHandler: { (response : Int) in libraryUpdateWindow.orderOut (nil) }
      )
    }
  case .ok (let responseData) :
    if let response = String (data: responseData, encoding: .utf8) {
      writeRepositoryDescriptionFile (withResponse: response)
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func writeRepositoryDescriptionFile (withResponse inResponse : String) {
  let components = inResponse.components (separatedBy:"\r\n\r\n")
  if components.count == 2 {
    let jsonData = components [1].data (using: .utf8)!
    do{
    //--- Get commit sha
      let jsonArray = try JSONSerialization.jsonObject (with: jsonData) as! NSArray
      let jsonDictionary = jsonArray [0] as! NSDictionary
      if LOG_LIBRARY_UPDATES {
        print ("-->  jsonDictionary \(jsonDictionary)")
      }
      let commitDict = jsonDictionary ["commit"]  as! NSDictionary
      let commitSHA = commitDict ["sha"]  as! String
    //--- Get ETag
      let c1 = components [0].components (separatedBy:"ETag: \"")
      let c2 = c1 [1].components (separatedBy:"\"")
      let etag = c2 [0]
      if LOG_LIBRARY_UPDATES {
        print ("-->  ETag \(etag)")
      }
    //--- If system library does not exist, create it
      let fm = FileManager ()
      if !fm.fileExists (atPath: systemLibraryPath ()) {
        try fm.createDirectory (atPath:systemLibraryPath (), withIntermediateDirectories:true, attributes:nil)
      }
    //--- Write result in repository description file
      let repositoryDescriptionDictionary = NSMutableDictionary ()
      repositoryDescriptionDictionary ["etag"] = etag
      repositoryDescriptionDictionary ["commitSHA"] = commitSHA
      let f = systemLibraryPath () + "/" + repositoryDescriptionFile
      repositoryDescriptionDictionary.write (toFile: f, atomically: true)
      performLibraryUpdateWithCurrentRepositoryDescriptionFile ()
    }catch let error {
      print ("Error, error \(error)")
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func performLibraryUpdateWithCurrentRepositoryDescriptionFile () {
  if LOG_LIBRARY_UPDATES {
    print ("---- performLibraryUpdateWithCurrentRepositoryDescriptionFile BEGIN")
  }
//------------------ Step ② : download from repository the library.plist file
  let response = runShellCommandAndGetDataOutput ([
    "/usr/bin/curl",
    "-s", // Silent mode, do not show download progress
    "-L", // Follow redirections
    "https://raw.githubusercontent.com/pierremolinaro/ElCanari-Library/\(getRepositoryCurrentCommitSHA ())/library.plist"
  ])
  switch response {
  case .error (let errorCode) :
    if errorCode != 6 { // Error #6 is 'no network connection'

    }
  case .ok (let responseData) :
    do{
      let repositoryFilePLIST = try PropertyListSerialization.propertyList (from: responseData, format: nil)
      let repositoryFileArray = repositoryFilePLIST as! [[String : String]]
      var libraryFileDictionary = [String : CanariLibraryFileDescriptor] ()
      if LOG_LIBRARY_UPDATES {
        print ("*********** Repository contents (SHA:size:path)")
      }
      for d in repositoryFileArray {
        let path = d ["name"]!
        let repositorySHA = d ["fileSHA"]!
        let sizeInRepository = d ["fileSize"]!
        if LOG_LIBRARY_UPDATES {
          print ("  \(repositorySHA):\(sizeInRepository):\(path)")
        }
        let descriptor = CanariLibraryFileDescriptor (
          relativePath: path,
          repositorySHA: repositorySHA,
          sizeInRepository: Int (sizeInRepository)!,
          localSHA: ""
        )
        libraryFileDictionary [path] = descriptor
      }
      try performUpdateWithCurrentRepositoryContents (libraryFileDictionary)
      // print ("libraryFileDictionary \(libraryFileDictionary)")
    }catch let error {
       print ("Error \(error)")
    }
  }
//------------------
  if LOG_LIBRARY_UPDATES {
    print ("---- performLibraryUpdateWithCurrentRepositoryDescriptionFile END")
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func performUpdateWithCurrentRepositoryContents (_ inLibraryFileDictionary : [String : CanariLibraryFileDescriptor]) throws {
//------------------ Step ③ : enumerate current file in library
  let fm = FileManager ()
  var libraryFileDictionary = inLibraryFileDictionary
//--- Get library files
  if fm.fileExists (atPath: systemLibraryPath ()) {
    let currentLibraryContents = try fm.subpathsOfDirectory (atPath: systemLibraryPath ())
    for filePath in currentLibraryContents {
    //--- Eliminate ".DS_store" and description plist file
      var enter = (filePath.lastPathComponent != ".DS_Store") && (filePath != repositoryDescriptionFile)
    //--- Eliminate directories
      if enter {
        let fullPath = systemLibraryPath () + "/" + filePath
        var isDirectory : ObjCBool = false
        _ = fm.fileExists (atPath:fullPath, isDirectory: &isDirectory)
        enter = !isDirectory.boolValue
      }
      if enter {
        if let descriptor = libraryFileDictionary [filePath] {
          let localSHA = try computeFileSHA (filePath)
          let newDescriptor = CanariLibraryFileDescriptor (
            relativePath: descriptor.mRelativePath,
            repositorySHA: descriptor.mRepositorySHA,
            sizeInRepository: descriptor.mSizeInRepository,
            localSHA: localSHA
          )
          libraryFileDictionary [filePath] = newDescriptor
        }else{
          let descriptor = CanariLibraryFileDescriptor (
            relativePath: filePath,
            repositorySHA: "",
            sizeInRepository: 0,
            localSHA: "?"
          )
          libraryFileDictionary [filePath] = descriptor
        }
      }
    }
  }
  if LOG_LIBRARY_UPDATES {
    print ("*********** Library descriptor contents (local SHA:repository SHA:SHA:repository size:file path)")
    for descriptor in libraryFileDictionary.values {
      print ("  \(descriptor.mLocalSHA):\(descriptor.mRepositorySHA):\(descriptor.mSizeInRepository):\(descriptor.mRelativePath)")
    }
  }
  try performUpdateWithLocalAndRepositoryContents (libraryFileDictionary)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func performUpdateWithLocalAndRepositoryContents (_ inLibraryFileDictionary : [String : CanariLibraryFileDescriptor]) throws {
  var libraryOperations = [LibraryOperationElement] ()
  for descriptor in inLibraryFileDictionary.values {
    if descriptor.mRepositorySHA == "" {
      let element = LibraryOperationElement (relativePath: descriptor.mRelativePath, sizeInRepository: 0, operation: .delete)
      libraryOperations.append (element)
    }else if (descriptor.mRepositorySHA != "") && (descriptor.mLocalSHA == "") {
      let element = LibraryOperationElement (relativePath: descriptor.mRelativePath, sizeInRepository: descriptor.mSizeInRepository, operation: .download)
      libraryOperations.append (element)
    }else if (descriptor.mRepositorySHA != descriptor.mLocalSHA) {
      let element = LibraryOperationElement (relativePath: descriptor.mRelativePath, sizeInRepository: descriptor.mSizeInRepository, operation: .update)
      libraryOperations.append (element)
    }
  }
  if LOG_LIBRARY_UPDATES {
    print ("*********** Library operations (operation:file path:size in repository)")
    for op in libraryOperations {
      print ("  \(op.mOperation):\(op.mRelativePath):\(op.mSizeInRepository)")
    }
  }
//--- Hide library checking window (if any)
  if libraryOperations.count != 0 {
    gLibraryUpdateWindow?.orderOut (nil)
    performLibraryOperations (libraryOperations)
  }else if let libraryUpdateWindow = gLibraryUpdateWindow { // Display an alert saying that library is up to date
    let alert = NSAlert ()
    alert.messageText = "The library is up to date"
    alert.addButton (withTitle: "Ok")
    alert.beginSheetModal (for: libraryUpdateWindow, completionHandler: {
     (response : Int) in
      libraryUpdateWindow.orderOut (nil)
    })
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func performLibraryOperations (_ inLibraryOperations : [LibraryOperationElement]) {
//--- Perform library update in main thread
  DispatchQueue.main.async  {
  //--- Configure informative text in library update window
    if inLibraryOperations.count == 1 {
      g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "1 element to update"
   }else{
      g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "\(inLibraryOperations.count) elements to update"
    }
    var progressMaxValue = 0.0
    for action in inLibraryOperations {
      progressMaxValue += action.maxIndicatorValue
    }
  //--- Configure progress indicator in library update window
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.minValue = 0.0
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.maxValue = progressMaxValue
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.doubleValue = 0.0
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.isIndeterminate = false
  //--- Configure table view in library update window
    gCanariLibraryUpdateController = CanariLibraryUpdateController (inLibraryOperations)
    gCanariLibraryUpdateController.bind ()
  //--- Enable update button
 //   g_Preferences?.mUpDateLibraryMenuItemInCanariMenu?.isEnabled = true
    g_Preferences?.mUpDateButtonInLibraryUpdateWindow?.isEnabled = true
  //--- Show library update window
    g_Preferences?.mLibraryUpdateWindow?.makeKeyAndOrderFront (nil)
  }
}

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

  private var mCanceled = false

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
        operation inOperation : LibraryOperation) {
    mRelativePath = inRelativePath
    mOperation = inOperation
    mSizeInRepository = inSizeInRepository
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
    if self.mCanceled {
      inController.elementActionDidEnd (self, 0)
    }else{
      switch mOperation {
      case .download, .update :
        self.mOperation = .downloading (0)
        let task = Process ()
        let concurrentQueue = DispatchQueue (label: "Queue \(relativePath)", attributes: .concurrent)
        concurrentQueue.async {
        //--- Define task
          task.launchPath = "/usr/bin/curl"
          task.arguments = [
            "-s", // Silent mode, do not show download progress
            "-L", // Follow redirections
            "https://raw.githubusercontent.com/pierremolinaro/ElCanari-Library/\(getRepositoryCurrentCommitSHA ())/\(self.mRelativePath)",
          ]
          let pipe = Pipe ()
          task.standardOutput = pipe
          task.standardError = pipe
          let fileHandle = pipe.fileHandleForReading
        //--- Launch
          task.launch ()
          var data = Data ()
          var hasData = true
        //--- Loop until all data is got, or download is cancelled
          while hasData && !self.mCanceled {
            let newData = fileHandle.availableData
            hasData = newData.count > 0
            data.append (newData)
            DispatchQueue.main.async {
              self.mOperation = .downloading (data.count * 100 / self.mSizeInRepository)
              inController.updateProgressIndicator ()
            }
            sleep (1)
          }
          if self.mCanceled {
            task.terminate ()
          }
        //--- Task completed
          task.waitUntilExit ()
          fileHandle.closeFile ()
          let status = task.terminationStatus
          if self.mCanceled || (status != 0) {
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

  func cancelAction () {
    self.mCanceled = true
  }

  //····················································································································

  func commit () throws {
    switch self.mOperation {
    case .download, .update, .downloadError, .downloading, .delete :
      ()
    case .deleteRegistered :
      let fullFilePath = systemLibraryPath() + "/" + self.mRelativePath
      let fm = FileManager ()
      try fm.removeItem (atPath: fullFilePath)
    case .downloaded (let data) :
      let fullFilePath = systemLibraryPath() + "/" + self.mRelativePath
      let fm = FileManager ()
    //--- Create directory
      let destinationDirectory = fullFilePath.deletingLastPathComponent
      if !fm.fileExists(atPath: destinationDirectory) { // If directory does not exist, creta it
        if LOG_LIBRARY_UPDATES {
          NSLog ("Create dir '\(destinationDirectory)'")
        }
        try fm.createDirectory (atPath:destinationDirectory, withIntermediateDirectories:true, attributes:nil)
      }else if fm.fileExists (atPath: fullFilePath) { // If file exists, delete it
        try fm.removeItem (atPath:fullFilePath)
      }
    //--- Write file
      try data.write(to: URL (fileURLWithPath: fullFilePath))
    }
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private var gCanariLibraryUpdateController = CanariLibraryUpdateController ()

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariLibraryUpdateController : EBObject {

  let mArrayController = NSArrayController ()

  var mCurrentActionArray : [LibraryOperationElement]
  var mCurrentParallelActionCount = 0
  var mNextActionIndex = 0 // Index of mActionArray

  let mActionArray : [LibraryOperationElement]

  //····················································································································
  //   Init
  //····················································································································

  init (_ inActionArray : [LibraryOperationElement]) {
    mCurrentActionArray = inActionArray
    mActionArray = inActionArray
    super.init ()
  }

  //····················································································································

  override init () {
    mCurrentActionArray = []
    mActionArray = []
    super.init ()
  }
  
  //····················································································································
  //  Cocoa bindings
  //····················································································································

  func bind () {
    if let tableView = g_Preferences?.mTableViewInLibraryUpdateWindow {
      tableView.tableColumn (withIdentifier: "name")?.bind (
        "value",
        to:self.mArrayController,
        withKeyPath:"arrangedObjects.relativePath",
        options:nil
      )
      tableView.tableColumn (withIdentifier: "action")?.bind (
        "value",
        to:self.mArrayController,
        withKeyPath:"arrangedObjects.actionName",
        options:nil
      )
      self.mArrayController.content = self.mCurrentActionArray
    }
  }
  
  //····················································································································

  func unbind () { //--- Remove bindings
    if let tableView = g_Preferences?.mTableViewInLibraryUpdateWindow {
      tableView.tableColumn(withIdentifier: "name")?.unbind ("value")
      tableView.tableColumn(withIdentifier: "action")?.unbind ("value")
      mArrayController.content = nil
    }
  }

  //····················································································································
  //   launchElementDownload
  //····················································································································

  fileprivate func launchElementDownload () {
    if self.mNextActionIndex < self.mActionArray.count {
      self.mNextActionIndex += 1
      self.mCurrentParallelActionCount += 1
      self.mActionArray [self.mNextActionIndex - 1].beginAction (self)
    }
  }

  //····················································································································
  //   elementActionDidEnd
  //····················································································································

  fileprivate func elementActionDidEnd (_ inElement : LibraryOperationElement, _ inErrorCode : Int32) {
    if inErrorCode != 0 {
//      cancelLibraryUpdate ()
    }else{
    //--- Decrement parallel action count
      self.mCurrentParallelActionCount -= 1
    //--- Remove corresponding entry in table view
      if let idx = self.mCurrentActionArray.index (of: inElement) {
        self.mCurrentActionArray.remove (at: idx)
        self.mArrayController.content = self.mCurrentActionArray
      }
    //--- Update progress indicator
      self.updateProgressIndicator ()
    //--- Update remaining operation count
      if self.mCurrentActionArray.count == 0 {
        g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "Commiting changes…"
      }else if self.mCurrentActionArray.count == 1 {
        g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "1 element to update"
     }else{
        g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "\(self.mCurrentActionArray.count) elements to update"
      }
    //--- Launch next action, if any
      if self.mNextActionIndex < self.mActionArray.count {
        self.mNextActionIndex += 1
        self.mCurrentParallelActionCount += 1
        self.mActionArray [self.mNextActionIndex - 1].beginAction (self)
      }else if self.mCurrentParallelActionCount == 0 { // Last download did end
        DispatchQueue.main.async { commitAllActions (self.mActionArray) }
      }
    }
  }

  //····················································································································

  fileprivate func updateProgressIndicator () {
    var progressCurrentValue = 0.0
    for action in self.mActionArray {
      progressCurrentValue += action.currentIndicatorValue
    }
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.doubleValue = progressCurrentValue
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func cleanLibraryUpdate () {
  if LOG_LIBRARY_UPDATES {
    NSLog ("\(#function)")
  }
//--- Hide library update window
  g_Preferences?.cancelDownloadElementFromRepository ()
//---
  gCanariLibraryUpdateController.unbind ()
  gCanariLibraryUpdateController = CanariLibraryUpdateController ()
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func startLibraryUpdate () {
  if LOG_LIBRARY_UPDATES {
    NSLog ("\(#function)")
  }
//--- Update UI
  g_Preferences?.mUpDateButtonInLibraryUpdateWindow?.isEnabled = false
//--- Launch parallel downloads
  for _ in 1...parallelDownloadCount {
    gCanariLibraryUpdateController.launchElementDownload ()
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func cancelLibraryUpdate () {
  if LOG_LIBRARY_UPDATES {
    NSLog ("\(#function)")
  }
//--- The button is inactived during download
//  if let button = g_Preferences?.mUpDateButtonInLibraryUpdateWindow, !button.isEnabled {
  //--- Cancel current downloadings
    for descriptor in gCanariLibraryUpdateController.mActionArray {
      descriptor.cancelAction ()
    }
    startLibraryUpdate ()
//  }else{ // Download is not started
//    cleanLibraryUpdate ()
//  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   C O M M I T    U P D A T E S   I N   F I L E    S Y S T E M
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func commitAllActions (_ inActionArray : [LibraryOperationElement]) {
//--- Update UI
  gCanariLibraryUpdateController.unbind ()
  gCanariLibraryUpdateController = CanariLibraryUpdateController ()
//--- Commit change only if all actions has been successdully completed
  var performCommit = true
  for action in inActionArray {
    switch action.mOperation {
    case .download, .update, .downloadError, .downloading, .delete :
      performCommit = false
    case .deleteRegistered, .downloaded :
      ()
    }
  }
//--- Perform commit
  if !performCommit {
    g_Preferences?.mLibraryUpdateWindow?.orderOut (nil)
  }else{
    if let window = g_Preferences?.mLibraryUpdateWindow {
      do{
        for action in inActionArray {
          try action.commit ()
        }
      //--- Delete orphean directories
        try deleteOrphanDirectories ()
        let alert = NSAlert ()
        alert.messageText = "Update completed, the library is up to date"
        alert.addButton (withTitle: "Ok")
        alert.beginSheetModal (
          for: window,
          completionHandler: { (response : Int) in window.orderOut (nil) }
        )
      }catch let error {
        let alert = NSAlert ()
        alert.messageText = "Cannot commit changes"
        alert.addButton (withTitle: "Ok")
        alert.informativeText = "A file system operation returns \(error) error"
        alert.beginSheetModal (
          for: window,
          completionHandler: { (response : Int) in window.orderOut (nil) }
        )
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    deleteOrphanDirectories
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func deleteOrphanDirectories () throws {
  if LOG_LIBRARY_UPDATES {
    NSLog ("\(#function)")
  }
  let fm = FileManager ()
  let currentLibraryContents = try fm.subpathsOfDirectory (atPath: systemLibraryPath ())
  var directoryArray = [String] ()
  for relativePath in currentLibraryContents {
    let fullPath = systemLibraryPath () + "/" + relativePath
    var isDirectory : ObjCBool = false
    fm.fileExists (atPath: fullPath, isDirectory: &isDirectory)
    if (isDirectory.boolValue) {
      directoryArray.append (fullPath)
    }
  }
  directoryArray.sort ()
  if LOG_LIBRARY_UPDATES {
    NSLog ("directories to delete '\(directoryArray.description)")
  }
  var i=directoryArray.count-1
  while i>=0 {
    let fullPath = directoryArray [i]
    var currentDirectoryContents = try fm.contentsOfDirectory (atPath: fullPath)
  //--- Remove .DS_Store files
    var j=0
    while j<currentDirectoryContents.count {
      let s = currentDirectoryContents [j]
      if s == ".DS_Store" {
        currentDirectoryContents.remove (at: j)
        j -= 1
      }
      j += 1
    }
    if (currentDirectoryContents.count == 0) {
      if LOG_LIBRARY_UPDATES {
        NSLog ("delete orphean at '\(fullPath)")
      }
      try fm.removeItem (atPath: fullPath)
    }
    i -= 1
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct CanariLibraryFileDescriptor {

  //····················································································································
  //   Properties
  //····················································································································

  let mRelativePath : String
  let mRepositorySHA : String
  let mSizeInRepository : Int
  let mLocalSHA : String

  //····················································································································

  init (relativePath inRelativePath : String,
        repositorySHA inRepositorySHA : String,
        sizeInRepository inSizeInRepository : Int,
        localSHA inLocalSHA : String) {
    mRelativePath = inRelativePath
    mRepositorySHA = inRepositorySHA
    mLocalSHA = inLocalSHA
    mSizeInRepository = inSizeInRepository
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  Computing SHA1 of Data
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func sha1 (_ inData : Data) -> Data {
  let transform = SecDigestTransformCreate (kSecDigestSHA1, 0, nil)
  SecTransformSetAttribute (transform, kSecTransformInputAttributeName, inData as CFTypeRef, nil)
  return SecTransformExecute (transform, nil) as! Data
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  Computing SHA1 of a library file
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func computeFileSHA (_ filePath : String) throws -> String {
  let absoluteFilePath = systemLibraryPath () + "/" + filePath
  let data = try Data (contentsOf: URL (fileURLWithPath: absoluteFilePath))
  var s = ""
  for byte in sha1 (data) {
    s += "\(String (byte, radix:16, uppercase: false))"
  }
  return s
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   runShellCommandAndGetDataOutput
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private enum ShellCommandStatus {
  case ok (Data)
  case error (Int32)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func runShellCommandAndGetDataOutput (_ command : [String]) -> ShellCommandStatus {
  if LOG_LIBRARY_UPDATES {
    print ("Command \(command)")
  }
//--- Separate command and arguments
  let cmd = command [0]
  let args = [String] (command.dropFirst ())
//--- Define task
  let task = Process ()
  task.launchPath = cmd
  task.arguments = args
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
  if status != 0 {
    if LOG_LIBRARY_UPDATES {
      print ("Error \(status)")
    }
    return .error (status)
  }else{
    if LOG_LIBRARY_UPDATES {
      print ("Ok \(data.count) bytes")
    }
    return .ok (data)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func getRepositoryCurrentETag () -> String? { // Returns nil if no current description file
  var result : String? = nil
//--- Get library file
  let currentLibraryContents = systemLibraryPath () + "/" + repositoryDescriptionFile
  if let dict = NSDictionary (contentsOfFile:currentLibraryContents), let etag = dict ["etag"] as? String {
    result = etag
  }
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func getRepositoryCurrentCommitSHA() -> String {
  var result = ""
//--- Get library file
  let currentLibraryContents = systemLibraryPath () + "/" + repositoryDescriptionFile
  if let dict = NSDictionary (contentsOfFile:currentLibraryContents), let sha = dict ["commitSHA"] as? String {
    result = sha
  }
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    extension Preferences
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension Preferences {

  //····················································································································

  func beginDownloadRepositoryList () {
    gLibraryUpdateWindow?.makeKeyAndOrderFront (nil)
    mCheckForLibraryUpdatesButton?.isEnabled = false
    mUpDateLibraryMenuItemInCanariMenu?.action = nil
  }

  //····················································································································

  func cancelDownloadRepositoryList () {
    mCheckForLibraryUpdatesButton?.isEnabled = true
    mUpDateLibraryMenuItemInCanariMenu?.action = #selector(ApplicationDelegate.updateLibrary(_:))
  }

  //····················································································································

  func cancelDownloadElementFromRepository () {
    mLibraryUpdateWindow?.orderOut (nil)
    mCheckForLibraryUpdatesButton?.isEnabled = true
    mUpDateLibraryMenuItemInCanariMenu?.action = #selector(ApplicationDelegate.updateLibrary(_:))
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
