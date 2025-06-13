//
//  DaysType.swift
//  CLC'd
//
//  Created by Peidong Chen on 6/6/25.
//

enum Days: Int, CaseIterable {
    case sunday = 0, monday, tuesday, wednesday, thursday, friday, saturday
    
    var name: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
    
    var abbrev: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }
}

extension Set where Element == Days {
    var description: String {
        let weekdays: Set<Days> = [.monday, .tuesday, .wednesday, .thursday, .friday]
        let weekends: Set<Days> = [.saturday, .sunday]
        let everyday: Set<Days> = Set(Days.allCases)
        
        if self.isEmpty {
            return "Never"
        } else if self == weekdays {
            return "Weekdays"
        } else if self == weekends {
            return "Weekends"
        } else if self == everyday {
            return "Every day"
        } else {
            return self.sorted(by: { $0.rawValue < $1.rawValue })
                    .map { $0.abbrev }
                    .joined(separator: ", ")
        }
    }
}

