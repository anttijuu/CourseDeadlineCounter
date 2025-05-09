//
//  ContentView.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 15.10.2024.
//

import SwiftUI

struct CourseEditButton: View {
	let action: () -> Void
	
	var body: some View {
		Button {
			action()
		} label: {
			Label("Edit Course", systemImage: "square.and.pencil")
		}
		.help("Edit Course")
	}
}

struct CourseDeleteButton: View {
	let action: () -> Void
	
	var body: some View {
		Button(role: .destructive) {
			action()
		} label: {
			Label("Delete Course", systemImage: "trash")
		}
		.help("Delete Course")
	}
}

struct CourseDetailsView: View {
	let course: Course
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack(alignment: .top) {
				Image(systemName: "book.and.wrench")
					.font(.largeTitle)
					.foregroundColor(.accentColor)
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
						CourseEditButton(action:  { showCourseEditView.toggle() } )
							.disabled(selectedCourse == nil)
						CourseDeleteButton(action: {deleteCourseAlert.toggle() } )
							.disabled(selectedCourse == nil)
					}
					.swipeActions(edge: .leading) {
						CourseEditButton(action:  { showCourseEditView.toggle() } )
							.disabled(selectedCourse == nil)
							.help("Edit Course")
					}
					.swipeActions(edge: .trailing) {
						CourseDeleteButton(action: {deleteCourseAlert.toggle() } )
							.disabled(selectedCourse == nil)
					}
					.alert("Confirm Delete", isPresented: $deleteCourseAlert) {
						Button(role: .destructive) {
							do {
								if let course = deadlines.course(id: selectedCourse) {
									try deadlines.delete(course)
								}
							} catch {
								errorMessage = error.localizedDescription
								isError = true
							}
						} label: {
							Text("Delete course")
						}
					} message: {
						Text("Move this course to Trash?")
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
							DeadlineEditView(course: course, deadline: selectedDeadline)
								.environment(deadlines)
								.frame(minWidth: 600, minHeight: 400)
						}
					}
					.alert("Confirm Delete",
							 isPresented: $deleteDeadlineAlert)
					{
						Button(role: .destructive) {
							if selectedDeadline != nil {
								delete(selectedDeadline!, from: course)
							}
						} label: {
							Text("Delete deadline")
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
		.confirmationDialog("Do you really want to delete the course with all deadlines?", isPresented: $deleteCourseAlert) {
			Button("Delete", role: .destructive)	 {
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
				deleteCourseAlert = false
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
