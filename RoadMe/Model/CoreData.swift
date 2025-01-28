//
//  CoreData.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 22.12.24.
//

import SwiftUI
import CoreData
import UIKit

class CoreDataModel: ObservableObject {
    
    @Published var savedEntities: [ProjectTaskEntity] = []
    @Published var tags: [String] = []
    @Published var gridSize: Int16 = 1
    
    let container: NSPersistentContainer
    private var mappedEntities: Set<UUID> = []
    private let themeManager: ThemeManager = ThemeManager()

    init() {
        self.container = NSPersistentContainer(name: "ProjectContainer")

        self.container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading Core Data: \(error)")
            }
        }
        
        self.fetchGridsize()
    }
    
    func deleteDatabase() {
        let persistentStoreCoordinator = container.persistentStoreCoordinator
        let stores = persistentStoreCoordinator.persistentStores

        for store in stores {
            if let storeURL = store.url {
                do {
                    try persistentStoreCoordinator.remove(store)
                    try FileManager.default.removeItem(at: storeURL)
                    print("Successfully deleted Core Data database.")
                } catch {
                    print("Error deleting Core Data database: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Grid Size
extension CoreDataModel {
    func fetchGridsize() {
        let request = NSFetchRequest<PersonEntity>(entityName: "PersonEntity")
        
        do {
            let personEntity = try container.viewContext.fetch(request)
            if let person = personEntity.first {
                self.gridSize = person.gridSize
                print("Grid Size: \(self.gridSize)")
            }
        } catch let error {
            print("Error fetching tags: \(error.localizedDescription)")
        }
    }
    
    func updateGridSize(_ gridSize: Int16) {
        let request = NSFetchRequest<PersonEntity>(entityName: "PersonEntity")
        
        do {
            let personEntity = try container.viewContext.fetch(request)
            if let person = personEntity.first {
                person.gridSize = gridSize
                try container.viewContext.save()
                self.fetchGridsize()
            }
        } catch let error {
            print("Error fetching tags: \(error.localizedDescription)")
        }
    }
}

// MARK: - Tags
extension CoreDataModel {
    func fetchTags() {
        let request = NSFetchRequest<PersonEntity>(entityName: "PersonEntity")
        
        do {
            let personEntity = try container.viewContext.fetch(request)
            if let person = personEntity.first {
                if let tagsData = person.tags as Data? {
                    let tags = try JSONDecoder().decode([String].self, from: tagsData)
                    print(tags)
                    self.tags = tags
                } else {
                    self.tags = []
                }
            }
        } catch let error {
            print("Error fetching tags: \(error.localizedDescription)")
        }
    }
    
    func saveTags(tags: [String]) -> Bool {
        let request = NSFetchRequest<PersonEntity>(entityName: "PersonEntity")
        
        do {
            let personEntities = try container.viewContext.fetch(request)
            
            // If a PersonEntity exists, update its tags
            if let personEntity = personEntities.first {
                personEntity.tags = try JSONEncoder().encode(tags)
            } else {
                // If no PersonEntity exists, create a new one
                let newPersonEntity = PersonEntity(context: container.viewContext)
                newPersonEntity.tags = try JSONEncoder().encode(tags)
            }
            
            try container.viewContext.save()
            print("Tags saved successfully.")
            self.fetchTags()
            return true
            
        } catch {
            print("Failed to save tags: \(error.localizedDescription)")
            return false
        }
    }
}

// MARK: - Look up table and task counter
extension CoreDataModel {
    // Load completedTasksLookup from Core Data
    func loadCompletedTasksLookup() -> [Date: [UUID]] {
        let request: NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()
        do {
            if let personEntity = try container.viewContext.fetch(request).first,
               let jsonData = personEntity.completedTasksLookup {
                let decodedDictionary = try JSONDecoder().decode([String: [UUID]].self, from: jsonData)
                return deserializeDictionary(decodedDictionary)
            }
        } catch {
            print("Error loading completedTasksLookup: \(error)")
        }
        return [:] // Return an empty dictionary if nothing is found
    }

    // Save completedTasksLookup to Core Data
    func saveCompletedTasksLookup(_ lookup: [Date: [UUID]]) {
        let request: NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()
        do {
            let personEntity: PersonEntity
            if let fetchedEntity = try container.viewContext.fetch(request).first {
                personEntity = fetchedEntity
            } else {
                personEntity = PersonEntity(context: container.viewContext)
            }
            let jsonData = try JSONEncoder().encode(serializeDictionary(lookup))
            personEntity.completedTasksLookup = jsonData
            try container.viewContext.save()
        } catch {
            print("Error saving completedTasksLookup: \(error)")
        }
    }

    // Serialize dictionary (convert Date keys to String)
    private func serializeDictionary(_ dictionary: [Date: [UUID]]) -> [String: [UUID]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return dictionary.reduce(into: [:]) { result, pair in
            result[formatter.string(from: pair.key)] = pair.value
        }
    }

    // Deserialize dictionary (convert String keys back to Date)
    private func deserializeDictionary(_ dictionary: [String: [UUID]]) -> [Date: [UUID]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return dictionary.reduce(into: [:]) { result, pair in
            if let date = formatter.date(from: pair.key) {
                result[date] = pair.value
            }
        }
    }
}

// MARK: - Task
extension CoreDataModel {
    // Fetch all tasks (root-level tasks and their subtasks recursively)
    func fetchTasks() -> [ProjectTaskEntity] {
        let request = NSFetchRequest<ProjectTaskEntity>(entityName: "ProjectTaskEntity")
        var savedEntities: [ProjectTaskEntity] = []
        
        do {
            savedEntities = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching tasks: \(error)")
        }
        
        return savedEntities
    }
    
    func addRootTask(task: ProjectTask, themeId: UUID) -> [ProjectTask] {
        // Create the new root task entity
        let taskEntity = ProjectTaskEntity(context: container.viewContext)
        taskEntity.id = task.id
        taskEntity.name = task.name
        taskEntity.descriptions = task.description
        taskEntity.isCompleted = task.isCompleted
        taskEntity.index = task.index
        taskEntity.process = task.process
        taskEntity.parentTaskID = nil // Explicitly set as a root-level task
        taskEntity.color = task.color
        taskEntity.themeID = themeId
        taskEntity.tag = task.tag
        
        if let coverImage = task.coverImage {
            taskEntity.coverImage = coverImage.pngData()
        }
        
        if let iconImage = task.iconImage {
            taskEntity.iconImage = iconImage.pngData()
        }
        
        if let iconString = task.iconString {
            taskEntity.iconString = iconString
        }

        // Save changes to Core Data and return updated model
        let tasks = saveData()
        return tasks
    }

    // Add a new root-level task
    func addSubtask(to parentTaskID: UUID, subtask: ProjectTask) -> [ProjectTask]{
        // Fetch the parent task by its ID
        let fetchRequest: NSFetchRequest<ProjectTaskEntity> = ProjectTaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", parentTaskID as CVarArg)
        var tasks: [ProjectTask] = []
        
        do {
            let matchingTasks = try container.viewContext.fetch(fetchRequest)
            if let parentTaskEntity = matchingTasks.first {
                // Create the new subtask entity
                let subtaskEntity = ProjectTaskEntity(context: container.viewContext)
                subtaskEntity.id = subtask.id
                subtaskEntity.name = subtask.name
                subtaskEntity.descriptions = subtask.description
                subtaskEntity.index = subtask.index
                subtaskEntity.color = subtask.color
                subtaskEntity.process = subtask.process
                subtaskEntity.isCompleted = subtask.isCompleted
                subtaskEntity.parentTaskID = subtask.parentTaskId // Link to the parent
                
                if let iconImage = subtask.iconImage {
                    subtaskEntity.iconImage = iconImage.pngData()
                }
                
                if let iconString = subtask.iconString {
                    subtaskEntity.iconString = iconString
                }
                
                if let date = subtask.dueDate {
                    subtaskEntity.dueDate = date
                }
                
                parentTaskEntity.addToSubTasks(subtaskEntity)
                
                // Save changes to Core Data
                tasks = saveData()
            } else {
                print("Parent task with ID not found")
            }
        } catch {
            print("Error fetching parent task: \(error)")
        }
        
        return tasks
    }
    
    func deleteTask(withID taskID: UUID) -> [ProjectTask] {
        let fetchRequest: NSFetchRequest<ProjectTaskEntity> = ProjectTaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", taskID as CVarArg)
        
        do {
            let matchingTasks = try container.viewContext.fetch(fetchRequest)
            for task in matchingTasks {
                // Recursively delete subtasks
                if let subtasks = task.subTasks as? Set<ProjectTaskEntity> {
                    for subtask in subtasks {
                        _ = deleteTask(withID: subtask.id!)
                    }
                }
                let parentTaskID = task.parentTaskID
                container.viewContext.delete(task) // Delete the main task
                if parentTaskID != nil {
                    // Reindex the subtasks of the parent task (if any)
                    return reindexSubtasks(for: parentTaskID)
                }
            }
        } catch {
            print("Error deleting task with ID \(taskID): \(error)")
        }
        
        return saveData() // Return the current model to avoid crashes
    }
    
    func updateTask(taskToEdit: ProjectTask) -> [ProjectTask] {
        let fetchRequest: NSFetchRequest<ProjectTaskEntity> = ProjectTaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", taskToEdit.id as CVarArg)
        var tasks: [ProjectTask] = []
        
        do {
            let matchingTasks = try container.viewContext.fetch(fetchRequest)
            if let lastTask = matchingTasks.first {
                lastTask.name = taskToEdit.name
                lastTask.descriptions = taskToEdit.description
                lastTask.color = taskToEdit.color
                
                if let iconImage = taskToEdit.iconImage {
                    lastTask.iconImage = iconImage.pngData()
                } else {
                    lastTask.iconImage = nil
                }
                
                if let coverImage = taskToEdit.coverImage {
                    lastTask.coverImage = coverImage.pngData()
                } else {
                    lastTask.coverImage = nil
                }
                
                if let iconString = taskToEdit.iconString {
                    lastTask.iconString = iconString
                } else {
                    lastTask.iconString = nil
                }
                
                if let date = taskToEdit.dueDate {
                    lastTask.dueDate = date
                } else {
                    lastTask.dueDate = nil
                }
                
                if let parentTaskId = taskToEdit.parentTaskId {
                    lastTask.parentTaskID = parentTaskId
                } else {
                    lastTask.parentTaskID = nil
                }
                // reload core model data
                tasks = saveData()
            }
        } catch {
            print("Error updating task: \(error)")
        }
        
        return tasks
    }
    
    func updateProcessForProject(_ project: ProjectTask) -> [ProjectTask] {
        // Fetch all tasks in the hierarchy of the project
        func traverseAndUpdate(_ task: ProjectTask) -> Double {
            if task.isCompleted {
                task.process = 1.0
            } else if !task.subtasks.isEmpty {
                // Recursively calculate process for subtasks
                let totalSubtaskProcess = task.subtasks.reduce(0.0) { sum, subtask in
                    sum + traverseAndUpdate(subtask)
                }
                task.process = totalSubtaskProcess / Double(task.subtasks.count)
            } else {
                task.process = 0.0
            }

            // Update the Core Data entity for this task
            let fetchRequest: NSFetchRequest<ProjectTaskEntity> = ProjectTaskEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)

            do {
                if let entity = try container.viewContext.fetch(fetchRequest).first {
                    entity.process = task.process
                } else {
                    print("Task with ID \(task.id) not found for Core Data update.")
                }
            } catch {
                print("Error updating process for task ID \(task.id): \(error)")
            }

            return task.process
        }

        // Start traversal and update from the project root
        _ = traverseAndUpdate(project)
        
        return saveData()
    }
    
    func updateIndex(taskID: UUID, index: Int32) -> [ProjectTask] {
        let fetchRequest: NSFetchRequest<ProjectTaskEntity> = ProjectTaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", taskID as CVarArg)
        var tasks: [ProjectTask] = []
        
        do {
            let matchingTasks = try container.viewContext.fetch(fetchRequest)
            if let task = matchingTasks.first {
                task.index = index
                tasks = saveData()
            } else {
                print("Task with ID \(taskID) not found.")
            }
        } catch {
            print("Error updating task attribute: \(error)")
        }
        
        return tasks
    }
    
    func updateIsCompleted(taskID: UUID, isCompleted: Bool, doneDate: Date?) -> [ProjectTask] {
        let fetchRequest: NSFetchRequest<ProjectTaskEntity> = ProjectTaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", taskID as CVarArg)
        var tasks: [ProjectTask] = []
        
        do {
            let matchingTasks = try container.viewContext.fetch(fetchRequest)
            if let task = matchingTasks.first {
                task.isCompleted = isCompleted
                task.doneDate = doneDate
                tasks = saveData()
            } else {
                print("Task with ID \(taskID) not found.")
            }
        } catch {
            print("Error updating task attribute: \(error)")
        }
        
        return tasks
    }
    
    func reindexSubtasks(for parentTaskID: UUID?) -> [ProjectTask] {
        let fetchRequest: NSFetchRequest<ProjectTaskEntity> = ProjectTaskEntity.fetchRequest()
        
        if let parentTaskID = parentTaskID {
            // Fetch subtasks of the given parent task
            fetchRequest.predicate = NSPredicate(format: "parentTaskID == %@", parentTaskID as CVarArg)
        } else {
            // Fetch root-level tasks if no parent task is provided
            fetchRequest.predicate = NSPredicate(format: "parentTaskID == nil")
        }
        
        do {
            let subtasks = try container.viewContext.fetch(fetchRequest)
            
            // Sort subtasks by their current index (optional, ensures correct reordering)
            let sortedSubtasks = subtasks.sorted { $0.index < $1.index }
            
            // Update the index for each subtask
            for (newIndex, subtask) in sortedSubtasks.enumerated() {
                subtask.index = Int32(newIndex)
            }
            
            // Save the updated indexes to Core Data
            return saveData() // Return updated model
        } catch {
            print("Error fetching or reindexing subtasks: \(error)")
            return mapToModel() // Return the current model to avoid crashes
        }
    }
    
    // Save context and return mapped model
    func saveData() -> [ProjectTask] {
        var savedEntities: [ProjectTask] = []
        do {
            try container.viewContext.save()
            savedEntities = mapToModel()
        } catch let error {
            print("Error saving Core Data: \(error)")
        }
        
        return savedEntities
    }
    
    // Map Core Data entities to model
    func mapToModel() -> [ProjectTask] {
        mappedEntities = []
        let savedTasks = fetchTasks()
        var projectTasks: [ProjectTask] = []
        
        for entity in savedTasks where entity.parentTaskID == nil { // Only map root-level tasks
            guard let task = mapTaskEntityToModel(entity) else { continue }
            projectTasks.append(task)
        }
        return projectTasks
    }
    
    private func mapTaskEntityToModel(_ entity: ProjectTaskEntity) -> ProjectTask? {
        guard let id = entity.id,
              let name = entity.name,
              !mappedEntities.contains(id),
              let description = entity.descriptions else { return nil }
        
        mappedEntities.insert(id)
        
        // Force the fault to load for subTasks
        let subTasksSet = entity.subTasks as? Set<ProjectTaskEntity> ?? []
        
        // Map subtasks recursively
        let subtasks: [ProjectTask] = subTasksSet.compactMap {
            mapTaskEntityToModel($0)
        }
        
        let projectTask = ProjectTask(
            id: id,
            name: name,
            description: description,
            subtasks: subtasks,
            color: entity.color ?? "",
            isCompleted: entity.isCompleted
        )
        
        // Assign other properties
        projectTask.process = entity.process
        projectTask.index = entity.index
        if let coverImageData = entity.coverImage {
            projectTask.coverImage = UIImage(data: coverImageData)
        }
        if let iconImageData = entity.iconImage {
            projectTask.iconImage = UIImage(data: iconImageData)
        }
        if let iconString = entity.iconString {
            projectTask.iconString = iconString
        }
        if let parentTaskId = entity.parentTaskID {
            projectTask.parentTaskId = parentTaskId
        }
        if let selectedThemeId = entity.themeID {
            let theme = self.themeManager.themes.first(where: { $0.id == selectedThemeId})
            if let theme = theme {
                projectTask.theme = theme
            }
        }
        if let date = entity.dueDate {
            projectTask.dueDate = date
        }
        if let tag = entity.tag {
            projectTask.tag = tag
        }
        
        return projectTask
    }
}
