//
//  Deadlines.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 15.10.2024.
//

import Foundation
import AppKit
import OSLog

// TODO: Fix: when changing future deadline to past, does not cancel forthcoming alerts.

@Observable
class Deadlines {
	
	static let appDocumentDirectory = "CourseDeadlines"
	
	private var counter = 0

	var courses: [Course] = []

	private var log = Logger(subsystem: "com.anttijuustila.coursedeadlines", category: "Deadlines")
	
	func course(id: UUID?) -> Course? {
		guard id != nil else { return nil }
		return courses.first(where: { $0.id == id })
	}
	
	func readCourseList() throws {
		let storagePath = URL.documentsDirectory.appending(component: Deadlines.appDocumentDirectory, directoryHint: .isDirectory)
		do {
			var courseNames = [String]()
			log.debug("Starting to read course list")
			let gotAccess = storagePath.startAccessingSecurityScopedResource()
			if !gotAccess {
				log.info("No access to file system")
				return
			}
			defer {
				storagePath.stopAccessingSecurityScopedResource()
			}
			log.debug("Creating file directory if needed")
			try FileManager.default.createDirectory(at: storagePath, withIntermediateDirectories: true)
			let thePath = storagePath.path()
			if let enumerator = FileManager.default.enumerator(atPath: thePath) {
				while let file = enumerator.nextObject() as? String {
					if file.hasSuffix(".json") {
						let nameElements = file.split(separator: ".")
						courseNames.append(String(nameElements[0]).removingPercentEncoding!)
					}
				}
			}
			courses.removeAll()
			if !courseNames.isEmpty {
				log.debug("Found \(courseNames.count) json files in directory")
				for courseName in courseNames {
					try loadDeadlines(for: courseName)
				}
				courses.sort()
				log.debug("Read \(self.courses.count) course data from json files")
			} else {
				log.info("No JSON files in the app directory")
			}
		}
	}
		
	func newCourse() -> Course {
		counter += 1
		return Course(
			name: NSLocalizedString("<New Course \(counter)>", comment: "String shown when a new course is created"),
			startDate: Date.now
		)
	}
	
	func hasCourse(withName: String) -> Bool {
		return courses.contains(where: { $0.name == withName } )
	}
	
	func notFinished() -> [Course] {
		courses.filter( { $0.notEnded } )
	}
	
	func delete(_ course: Course) throws {
		do {
			log.debug("Starting to delete current course")
			try deleteFile(for: course.name)
			courses.removeAll(where: { $0.name == course.name })
			Notifications.shared.removeNotifications(for: course)
		} catch {
			log.error("Error in deleting course \(course.name) because \(error.localizedDescription)")
			throw DeadlineErrors.fileDeleteError(error.localizedDescription)
		}
	}
		
	private func deleteFile(for course: String) throws {
		let storagePath = URL.documentsDirectory.appending(component: Deadlines.appDocumentDirectory, directoryHint: .isDirectory)
		let coursePath = storagePath.appending(path: course + ".json")
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
		let storagePath = URL.documentsDirectory.appending(component: Deadlines.appDocumentDirectory, directoryHint: .isDirectory)
		let course = try Course.restore(from: storagePath, for: courseName)
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
		try course.store()
	}

}
