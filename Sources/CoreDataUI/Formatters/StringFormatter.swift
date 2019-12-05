//
//  StringFormatter.swift
//  CoreDataUI
//
//  Created by Bradford Dillon on 11/26/19.
//  Copyright © 2019 Ridiculous Haircut, LLC. All rights reserved.
//

import Foundation

public class StringFormatter: Formatter {
    public override func string(for obj: Any?) -> String? {
        guard let s = obj as? String else { return nil }
        return s
    }
}
