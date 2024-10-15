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
	
	@Binding var course: Course?
	
	@State var editCourseName: String = "New Course"
	@State var editStartDate: Date = Date.now

	@State var isError: Bool = false
	@State var errorMessage: String = ""
	
	var body: some View {
		VStack(spacing: 8) {
			Text("Edit Course")
				.font(.title)
			Form {
				TextField("Course name:", text: $editCourseName)
				DatePicker("Started in:", selection: $editStartDate, displayedComponents: [.date])
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
			if let course {
				editCourseName = course.name
				editStartDate = course.startDate
			}
		}
		.alert("Could not save Course", isPresented: $isError, actions: {
			// No action
		}, message: {
			Text(errorMessage)
		})
	}
	
	private func save() throws {
		let editedCourse = Course(name: editCourseName, startDate: editStartDate)
		try deadlines.saveDeadlines(for: editedCourse, with: editedCourse.name != course!.name ? course!.name : nil)
	}
}
