//
//  CustomViewController.swift
//  KeepTimeLite
//
//  Created by Nishchay Karle on 5/23/24.
//

import AppKit

class CustomStatusItemView: NSView {
    var menuProvider: (() -> NSMenu)?

    override func rightMouseDown(with event: NSEvent) {
        if let menu = menuProvider?() {
            NSMenu.popUpContextMenu(menu, with: event, for: self)
        }
    }
}
