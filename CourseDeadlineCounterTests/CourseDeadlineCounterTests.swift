//
//  CourseDeadlineCounterTests.swift
//  CourseDeadlineCounterTests
//
//  Created by Antti Juustila on 15.10.2024.
//

import Foundation
import Testing
@testable import CourseDeadlineCounter

struct CourseDeadlineCounterTests {

    @Test func exportToJSON() async throws {
		 let course = Deadlines.preview.deadlines
		 let json = try JSONEncoder().encode(course)
		 #expect(json.count > 0)
		 try course.store(to: Deadlines.preview.storagePath)		 
    }

}
