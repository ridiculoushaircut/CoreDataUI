//
//  StringModifier.swift
//  CoreDataUI
//
//  Created by Bradford Dillon on 11/25/19.
//  Copyright © 2019 Ridiculous Haircut, LLC. All rights reserved.
//

import SwiftUI

class StringEditor: AttributeEditing {
    var label: String
    var key: String
    var value: String
    var view: AnyView?
    
    init(label: String, key: String, value: String) {
        self.label = label
        self.key = key
        self.value = value
        self.view = AnyView(EditorView(label: label, value: valueBinding))
    }
    
    struct EditorView: View {
        var label: String
        @Binding var value: String
        var body: some View {
            TextField(label, text: $value)
        }
    }
}
