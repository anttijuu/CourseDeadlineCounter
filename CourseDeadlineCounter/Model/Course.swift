//
//  Deadlines.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 15.10.2024.
//

import Foundation

struct Course: Codable {
	var uuid: UUID = UUID()
	let name: String
	let startDate: Date
	var deadlines: [Deadline] = []
	
	var courseAgeInDays: Int {
		Int(Date.now.timeIntervalSince(startDate)) / 86400
	}
	
	func percentageReached() -> Int {
		let wholeSpan = abs(deadlines.last?.date.distance(to: startDate) ?? 0.0)
		let currentSpan = abs(Date.now.distance(to: startDate))
		if wholeSpan > 0 {
			return Int((currentSpan / wholeSpan) * 100)
		}
		return 0
	}
	
	mutating func add(_ deadline: Deadline) throws {
		deadlines.append(deadline)
		deadlines.sort()
		try store(to: Deadlines.storagePath)
	}
	
	mutating func remove(at index: Int) throws {
		deadlines.remove(at: index)
		try store(to: Deadlines.storagePath)
	}
	
	mutating func remove(_ deadline: Deadline) throws {
		try remove(at: deadlines.firstIndex(of: deadline)!)
	}
	
	mutating func modifyOrAdd(_ deadline: Deadline) throws {
		if let i = deadlines.firstIndex(of: deadline) {
			 deadlines[i] = deadline
		} else {
			deadlines.append(deadline)
		}
		try store(to: Deadlines.storagePath)
	}
	
	func store(to path: URL) throws {
		let fileManager = FileManager.default
		let encoder = JSONEncoder()
		encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
		let data = try JSONEncoder().encode(self)
		let string = String(data: data, encoding: .utf8)
		print(string!)
		let filePath = path.appending(path: name + ".json")
		if fileManager.fileExists(atPath: filePath.path()) {
			try fileManager.removeItem(at: filePath)
		}
		if !fileManager.createFile(atPath: filePath.path(), contents: data) {
			print("createFile retuned false :(")
			//throw DeadlineErrors.fileSaveError
		}
	}
	
	static func restore(from path: URL, for course: String) throws -> Course {
		let fileManager = FileManager.default
		let filePath = path.appending(path: course + ".json")
		guard fileManager.fileExists(atPath: filePath.path()) else {
			throw DeadlineErrors.fileDoesNotExist
		}
		let data = try Data(contentsOf: filePath)
		var course = try JSONDecoder().decode(Course.self, from: data)
		course.deadlines.sort()
		return course
	}
}

extension Course: Identifiable, Equatable, Comparable, Hashable {
	var id: UUID {
		uuid
	}
	
	static func == (lhs: Course, rhs: Course) -> Bool {
		lhs.uuid == rhs.uuid
	}
	
	static func < (lhs: Course, rhs: Course) -> Bool {
		lhs.name < rhs.name
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(name)
	}
}
