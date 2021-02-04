//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class AutoLayoutVersionField : NSTextField, EBUserClassNameProtocol {

  //····················································································································

  init () {
    super.init (frame: NSRect ())
    self.isEditable = false
    self.drawsBackground = false
    self.isBordered = false
    noteObjectAllocation (self)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  @discardableResult static func make () -> AutoLayoutVersionField {
    let b = AutoLayoutVersionField ()
    gCurrentStack?.addView (b, in: .leading)
    return b
  }

  //····················································································································
  //  version binding
  //····················································································································

  private var mVersionController : EBReadOnlyPropertyController? = nil

  //····················································································································

  @discardableResult func bind_version (_ inObject : EBReadOnlyProperty_Int) -> Self {
    self.mVersionController = EBReadOnlyPropertyController (
      observedObjects: [inObject],
      callBack: { [weak self] in self?.updateVersion (from: inObject) }
    )
     return self
  }

  //····················································································································

//  func unbind_version () {
//    self.mVersionController?.unregister ()
//    self.mVersionController = nil
//  }

  //····················································································································

  private func updateVersion (from inObject : EBReadOnlyProperty_Int) {
    switch inObject.selection {
    case .empty :
      self.enableFromValueBinding (false)
      self.stringValue = "—"
    case .single (let v) :
      self.enableFromValueBinding (true)
      self.stringValue = String (v)
    case .multiple :
      self.enableFromValueBinding (false)
      self.stringValue = "—"
    }
  }

  //····················································································································
  //  versionShouldChange binding
  //····················································································································

  private var mVersionShouldChangeController : EBReadOnlyPropertyController? = nil

  //····················································································································

  @discardableResult func bind_versionShouldChange (_ inObject : EBReadOnlyProperty_Bool) -> Self {
    self.mVersionShouldChangeController = EBReadOnlyPropertyController (
      observedObjects: [inObject],
      callBack: { [weak self] in self?.updateVersionShouldChange (from: inObject) }
     )
     return self
  }

  //····················································································································

//  func unbind_versionShouldChange () {
//    self.mVersionShouldChangeController?.unregister ()
//    self.mVersionShouldChangeController = nil
//  }

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
