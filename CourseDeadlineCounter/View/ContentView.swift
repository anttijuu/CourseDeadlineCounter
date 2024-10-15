//
//  ContentView.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 15.10.2024.
//

import SwiftUI

struct ContentView: View {
	@Environment(Deadlines.self) var deadlines: Deadlines
	
	@State var showDeadlineEditView: Bool = false
	@State var showCourseEditView: Bool = false
	
	@State var selectedDeadline: Deadline? = nil
	@State var selectedCourse: Course? = nil
	
	@State var isError: Bool = false
	@State var errorMessage: String = ""
	
	var body: some View {
		VStack {
			HStack {
				Button("New Course") {
					selectedCourse = Course(name: "New Course", startDate: .now)
					showCourseEditView.toggle();
				}
				Spacer()
				Group {
					Image(systemName: "flag.pattern.checkered.2.crossed")
					Text("Deadlines for \(deadlines.currentCourse.name)")
					Image(systemName: "flag.pattern.checkered.2.crossed")
				}
				.font(.title)
				Spacer()
				VStack {
					Button("Edit Course") {
						selectedCourse = deadlines.currentCourse
						showCourseEditView.toggle();
					}
					Button("New Deadline") {
						let newDeadline = Deadline(date: Date.now.addingTimeInterval(60*60*24*30), symbol: "pencil.and.list.clipboard", goal: "A goal to reach in the course", becomesHotDaysBefore: 7)
						deadlines.currentCourse.deadlines.append(newDeadline)
						selectedDeadline = newDeadline
						showDeadlineEditView.toggle();
					}
				}
			}
			HStack {
				Text("Course started \(deadlines.currentCourse.startDate.formatted(date: .abbreviated, time: .omitted)).")
				Text("and is now \(deadlines.currentCourse.courseAgeInDays) days old, \(deadlines.currentCourse.percentageReached().formatted(.percent)) done.")
			}
			Divider()
			List(deadlines.currentCourse.deadlines, selection: $selectedDeadline) { deadline in
				SingleDeadlineListRow(deadline: deadline)
					.swipeActions(edge: .leading) {
						Button {
							selectedDeadline = deadline
							showDeadlineEditView.toggle()
						} label: {
							Label("Edit Deadline", systemImage: "square.and.pencil")
						}
						.help("Edit Deadline")
					}
			}
		}
		.padding()
		.sheet(isPresented: $showDeadlineEditView) {
			if selectedDeadline != nil {
				DeadlineEditView(deadline: $selectedDeadline)
					.environment(deadlines)
					.frame(minWidth: 600, minHeight: 400)
			}
		}
		.sheet(isPresented: $showCourseEditView) {
			if selectedCourse != nil {
				CourseEditView(course: $selectedCourse)
					.environment(deadlines)
					.frame(minWidth: 600, minHeight: 400)
			}
		}
		.alert("Error", isPresented: $isError, actions: {
			// No action
		}, message: {
			Text(errorMessage)
		})
	}
	
	private func delete(at offsets: IndexSet) {
		do {
			try deadlines.currentCourse.remove(at: offsets[offsets.startIndex])
		} catch {
			isError = true
			errorMessage = error.localizedDescription
		}
	}
	
}
