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
	
	@State var positions: [SIMD2<Float>] = [
		 .init(x: 0, y: 0), .init(x: 0.2, y: 0), .init(x: 1, y: 0),
		 .init(x: 0, y: 0.7), .init(x: 0.1, y: 0.5), .init(x: 1, y: 0.2),
		 .init(x: 0, y: 1), .init(x: 0.9, y: 1), .init(x: 1, y: 1)
	]
	
	let defaultTimeFrame = TimeInterval(60 * 60 * 24 * 7 * 4 * 6)
	let margin = 1.0
	
	var body: some View {
		VStack {
			Text("Deadline is at the symbol location on the timeline")
				.font(.caption)
			Divider()
			ZStack {
				MeshGradient(
					 width: 3,
					 height: 3,
					 points: positions,
					 colors: [
						  .purple, .red, .yellow,
						  .blue, .green, .orange,
						  .indigo, .teal, .cyan
					 ]
				)
				.overlay(.thickMaterial)
				Canvas { context, size in
					
					var origin = CGPoint(x: 0, y: 0)
					let text = Text("No courses to show").font(.title).bold()
					let resolved = context.resolve(text)
					var symbolHeight = min(size.height / CGFloat(deadlines.courses.count), 20.0)
					symbolHeight = resolved.measure(in: CGSize(width: size.width, height: 20.0)).height
					
					// TODO:
					// - Draw a pink background from date-when-becomes-hot to actual deadline date.
					// - Horizontal lines or a grid drawn at the background? Below course, separating courses better?
					// - What if the space is too small for all ongoing courses? Zoom or scroll?
					// - Check if looks cleaner without the grid/lines...
					
					let coursesToPlot = deadlines.ongoing.sorted(by: { $0.startDate < $1.startDate } )
					if coursesToPlot.isEmpty {
						// Draw info that there is no ongoing courses to show
						var textSize = size
						textSize = resolved.measure(in: size)
						origin.x = size.width / 2 - textSize.width / 2
						origin.y = size.height / 2 - textSize.height / 2
						let rect = CGRect(origin: origin, size: textSize)
						context.draw(resolved, in: rect)
					} else {
						let firstDate = (coursesToPlot.min(by: { $0.startDate < $1.startDate } )?.startDate ?? Date.now.addingTimeInterval(-defaultTimeFrame)).toPreviousMonday()
						let lastDate = coursesToPlot.max(by: { $0.endDate < $1.endDate } )?.endDate ?? Date.now.addingTimeInterval(defaultTimeFrame)
						let daysToShow = (abs(lastDate.timeIntervalSince(firstDate)) / 86400) + 4
						let dayWidth: CGFloat = size.width / daysToShow

						origin = .zero
						
						if Date.now > firstDate && Date.now < lastDate {
							let daysFromFirstDate = abs(firstDate.timeIntervalSince(Date.now)) / 86400
							origin.x += daysFromFirstDate * dayWidth
							let text = Text("Now").font(.caption)
							let resolved = context.resolve(text)
							let rect = CGRect(origin: CGPoint(x: origin.x, y: size.height - symbolHeight), size: CGSize(width: size.width, height: symbolHeight))
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
						
						origin = CGPoint(x: margin, y: margin)

						// Draw the ongoing courses
						coursesToPlot.forEach { course in
							let daysFromFirstDate = abs(firstDate.timeIntervalSince(course.startDate)) / 86400
							origin.x = daysFromFirstDate * dayWidth

							let image = Image(systemName: "arrowtriangle.right.square.fill")
							let resolvedImage = context.resolve(image)

							let text = Text("\(course.name) (\(course.startDate.formatted(date: .numeric, time: .omitted)))").font(.title2).bold().foregroundStyle(courseTextColor)
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
									
									// Specify deadline text and measure it
									let text = (Text(deadline.date.formatted(date: .abbreviated, time: .shortened)).font(.title2) + Text(" \(deadline.goal)").font(.title2)).foregroundStyle(deadline.color)
									let resolvedDeadlineText = context.resolve(text)
									var deadlineTextSize = size
									deadlineTextSize = resolvedDeadlineText.measure(in: deadlineTextSize)
									
									// Specify image to draw and measure it
									let daysFromFirstDateToDeadline = abs(firstDate.timeIntervalSince(deadline.date)) / 86400
									origin.x = daysFromFirstDateToDeadline * dayWidth
									let image = context.resolve(Image(systemName: deadline.symbol))
									// origin.x -= image.size.width + 2
																		
									// Draw the deadline image symbol
									context.draw(image, in: CGRect(origin: origin, size: image.size))
									
									// Draw the hotness indicator before the deadline
									var hotOrigin = CGPoint(x: origin.x, y: origin.y)
									hotOrigin.x -= dayWidth * CGFloat(deadline.becomesHotDaysBefore)
									hotOrigin.y += deadlineTextSize.height
									
									var hotnessPath = Path()
									hotnessPath.move(to: hotOrigin)
									hotnessPath.addLine(to: CGPoint(x: origin.x, y: origin.y + deadlineTextSize.height))
									context.stroke(hotnessPath, with: .color(Color(.red)), style: .init(lineWidth: 2, dash: [3,3]))
									
									// Adjust and draw the text of the deadline after or before the deadline symbol
									origin.x += image.size.width + 2
									rect = CGRect(origin: origin, size: CGSize(width: size.width, height: symbolHeight))
									let measuredSize = resolvedDeadlineText.measure(in: rect.size)
									if rect.origin.x + measuredSize.width > size.width {
										rect = rect.offsetBy(dx: -measuredSize.width - image.size.width , dy: 0)
									}
									context.draw(resolvedDeadlineText, in: rect)
									origin.y += symbolHeight + 6
								}
								origin.y += symbolHeight + 6
							}
							origin.y += symbolHeight + 6
						}
					}
				} // Canvas
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
