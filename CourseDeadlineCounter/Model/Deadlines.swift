//
//  Deadlines.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 15.10.2024.
//

import Foundation
import AppKit

// TODO: Observe document folder for new files, reload list if changes in files.
// TODO: Add logging
// TODO: New screenshots
// TODO: Consider GUI choices, should change to hierarchical lists like GitLogVisualized with toolbar buttons?

@Observable
class Deadlines {
	
	static private(set) var storagePath: URL = URL.documentsDirectory
	private static var counter = 0

	var courses: [String] = []
	var currentCourse = Course(
		name: NSLocalizedString("<New Course \(Deadlines.counter)>", comment: "String shown when a new course is created"),
		startDate: Date.now
	)
	var selectedCourseName: String = ""

	init() {
		selectedCourseName = currentCourse.name
	}
	
	func readCourseList() throws {
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
			if !courses.isEmpty {
				courses.sort()
				selectedCourseName = courses[0]
				try loadDeadlines(for: courses[0])
			}
		}
	}
		
	func newCourse() -> Course {
		Deadlines.counter += 1
		return Course(
			name: NSLocalizedString("<New Course \(Deadlines.counter)>", comment: "String shown when a new course is created"),
			startDate: Date.now
		)
	}
	
	func deleteCurrentCourse() throws {
		do {
			try deleteFile(for: currentCourse.name)
			courses.removeAll(where: { $0 == currentCourse.name })
			if courses.isEmpty {
				currentCourse = Course(
					name: NSLocalizedString("<New Course \(Deadlines.counter)>", comment: "String shown when a new course is created"),
					startDate: Date.now
				)
				selectedCourseName = currentCourse.name
				courses.append(currentCourse.name)
			} else {
				selectedCourseName = courses[0]
				try loadDeadlines(for: selectedCourseName)
			}
		} catch {
			print("Error in deleting course \(currentCourse.name) because \(error.localizedDescription)")
			throw DeadlineErrors.fileDeleteError(error.localizedDescription)
		}
	}
		
	private func deleteFile(for course: String) throws {
		let coursePath = Self.storagePath.appending(path: course + ".json")
		var removeError: Error?
		if FileManager.default.fileExists(atPath: coursePath.path(percentEncoded: false)){
			NSWorkspace.shared.recycle([coursePath]) { trashedFiles, error in
				guard let error = error else { return }
				removeError = error
			}
			if let removeError {
				throw DeadlineErrors.fileDeleteError(removeError.localizedDescription)
			}
		}
	}
	
	func loadDeadlines(for courseName: String) throws {
		guard courses.contains(courseName) else {
			return
		}
		_ = try currentCourse.restore(from: Self.storagePath, for: courseName)
	}
	
	func saveCourse(for course: Course, oldName: String) throws {
		try course.store(to: Self.storagePath)
		try deleteFile(for: oldName)
		currentCourse = course
		selectedCourseName = currentCourse.name
		if courses.contains(oldName) {
			courses.removeAll(where: { $0 == oldName })
		}
		if !courses.contains(course.name) {
			courses.append(course.name)
			courses.sort()
		}
	}

	func saveCourse(for course: Course) throws {
		if !courses.contains(course.name) {
			courses.append(course.name)
			courses.sort()
		}
		try course.store(to: Self.storagePath)
		currentCourse = course
		selectedCourseName = currentCourse.name
	}

}
