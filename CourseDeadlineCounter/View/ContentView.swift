//
//  ContentView.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 15.10.2024.
//

import SwiftUI

struct ContentView: View {
	@Environment(Deadlines.self) var deadlines
	
	@State var showDeadlineEditView: Bool = false
	@State var showCourseEditView: Bool = false
	@State var deleteDeadlineAlert: Bool = false
	
	@State var selectedDeadline: Deadline? = nil
	@State var selectedCourseName: String
	
	@State var isError: Bool = false
	@State var errorMessage: String = ""
	
	var body: some View {
		VStack {
			HStack {
				VStack {
					Button("New Course") {
						deadlines.newCourse()
						showCourseEditView.toggle();
					}
					Button("Delete course") {
						deadlines.deleteCourse()
					}
				}
				Spacer()
				Group {
					Image(systemName: "flag.pattern.checkered.2.crossed")
					Picker("Deadlines for course", selection: $selectedCourseName, content: {
						ForEach(deadlines.courses, id: \.self) { course in
							Text("\(course)")
								.tag(course.hashValue)
						}
					})
					.onChange(of: selectedCourseName) {
						do {
							try deadlines.loadDeadlines(for: selectedCourseName)
						} catch  {
							errorMessage = error.localizedDescription
							isError = true
						}
					}
					Image(systemName: "flag.pattern.checkered.2.crossed")
				}
				.font(.title)
				Spacer()
				VStack {
					Button("Edit Course") {
						showCourseEditView.toggle();
					}
					Button("New Deadline") {
						let newDeadline = Deadline(date: Date.now.addingTimeInterval(60*60*24*30), symbol: "pencil.and.list.clipboard", goal: "A goal to reach in the course", becomesHotDaysBefore: 7)
						deadlines.currentCourse.deadlines.append(newDeadline)
					}
				}
			}
			.padding()
			HStack {
				Text("Course started \(deadlines.currentCourse.startDate.formatted(date: .abbreviated, time: .omitted)).")
				Text("and is now \(deadlines.currentCourse.courseAgeInDays) days old, \(deadlines.currentCourse.percentageLeft().formatted(.percent)) left to go.")
			}
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
			if selectedDeadline != nil {
				DeadlineEditView(deadline: $selectedDeadline)
					.environment(deadlines)
					.frame(minWidth: 600, minHeight: 400)
			}
		}
		.sheet(isPresented: $showCourseEditView) {
			CourseEditView(course: deadlines.currentCourse)
				.environment(deadlines)
				.frame(minWidth: 600, minHeight: 400)
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
				Button("Cancel") {
					
				}
			} message: {
				Text("Delete this deadline?")
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
