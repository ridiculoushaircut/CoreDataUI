//
//  DateModifier.swift
//  CoreDataUI
//
//  Created by Bradford Dillon on 11/25/19.
//  Copyright © 2019 Ridiculous Haircut, LLC. All rights reserved.
//

import SwiftUI

class DateEditor: AttributeEditing {
    var label: String
    var key: String
    var value: Date
    var view: AnyView?
    
    init(label: String, key: String, value: Date) {
        self.label = label
        self.key = key
        self.value = value
        self.view = AnyView(EditorView(label: label, value: valueBinding))
    }
    
    struct EditorView: View {
        var label: String
        @Binding var value: Date
        var body: some View {
            DatePicker(selection: $value) { Text(label) }
        }
    }
}
