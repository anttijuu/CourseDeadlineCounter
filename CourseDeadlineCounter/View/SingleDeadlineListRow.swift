//
//  SingleDeadlineView.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 15.10.2024.
//

import SwiftUI

struct SingleDeadlineListRow: View {
	@Environment(Deadlines.self) var deadlines
	
	@Bindable var course: Course
	@Bindable var deadline: Deadline

	var body: some View {
		HStack(spacing: 12) {
			Image(systemName: deadline.symbol)
				.font(.title)
				.symbolRenderingMode(.multicolor)
				.foregroundStyle(deadline.color)
				.frame(width: 48)
			VStack(alignment: .leading, spacing: 2) {
				HStack {
					if deadline.isDealBreaker {
						Image(systemName: "exclamationmark.triangle.fill")
							.foregroundStyle(deadline.color)
					}
					if deadline.isReached {
						Text("Deadline passed")
							.padding(.trailing, 0)
						Text(deadline.date, style: .relative)
							.padding([.leading, .trailing], 0)
						Text("ago")
							.padding(.leading, 0)
					} else {
						Text(deadline.date, style: .relative)
							.padding(.trailing, 0)
						Text("until deadline")
							.padding(.leading, 0)
						Text("\(deadline.percentageLeft(from: course.startDate).formatted(.percent)) calendar time left")
							.bold()
					}
				}
				.font(.title3)
				.foregroundStyle(deadline.color)
				VStack(alignment: .leading) {
					Text(deadline.goal)
						.font(.title3)
						.bold()
					Text(deadline.date.formatted(date: .long, time: .shortened))
				}
				.foregroundStyle(deadline.isReached ? .gray : .primary)
			}
		}
		.padding(.vertical, 4)
	}
	
}
