//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class AutoLayoutVersionField : NSTextField, EBUserClassNameProtocol {

  //····················································································································

  init () {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.isEditable = false
    self.isEnabled = true
    self.drawsBackground = false
    self.isBordered = false
    self.controlSize = .small
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  override func ebCleanUp () {
    self.mVersionController?.unregister ()
    self.mVersionController = nil
    super.ebCleanUp ()
  }

  //····················································································································
  //  version binding
  //····················································································································

  private var mVersionController : EBReadOnlyPropertyController? = nil

  //····················································································································

  func bind_version (_ inObject : EBReadOnlyProperty_Int) -> Self {
    self.mVersionController = EBReadOnlyPropertyController (
      observedObjects: [inObject],
      callBack: { [weak self] in self?.updateVersion (from: inObject) }
    )
     return self
  }

  //····················································································································

  private func updateVersion (from inObject : EBReadOnlyProperty_Int) {
    switch inObject.selection {
    case .empty, .multiple :
      self.enable (fromValueBinding: false)
      self.stringValue = "—"
    case .single (let v) :
      self.enable (fromValueBinding: true)
      self.stringValue = String (v)
      self.needsUpdateConstraints = true
      self.needsLayout = true
      Swift.print ("self.intrinsicContentSize \(self.intrinsicContentSize)")
      Swift.print ("self.fittingSize \(self.fittingSize)")
      self.frame.size = self.intrinsicContentSize
    }
  }

  //····················································································································
  //  versionShouldChange binding
  //····················································································································

  private var mVersionShouldChangeController : EBReadOnlyPropertyController? = nil

  //····················································································································

  func bind_versionShouldChange (_ inObject : EBReadOnlyProperty_Bool) -> Self {
    self.mVersionShouldChangeController = EBReadOnlyPropertyController (
      observedObjects: [inObject],
      callBack: { [weak self] in self?.updateVersionShouldChange (from: inObject) }
     )
     return self
  }

  //····················································································································
  // NSColor.systemBlue is not defined in 10.9
  // We use 10.10 setting for getting systemBlue RGB components:
  //      let c = NSColor.systemBlue.usingColorSpace (.sRGB)!
  //      Swift.print ("RGB \(c.redComponent) \(c.greenComponent) \(c.blueComponent)")

  private func updateVersionShouldChange (from inObject : EBReadOnlyProperty_Bool) {
    switch inObject.selection {
    case .empty, .multiple :
      break
    case .single (let v) :
      if v {
        self.textColor = NSColor (
          calibratedRed: 0.10588235294117647,
          green: 0.6784313725490196,
          blue: 0.9725490196078431,
          alpha: 1.0
        )
      }else{
        self.textColor = NSColor.black
      }
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
