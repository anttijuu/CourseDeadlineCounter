//
//  Deadlines.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 15.10.2024.
//

import Foundation

@Observable
class Course: Codable {
	var uuid: UUID
	var name: String
	var startDate: Date
	var deadlines: [Deadline]
	
	enum CodingKeys: String, CodingKey {
		case _uuid = "uuid"
		case _name = "name"
		case _startDate = "startDate"
		case _deadlines = "deadlines"
	}
	
	init(name: String, startDate: Date) {
		uuid = UUID()
		self.name = name
		self.startDate = startDate
		deadlines = []
	}
	
	var hasStarted: Bool {
		return Date.now >= startDate
	}
	
	var daysToStart: Int {
		abs(Int(Date.now.distance(to: startDate) / 86400))
	}
	
	var courseAgeInDays: Int {
		Int(Date.now.timeIntervalSince(startDate) / 86400)
	}
	
	func percentageLeft() -> Int {
		return min(max(100 - percentageReached(), 0), 100)
	}
	
	func percentageReached() -> Int {
		let wholeSpan = abs(deadlines.last?.date.distance(to: startDate) ?? 0.0)
		let currentSpan = abs(Date.now.distance(to: startDate))
		if wholeSpan > 0 {
			return Int((currentSpan / wholeSpan) * 100)
		}
		return 0
	}
	
	func add(_ deadline: Deadline) throws {
		deadlines.append(deadline)
		deadlines.sort()
		try store(to: Deadlines.storagePath)
	}
	
	func remove(at index: Int) throws {
		deadlines.remove(at: index)
		try store(to: Deadlines.storagePath)
	}
	
	func remove(_ deadline: Deadline) throws {
		if let index = deadlines.firstIndex(where: { $0.id == deadline.id }) {
			try remove(at: index)
		}
	}
		
	func store(to path: URL) throws {
		deadlines.sort()
		let fileManager = FileManager.default
		let encoder = JSONEncoder()
		encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
		let data = try encoder.encode(self)
		let string = String(data: data, encoding: .utf8)
		print(string!)
		let filePath = path.appending(path: name + ".json").path(percentEncoded: false)
		print("Storing file \(filePath)")
		if !fileManager.createFile(atPath: filePath, contents: data) {
			print("createFile returned false :(")
			throw DeadlineErrors.fileSaveError
		}
	}
	
	static func restore(from path: URL, for courseNamed: String) throws -> Course {
		let fileManager = FileManager.default
		let filePath = path.appending(path: courseNamed + ".json").path(percentEncoded: false)
		guard fileManager.fileExists(atPath: filePath) else {
			throw DeadlineErrors.fileDoesNotExist
		}
		let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
		let course = try JSONDecoder().decode(Course.self, from: data)
		course.deadlines.sort()
		course.uuid = course.uuid
		course.name = course.name
		course.startDate = course.startDate
		course.deadlines = course.deadlines
		return course
	}
}

extension Course: Identifiable, Equatable, Comparable, Hashable {
	
	var id: UUID {
		uuid
	}
	
	static func == (lhs: Course, rhs: Course) -> Bool {
		lhs.name == rhs.name
	}
	
	static func < (lhs: Course, rhs: Course) -> Bool {
		lhs.name < rhs.name
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(name)
	}
}
