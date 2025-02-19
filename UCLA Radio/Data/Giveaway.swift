//
//  Giveaway.swift
//  UCLA Radio
//
//  Created by Christopher Laganiere on 10/1/16.
//  Copyright © 2016 UCLA Student Media. All rights reserved.
//

import Foundation

class Giveaway {
    let summary: String
    let date: String
    
    init(summary: String, date: String) {
        self.summary = summary
        self.date = date
    }
    
    static func formattedDateFromRawString(_ rawString: String) -> String? {
        guard let day = Int(rawString) else {
            return nil
        }
        
        if 11...13 ~= day {
            return "\(day)th"
        } else if day % 10 == 1 {
            return "\(day)st"
        } else if day % 10 == 2 {
            return "\(day)nd"
        } else if day % 10 == 3 {
            return "\(day)rd"
        }
        return "\(day)th"
    }
    
    static func giveawaysFromJSON(_ rawGiveaways: NSArray) -> [String: [Giveaway]] {
        var giveaways = [String: [Giveaway]]()
        
        // regex patterns
        // date format: 2016-10-05T07:00:00.000Z
        let searchPattern = "\\d{4}-\\d+-(\\d+)T\\d+:\\d+:\\d+.\\d+Z"
        let replacementPattern = "$1"
        do {
            let regex = try NSRegularExpression(pattern: searchPattern, options: [])
            
            for rawGiveaway: Any in rawGiveaways {
                if let monthDict = rawGiveaway as? NSDictionary,
                    let currentMonth = monthDict["month"] as? String,
                    let monthGiveaways = monthDict["arr"] as? NSArray {
                    
                    // giveaways for given month
                    var month = [Giveaway]()
                    for monthGiveaway: Any in monthGiveaways {
                        if let monthGiveaway = monthGiveaway as? NSDictionary,
                            let summary = monthGiveaway["summary"] as? String,
                            let rawDate = monthGiveaway["start"] as? String {
                            
                            let day = NSMutableString(string: rawDate)
                            regex.replaceMatches(in: day, options: [], range: NSRange(location: 0, length: rawDate.count), withTemplate: replacementPattern)
                            let date = formattedDateFromRawString(day.substring(from: 0)) ?? ""
                            month.append(Giveaway(summary: summary, date: date))
                        }
                    }
                    
                    giveaways[currentMonth] = month
                }
            }
        } catch let error as NSError {
            print("Giveaway regex error: \(error.localizedDescription)")
        }
        
        return giveaways
    }

    // sorts month strings by proper order: "January" < "February"
    static func sortedMonths(months: [String]) -> [String] {
        func monthValue(_ month: String) -> Int {
            switch(month) {
            case "January":
                return 0
            case "February":
                return 1
            case "March":
                return 2
            case "April":
                return 3
            case "May":
                return 4
            case "June":
                return 5
            case "July":
                return 6
            case "August":
                return 7
            case "September":
                return 8
            case "October":
                return 9
            case "November":
                return 10
            case "December":
                return 11
            default:
                return -1
            }
        }
        return months.sorted() { (s1, s2) -> Bool in
            monthValue(s1) < monthValue(s2)
        }
    }
    
}
