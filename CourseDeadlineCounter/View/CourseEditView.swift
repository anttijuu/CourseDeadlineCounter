//
//  CourseEditView.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 15.10.2024.
//

import SwiftUI

struct CourseEditView: View {
	@Environment(Deadlines.self) var deadlines
	
	@Environment(\.dismiss) var dismiss
		
	var course: Course
	
	@State var editCourseName: String = NSLocalizedString("New Course", comment: "User is creating a new course")
	@State var editStartDate: Date = Date.now

	@State var isError: Bool = false
	@State var errorMessage: String = ""
	
	var body: some View {
		VStack(spacing: 8) {
			Text("Edit Course")
				.font(.title)
			Form {
				TextField("Course name:", text: $editCourseName)
				DatePicker("Start date:", selection: $editStartDate, displayedComponents: [.date])
			}
			Spacer()
			Button("Save", action: {
				do {
					try save()
					dismiss()
				} catch {
					isError = true
					errorMessage = error.localizedDescription
				}
			})
		}
		.padding()
		.onAppear {
			editCourseName = course.name
			editStartDate = course.startDate
		}
		.alert("Could not save Course", isPresented: $isError, actions: {
			// No action
		}, message: {
			Text(errorMessage)
		})
	}
	
	private func save() throws {
		let oldCourseName = course.name
		let newCourseName = editCourseName
		course.name = newCourseName
		course.startDate = editStartDate.toMidnight()
		if oldCourseName != newCourseName {
			try deadlines.saveCourse(for: course, oldName: oldCourseName)
		} else {
			try deadlines.saveCourse(for: course)
		}
	}
}
