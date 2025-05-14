//
//  DeadlineEditView.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 15.10.2024.
//

import SwiftUI

struct DeadlineEditView: View {
	@Environment(Deadlines.self) var deadlines
	
	var course: Course
	@Bindable var deadline: Deadline
	
	@Environment(\.dismiss) var dismiss
	
	@State var editSymbolName: String = "hammer"
	@State var editDeadlineGoal: String = ""
	@State var editDeadline: Date = .now
	@State var editDaysComesHot: Int = 14
	@State var editIsDealBreaker: Bool = false
	
	@State var isError: Bool = false
	@State var errorMessage: String = ""
	
	@State var showSymbolPickerView: Bool = false
	
	let hotDaysRange = 1...30 // alert range 1...30 days before deadline
	let step = 1

	let deadlineDateRange: ClosedRange<Date>
	
	init(course: Course, deadline: Deadline) {
		self.course = course
		self.deadline = deadline
		deadlineDateRange = {
			let calendar = Calendar.current
			let startComponents = calendar.dateComponents([.year, .month, .day], from: course.startDate) // Date.now)
			let endDate = course.startDate.addingTimeInterval(60 * 60 * 24 * 365)
			return calendar.date(from:startComponents)!
			...
			endDate
		}()
	}
	var body: some View {
		VStack(spacing: 8) {
			Text("Edit deadline")
				.font(.title)
			Form {
				HStack {
					TextField("SF Symbol name:", text: $editSymbolName)
					Button("Pick") {
						showSymbolPickerView.toggle()
					}
					.sheet(isPresented: $showSymbolPickerView) {
						SymbolPickerView(symbolName: $editSymbolName)
					}
				}
				Text("See SF Symbols app for available symbols")
					.font(.caption)
				TextField("Deadline goal:", text: $editDeadlineGoal)
				DatePicker("Set deadline:", selection: $editDeadline, in: deadlineDateRange, displayedComponents: [.date, .hourAndMinute])
				HStack {
					Stepper(
						value: $editDaysComesHot,
						in: hotDaysRange,
						step: step
					) {
						Text("Deadline becomes hot")
					}
					Text("\(editDaysComesHot) days before deadline")
				}
				Toggle("Is deal breaker?", isOn: $editIsDealBreaker)
				Text("If deadline is not met, course is considered failed or grade is lowered")
					.font(.caption)
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
			editSymbolName = deadline.symbol
			editDeadlineGoal = deadline.goal
			editDeadline = deadline.date
			editDaysComesHot = deadline.becomesHotDaysBefore
			editIsDealBreaker = deadline.isDealBreaker
		}
		.alert("Could not save deadline", isPresented: $isError, actions: {
			// No action
		}, message: {
			Text(errorMessage)
		})
	}
	
	private func save() throws {
		if editDeadlineGoal.isEmpty {
			errorMessage = NSLocalizedString("Deadline must have a goal", comment: "Shown if user tries to save a deadline without a goal")
			isError = true
			return
		}
		Task {
			let changeToAlert = deadline.date != editDeadline || deadline.goal != editDeadlineGoal || deadline.becomesHotDaysBefore != editDaysComesHot
			deadline.date = editDeadline.secondsRoundedToZero()
			deadline.symbol = editSymbolName.isEmpty ? "hammer" : editSymbolName
			deadline.goal = editDeadlineGoal
			deadline.becomesHotDaysBefore = editDaysComesHot
			deadline.isDealBreaker = editIsDealBreaker
			try course.store()
			if changeToAlert {
				let alertDate = deadline.date.addingTimeInterval(-Double(deadline.becomesHotDaysBefore) * 86400)
				await Notifications.shared.updateNotification(
					deadlineID: deadline.uuid.uuidString,
					name: deadline.goal,
					alertDate: alertDate,
					deadlineDate: deadline.date,
					courseName: course.name
				)
			}
			dismiss()
		}
	}
}
