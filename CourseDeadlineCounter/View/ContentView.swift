//
//  ContentView.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 15.10.2024.
//

import SwiftUI

struct EditButton: View {
	let label: String
	let action: () -> Void
	
	var body: some View {
		Button {
			action()
		} label: {
			Label(label, systemImage: "square.and.pencil")
		}
		.help(label)
	}
}

struct DeleteButton: View {
	let label: String
	let action: () -> Void
	
	var body: some View {
		Button(role: .destructive) {
			action()
		} label: {
			Label(label, systemImage: "trash")
		}
		.help(label)
	}
}

struct CourseDetailsView: View {
	let course: Course
	
	var body: some View {
		HStack {
			Image(systemName: "book.and.wrench")
				.font(.largeTitle)
				.foregroundColor(.accentColor)
			HStack(alignment: .bottom) {
				VStack(alignment: .leading) {
					Text(course.name)
						.font(.title2)
					Text("Starts at \(course.startDate.formatted(date: .abbreviated, time: .omitted))")
					Text("Has \(course.deadlines.count) deadlines (\(course.deadlines.filter( { $0.isReached == true } ).count) completed)")
				}
				Spacer()
				VStack(alignment: .trailing) {
					if course.hasStarted {
						Text("Course is now \(course.courseAgeInDays) days old")
						Text("\(course.percentageLeft().formatted(.percent)) left to go")
					} else {
						Text("Starts in \(course.daysToStart) days")
					}
				}
			}
		}
		.padding([.top, .leading, .trailing])
	}
}

struct ContentView: View {
	@Environment(Deadlines.self) var deadlines
	@State private var selectedCourse: Course.ID?
	
	@State var showDeadlineEditView: Bool = false
	@State var showCourseEditView: Bool = false
	@State var showNewCourseView: Bool = false
	@State var editingNewCourse = false
	@State var deleteDeadlineAlert: Bool = false
	@State var deleteCourseAlert: Bool = false
	
	@State var selectedDeadline: Deadline? = nil
	
	@State var isError: Bool = false
	@State var errorMessage: String = ""
	
	var body: some View {
		NavigationSplitView(sidebar: {
			List(deadlines.courses, selection: $selectedCourse) { course in
				Text(course.name)
					.font(.title3)
					.contextMenu {
						EditButton(label: "Edit Course", action: { showCourseEditView.toggle() } )
							.disabled(selectedCourse == nil)
						DeleteButton(label: "Delete Course", action: {deleteCourseAlert.toggle() } )
							.disabled(selectedCourse == nil)
					}
					.swipeActions(edge: .leading) {
						EditButton(label: "Edit Course", action: { showCourseEditView.toggle() } )
							.disabled(selectedCourse == nil)
							.help("Edit Course")
					}
					.swipeActions(edge: .trailing) {
						DeleteButton(label: "Delete Course", action: {deleteCourseAlert.toggle() } )
							.disabled(selectedCourse == nil)
					}
			}
			.toolbar {
				ToolbarItemGroup(placement: .primaryAction) {
					Button(action: {
						showNewCourseView.toggle()
					}, label: {
						Image(systemName: "rectangle.stack.badge.plus")
					})
					.help("Add new course")
				}
			}
		}, detail: {
			if let course = deadlines.course(id: selectedCourse) {
				VStack(alignment: .leading, spacing: 2) {
					CourseDetailsView(course: course)
					List(course.deadlines, id: \.self, selection: $selectedDeadline) { deadline in
						SingleDeadlineListRow(course: course, deadline: deadline)
							.contextMenu {
								EditButton(label: "Edit Deadline", action: { showDeadlineEditView.toggle() } )
								DeleteButton(label: "Delete Deadline", action: { deleteDeadlineAlert.toggle() } )
							}
							.swipeActions(edge: .leading) {
								EditButton(label: "Edit Deadline", action: { showDeadlineEditView.toggle() } )
							}
							.swipeActions(edge: .trailing) {
								DeleteButton(label: "Delete Deadline", action: { deleteDeadlineAlert.toggle() } )
							}
					}
					.padding()
					.sheet(isPresented: $showDeadlineEditView) {
						if let selectedDeadline {
							DeadlineEditView(course: course, deadline: selectedDeadline)
								.environment(deadlines)
								.frame(minWidth: 600, minHeight: 400)
						}
					}
					.alert("Confirm Delete",
							 isPresented: $deleteDeadlineAlert)
					{
						Button(role: .destructive) {
							if let selectedDeadline {
								delete(selectedDeadline, from: course)
							}
						} label: {
							Label("Delete Deadline", systemImage: "trash")
						}
					} message: {
						Text("Delete this deadline? This cannot be undone.")
					}
				}
				.toolbar {
					ToolbarItemGroup(placement: .secondaryAction) {
						Button(action: {
							if let course = deadlines.course(id: selectedCourse) {
								let newDeadline = Deadline(date: course.startDate.addingTimeInterval(60*60*24*30), symbol: "pencil.and.list.clipboard", goal: NSLocalizedString("A goal to reach in the course", comment: "String to put to a new deadline for user to edit"), becomesHotDaysBefore: 7)
								course.deadlines.append(newDeadline)
							}
						}, label: {
							Image(systemName: "plus")
						})
						.help("Add new deadline")
					}
				}
			} else {
				Text("Select course from the list or create a new course")
			}
		})
		.sheet(isPresented: $showNewCourseView) {
			CourseEditView(course: deadlines.newCourse())
				.environment(deadlines)
				.frame(minWidth: 600, minHeight: 400)
		}
		.sheet(isPresented: $showCourseEditView) {
			if let course = deadlines.course(id: selectedCourse) {
				CourseEditView(course: course)
					.environment(deadlines)
					.frame(minWidth: 600, minHeight: 400)
			}
		}
		.alert("Error", isPresented: $isError, actions: {
			// No action
		}, message: {
			Text(errorMessage)
		})
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
		.confirmationDialog("Move the the course to Trash?", isPresented: $deleteCourseAlert) {
			Button("Delete Course", role: .destructive)	 {
				if let course = deadlines.course(id: selectedCourse) {
					do {
						try deadlines.delete(course)
					} catch {
						errorMessage = "Could not delete course because \(error.localizedDescription)"
						isError.toggle()
					}
				}
			}
			Button("Cancel", role: .cancel) {
				
			}
		}
		
	}
	
	private func delete(_ deadline: Deadline, from course: Course) {
		do {
			try course.remove(deadline)
		} catch {
			isError = true
			errorMessage = error.localizedDescription
		}
	}
	
}
