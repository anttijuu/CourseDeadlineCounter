//
//  MainView.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 16.5.2025.
//

import SwiftUI

struct MainView: View {
	@Environment(Deadlines.self) var deadlines
	
	var body: some View {
		TabView {
			Tab("Course List", systemImage: "book.and.wrench") {
				ContentView()
					.environment(deadlines)
			}
			Tab("Timeline", systemImage: "calendar.day.timeline.left") {
				TimelineView()
					.environment(deadlines)
			}
		}
	}
	
}

#Preview {
	MainView()
}
