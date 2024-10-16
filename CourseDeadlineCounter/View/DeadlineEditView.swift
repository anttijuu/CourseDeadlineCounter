//
//  DeadlineEditView.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 15.10.2024.
//

import SwiftUI

struct DeadlineEditView: View {
	@Environment(Deadlines.self) var deadlines
	
	@Binding var deadline: Deadline?
	
	@Environment(\.dismiss) var dismiss

	@State var editSymbolName: String = ""
	@State var editDeadlineGoal: String = ""
	@State var editDeadline: Date = .now
	@State var editDaysComesHot: Int = 14
	
	@State var isError: Bool = false
	@State var errorMessage: String = ""
	
	let range = 1...100
	let step = 1
	
	var body: some View {
		VStack(spacing: 8) {
			Text("Edit deadline")
				.font(.title)
			Form {
				TextField("SF Symbol name:", text: $editSymbolName)
				Text("See SF Symbols app for available symbols")
					.font(.caption)
				TextField("Deadline goal:", text: $editDeadlineGoal)
				DatePicker("Set deadline:", selection: $editDeadline, displayedComponents: [.date, .hourAndMinute])
				HStack {
						Stepper(
						value: $editDaysComesHot,
						in: range,
						step: step
					) {
						Text("Deadline becomes a hot thing")
					}
					Text("\(editDaysComesHot) days before deadline")
				}
			}
			Spacer()
			Button("Save", action: {
				do {
					try save()
				} catch {
					isError = true
					errorMessage = error.localizedDescription
				}
			})
		}
		.padding()
		.onAppear {
			if let deadline {
				editSymbolName = deadline.symbol
				editDeadlineGoal = deadline.goal
				editDeadline = deadline.date
				editDaysComesHot = deadline.becomesHotDaysBefore
			}
		}
		.alert("Could not save deadlines", isPresented: $isError, actions: {
			// No action
		}, message: {
			Text(errorMessage)
		})
	}
	
	private func save() throws {
		let modifiedDeadline = Deadline(uuid: deadline!.uuid, date: editDeadline, symbol: editSymbolName, goal: editDeadlineGoal, becomesHotDaysBefore: editDaysComesHot)
		try deadlines.currentCourse.modifyOrAdd(modifiedDeadline)
		try deadlines.loadDeadlines(for: deadlines.currentCourse.name)
		dismiss()
	}
}
