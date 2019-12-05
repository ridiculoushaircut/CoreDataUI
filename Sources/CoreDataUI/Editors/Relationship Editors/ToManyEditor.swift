//
//  ToManyEditor.swift
//  CoreDataUI
//
//  Created by Bradford Dillon on 11/27/19.
//  Copyright © 2019 Ridiculous Haircut, LLC. All rights reserved.
//

import CoreData
import SwiftUI

class ToManyEditor: ToManyEditing, ObservableObject {
    var editedModel: NSManagedObject?
    var key: String
    var entity: NSEntityDescription
    var context: NSManagedObjectContext
    @Published var models: [NSManagedObject]
    var view: AnyView?
    
    init(key: String, entity: NSEntityDescription, context: NSManagedObjectContext, editedModel: NSManagedObject? = nil, models: [NSManagedObject] = []) {
        self.key = key
        self.entity = entity
        self.context = context
        self.editedModel = editedModel
        self.models = models
        self.view = AnyView(SummaryView(editor: self))
    }
    
    var predicate: NSPredicate? {
        guard let editedModel = editedModel,
            let relationship = editedModel.entity.relationshipsByName[key],
            let inverse = relationship.inverseRelationship,
            let filter = CoreDataUI.container.entityConfig(for: editedModel.entity.name!)?.relationshipFilters[relationship.name] else { return nil }
        
        switch filter {
        case .all:
            
        }
        let inverseKey = inverse.name
        if inverse.isToMany {
            return NSPredicate(format: "%@ in %K", argumentArray: [editedModel, inverseKey])
        }
        else {
            return NSPredicate(format: "%@ == %K", argumentArray: [editedModel, inverseKey])
        }
        
        return nil
    }
        
    struct SummaryView: View {
        @ObservedObject var editor: ToManyEditor
        
        var modelDescription: String {
            if editor.models.count > 0 {
                return editor.models.map { CoreDataUI.container.entityConfig(for: editor.entity.name!)!.summary.title(from: $0)! }.joined(separator: "\n")
            }
            else {
                return "None"
            }
        }
        
        var body: some View {
            NavigationLink(destination: ModelSelectionView(viewModel: FetchedResultsViewModel(entity: editor.entity,
                                                                                              context: editor.context,
                                                                                              predicate: editor.predicate), selection: $editor.models) { (object) in
                if self.editor.models.contains(object) {
                    self.editor.models = self.editor.models.filter { $0 != object }
                }
                else {
                    self.editor.models.append(object)
                }
                return false
            }.navigationBarTitle("Edit \(editor.key)")) {
                HStack {
                    Text(editor.key)
                    Spacer()
                    Text("\(modelDescription)")
                }
            }
        }
    }
}
