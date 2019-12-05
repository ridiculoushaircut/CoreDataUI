//
//  FetchRequestView.swift
//  CoreDataUI
//
//  Created by Bradford Dillon on 11/25/19.
//  Copyright © 2019 Ridiculous Haircut, LLC. All rights reserved.
//

import SwiftUI
import CoreData
import Combine

public class FetchedResultsViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    struct Section: Identifiable {
        let name: String
        let objects: [NSManagedObject]
        var id: String { name }
    }
    
    public let entity: NSEntityDescription
    public let context: NSManagedObjectContext
    let resultsController: NSFetchedResultsController<NSManagedObject>
    public let objectWillChange: ObservableObjectPublisher = ObservableObjectPublisher()
    
    private var selection: [NSManagedObject]?
    
    let title: String
    
    var sections: [Section] { (resultsController.sections ?? []).map { Section(name: $0.name, objects: ($0.objects ?? []) as! [NSManagedObject]) } }
    var objects: [NSManagedObject] { resultsController.fetchedObjects ?? [] }
    
    public init(entity: NSEntityDescription, context: NSManagedObjectContext, sortDescriptors: [NSSortDescriptor]? = nil, predicate: NSPredicate? = nil, sectionNameKeyPath: String? = nil, cacheName: String? = nil) {
        self.entity = entity
        self.context = context
        self.title = "\(entity.name!) List"
        
        let request = NSFetchRequest<NSManagedObject>(entityName: entity.name!)
        request.sortDescriptors = sortDescriptors ?? CoreDataUI.container.entityConfig(for: entity.name!)!.defaultSortDescriptors
        request.predicate = predicate
        self.resultsController = NSFetchedResultsController(fetchRequest: request,
                                                            managedObjectContext: context,
                                                            sectionNameKeyPath: sectionNameKeyPath,
                                                            cacheName: cacheName)
        
        super.init()
        
        resultsController.delegate = self
        try! resultsController.performFetch()
    }
    
    func create(_ modifier: ((NSManagedObject) -> Void)) -> NSManagedObject {
        let object = NSEntityDescription.insertNewObject(forEntityName: entity.name!, into: context)
        modifier(object)
        try? context.save()
        
        return object
    }
    
    func delete(_ indexSet: IndexSet) {
        let entries = indexSet.map { self.objects[$0] }
        entries.forEach { self.context.delete($0) }
        try? self.context.save()
    }
    
    var predicate: NSPredicate? {
        get { resultsController.fetchRequest.predicate }
        set {
            resultsController.fetchRequest.predicate = newValue
            try! resultsController.performFetch()
        }
    }
    
    func select(object: NSManagedObject) {
        var selection = self.selection ?? []
        selection.append(object)
        self.selection = selection
    }
    
    func deselect(object: NSManagedObject) {
        if selection == nil { return }
        self.selection = self.selection!.filter { $0 != object }
    }
    
    func isSelected(_ object: NSManagedObject) -> Bool {
        return selection?.contains(object) ?? false
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.objectWillChange.send()
    }
}

public struct FetchRequestView: View {
    var viewModel: FetchedResultsViewModel
    
    @State var newModelPresented = false
    
    public init(viewModel: FetchedResultsViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            List {
                ForEach(viewModel.sections) { (section) in
                    Section(header: Text(section.name)) {
                        ForEach(section.objects, id: \.objectID) { (object: NSManagedObject) in
                            NavigationLink(destination: ModelDetailView(model: object, entity: object.entity, context: self.viewModel.context)) {
                                ModelSummaryView(model: object,
                                                 context: self.viewModel.context,
                                                 config: CoreDataUI.container.entityConfig(for: object.entity.name!)?.summary)
                            }
                        }
                        .onDelete { self.viewModel.delete($0) }
                    }
                }
            }
            .environmentObject(viewModel)
        }
        .navigationBarTitle(viewModel.title)
        .navigationBarItems(trailing:
            Button(action: {
                self.newModelPresented = true
            }) {
                Image(systemName: "plus")
                    .padding([.top, .bottom])
            }
        )
            .sheet(isPresented: $newModelPresented) {
                NavigationView {
                    ModelDetailView(entity: self.viewModel.entity, context: self.viewModel.context)
                }
        }
    }
}
