//
//  ContentView.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 15.10.2024.
//

import SwiftUI

// TODO: Add confirmation alert to removing a course!


struct ContentView: View {
	@Environment(Deadlines.self) var deadlines
	
	@State var showDeadlineEditView: Bool = false
	@State var showCourseEditView: Bool = false
	@State var editingNewCourse = false
	@State var deleteDeadlineAlert: Bool = false
	@State var deleteCourseAlert: Bool = false
	
	@State var selectedDeadline: Deadline? = nil
	// @State var selectedCourseName: String
	
	@State var isError: Bool = false
	@State var errorMessage: String = ""
	
	var body: some View {
		VStack {
			HStack {
				Group {
					Image(systemName: "flag.pattern.checkered.2.crossed")
						.foregroundStyle(.blue)
					Picker("Deadlines for course", selection: Bindable(deadlines).selectedCourseName, content: {
						ForEach(deadlines.courses, id: \.self) { course in
							Text("\(course)")
								.tag(course.hashValue)
						}
					})
					.onChange(of: deadlines.selectedCourseName) {
						do {
							try deadlines.loadDeadlines(for: deadlines.selectedCourseName)
						} catch  {
							errorMessage = error.localizedDescription
							isError = true
						}
					}
					Image(systemName: "flag.pattern.checkered.2.crossed")
						.foregroundStyle(.red)
				}
			}
			.font(.title2)
			.padding()
			HStack {
				Text("Course start date is \(deadlines.currentCourse.startDate.formatted(date: .abbreviated, time: .omitted))")
				if deadlines.currentCourse.hasStarted {
					Text(" Course is now \(deadlines.currentCourse.courseAgeInDays) days old, \(deadlines.currentCourse.percentageLeft().formatted(.percent)) left to go.")
				} else {
					Text(" Starts in \(deadlines.currentCourse.daysToStart) days")
				}
			}
			.font(.title2)
			Spacer()
			HStack {
				Button("New Course") {
					editingNewCourse = true
					showCourseEditView.toggle();
				}
				Button("Delete course") {
					deleteCourseAlert.toggle()
				}
				.alert("Confirm Delete",
						 isPresented: $deleteCourseAlert)
				{
					Button(role: .destructive) {
						do {
							try deadlines.deleteCurrentCourse()
						} catch {
							errorMessage = error.localizedDescription
							isError = true
						}
					} label: {
						Text("Delete course")
					}
				} message: {
					Text("Delete this course? This cannot be undone")
				}
				Button("Edit Course") {
					editingNewCourse = false
					showCourseEditView.toggle();
				}
				Button("New Deadline") {
					let newDeadline = Deadline(date: deadlines.currentCourse.startDate.addingTimeInterval(60*60*24*30), symbol: "pencil.and.list.clipboard", goal: NSLocalizedString("A goal to reach in the course", comment: "String to put to a new deadline for user to edit"), becomesHotDaysBefore: 7)
					deadlines.currentCourse.deadlines.append(newDeadline)
				}
			}
			.buttonStyle(PrimaryButtonStyle())
			.fixedSize(horizontal: true, vertical: false)
			.padding()
			Divider()
			List(deadlines.currentCourse.deadlines, id: \.self, selection: $selectedDeadline) { deadline in
				SingleDeadlineListRow(deadline: deadline)
					.swipeActions(edge: .leading) {
						Button {
							showDeadlineEditView.toggle()
						} label: {
							Label("Edit", systemImage: "square.and.pencil")
						}
						.help("Edit Deadline")
					}
					.swipeActions(edge: .trailing) {
						Button(role: .destructive) {
							deleteDeadlineAlert.toggle()
						} label: {
							Label("Delete", systemImage: "trash")
						}
						.help("Delete Deadline")
					}
			}
			.padding()
			.sheet(isPresented: $showDeadlineEditView) {
				if let selectedDeadline {
					DeadlineEditView(deadline: selectedDeadline)
						.environment(deadlines)
						.frame(minWidth: 600, minHeight: 400)
				}
			}
			.sheet(isPresented: $showCourseEditView) {
				if editingNewCourse {
					CourseEditView(course: deadlines.newCourse())
						.environment(deadlines)
						.frame(minWidth: 600, minHeight: 400)
				} else {
					CourseEditView(course: deadlines.currentCourse)
						.environment(deadlines)
						.frame(minWidth: 600, minHeight: 400)
				}
			}
			.alert("Error", isPresented: $isError, actions: {
				// No action
			}, message: {
				Text(errorMessage)
			})
			.alert("Confirm Delete",
					 isPresented: $deleteDeadlineAlert)
			{
				Button(role: .destructive) {
					if selectedDeadline != nil {
						delete(selectedDeadline!)
					}
				} label: {
					Text("Delete deadline")
				}
			} message: {
				Text("Delete this deadline? This cannot be undone.")
			}
		}
		.onAppear() {
			do {
				try deadlines.readCourseList()
				if deadlines.courses.isEmpty {
					editingNewCourse = false
					showCourseEditView.toggle();
				}
			} catch {
				errorMessage = error.localizedDescription
				isError = true
			}
		}
		
	}
	
	private func delete(_ deadline: Deadline) {
		do {
			try deadlines.currentCourse.remove(deadline)
		} catch {
			isError = true
			errorMessage = error.localizedDescription
		}
	}
	
}
