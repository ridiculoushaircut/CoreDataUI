//
//  NumberModifier.swift
//  CoreDataUI
//
//  Created by Bradford Dillon on 11/25/19.
//  Copyright © 2019 Ridiculous Haircut, LLC. All rights reserved.
//

import SwiftUI

class NumberEditor: AttributeEditing, ObservableObject {
    var label: String
    var key: String
    var value: NSNumber
    var view: AnyView?
    
    @Published var valueString: String
    
    init(label: String, key: String, value: NSNumber) {
        self.label = label
        self.key = key
        self.value = value
        
        self.valueString = valueFormatter.string(from: value) ?? ""
        
        let modifier = EditorView(label: label, value: valueBinding, modifier: self)
        self.view = AnyView(modifier)
    }
    
    func editingValue(_ editing: Bool) {
        let sanitized = self.valueString.components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted).joined()
        
        if editing {
            self.valueString = sanitized
        }
        else {
            if let value = valueFormatter.number(from: sanitized) {
                self.value = value
                self.valueString = valueFormatter.string(from: value) ?? ""
            }
        }
    }

    struct EditorView: View {
        var label: String
        @Binding var value: NSNumber
        @ObservedObject var modifier: NumberEditor
        
        var body: some View {
            TextField(label, text: $modifier.valueString, onEditingChanged: modifier.editingValue(_:), onCommit: {})
        }
    }
}

var valueFormatter: NumberFormatter = {
    let valueFormatter = NumberFormatter()
    valueFormatter.numberStyle = .decimal
    valueFormatter.maximumFractionDigits = 5
    return valueFormatter
}()

