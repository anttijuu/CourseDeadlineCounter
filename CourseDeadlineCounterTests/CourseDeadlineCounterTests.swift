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

	@Test
	func testDateTimeRoundings() {
		let date = Date.now
		let rounded = date.secondsRoundedToZero()
		#expect(rounded.secondsRoundedToZero() != date)
		print(date)
		print(rounded)
	}

}
