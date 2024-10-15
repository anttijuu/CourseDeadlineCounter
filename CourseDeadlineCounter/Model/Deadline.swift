//
//  Deadline.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 15.10.2024.
//

import Foundation

struct Deadline: Codable {
	var uuid: UUID = UUID()
	var date: Date
	var symbol: String
	var goal: String
	var becomesHotDaysBefore: Int
	
	var isReached: Bool {
		date <= Date.now
	}
	
	var isHot: Bool {
		guard !isReached else {
			return false
		}
		return Date.now.distance(to: date) <= TimeInterval(becomesHotDaysBefore * 24 * 60 * 60)
	}
	
	func percentageReached(from startDate: Date) -> Int {
		let wholeSpan = date.distance(to: startDate)
		let currentSpan = Date.now.distance(to: startDate)
		return Int((currentSpan / wholeSpan) * 100)
	}
}

extension Deadline: Identifiable, Equatable, Comparable, Hashable {
	var id: UUID {
		uuid
	}
	
	static func == (lhs: Deadline, rhs: Deadline) -> Bool {
		lhs.uuid == rhs.uuid
	}
	
	static func < (lhs: Deadline, rhs: Deadline) -> Bool {
		lhs.date < rhs.date
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(date)
	}
}
