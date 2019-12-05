//
//  BoolModifier.swift
//  CoreDataUI
//
//  Created by Bradford Dillon on 11/25/19.
//  Copyright © 2019 Ridiculous Haircut, LLC. All rights reserved.
//

import SwiftUI

class BoolEditor: AttributeEditing {
    var label: String
    var key: String
    var value: Bool
    var view: AnyView?
    
    init(label: String, key: String, value: Bool) {
        self.label = label
        self.key = key
        self.value = value
        self.view = AnyView(EditorView(label: label, value: valueBinding))
    }
    
    struct EditorView: View {
        var label: String
        @Binding var value: Bool
        var body: some View {
            Toggle(isOn: $value) { Text(label) }
        }
    }
}
