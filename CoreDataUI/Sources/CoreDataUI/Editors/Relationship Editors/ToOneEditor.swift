//
//  ToOneEditor.swift
//  CoreDataUI
//
//  Created by Bradford Dillon on 11/27/19.
//  Copyright © 2019 Ridiculous Haircut, LLC. All rights reserved.
//

import CoreData
import SwiftUI

class ToOneEditor: ToOneEditing {
    
    var key: String
    var entity: NSEntityDescription
    var context: NSManagedObjectContext
    var model: NSManagedObject?
    var view: AnyView?
    
    init(key: String, entity: NSEntityDescription, context: NSManagedObjectContext, model: NSManagedObject? = nil) {
        self.key = key
        self.entity = entity
        self.context = context
        self.model = model
        self.view = AnyView(SummaryView(relationshipName: key, entity: entity, context: context, models: model == nil ? [] : [model!]))
    }
    
    struct SummaryView: View {
        var relationshipName: String
        var entity: NSEntityDescription
        var context: NSManagedObjectContext
        
        @State var models: [NSManagedObject]
        
        var modelDescription: String {
            if models.count > 0 {
                return models.map { CoreDataUI.container.entityConfig(for: entity.name!)!.summary.title(from: $0)! }.joined(separator: "\n")
            }
            else {
                return "None"
            }
        }

        var body: some View {
            NavigationLink(destination: ModelSelectionView(viewModel: FetchedResultsViewModel(entity: entity, context: context), selection: $models) { (object) in
                self.models = [object]
                return true
            }) {
                HStack {
                    Text(relationshipName)
                    Spacer()
                    VStack {
                        Text("\(modelDescription)")
                        Text("One<\(entity.name!)>")
                            .font(.caption)
                    }
                }
            }
        }
    }
}
