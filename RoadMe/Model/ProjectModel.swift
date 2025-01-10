//
//  Project.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 22.12.24.
//

import SwiftUI

class ProjectModel: ObservableObject {
    let id: UUID = UUID()
    @Published var projectsTasks: [ProjectTask] = []
    @Published var selectedTask: ProjectTask = ProjectTask(
        id: UUID(),
        name: "Default-Task-ID",
        description: "Default-Task-Description",
        subtasks: [],
        color: "BlushPink",
        isCompleted: false)
    @Published var selectedProject: ProjectTask?
    @Published var draggedTask: ProjectTask?
    @Published var showNameEditor: Bool = false
    @Published var showTaskEditor: Bool = false
    @Published var filteredTasks: [ProjectTask] = []
    @Published var updateUI: Bool = false
    @Published var showHiddenTasks: Bool = false
    @Published var showEditTaskEditor: Bool = false
    @Published var taskToEdit: ProjectTask?
    @Published var deviceType: DeviceType = .iPhone
    
    init() {
        self.deviceType = UIDevice.current.userInterfaceIdiom == .phone ? .iPhone : UIDevice.current.userInterfaceIdiom == .pad ? .iPad : .Mac
        print(deviceType)
        updateFilteredTasks()
    }
    
    let default_Project = ProjectTask(
        id: UUID(),
        name: "Default-Task-ID",
        description: "Default-Task-Description",
        subtasks: [],
        color: "BlushPink",
        isCompleted: false)
    
    func changeSelectedTask(task: ProjectTask) {
        self.selectedTask = task
        updateFilteredTasks()
    }
    
    func updateCompleteStatus(task: ProjectTask) {
        task.isCompleted.toggle()
        updateFilteredTasks() // Update filtered tasks
    }

    func updateFilteredTasks() {
        for task in selectedTask.subtasks {
            print("\(task.name): \(task.isCompleted)")
        }
        if let updatedTasks = findTask(in: self.projectsTasks, withID: selectedTask.id) {
            if self.showHiddenTasks {
                self.filteredTasks = updatedTasks.subtasks
            } else {
//                self.filteredTasks = updatedTasks.subtasks.filter { !$0.isCompleted }
                self.filteredTasks = updatedTasks.subtasks
            }
        }
        self.toggleUIUpdate()
    }
    
    func updateHiddenTasks() {
        self.showHiddenTasks.toggle()
        updateFilteredTasks()
    }
    
    func toggleUIUpdate() {
        self.updateUI.toggle()
    }
}

class ProjectTask: ObservableObject, Identifiable, Equatable {
    var id: UUID
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var subtasks: [ProjectTask] = []
    @Published var color: String = ""
    @Published var isCompleted: Bool = false
    @Published var index: Int32 = 0
    @Published var process: Double = 0
    @Published var parentTaskId: UUID?
    @Published var iconString: String?
    @Published var iconImage: UIImage?
    @Published var coverImage: UIImage?
    
    init(id: UUID,
         name: String,
         description: String,
         subtasks: [ProjectTask],
         color: String,
         isCompleted: Bool) {
        self.id = id
        self.name = name
        self.description = description
        self.subtasks = subtasks
        self.color = color
        self.isCompleted = isCompleted
        sortSubtasks()
    }
    
    static func == (lhs: ProjectTask, rhs: ProjectTask) -> Bool {
        return lhs.id == rhs.id
    }
}

extension ProjectTask {
    func sortSubtasks() {
        subtasks.sort { $0.index < $1.index }
    }
}

extension ProjectTask {
    func calculateProcess() -> Double {
        if isCompleted {
            process = 1.0
        } else if !subtasks.isEmpty {
            // Calculate the total process for all subtasks
            let totalSubtaskProcess = subtasks.reduce(0.0) { sum, subtask in
                sum + subtask.calculateProcess()
            }
            // Safely calculate the average process
            process = totalSubtaskProcess / Double(subtasks.count)
        } else {
            // If no subtasks and not completed, process remains 0
            process = 0.0
        }

        print("Task: \(name), Process: \(process)") // Debug print for verification
        return process
    }

    func updateProcessForAllTasks() {
        _ = calculateProcess()
    }
}


func findTask(in tasks: [ProjectTask], withID id: UUID) -> ProjectTask? {
    for task in tasks {
        if task.id == id {
            return task
        }
        if let found = findTask(in: task.subtasks, withID: id) {
            return found
        }
    }
    return nil
}
