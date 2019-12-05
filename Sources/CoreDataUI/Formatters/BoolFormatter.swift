//
//  BoolFormatter.swift
//  CoreDataUI
//
//  Created by Bradford Dillon on 11/26/19.
//  Copyright © 2019 Ridiculous Haircut, LLC. All rights reserved.
//

import Foundation

public class BoolFormatter: Formatter {
    public var trueText = "True"
    public var falseText = "False"
    
    public override func string(for obj: Any?) -> String? {
        guard let b = obj as? Bool else { return nil }
        return b ? trueText : falseText
    }
}
