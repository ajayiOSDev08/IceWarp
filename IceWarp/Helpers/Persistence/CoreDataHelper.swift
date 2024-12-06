//
//  CoreDataHelper.swift
//  IceWarp
//
//  Created by Ajay on 05/12/24.
//

import CoreData

// MARK: - ModelConvertible Protocol
protocol ModelConvertible {
    associatedtype EntityType: NSManagedObject
    func toEntity(context: NSManagedObjectContext) -> EntityType
}

// MARK: - EntityConvertible Protocol
protocol EntityConvertible {
    associatedtype ModelType
    func toModel() -> ModelType
}

// MARK: - Core Data Helper
final class CoreDataHelper {
    static let shared = CoreDataHelper()
    private init() {}
    
    // MARK: - Core Data Stack
    
    // Persistent container to manage Core Data stack.
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "IceWarp") // Replace with your .xcdatamodeld name
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // Main context for UI-related tasks.
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // Background context for performing heavy or non-UI tasks.
    var backgroundContext: NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    // MARK: - CRUD Operations
    // Save changes in the context.
    func saveContext(_ context: NSManagedObjectContext? = nil) {
        let context = context ?? viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // Fetch entities of a given type with an optional predicate.
    func fetchEntities<T: NSManagedObject>(ofType type: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> [T] {
        let entityName = String(describing: type)
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch \(entityName): \(error)")
            return []
        }
    }
    
    // Delete an entity from the context.
    func deleteEntity(_ entity: NSManagedObject) {
        viewContext.delete(entity)
    }
    
    // Delete all entities of a given type.
    func deleteAllEntities<T: NSManagedObject>(ofType type: T.Type) {
        let entityName = String(describing: type)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(batchDeleteRequest)
        } catch {
            print("Failed to delete all \(entityName): \(error)")
        }
    }
}
