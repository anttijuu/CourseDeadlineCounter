//
//  SingleDeadlineView.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 15.10.2024.
//

import SwiftUI

struct SingleDeadlineListRow: View {
	let deadline: Deadline
	
	var body: some View {
		HStack(spacing: 12) {
			Image(systemName: deadline.symbol)
				.font(.title)
				.symbolRenderingMode(.multicolor)
				.foregroundStyle(deadlineColor)
				.frame(width: 42)
			VStack(alignment: .leading, spacing: 2) {
				HStack {
					Text(deadline.date, style: .relative)
					Text(deadline.isReached ? "ago" : "left")
				}
				.font(.title3)
				.foregroundStyle(deadlineColor)
				VStack(alignment: .leading) {
					Text(deadline.goal)
						.bold()
					Text(deadline.date.formatted(date: .long, time: .standard))
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
