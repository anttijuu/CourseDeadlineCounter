//
//  ContentView.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 15.10.2024.
//

import SwiftUI

struct ContentView: View {
	@Environment(Deadlines.self) var deadlines: Deadlines
	
	@State var showDeadlineEditView: Bool = false
	@State var selectedDeadline: Deadline? = nil
	
	@State var isError: Bool = false
	@State var errorMessage: String = ""
	
	var body: some View {
		VStack {
			HStack {
				Image(systemName: "flag.pattern.checkered.2.crossed")
				Text("Deadlines for \(deadlines.deadlines.course)")
				Image(systemName: "flag.pattern.checkered.2.crossed")
			}
			.font(.title)
			Divider()
			List(deadlines.deadlines.deadlines, selection: $selectedDeadline) { deadline in
				SingleDeadlineListRow(deadline: deadline)
					.swipeActions(edge: .leading) {
						Button {
							selectedDeadline = deadline
							showDeadlineEditView.toggle()
						} label: {
							Label("Edit Deadline", systemImage: "square.and.pencil")
						}
						.help("Edit Deadline")
					}
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
		.alert("Error", isPresented: $isError, actions: {
			// No action
		}, message: {
			Text(errorMessage)
		})

	}
	
	private func delete(at offsets: IndexSet) {
		do {
			try deadlines.deadlines.remove(at: offsets[offsets.startIndex])
		} catch {
			isError = true
			errorMessage = error.localizedDescription
		}
	}
	
}
