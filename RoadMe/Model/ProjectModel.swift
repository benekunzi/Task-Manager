//
//  Project.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 22.12.24.
//

import SwiftUI


enum TaskTab {
    case tasks, notes
}

class ProjectModel: ObservableObject {
    let id: UUID = UUID()
    @Published var projectsTasks: [ProjectTask] = []
    @Published var completedTasksLookup: [Date: [UUID]] = [:]
    @Published var selectedTask: ProjectTask = ProjectTask(
        id: UUID(),
        name: "Default-Task-ID",
        description: "Default-Task-Description",
        subtasks: [],
        color: "",
        isCompleted: false)
    @Published var selectedProject: ProjectTask?
    @Published var draggedTask: ProjectTask?
    @Published var showProjectEditor: Bool = false
    @Published var showTaskEditor: Bool = false
    @Published var filteredTasks: [ProjectTask] = []
    @Published var updateUI: Bool = false
    @Published var showEditTaskEditor: Bool = false
    @Published var taskToEdit: ProjectTask?
    @Published var deviceType: DeviceType = .iPhone
    @Published var selectedTheme: Theme = themeBasis
    @Published var redrawID: UUID = UUID()
    @Published var showDetailView: Bool = false
    @Published var offsetTaskCards: CGFloat = 0
    @Published var offsetTopView: CGFloat = 0
    @Published var offsetContentBottom: CGFloat = 0
    @Published var taskTab: TaskTab = .tasks
    @Published var taskCounter: Int = 0
    @Published var showTopMenu: Bool = false
    
    private let coreDataModel: CoreDataModel = CoreDataModel()
    
    init() {
        self.deviceType = UIDevice.current.userInterfaceIdiom == .phone ? .iPhone : UIDevice.current.userInterfaceIdiom == .pad ? .iPad : .Mac
        print(deviceType)
        self.selectedTask = self.default_Project
        self.offsetTaskCards = UIScreen.main.bounds.height
        updateFilteredTasks()
        self.completedTasksLookup = coreDataModel.loadCompletedTasksLookup()
        self.countTasks(date: .now)
    }
    
    let default_Project = ProjectTask(
        id: UUID(),
        name: "Default-Task-ID",
        description: "Default-Task-Description",
        subtasks: [],
        color: "",
        isCompleted: false)
    
    func changeSelectedTask(task: ProjectTask) {
        self.selectedTask = task
        updateFilteredTasks()
    }
    
    func updateSelectedProject(project: ProjectTask) {
        self.selectedProject = project
        updateFilteredTasks()
    }

    func updateFilteredTasks() {
        if let updatedTasks = findTask(in: self.projectsTasks, withID: selectedTask.id) {
            self.filteredTasks = updatedTasks.subtasks
            self.filteredTasks.sort { $0.index < $1.index }
            self.filteredTasks.sort { $0.isCompleted == false && $1.isCompleted == true }
        }
        self.toggleUIUpdate()
    }
    
    func toggleUIUpdate() {
        self.updateUI.toggle()
        self.redrawID = UUID()
    }

    func countTasks(date: Date) {
        print("updating task counter")
        let date = Date()
        let normalizedDate = Calendar.current.startOfDay(for: date)
        self.taskCounter = completedTasksLookup[normalizedDate]?.count ?? 0
    }
    
    func updateCompleteStatus(task: ProjectTask) {
        let previousDoneDate = task.doneDate
        task.isCompleted.toggle()

        if task.isCompleted {
            task.doneDate = Date()
        } else {
            task.doneDate = nil
        }

        if let doneDate = task.doneDate {
            addToLookup(taskID: task.id, for: doneDate)
        } else if let previousDoneDate = previousDoneDate {
            removeFromLookup(taskID: task.id, for: previousDoneDate)
        }

        updateFilteredTasks() // Update filtered tasks
    }

    private func addToLookup(taskID: UUID, for date: Date) {
        var lookup = coreDataModel.loadCompletedTasksLookup()
        let normalizedDate = Calendar.current.startOfDay(for: date)

        if lookup[normalizedDate] != nil {
            lookup[normalizedDate]?.append(taskID)
        } else {
            lookup[normalizedDate] = [taskID]
        }

        // Save updated lookup
        coreDataModel.saveCompletedTasksLookup(lookup)
        self.completedTasksLookup = lookup // Update in-memory lookup
        self.countTasks(date: .now)
    }

    private func removeFromLookup(taskID: UUID, for date: Date) {
        var lookup = coreDataModel.loadCompletedTasksLookup()
        let normalizedDate = Calendar.current.startOfDay(for: date)

        if let taskIDs = lookup[normalizedDate] {
            lookup[normalizedDate] = taskIDs.filter { $0 != taskID }
            if lookup[normalizedDate]?.isEmpty == true {
                lookup.removeValue(forKey: normalizedDate) // Remove the date key if no tasks remain
            }
        }

        // Save updated lookup
        coreDataModel.saveCompletedTasksLookup(lookup)
        self.completedTasksLookup = lookup // Update in-memory lookup
        self.countTasks(date: .now)
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
    @Published var tag: String?
    @Published var parentTaskId: UUID?
    @Published var iconString: String?
    @Published var iconImage: UIImage?
    @Published var coverImage: UIImage?
    @Published var dueDate: Date?
    @Published var doneDate: Date?
    @Published var theme: Theme?
    
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

extension ProjectModel {
    func calculateProcess(for task: ProjectTask) -> Double {
        if task.isCompleted {
            task.process = 1.0
        } else if !task.subtasks.isEmpty {
            // Recursively calculate the total process for subtasks
            let totalSubtaskProcess = task.subtasks.reduce(0.0) { sum, subtask in
                sum + calculateProcess(for: subtask)
            }
            // Calculate the average process
            task.process = totalSubtaskProcess / Double(task.subtasks.count)
        } else {
            // If no subtasks and not completed, process remains 0
            task.process = 0.0
        }

        // Save the updated process to Core Data
//        coreDataModel.updateProcess(taskID: task.id, process: task.process)
        print("Task: \(task.name), Process Updated: \(task.process), Status: \(task.isCompleted)")

        return task.process
    }

    func calculateProcessForSelectedProject() -> ProjectTask? {
        guard let selectedProject = selectedProject else {
            print("No selected project to calculate process.")
            return nil
        }

        // Start process calculation from the root project task
        _ = calculateProcess(for: selectedProject)

        // Notify the UI about the changes
        toggleUIUpdate()
        print("Recalculated process for the selected project.")
        return selectedProject
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
