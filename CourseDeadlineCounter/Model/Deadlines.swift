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
	var deadlines = CourseDeadlines(course: "???")
	
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
				if let file = enumerator.nextObject() as? String {
					if file.hasSuffix(".json") {
						let nameElements = file.split(separator: ".")
						courses.append(String(nameElements[0]))
					}
				}
			}
			if !courses.isEmpty {
				deadlines = try loadDeadlines(for: courses[0])!
			}
		} catch {
			print("Error in restoring deadlines for course \(courses[0]) because \(error.localizedDescription)")
		}
	}
	
	func loadDeadlines(for course: String) throws -> CourseDeadlines? {
		guard courses.contains(course) else {
			return nil
		}
		return try CourseDeadlines.restore(from: Self.storagePath, for: course)
	}
	
}
