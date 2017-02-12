//
//  Style.swift
//  Notepad
//
//  Created by Rudd Fawcett on 10/14/16.
//  Copyright © 2016 Rudd Fawcett. All rights reserved.
//

import UIKit

public struct Style {
    var regex: NSRegularExpression!
    var attributes: [String: Any] = [:]

    init(element: Element, attributes: [String: Any]) {
        self.regex = element.toRegex()
        self.attributes = attributes
    }

    init(regex: NSRegularExpression, attributes: [String: Any]) {
        self.regex = regex
        self.attributes = attributes
    }

    init() {
        self.regex = Element.unknown.toRegex()
    }
}
