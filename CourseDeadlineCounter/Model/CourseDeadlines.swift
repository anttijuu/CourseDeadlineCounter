//
//  Deadlines.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 15.10.2024.
//

import Foundation

struct CourseDeadlines: Codable {
	let course: String
	let startDate: Date // TODO: use start date to count percentage of course done & time left
	var deadlines: [Deadline] = []
	
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
	
	mutating func modify(_ deadline: Deadline) throws {
		if let i = deadlines.firstIndex(of: deadline) {
			 deadlines[i] = deadline
		}
		try store(to: Deadlines.storagePath)
	}
	
	func store(to path: URL) throws {
		let fileManager = FileManager.default
		let data = try JSONEncoder().encode(self)
		let string = String(data: data, encoding: .utf8)
		print(string!)
		let filePath = path.appending(path: course + ".json")
		if fileManager.fileExists(atPath: filePath.path()) {
			try fileManager.removeItem(at: filePath)
		}
		if !fileManager.createFile(atPath: filePath.path(), contents: data) {
			print("createFile retuned false :(")
			//throw DeadlineErrors.fileSaveError
		}
	}
	
	static func restore(from path: URL, for course: String) throws -> CourseDeadlines {
		let fileManager = FileManager.default
		let filePath = path.appending(path: course + ".json")
		guard fileManager.fileExists(atPath: filePath.path()) else {
			throw DeadlineErrors.fileDoesNotExist
		}
		let data = try Data(contentsOf: filePath)
		var course = try JSONDecoder().decode(CourseDeadlines.self, from: data)
		course.deadlines.sort()
		return course
	}
}
