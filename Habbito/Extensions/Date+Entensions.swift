//
//  Date+Entensions.swift
//  Habbito
//
//  Created by Khondakar Afridi on 14/1/25.
//

import SwiftUI

extension Date {
    var weekDay: String {
        let calendar = Calendar.current
        let weekDay = calendar.weekdaySymbols[calendar.component(.weekday, from: self) - 1]
        return weekDay
    }
    
    var startOfDay: Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: self)
    }
    
    var isToday: Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(self)
    }
    
    static var startOffsetOfThisMonth: Int {
        Calendar.current.component(.weekday, from: startDateOfThisMonth) - 1
    }
    
    func format(_ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    static var startDateOfThisMonth: Date {
        let calendar = Calendar.current
        guard let date = calendar.date(from: calendar.dateComponents([.year, .month], from: .now)) else {
            fatalError("Could not retrieve start date of this month")
        }
        
        return date
    }
    
    static var datesInThisMonth: [Date] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: .now) else {
            fatalError("Could not retrieve start date of this month")
        }
        
        return range.compactMap{
            calendar.date(byAdding: .day, value: $0 - 1 , to: startDateOfThisMonth)
        }
    }
}
