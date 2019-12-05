//
//  ModelSelectionView.swift
//  CoreDataUI
//
//  Created by Bradford Dillon on 11/29/19.
//  Copyright © 2019 Ridiculous Haircut, LLC. All rights reserved.
//

import SwiftUI
import CoreData

struct ModelSelectionView: View {
    @Environment(\.presentationMode) var mode
    
    @ObservedObject var viewModel: FetchedResultsViewModel
    
    @Binding var selection: [NSManagedObject]
    var allowCreation: Bool = true

    @State var selectionHandler: (NSManagedObject) -> Bool
    
    var body: some View {
        List {
            ForEach(viewModel.sections) { (section) in
                Section(header: Text(section.name)) {
                    ForEach(section.objects, id: \.objectID) { (object: NSManagedObject) in
                        Button(action: {
                            if self.selectionHandler(object) {
                                self.mode.wrappedValue.dismiss()
                            }
                        }) {
                            HStack {
                                ModelSummaryView(model: object,
                                                 context: self.viewModel.context,
                                                 config: CoreDataUI.container.entityConfig(for: object.entity.name!)?.summary)
                                Image(systemName: "checkmark")
                                    .opacity(self.selection.contains(object) ? 1.0 : 0.0)
                            }
                        }
                            .foregroundColor(Color.black)
                    }
                    .onDelete { self.viewModel.delete($0) }
                }
            }
            
            if self.allowCreation {
                Section(header: Text("ACTIONS")) {
                    NavigationLink(destination: ModelDetailView(entity: self.viewModel.entity, context: self.viewModel.context)) {
                        Text("New")
                    }
                }
            }
        }
        .environmentObject(viewModel)
        .navigationBarItems(trailing: Button(action: {
            self.mode.wrappedValue.dismiss()
        }) {
            Text("Done")
        })
    }
}
