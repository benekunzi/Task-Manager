//
//  MainContent.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 07.01.25.
//

import SwiftUI
import UniformTypeIdentifiers

struct MainContentView: View {
    @Binding var showMoreOptions: Bool
    @Binding var isWiggling: Bool
    
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var coreDataModel: CoreDataModel
    
    @Binding var columns: [GridItem]
    @Binding var numberOfColumns: Int
    
    @State var size: CGSize = .zero
    @State var taskCardWidth: CGFloat = 0
    
    var body: some View {
        LazyVGrid(columns: self.columns, spacing: 20) {
            ForEach(projectModel.filteredTasks, id: \.id) { task in
                TaskCard(task: task,
                         showMoreOptions: $showMoreOptions,
                         isWiggling: $isWiggling,
                         taskCardWidth: $taskCardWidth,
                         numberOfColumns: $numberOfColumns)
                .padding(.horizontal, numberOfColumns == 1 ? 20 : 0)
                .readWidth {
                    taskCardWidth = $0
                }
                // Conditionally apply `onDrag` and `onDrop`
                .if(showMoreOptions) { view in
                    view
                        .onDrag {
                            projectModel.draggedTask = task
                            return NSItemProvider(object: task.name as NSString)
                        }
                        .onDrop(of: [UTType.text],
                                delegate: DropViewDelegate(
                                    task: task,
                                    subtasks: $projectModel.filteredTasks,
                                    draggedTask: $projectModel.draggedTask)
                        )
                }
            }
        }.padding(.horizontal)
        .onChange(of: projectModel.filteredTasks) {tasks in
            if tasks.count == 0 {
                showMoreOptions = false
                isWiggling = false
            }
            
            for task in tasks {
                let newIndex = tasks.firstIndex(where: { $0.id == task.id }) ?? Int(task.index)
                task.index = Int32(newIndex)
                coreDataModel.updateIndex(taskID: task.id, index: Int32(newIndex))
            }
        }
    }
}

extension View {
  func readWidth(onChange: @escaping (CGFloat) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Spacer()
          .preference(
            key: HeightPreferenceKey.self,
            value: geometryProxy.size.width
          )
      }
    )
    .onPreferenceChange(HeightPreferenceKey.self, perform: onChange)
  }
}

private struct HeightPreferenceKey: PreferenceKey {
  static var defaultValue: CGFloat = .zero
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}
