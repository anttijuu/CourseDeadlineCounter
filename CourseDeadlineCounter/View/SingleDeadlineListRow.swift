//
//  SingleDeadlineView.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 15.10.2024.
//

import SwiftUI

struct SingleDeadlineListRow: View {
	@Environment(Deadlines.self) var deadlines
	
	@State var deadline: Deadline
	
	var body: some View {
		HStack(spacing: 12) {
			Image(systemName: deadline.symbol)
				.font(.title)
				.symbolRenderingMode(.multicolor)
				.foregroundStyle(deadlineColor)
				.frame(width: 48)
			VStack(alignment: .leading, spacing: 2) {
				HStack {
					Text(deadline.date, style: .relative)
					Text(deadline.isReached ? "ago" : "left")
				}
				.font(.title3)
				.foregroundStyle(deadlineColor)
				if !deadline.isReached {
					Text("\(deadline.percentageReached(from: deadlines.currentCourse.startDate).formatted(.percent)) of course time spent")
						.font(.title2)
						.bold()
						.foregroundStyle(deadlineColor)
				}
				VStack(alignment: .leading) {
					Text(deadline.goal)
						.font(.title2)
						.bold()
					Text(deadline.date.formatted(date: .long, time: .shortened))
				}
				.foregroundStyle(deadline.isReached ? .gray : .primary)
			}
		}
	}
	
	var deadlineColor: Color {
		if deadline.isReached {
			return .gray
		} else if deadline.isHot {
			return .red
		} else {
			return .accentColor
		}
	}
}
