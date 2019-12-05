//
//  RelationshipEditor.swift
//  CoreDataUI
//
//  Created by Bradford Dillon on 11/27/19.
//  Copyright © 2019 Ridiculous Haircut, LLC. All rights reserved.
//

import CoreData
import SwiftUI

protocol RelationshipEditing: class, ViewHosting, Debuggable {
    var key: String { get }
    var entity: NSEntityDescription { get }
    func applyTo(model: NSManagedObject)
}

protocol ToOneEditing: RelationshipEditing {
    var model: NSManagedObject? { get set }
}

protocol ToManyEditing: RelationshipEditing {
    associatedtype EntityType
    var models: [EntityType] { get set }
    func applyTo(model: NSManagedObject)
}

extension ToOneEditing {
    func applyTo(model: NSManagedObject) {
        model.setValue(self.model, forKey: key)
    }
    
    var debugDescription: String {
        return "\(key) \(model!)"
    }
}

extension ToManyEditing {
    func applyTo(model: NSManagedObject) {
        guard let relationship = model.entity.relationshipsByName[key] else { return }
        if relationship.isOrdered {
            model.setValue(NSOrderedSet(array: models), forKey: key)
        }
        else {
            model.setValue(NSSet(array: models), forKey: key)
        }
    }
    
    var debugDescription: String {
        return "\(key) \(models)"
    }
}

class AnyRelationshipEditor: ViewHosting, RelationshipEditing, Identifiable {
    let id = UUID()
    
    var key: String = ""
    var entity: NSEntityDescription
    
    fileprivate let wrapped: ViewHosting & Debuggable
    private let _apply: ((NSManagedObject) -> Void)
    
    init<W: RelationshipEditing>(_ wrapped: W) {
        self.wrapped = wrapped
        self.key = wrapped.key
        self.entity = wrapped.entity
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
