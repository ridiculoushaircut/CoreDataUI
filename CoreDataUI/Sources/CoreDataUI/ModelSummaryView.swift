//
//  ModelSummaryView.swift
//  CoreDataUI
//
//  Created by Bradford Dillon on 11/25/19.
//  Copyright © 2019 Ridiculous Haircut, LLC. All rights reserved.
//

import SwiftUI
import CoreData

struct ModelSummaryView<T: NSManagedObject>: View {
    var model: T
    var entity: NSEntityDescription
    var context: NSManagedObjectContext
    var config: SummaryViewConfig?
    
    public init(model: T, context: NSManagedObjectContext, config: SummaryViewConfig? = nil) {
        self.entity = model.entity
        self.context = context
        self.config = config

        self.model = model
    }
    
    var body: some View {
        HStack {
            Text(config?.title(from: model) ?? "Title")
            Spacer()
            Text(config?.detail(from: model) ?? "")
        }
    }
}

protocol AttributeFormatter {
    associatedtype Input
    func string(from input: Input) -> String
}
