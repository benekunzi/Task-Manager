//
//  Calendar.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 21.01.25.
//

import SwiftUI

struct CalendarView: View {
    
    @Binding var color: String
    @StateObject var newTask: ProjectTask
    
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var date: Date = Date.now
    @State private var toggleDateCalander: Bool = false
    @State private var toggleTimeCalander: Bool = false
    @State private var days: [Date] = []
    @State private var showMonthPicker: Bool = false
    @State private var selectionDate: [Int] = [0, 0]
    @State private var selectionTime: [Int] = [0, 0]
    
    private let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter
    }
    
    private let fontModel: FontModel = FontModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: "calendar")
                    .font(.system(size: 20))
                    .padding(4)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(color == "" ? Color.clear : Color(themeManager.currentTheme.colors[color]!.primary))
                    )
                    .foregroundStyle(Color.white)
                VStack(alignment: .leading) {
                    Text("Date")
                        .font(.custom(fontModel.font_body_semiBold, size: 16))
                    if (self.toggleDateCalander) {
                        Text(date, style: .date)
                            .font(.custom(fontModel.font_body_medium, size: 14))
                    }
                }
                
                Spacer()
                Toggle("", isOn: self.$toggleDateCalander)
                    .tint(color == "" ? Color.clear : Color(themeManager.currentTheme.colors[color]!.primary))
            }
            
            if self.toggleDateCalander {
                VStack(alignment: .center, spacing: 10) {
                    HStack {
                        Text(dateFormatter.string(from: date))
                        Image(systemName: showMonthPicker ? "chevron.down" : "chevron.right")
                        Spacer()
                    }.onTapGesture {
                        self.showMonthPicker.toggle()
                    }
                    if !showMonthPicker {
                        HStack {
                            ForEach(self.daysOfWeek.indices, id: \.self) { index in
                                Text(daysOfWeek[index])
                                    .font(.custom(fontModel.font_body_semiBold, size: 16))
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        LazyVGrid(columns: self.columns) {
                            ForEach(days, id:\.self) { day in
                                if day.monthInt != self.date.monthInt {
                                    Text("")
                                } else {
                                    Text("\(day.formatted(.dateTime.day()))")
                                        .font(.custom(fontModel.font_body_medium, size: 16))
                                        .foregroundStyle(self.date == day.startOfDay ? Color.white : Color("Gray"))
                                        .frame(maxWidth: .infinity, minHeight: 40)
                                        .background(
                                            Circle()
                                                .fill(color == "" ? Color.clear : self.date == day.startOfDay ? Color(themeManager.currentTheme.colors[color]!.primary) : Color(themeManager.currentTheme.colors[color]!.secondary))
                                        )
                                        .onTapGesture {
                                            self.date = day
                                            newTask.dueDate = date
                                        }
                                }
                                
                            }
                        }
                    } else {
                        let monthsAndYears: [[String]] = [Date.fullMonthNames, Date.years]
                        PickerView(data: monthsAndYears, selections: $selectionDate)
                            .onAppear {
                                // Set initial selection based on the current date
                                selectionDate = [date.monthIndex, date.yearIndex]
                            }
                            .onChange(of: selectionDate) { newSelection in
                                // Update the date based on picker selection
                                date = date.updatedDate(monthIndex: newSelection[0], yearIndex: newSelection[1])
                                newTask.dueDate = date
                            }
                    }
                }.onAppear {
                    self.days = date.calendarDisplayDays
                }
                .onChange(of: date) { newDate in
                    self.days = newDate.calendarDisplayDays
                }
            }
            
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 20))
                    .padding(4)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(color == "" ? Color.clear : Color(themeManager.currentTheme.colors[color]!.primary))
                    )
                    .foregroundStyle(Color.white)
                VStack(alignment: .leading) {
                    Text("Time")
                        .font(.custom(fontModel.font_body_semiBold, size: 16))
                    if (self.toggleTimeCalander) {
                        Text(date, style: .time)
                            .font(.custom(fontModel.font_body_medium, size: 14))
                    }
                }
                
                Spacer()
                Toggle("", isOn: self.$toggleTimeCalander)
                    .tint(color == "" ? Color.clear : Color(themeManager.currentTheme.colors[color]!.primary))
            }
            .onChange(of: self.toggleTimeCalander) { _ in
                if !self.toggleDateCalander {
                    self.toggleDateCalander = true
                }
            }
            
            if toggleTimeCalander {
                let clockData: [[String]] = [Date.hours, Date.minutes]
                PickerView(data: clockData, selections: $selectionTime)
                    .onAppear {
                        // Set initial selection based on the current date
                        selectionTime = [date.hourIndex, date.minuteIndex]
                    }
                    .onChange(of: selectionTime) { newSelection in
                        // Update the date based on picker selection
                        date = date.updatedTime(
                            hourIndex: newSelection[0],
                            minuteIndex: newSelection[1]
                        )
                        newTask.dueDate = date
                    }
            }
        }
        .onChange(of: self.toggleDateCalander) {newValue in
            if !newValue {
                self.toggleTimeCalander = false
                newTask.dueDate = nil
            }
        }
        .onAppear {
            if let taskDate = newTask.dueDate {
                self.date = taskDate
                self.toggleDateCalander = true
                self.toggleTimeCalander = true
            }
        }
        .animation(.spring(), value: self.toggleDateCalander)
        .animation(.spring(), value: self.toggleTimeCalander)
    }
}
