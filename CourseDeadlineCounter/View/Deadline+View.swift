//
//  Deadline+View.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 16.5.2025.
//

import SwiftUI

extension Deadline {
	var color: Color {
		if isReached {
			return .gray
		} else if isHot {
			return .red
		} else if isDealBreaker {
			return .orange
		} else {
			return .accentColor
		}
	}
}
