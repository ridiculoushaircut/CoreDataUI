//
//  PickerModifier.swift
//  CoreDataUI
//
//  Created by Bradford Dillon on 11/25/19.
//  Copyright © 2019 Ridiculous Haircut, LLC. All rights reserved.
//

import SwiftUI

class PickerEditor: AttributeEditing {
    struct PickerOption: Identifiable {
        let index: Int
        let text: String
        
        var id: String { text }
    }
    
    var label: String
    var options: [PickerOption]
    var key: String
    var value: Int
    var view: AnyView?
    
    init(label: String, options: [String], key: String, value: Int) {
        self.label = label
        self.options = options.enumerated().map { PickerOption(index: $0, text: $1) }
        self.key = key
        self.value = value
        self.view = AnyView(EditorView(label: label, options: self.options, value: valueBinding))
    }
    
    struct EditorView: View {
        var label: String
        var options: [PickerOption]
        @Binding var value: Int
        var body: some View {
            Picker(selection: $value, label: Text(label)) {
                ForEach(options) { Text($0.text).tag($0.index) }
            }
        }
    }
}
