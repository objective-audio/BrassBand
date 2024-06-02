@_exported import BrassBandCpp
@_exported import Combine

public enum UI {}

#if os(iOS)

    @_exported import UIKit

    extension UI {
        public typealias Color = UIColor
        public typealias View = UIView
        public typealias ViewController = UIViewController
        public typealias EdgeInsets = UIEdgeInsets
    }

#elseif os(macOS)

    @_exported import AppKit

    extension UI {
        public typealias Color = NSColor
        public typealias View = NSView
        public typealias ViewController = NSViewController
        public typealias EdgeInsets = NSEdgeInsets
    }

#endif
