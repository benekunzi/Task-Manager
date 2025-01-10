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
    
    let container: NSPersistentContainer
    private var mappedEntities: Set<UUID> = []

    init() {
        self.container = NSPersistentContainer(name: "ProjectContainer")

        self.container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading Core Data: \(error)")
            }
        }
    }
    
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
    
    func addRootTask(task: ProjectTask) -> [ProjectTask] {
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
        
        return mapToModel() // Return the current model to avoid crashes
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
                tasks = saveData()
            }
        } catch {
            print("Error updating task: \(error)")
        }
        
        return tasks
    }
    
    func updateIndex(taskID: UUID, index: Int32) {
        let fetchRequest: NSFetchRequest<ProjectTaskEntity> = ProjectTaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", taskID as CVarArg)
        
        do {
            let matchingTasks = try container.viewContext.fetch(fetchRequest)
            if let task = matchingTasks.first {
                task.index = index
                try container.viewContext.save()
            } else {
                print("Task with ID \(taskID) not found.")
            }
        } catch {
            print("Error updating task attribute: \(error)")
        }
    }
    
    func updateIsCompleted(taskID: UUID, isCompleted: Bool) {
        let fetchRequest: NSFetchRequest<ProjectTaskEntity> = ProjectTaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", taskID as CVarArg)
        
        do {
            let matchingTasks = try container.viewContext.fetch(fetchRequest)
            if let task = matchingTasks.first {
                task.isCompleted = isCompleted
                try container.viewContext.save()
            } else {
                print("Task with ID \(taskID) not found.")
            }
        } catch {
            print("Error updating task attribute: \(error)")
        }
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
        
        return projectTask
    }
}
