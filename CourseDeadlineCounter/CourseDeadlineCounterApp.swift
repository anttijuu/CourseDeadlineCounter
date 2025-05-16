//
//  CourseDeadlineCounterApp.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 15.10.2024.
//

import SwiftUI

@main
struct CourseDeadlineCounterApp: App {
	
	@State private var deadlines = Deadlines()
	
	var body: some Scene {
		WindowGroup {
			MainView()
				.environment(deadlines)
		}
		WindowGroup("Timeline View", id: "timeline-view") {
			TimelineView()
				.environment(deadlines)
		}
	}
}
