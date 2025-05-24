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

	@State private var askMovingDeadlineDates: Bool = false
		
	@State var isError: Bool = false
	@State var errorMessage: String = ""

	private enum DeadlineMove {
		case askMovingDeadlines
		case moveDeadlines
		case doNotMoveDeadlines
	}
	
	var body: some View {
		VStack(spacing: 8) {
			Text("Edit Course")
				.font(.title)
			Form {
				TextField("Course name:", text: $editCourseName)
					.onSubmit {
						if save(moveDeadlinesState: .askMovingDeadlines) {
							 dismiss()
						}
					}
				DatePicker("Start date:", selection: $editStartDate, displayedComponents: [.date])
			}
			Spacer()
			Button("Save", action: {
				if save(moveDeadlinesState: .askMovingDeadlines) {
					 dismiss()
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
		.confirmationDialog("Move deadline dates too?", isPresented: $askMovingDeadlineDates) {
			VStack {
				Text("Course start date was moved \(editStartDate.timeIntervalSince(course?.startDate ?? Date.now) / 86400) days")
				Text("Do you wish to move deadline dates accordingly?")
				Button("Yes") {
					if save(moveDeadlinesState: .moveDeadlines) {
						 dismiss()
					}
				}
				Button("No", role: .cancel) {
					if save(moveDeadlinesState: .doNotMoveDeadlines) {
						 dismiss()
					}
				}
			}
		}
	}
	
	private func save(moveDeadlinesState: DeadlineMove) -> Bool {
		do {
			if editCourseName.isEmpty {
				errorMessage = NSLocalizedString("Course must have a name", comment: "Shown if user tries to save a course without a name")
				isError = true
				return false
			}
			// If we already have a course with the edited name...
			if deadlines.hasCourse(withName: editCourseName) {
				// ..and we are now creating a new one, then we have an issue.
				// Otherwise, we have an old course and new name for it is already taken, we have an issue
				if course == nil || (course != nil && course!.name != editCourseName) {
					errorMessage = NSLocalizedString("Courses must have a unique name", comment: "Shown if user tries to save a course with a name of an existing course")
					isError = true
					return false
				}
			}
			if let course {
				let oldCourseName = course.name
				let newCourseName = editCourseName
				editStartDate = editStartDate.toMidnight()
				if editStartDate != course.startDate {
					switch moveDeadlinesState {
					case .askMovingDeadlines:
						askMovingDeadlineDates.toggle()
						return false
					case .moveDeadlines:
						course.moveDeadlines(forDays: Int(editStartDate.timeIntervalSince(course.startDate) / 86400))
					case .doNotMoveDeadlines:
						break
					}
				}
				course.changeName(editCourseName)
				course.startDate = editStartDate
				if newCourseName != oldCourseName {
					try deadlines.saveCourse(for: course, oldName: oldCourseName)
				} else {
					try deadlines.saveCourse(for: course)
				}
			} else {
				course = Course(name: editCourseName, startDate: editStartDate.toMidnight())
				try deadlines.saveCourse(for: course!)
			}
			return true
		} catch {
			isError = true
			errorMessage = error.localizedDescription
			return false
		}
	}
}
