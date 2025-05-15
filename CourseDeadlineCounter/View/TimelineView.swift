//
//  TimelineView.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 15.5.2025.
//

import SwiftUI

struct TimelineView: View {
	@Environment(Deadlines.self) var deadlines
	@Environment(\.colorScheme) var colorScheme
	
	let timeFrame = TimeInterval(60 * 60 * 24 * 7 * 4 * 6)
	let margin = 6.0

	var body: some View {
		Canvas { context, size in
			
			var origin = CGPoint(x: margin, y: margin)
			let text = Text("No courses to show").font(.title)
			let resolved = context.resolve(text)
			var symbolHeight = min(size.height / CGFloat(deadlines.courses.count), 24.0)
			symbolHeight = resolved.measure(in: CGSize(width: size.width, height: 24.0)).height

			// TODO:
			// - Draw course start symbol
			// - Use special chars or emojis as symbols and draw as text 🔸🔹🚩🏁
			// - Draw week lines from first _monday_ from firstDate onwards
			// - Horizontal lines? Below course, separating courses better?
			let coursesToPlot = deadlines.notFinished()
			if coursesToPlot.isEmpty {
				let rect = CGRect(origin: origin, size: CGSize(width: size.width, height: symbolHeight))
				context.draw(resolved, in: rect)
			} else {
				let firstDate = coursesToPlot.min(by: { $0.startDate < $1.startDate } )?.startDate ?? Date.now.addingTimeInterval(-timeFrame)
				let lastDate = coursesToPlot.max(by: { $0.endDate < $1.endDate } )?.endDate ?? Date.now.addingTimeInterval(timeFrame)
				let daysToShow = abs(lastDate.timeIntervalSince(firstDate)) / 86400
				print("Dates: \(firstDate) - \(lastDate), \(daysToShow) days")
				let dayWidth: CGFloat = size.width / daysToShow
				
				print("Day width: \(dayWidth) pixels")
				print("Canvas size: \(size.width) x \(size.height) pixels")
				if Date.now > firstDate && Date.now < lastDate {
					let daysFromFirstDate = abs(firstDate.timeIntervalSince(Date.now)) / 86400
					origin.x += daysFromFirstDate * dayWidth

					let text = Text("Now").font(.caption)
					let resolved = context.resolve(text)
					let rect = CGRect(origin: origin, size: CGSize(width: size.width, height: symbolHeight))
					context.draw(resolved, in: rect)
					var centerLinePath = Path()
					centerLinePath.move(to: origin)
					centerLinePath.addLine(to: CGPoint(x: origin.x, y: size.height))
					context.stroke(centerLinePath, with: .color(.red))
				}
				origin = .zero
				let weekGap = size.width / (daysToShow / 7)
				for _ in stride(from: 0, to: daysToShow, by: 7) {
					var weekLinePath = Path()
					weekLinePath.move(to: origin)
					weekLinePath.addLine(to: CGPoint(x: origin.x, y: size.height))
					context.stroke(weekLinePath, with: .color(.gray))
					origin.x += weekGap
				}
				
				coursesToPlot.forEach { course in
					origin.x = margin
					print("\(course.name)")
					let text = Text("\(course.name)").font(.title2).foregroundStyle(courseTextColor)
					let resolved = context.resolve(text)
					let rect = CGRect(origin: origin, size: CGSize(width: size.width, height: symbolHeight))
					context.draw(resolved, in: rect)
					origin.y += symbolHeight + 6
					if !course.deadlines.isEmpty {
						for deadline in course.deadlines {
							print("\(deadline.goal)")
							let text = (Text(deadline.date.formatted(date: .abbreviated, time: .shortened)) + Text(" \(deadline.goal)").font(.body)).foregroundStyle(deadlineTextColor)
							let daysFromFirstDate = abs(firstDate.timeIntervalSince(deadline.date)) / 86400
							origin.x = daysFromFirstDate * dayWidth
							
							var path = Path()
							path.move(to: origin)
							path.addRect(CGRect(origin: origin, size: CGSize(width: dayWidth, height: symbolHeight)))
							context.fill(path, with: .color(deadlineColor))
							
							origin.x += dayWidth + 2
							var rect = CGRect(origin: origin, size: CGSize(width: size.width, height: symbolHeight))
							let resolved = context.resolve(text)
							let measuredSize = resolved.measure(in: rect.size)
							if rect.origin.x + measuredSize.width > size.width {
								rect = rect.offsetBy(dx: -measuredSize.width - dayWidth * 2 , dy: 0)
							}
							print("rect size: \(rect.width)x\(rect.height), resolved size: \(measuredSize.width)x\(measuredSize.height)")
							context.draw(resolved, in: rect)
							origin.y += symbolHeight + 6
						}
						origin.y += symbolHeight + 6
					}
					origin.y += symbolHeight + 6
				}
			}
		}
	}
	
	private var deadlineColor: Color	{
		if colorScheme == .dark {
			return .orange
		}
		return .red
	}
	private var deadlineTextColor: Color {
		if colorScheme == .dark {
			return Color(.lightGray)
		}
		return .gray
	}
	
	private var courseTextColor: Color {
		if colorScheme == .dark {
			return .white
		}
		return .black
	}
	
	private var weekGridLineColor: Color {
		if colorScheme == .dark {
			return Color(.lightGray)
		}
		return .gray
	}
		
}

#Preview {
	TimelineView()
}
