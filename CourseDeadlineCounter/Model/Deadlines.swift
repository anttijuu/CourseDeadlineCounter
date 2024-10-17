//
//  Deadlines.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 15.10.2024.
//

import Foundation

@Observable
class Deadlines {
	
	static private(set) var storagePath: URL = URL.documentsDirectory
	var courses: [String] = []
	var currentCourse = Course(name: "---", startDate: Date.now)
	var selectedCourse: String = ""
	
	init() {
		Self.storagePath = URL.documentsDirectory.appending(component: "CourseDeadlines", directoryHint: .isDirectory)
		do {
			let gotAccess = Self.storagePath.startAccessingSecurityScopedResource()
			if !gotAccess {
				return
			}
			defer {
				Self.storagePath.stopAccessingSecurityScopedResource()
			}
			
			try FileManager.default.createDirectory(at: Self.storagePath, withIntermediateDirectories: true)
			let thePath = Self.storagePath.path()
			if let enumerator = FileManager.default.enumerator(atPath: thePath) {
				while let file = enumerator.nextObject() as? String {
					if file.hasSuffix(".json") {
						let nameElements = file.split(separator: ".")
						courses.append(String(nameElements[0]).removingPercentEncoding!)
					}
				}
			}
			courses.sort()
			if !courses.isEmpty {
				selectedCourse = courses[0]
				try loadDeadlines(for: courses[0])
			}
		} catch {
			print("Error in restoring deadlines for course \(courses[0]) because \(error.localizedDescription)")
		}
	}
	
	func newCourse() {
		currentCourse.name = "---"
		currentCourse.startDate = Date.now
		currentCourse.deadlines.removeAll()
		currentCourse.uuid = UUID()
	}
	
	func deleteCourse() {
		if currentCourse.name != "---" {
			let coursePath = Self.storagePath.appending(path: currentCourse.name + ".json")
			do {
				try FileManager.default.removeItem(at: coursePath)
				courses.removeAll(where: { $0 == currentCourse.name })
				currentCourse.name = "---"
				currentCourse.deadlines = []
				currentCourse.startDate = .now
				currentCourse.uuid = UUID()
			} catch {
				print("Error in deleting course \(currentCourse.name) because \(error.localizedDescription)")
			}
		}
	}
	
	func loadDeadlines(for courseName: String) throws {
		guard courses.contains(courseName) else {
			return
		}
		_ = try currentCourse.restore(from: Self.storagePath, for: courseName)
	}
	
	func saveCourse(for course: Course, with oldName: String? = nil) throws {
		if let oldName {
			if currentCourse.name != oldName {
				courses.removeAll(where: { $0 == oldName })
			}
		}
		if !courses.contains(course.name) {
			courses.append(course.name)
		}
		try course.store(to: Self.storagePath)
		// currentCourse = course
	}
	
}
