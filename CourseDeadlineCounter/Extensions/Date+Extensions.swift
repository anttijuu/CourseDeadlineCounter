//
//  Date+Extensions.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 13.5.2025.
//
import Foundation

extension Date {
	
	func secondsRoundedToZero() -> Date {
		var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self)
		components.second = 0
		return Calendar.current.date(from: components)!
	}
	
	func toMidnight() -> Date {
		var components = Calendar.current.dateComponents([.year, .month, .day], from: self)
		components.hour = 0
		components.minute = 0
		components.second = 0
		return Calendar.current.date(from: components)!
	}
	
}
