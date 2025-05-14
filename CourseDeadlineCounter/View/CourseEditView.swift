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
		
	@State var course: Course?
	
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
					if try save() {
						dismiss()
					}
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
	
	private func save() throws -> Bool {
		if editCourseName.isEmpty {
			errorMessage = NSLocalizedString("Course must have a name", comment: "Shown if user tries to save a course without a name")
			isError = true
			return false
		}
		if /*isNew &&*/ deadlines.hasCourse(withName: editCourseName) {
			errorMessage = NSLocalizedString("Courses must have a unique name", comment: "Shown if user tries to save a course with a name of an existiing course")
			isError = true
			return false
		}
		if let course {
			let oldCourseName = course.name
			let newCourseName = editCourseName
			course.name = editCourseName
			course.startDate = editStartDate.toMidnight()
			if newCourseName != editCourseName {
				try deadlines.saveCourse(for: course, oldName: oldCourseName)
			} else {
				try deadlines.saveCourse(for: course)
			}
		} else {
			course = deadlines.newCourse()
			course!.name = editCourseName
			course!.startDate = editStartDate.toMidnight()
			try deadlines.saveCourse(for: course!)
		}
		return true
	}
}
