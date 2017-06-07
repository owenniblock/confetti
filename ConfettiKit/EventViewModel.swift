import Foundation

public struct NotificationSpec {
    public let id, title, message: String
    public let daysBefore: Int
}

public class EventViewModel {
    
    static let soonDaysAway = 20
    
    public static func fromEvent(_ event: Event) -> EventViewModel {
        switch event.occasion {
        case .holiday(let holiday):
            return HolidayViewModel(event, holiday: holiday)
        case .birthday(_, _, _):
            return BirthdayViewModel(event)
        case .anniversary(_, _, _):
            return AnniversaryViewModel(event)
        }
    }
    
    public let event: Event
    
    init(_ event: Event) {
        self.event = event
    }
    
    public var isSoon: Bool {
        return daysAway <= EventViewModel.soonDaysAway
    }
    
    public var title: String {
        return "\(event.person.firstName)'s Event"
    }
    
    public var description: String {
        return "\(daysAway) days away"
    }
    
    public var notifications: [NotificationSpec] {
        return [
            NotificationSpec(
                id: "default",
                title: title,
                message: description,
                daysBefore: 0
            )
        ]
    }
    
    public var person: Person {
        return event.person
    }
    
    var calendar: Calendar {
        return Calendar.current
    }
    
    var startOfToday: Date {
        return calendar.startOfDay(for: Date())
    }
    
    var startOfYesterday: Date {
        return calendar.date(byAdding: .day, value: -1, to: startOfToday)!
    }
    
    public var nextOccurrence: Date {
        return calendar.nextDate(after: startOfYesterday,
                                 matching: DateComponents(month: month, day: day),
                                 matchingPolicy: .nextTime,
                                 repeatedTimePolicy: .first,
                                 direction: .forward)!
    }
    
    public var daysAway: Int {
        return calendar.dateComponents([.day], from: startOfToday, to: nextOccurrence).day!
    }
    
    public var weeksAway: Int {
        return Int(round(Float(daysAway) / 7.0))
    }
    
    public var monthsAway: Int {
        return calendar.dateComponents([.month], from: startOfToday, to: nextOccurrence).month!
    }
    
    public var countdown: String {
        switch (daysAway, weeksAway, monthsAway) {
        case (0, _, _):
            return "today"
        case (1, _, _):
            return "tomorrow"
        case (2...EventViewModel.soonDaysAway, _, _):
            return "\(daysAway) days"
        case (_, 1, _):
            return "1 week"
        case (_, 2..<4, _):
            return "\(weeksAway) weeks"
        case (_, _, 1):
            return "1 month"
        case (_, _, let months) where months < 12:
            return "\(months) months"
        default:
            return "a year"
        }
    }
    
    var monthName: String {
        let formatter = DateFormatter()
        return formatter.monthSymbols[month - 1]
    }
    
    var shortMonthName: String {
        let formatter = DateFormatter()
        return formatter.shortMonthSymbols[month - 1]
    }
    
    var date: DateComponents {
        switch event.occasion {
        case let .birthday(month, day, year),
             let .anniversary(month, day, year):
            return DateComponents(year: year, month: month, day: day)
        case let .holiday(holiday):
            return holiday.nextOccurrenceIn(region: .usa)
        }
    }
    
    public var month: Int {
        return date.month!
    }
    
    public var day: Int {
        return date.day!
    }
    
    public var year: Int? {
        return date.year
    }
}

extension Int {
    static let suffixes = [
        /*0*/"th",
             /*1*/"st",
                  /*2*/"nd",
                       /*3*/"rd",
                            /*4*/"th",
                                 /*5*/"th",
                                      /*6*/"th",
                                           /*7*/"th",
                                                /*8*/"th",
                                                     /*9*/"th",
                                                          /*10*/"th"
    ]
    
    public var th: String {
        if self < 10 {
            return Int.suffixes[self]
        } else if self < 20 {
            return "th"
        } else {
            return Int.suffixes[self % 10]
        }
    }
}
