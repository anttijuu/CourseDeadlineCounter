//
//  Deadlines.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 15.10.2024.
//

import Foundation
import AppKit
import OSLog

// TODO: Observe document folder for new files, reload list if changes in files.
// TODO: New screenshots
// TODO: Consider GUI choices, should change to hierarchical lists like GitLogVisualized with toolbar buttons?

@Observable
class Deadlines {
	
	static private(set) var storagePath: URL = URL.documentsDirectory
	private static var counter = 0

	var courses: [Course] = []

	private var log = Logger(subsystem: "com.anttijuustila.coursedeadlines", category: "Deadlines")
	
	func course(id: UUID?) -> Course? {
		guard id != nil else { return nil }
		return courses.first(where: { $0.id == id })
	}
	
	func readCourseList() throws {
		Self.storagePath = URL.documentsDirectory.appending(component: "CourseDeadlines", directoryHint: .isDirectory)
		do {
			var courseNames = [String]()
			log.debug("Starting to read course list")
			let gotAccess = Self.storagePath.startAccessingSecurityScopedResource()
			if !gotAccess {
				log.info("No access to file system")
				return
			}
			defer {
				Self.storagePath.stopAccessingSecurityScopedResource()
			}
			log.debug("Creating file directory if needed")
			try FileManager.default.createDirectory(at: Self.storagePath, withIntermediateDirectories: true)
			let thePath = Self.storagePath.path()
			if let enumerator = FileManager.default.enumerator(atPath: thePath) {
				while let file = enumerator.nextObject() as? String {
					if file.hasSuffix(".json") {
						let nameElements = file.split(separator: ".")
						courseNames.append(String(nameElements[0]).removingPercentEncoding!)
					}
				}
			}
			if !courseNames.isEmpty {
				log.debug("Found \(self.courses.count) json files in directory")
				for courseName in courseNames {
					try loadDeadlines(for: courseName)
				}
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
	
	func delete(_ course: Course) throws {
		do {
			log.debug("Starting to delete current course")
			try deleteFile(for: course.name)
			courses.removeAll(where: { $0.name == course.name })
		} catch {
			log.error("Error in deleting course \(course.name) because \(error.localizedDescription)")
			throw DeadlineErrors.fileDeleteError(error.localizedDescription)
		}
	}
		
	private func deleteFile(for course: String) throws {
		let coursePath = Self.storagePath.appending(path: course + ".json")
		var removeError: Error?
		if FileManager.default.fileExists(atPath: coursePath.path(percentEncoded: false)) {
			log.debug("Moving the \(course) to Trash")
			NSWorkspace.shared.recycle([coursePath]) { trashedFiles, error in
				guard let error = error else { return }
				removeError = error
			}
			if let removeError {
				log.error("Failed to trash the file: \(removeError.localizedDescription)")
				throw DeadlineErrors.fileDeleteError(removeError.localizedDescription)
			}
		}
	}
	
	func loadDeadlines(for courseName: String) throws {
		let course = try Course.restore(from: Self.storagePath, for: courseName)
		courses.append(course)
	}
	
	func saveCourse(for course: Course, oldName: String) throws {
		log.debug("Saving course \(course.name), old name was \(oldName)")
		try saveCourse(for: course)
		log.debug("Then deleting the file with old name \(oldName)")
		try deleteFile(for: oldName)
		courses.removeAll(where: { $0.name == oldName })
	}

	func saveCourse(for course: Course) throws {
		if !courses.contains(where: { $0.name == course.name }) {
			courses.append(course)
			courses.sort()
		}
		try course.store(to: Self.storagePath)
	}

}
