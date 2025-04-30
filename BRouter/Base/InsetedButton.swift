//
//  InsetedButton.swift
//  BRouter
//
//  Created by csz on 2023/8/26.
//

import AppKit

class InsetedButton: NSButton {
    var verticalPadding: CGFloat = 4
    var horizontalPadding: CGFloat = 10
    
    override var intrinsicContentSize: NSSize {
        var size = super.intrinsicContentSize
        size.width += horizontalPadding * 2
        size.height += verticalPadding * 2
        return size
    }
}
