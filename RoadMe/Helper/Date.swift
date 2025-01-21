//
//  Date.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 21.01.25.
//

import Foundation

extension Date {
    static var capitalizedFirstLettersOfWeekdays: [String] {
        let calendar = Calendar.current
        let weekdays = calendar.shortWeekdaySymbols
        
        return weekdays.map { weekday in
            guard let firstLetter = weekday.first else { return "" }
            return String(firstLetter).capitalized
        }
    }
    
    static var fullMonthNames: [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        
        return (1...12).compactMap { month in
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMM")
            let date = Calendar.current.date(from: DateComponents(year: 2000, month: month, day: 1))
            return date.map { dateFormatter.string(from: $0) }
        }
    }
    
    static var years: [String] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return (2000...currentYear + 10).map { "\($0)" }
    }
    
    static var hours: [String] {
        (0...23).map { String(format: "%02d", $0) }
    }
    
    static var minutes: [String] {
        (0...59).map { String(format: "%02d", $0) }
    }
    
    var hourIndex: Int {
        Calendar.current.component(.hour, from: self)
    }
    
    var minuteIndex: Int {
        Calendar.current.component(.minute, from: self)
    }
    
    var monthIndex: Int {
        Calendar.current.component(.month, from: self) - 1 // Zero-based index
    }
    
    var yearIndex: Int {
        let year = Calendar.current.component(.year, from: self)
        return Date.years.firstIndex(of: "\(year)") ?? 0
        }
    
    var startOfMonth: Date {
        Calendar.current.dateInterval(of: .month, for: self)!.start
    }
    
    var endOfMonth: Date {
        let lastDay = Calendar.current.dateInterval(of: .month, for: self)!.end
        return Calendar.current.date(byAdding: .day, value: -1, to: lastDay)!
    }
    
    var startOfPreviousMonth: Date {
        let lastDayPreviousMonth = Calendar.current.date(byAdding: .month, value: -1, to: self)!
        return lastDayPreviousMonth.startOfMonth
    }
    
    var numberOfDaysInMonth: Int {
        Calendar.current.component(.day, from: endOfMonth)
    }
    
    var sundayBeforeStart: Date {
        let startOFMonthWeekday = Calendar.current.component(.weekday, from: startOfMonth)
        let numberOfPreviousMonth = startOFMonthWeekday - 1
        return Calendar.current.date(byAdding: .day, value: -numberOfPreviousMonth, to: startOfMonth)!
    }
    
    var calendarDisplayDays: [Date] {
        var days: [Date] = []
        for dayOffset in 0..<numberOfDaysInMonth {
            let newDay = Calendar.current.date(byAdding: .day, value: dayOffset, to: startOfMonth)!
            days.append(newDay)
        }
        
        for dayOffset in 0..<startOfPreviousMonth.numberOfDaysInMonth {
            let newDay = Calendar.current.date(byAdding: .day, value: dayOffset, to: startOfPreviousMonth)!
            days.append(newDay)
        }
        
        return days.filter{ $0 >= sundayBeforeStart && $0 <= endOfMonth }.sorted(by: <)
    }
    
    var monthInt: Int {
        Calendar.current.component(.month, from: self)
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    func updatedDate(monthIndex: Int, yearIndex: Int) -> Date {
        let calendar = Calendar.current
        let year = Int(Date.years[yearIndex]) ?? calendar.component(.year, from: self)
        let month = monthIndex + 1 // Convert zero-based index to calendar month
        let day = min(calendar.component(.day, from: self), calendar.range(of: .day, in: .month, for: self)!.count)
        
        return calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? self
    }
    
    func updatedTime(hourIndex: Int, minuteIndex: Int) -> Date {
        let calendar = Calendar.current
        let hour = hourIndex
        let minute = minuteIndex
        let second = calendar.component(.second, from: self)
        
        return calendar.date(
            bySettingHour: hour,
            minute: minute,
            second: second,
            of: self
        ) ?? self
    }
}
