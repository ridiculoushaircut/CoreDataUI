//
//  AttributeModifier.swift
//  CoreDataUI
//
//  Created by Bradford Dillon on 11/25/19.
//  Copyright © 2019 Ridiculous Haircut, LLC. All rights reserved.
//

import SwiftUI
import CoreData

protocol Debuggable {
    var debugDescription: String { get }
}

protocol ViewHosting {
    var view: AnyView? { get }
}

protocol AttributeEditing: class, ViewHosting, Debuggable {
    associatedtype ValueType
    
    var key: String { get set }
    var value: ValueType { get set }
    var valueBinding: Binding<ValueType> { get }
    
    func applyTo(model: NSManagedObject)
}

extension AttributeEditing {
    func applyTo(model: NSManagedObject) {
        model.setValue(value, forKey: key)
    }
    
    var valueBinding: Binding<ValueType> {
        Binding(get: { self.value }, set: { self.value = $0 })
    }
    
    var debugDescription: String {
        "\(self), \(key): \(value)"
    }
}

class AnyAttributeEditor: ViewHosting, AttributeEditing, Identifiable {
    let id = UUID()
    
    var key: String = ""
    var value: String = ""
    
    fileprivate let wrapped: ViewHosting & Debuggable
    private let _apply: ((NSManagedObject) -> Void)
    
    init<W: AttributeEditing>(_ wrapped: W) {
        self.wrapped = wrapped
        self._apply = wrapped.applyTo(model:)
    }
    
    var view: AnyView? { wrapped.view }
    
    func applyTo(model: NSManagedObject) {
        _apply(model)
    }
    
    var debugDescription: String {
        "\(self)(\(wrapped.debugDescription))"
    }
}

class NullEditor: AttributeEditing {
    var key: String
    var value: Int? = nil
    var view: AnyView?
    
    init(key: String) {
        self.key = key
        self.view = nil
    }
    
    func applyTo(model: NSManagedObject) {}
}
