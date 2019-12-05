//
//  CoreDataUI.swift
//  CoreDataUI
//
//  Created by Bradford Dillon on 11/25/19.
//  Copyright © 2019 Ridiculous Haircut, LLC. All rights reserved.
//

import SwiftUI
import CoreData

public class CoreDataUI {
    public static var container = CoreDataUIContainer()
}

public enum RelationshipFilter {
    case all
    case owned
    case custom(NSPredicate)
}

public struct EntityConfig {
    public var defaultSortDescriptors: [NSSortDescriptor]
    public var summary: SummaryViewConfig
    public var relationshipFilters: [String: RelationshipFilter]
    
    public init(defaultSortDescriptors: [NSSortDescriptor], summary: SummaryViewConfig, relationshipFilters: [String: RelationshipFilter] = [:]) {
        self.defaultSortDescriptors = defaultSortDescriptors
        self.summary = summary
        self.relationshipFilters = relationshipFilters
    }
}

public class CoreDataUIContainer {
    
    var entityConfigs = [String: EntityConfig]()
    
    fileprivate init() {}
    
    public func register(_ configs: [String: EntityConfig]) {
        for (key, config) in configs {
            setEntityConfig(for: key, config: config)
        }
    }
    
    public func setEntityConfig(for entityName: String, config: EntityConfig) {
        entityConfigs[entityName] = config
    }
    
    public func entityConfig(for entityName: String) -> EntityConfig? {
        entityConfigs[entityName]
    }
}

public struct SummaryViewConfig {
    private var title: (String, Formatter)
    private var detail: (String, Formatter)?
    
    public init(_ title: (String, Formatter), _ detail: (String, Formatter)? = nil) {
        self.title = title
        self.detail = detail
    }
    
    public func title(from model: NSManagedObject) -> String? {
        format(pair: title, model: model)
    }
    
    public func detail(from model: NSManagedObject) -> String? {
        guard let detail = detail else { return nil }
        return format(pair: detail, model: model)
    }
    
    private func format(pair: (String, Formatter), model: NSManagedObject) -> String? {
        let (key, formatter) = pair
        return formatter.string(for: model.value(forKey: key))
    }
}
