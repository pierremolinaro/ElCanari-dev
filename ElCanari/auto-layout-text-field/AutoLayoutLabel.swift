//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutLabel : AutoLayoutBase_NSTextField {

  //····················································································································
  // INIT
  //····················································································································

  init (bold inBold : Bool, size inSize : EBControlSize) {
    super.init (optionalWidth: nil, bold: inBold, size: inSize)

    self.isBezeled = false
    self.isBordered = false
    self.drawsBackground = false
    self.isEnabled = true
    self.isEditable = false
    self.controlSize = inSize.cocoaControlSize
    let fontSize = NSFont.systemFontSize (for: self.controlSize)
    self.font = inBold ? NSFont.boldSystemFont (ofSize: fontSize) : NSFont.systemFont (ofSize: fontSize)
  }

  //····················································································································

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
    if debugAutoLayout () {
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

  final func setTextColor (_ inTextColor : NSColor) -> Self {
    self.textColor = inTextColor
    return self
  }

  //····················································································································
  // setRedTextColor
  //····················································································································

  final func setRedTextColor () -> Self {
    self.textColor = .red
    return self
  }

  //····················································································································
  //MARK:  $title binding
  //····················································································································

  private var mTitleController : EBObservablePropertyController? = nil

  //····················································································································

  final func bind_title (_ inObject : EBReadOnlyProperty_String) -> Self {
    self.mTitleController = EBObservablePropertyController (
      observedObjects: [inObject],
      callBack: { [weak self] in self?.update (from: inObject.selection) }
    )
    return self
  }

  //····················································································································

  private func update (from inObjectSelection : EBSelection <String>) {
    switch inObjectSelection {
    case .empty :
      self.placeholderString = "No Selection"
      self.stringValue = ""
    case .single (let v) :
      self.placeholderString = nil
      self.stringValue = v
    case .multiple :
      self.placeholderString = "Multiple Selection"
      self.stringValue = ""
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

