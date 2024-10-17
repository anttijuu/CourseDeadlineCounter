//
//  Deadline.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 15.10.2024.
//

import Foundation

@Observable
class Deadline: Codable {
	var uuid: UUID
	var date: Date
	var symbol: String
	var goal: String
	var becomesHotDaysBefore: Int
	
	enum CodingKeys: String, CodingKey {
		case _uuid = "uuid"
		case _date = "date"
		case _symbol = "symbol"
		case _goal = "goal"
		case _becomesHotDaysBefore = "becomesHotDaysBefore"
	}
	
	init(uuid: UUID = UUID(), date: Date, symbol: String, goal: String, becomesHotDaysBefore: Int) {
		self.uuid = uuid
		self.date = date
		self.symbol = symbol
		self.goal = goal
		self.becomesHotDaysBefore = becomesHotDaysBefore
	}
	
	var isReached: Bool {
		date <= Date.now
	}
	
	var isHot: Bool {
		guard !isReached else {
			return false
		}
		return Date.now.distance(to: date) <= TimeInterval(becomesHotDaysBefore * 24 * 60 * 60)
	}
	
	func percentageLeft(from startDate: Date) -> Int {
		return 100 - percentageReached(from: startDate)
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
		lhs.date == rhs.date
	}
	
	static func < (lhs: Deadline, rhs: Deadline) -> Bool {
		lhs.date < rhs.date
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(uuid)
		hasher.combine(date)
	}
}
