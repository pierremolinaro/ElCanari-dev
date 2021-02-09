//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class AutoLayoutLabel : NSTextField, EBUserClassNameProtocol {

  //····················································································································
  // INIT
  //····················································································································

  init (small inSmall : Bool) {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.isBezeled = false
    self.isBordered = false
    self.drawsBackground = false
    self.isEnabled = true
    self.isEditable = false
    self.controlSize = inSmall ? .small : .regular
//    let fontSize = inSmall ? NSFont.smallSystemFontSize : NSFont.systemFontSize
//    self.font = NSFont.systemFont (ofSize: fontSize)
  }

  //····················································································································

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override func ebCleanUp () {
    self.mTitleController?.unregister ()
    self.mTitleController = nil
    super.ebCleanUp ()
  }

  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
    if DEBUG_AUTO_LAYOUT {
      DEBUG_FILL_COLOR.setFill ()
      NSBezierPath.fill (inDirtyRect)
      let bp = NSBezierPath (rect: self.bounds)
      bp.lineWidth = 1.0
      bp.lineJoinStyle = .round
      DEBUG_STROKE_COLOR.setStroke ()
      bp.stroke ()
    }
    super.draw (inDirtyRect)
  }

  //····················································································································
  // SET TEXT color
  //····················································································································

  func setTextColor (_ inTextColor : NSColor) -> Self {
    self.textColor = inTextColor
    return self
  }

  //····················································································································
  // SET TITLE ALIGNMENT
  //····················································································································

  func setTitleAlignment (_ inAlignment : NSTextAlignment) -> Self {
    self.alignment = inAlignment
    return self
  }

  //····················································································································
  //  $title binding
  //····················································································································

  private var mTitleController : EBReadOnlyPropertyController? = nil

  //····················································································································

  func bind_title (_ model : EBReadOnlyProperty_String) -> Self {
    self.mTitleController = EBReadOnlyPropertyController (
      observedObjects: [model],
      callBack: { [weak self] in self?.update (from: model) }
    )
    return self
  }

  //····················································································································

  private func update (from model : EBReadOnlyProperty_String) {
    switch model.selection {
    case .empty :
      self.stringValue = "—"
    case .single (let v) :
      self.stringValue = v
    case .multiple :
      self.stringValue = "—"
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------

