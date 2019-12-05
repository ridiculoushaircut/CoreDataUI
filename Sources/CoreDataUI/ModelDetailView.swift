//
//  ModelView.swift
//  CoreDataUI
//
//  Created by Bradford Dillon on 11/21/19.
//  Copyright © 2019 Ridiculous Haircut, LLC. All rights reserved.
//

import SwiftUI
import CoreData

class ModelDetailViewModel<T: NSManagedObject>: ObservableObject {
    var model: T?
    var entity: NSEntityDescription
    var context: NSManagedObjectContext
    var attributeModifiers: [AnyAttributeEditor]
    var relationshipViews: [AnyRelationshipEditor]
    var attributeKeyOrder: [String]? = nil
    var relationshipKeyOrder: [String]? = nil

    init(model: T?, entity: NSEntityDescription, context: NSManagedObjectContext, attributeKeyOrder: [String]? = nil, relationshipKeyOrder: [String]? = nil) {
        self.model = model
        self.entity = entity
        self.context = context
        self.attributeModifiers = []
        self.attributeKeyOrder = attributeKeyOrder ?? CoreDataUI.container.entityConfig(for: entity.name!)?.detail?.attributeOrder
        self.relationshipKeyOrder = relationshipKeyOrder ?? CoreDataUI.container.entityConfig(for: entity.name!)?.detail?.relationshipOrder

        let akeys = attributeKeyOrder ?? entity.attributesByName.keys.map { $0 }.sorted()
        let attributes = akeys.map { ($0, entity.attributesByName[$0]!) }
        self.attributeModifiers = attributes.map {
            let (key, attribute) = $0
            
            switch attribute.attributeType {
            case .integer16AttributeType,
                 .integer32AttributeType,
                 .integer64AttributeType:
                return AnyAttributeEditor(NumberEditor(label: key,
                                                       key: key,
                                                       value: model?.value(forKey: key) as? NSNumber ?? 0))
            case .decimalAttributeType,
                 .floatAttributeType,
                 .doubleAttributeType:
                return AnyAttributeEditor(NumberEditor(label: key,
                                                           key: key,
                                                           value: model?.value(forKey: key) as? NSNumber ?? 0))
            case .booleanAttributeType:
                return AnyAttributeEditor(BoolEditor(label: key,
                                                         key: key,
                                                         value: model?.value(forKey: key) as? Bool ?? false))
            case .stringAttributeType:
                return AnyAttributeEditor(StringEditor(label: key,
                                                           key: key,
                                                           value: model?.value(forKey: key) as? String ?? ""))
            case .dateAttributeType:
                return AnyAttributeEditor(DateEditor(label: key,
                                                         key: key,
                                                         value: model?.value(forKey: key) as? Date ?? Date()))
            default:
                return AnyAttributeEditor(NullEditor(key: key))
            }
        }
        
        let rkeys = relationshipKeyOrder ?? entity.relationshipsByName.keys.map { $0 }
        let relationships = rkeys.map { ($0, entity.relationshipsByName[$0]! )}
        self.relationshipViews = relationships.map {
            let (key, relationship) = $0
            if relationship.isToMany {
                var objects: [NSManagedObject] = []
                if relationship.isOrdered {
                    if let rawObjects = model?.value(forKey: key) as? NSOrderedSet {
                        objects = rawObjects.array as? [NSManagedObject] ?? []
                    }
                }
                else {
                    if let rawObjects = model?.value(forKey: key) as? NSSet {
                        objects = rawObjects.allObjects as? [NSManagedObject] ?? []
                    }
                }

                return AnyRelationshipEditor(ToManyEditor(key: key, entity: relationship.destinationEntity!, context: context, editedModel: model, models: objects))
            }
            else {
                return AnyRelationshipEditor(ToOneEditor(key: key, entity: relationship.destinationEntity!, context: context, model: model?.value(forKey: key) as? NSManagedObject))
            }
        }
    }
    
    func save() {
        if self.model == nil {
            self.model = NSEntityDescription.insertNewObject(forEntityName: self.entity.name!, into: self.context) as? T
        }
        
        self.attributeModifiers.forEach {
            $0.applyTo(model: self.model!)
        }
        
        self.relationshipViews.forEach {
            $0.applyTo(model: self.model!)
        }
        
        try! self.model!.managedObjectContext?.save()
    }
}

public struct ModelDetailView<T: NSManagedObject>: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ModelDetailViewModel<T>

    public init(model: T? = nil, entity: NSEntityDescription, context: NSManagedObjectContext, attributeKeyOrder: [String]? = nil, relationshipKeyOrder: [String]? = nil) {
        self.viewModel = ModelDetailViewModel(model: model,
                                              entity: entity,
                                              context: context,
                                              attributeKeyOrder: attributeKeyOrder,
                                              relationshipKeyOrder: relationshipKeyOrder)

    }
    
    public var body: some View {
        Form {
            Section(header: Text("Attributes".uppercased())) {
                ForEach(viewModel.attributeModifiers) {
                    $0.view
                }
            }
            Section(header: Text("Relationships".uppercased())) {
                ForEach(viewModel.relationshipViews) {
                    $0.view
                }
            }
            Section(header: Text("Actions".uppercased())) {
                Button(action: {
                    
                }) {
                    Text("Delete")
                        .foregroundColor(Color.red)
                }
            }
        }
        .navigationBarTitle(Text(viewModel.entity.name!))
        .navigationBarItems(
            trailing: Button(action: {
                self.viewModel.save()
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Save")
            }))
    }
}
