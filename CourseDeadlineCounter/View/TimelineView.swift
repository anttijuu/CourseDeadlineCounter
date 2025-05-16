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
	
	let defaultTimeFrame = TimeInterval(60 * 60 * 24 * 7 * 4 * 6)
	let margin = 1.0
	
	var body: some View {
		VStack {
			Text("Deadline is at the symbol location on the timeline")
				.font(.caption)
			Divider()
			Canvas { context, size in
				
				var origin = CGPoint(x: margin, y: margin)
				let text = Text("No courses to show").font(.title).bold()
				let resolved = context.resolve(text)
				var symbolHeight = min(size.height / CGFloat(deadlines.courses.count), 24.0)
				symbolHeight = resolved.measure(in: CGSize(width: size.width, height: 24.0)).height
				
				// TODO:
				// - Draw a pink background from date-when-becomes-hot to actual deadline date.
				// - Horizontal lines or a grid drawn at the background? Below course, separating courses better?
				// - What if the space is too small for all ongoing courses? Zoom or scroll?
				// - Check if looks cleaner without the grid/lines...
				
				let coursesToPlot = deadlines.notFinished().sorted(by: { $0.startDate < $1.startDate } )
				if coursesToPlot.isEmpty {
					let rect = CGRect(origin: origin, size: CGSize(width: size.width, height: symbolHeight))
					context.draw(resolved, in: rect)
				} else {
					let firstDate = (coursesToPlot.min(by: { $0.startDate < $1.startDate } )?.startDate ?? Date.now.addingTimeInterval(-defaultTimeFrame)).toPreviousMonday()
					let lastDate = coursesToPlot.max(by: { $0.endDate < $1.endDate } )?.endDate ?? Date.now.addingTimeInterval(defaultTimeFrame)
					let daysToShow = (abs(lastDate.timeIntervalSince(firstDate)) / 86400) + 4
					let dayWidth: CGFloat = size.width / daysToShow
					
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
					for _ in stride(from: 0, to: daysToShow, by: 7) {
						var weekLinePath = Path()
						weekLinePath.move(to: origin)
						weekLinePath.addLine(to: CGPoint(x: origin.x, y: size.height))
						context.stroke(weekLinePath, with: .color(Color(.lightGray)))
						origin.x += dayWidth * 7
					}
					
					coursesToPlot.forEach { course in
						let daysFromFirstDate = abs(firstDate.timeIntervalSince(course.startDate)) / 86400
						origin.x = daysFromFirstDate * dayWidth

						let image = Image(systemName: "arrowtriangle.right.square.fill")
						let resolvedImage = context.resolve(image)

						let text = Text("\(course.name) (\(course.startDate.formatted(date: .numeric, time: .omitted)))").font(.title3).bold().foregroundStyle(courseTextColor)
						let resolvedCourseText = context.resolve(text)
						var rect = CGRect(origin: origin, size: CGSize(width: size.width, height: symbolHeight))
						let measuredSize = resolvedCourseText.measure(in: rect.size)
						let sizeOfImage = max(resolvedImage.size.height, measuredSize.height)

						origin.x += sizeOfImage + 2
						context.draw(resolvedCourseText, in: CGRect(origin: origin, size: measuredSize))

						origin.x -= sizeOfImage + 2
						context.draw(resolvedImage, in: CGRect(origin: origin, size: CGSize(width: sizeOfImage, height: sizeOfImage)))
						
						origin.y += symbolHeight

						if !course.deadlines.isEmpty {
							for deadline in course.deadlines {
								
								let text = (Text(deadline.date.formatted(date: .abbreviated, time: .shortened)) + Text(" \(deadline.goal)").font(.body)).foregroundStyle(deadline.color)
								let resolved = context.resolve(text)
								let daysFromFirstDate = abs(firstDate.timeIntervalSince(deadline.date)) / 86400
								origin.x = daysFromFirstDate * dayWidth
								
								let image = context.resolve(Image(systemName: deadline.symbol))
								origin.x -= image.size.width + 2
								context.draw(image, in: CGRect(origin: origin, size: image.size))
								origin.x += image.size.width + 2
								rect = CGRect(origin: origin, size: CGSize(width: size.width, height: symbolHeight))
								let measuredSize = resolved.measure(in: rect.size)
								if rect.origin.x + measuredSize.width > size.width {
									rect = rect.offsetBy(dx: -measuredSize.width - image.size.width - 4.0 , dy: 0)
								}
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
		
		
	}
		
	private var courseTextColor: Color {
		if colorScheme == .dark {
			return .purple
		}
		return .blue
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
