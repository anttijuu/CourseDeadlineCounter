//
//  Notifications.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 13.5.2025.
//

import OSLog
@preconcurrency import UserNotifications

struct Notifications {
	
	static let shared = Notifications()
	let log = Logger(subsystem: "com.anttijuustila.coursedeadlines", category: "notifications")
	
	func updateNotification(for deadline: Deadline, in course: Course) async {
		let center = UNUserNotificationCenter.current()
		let settings = await center.notificationSettings()

		// Verify the authorization status.
		guard (settings.authorizationStatus == .authorized) ||
				(settings.authorizationStatus == .provisional) else { return }

		if settings.alertSetting == .enabled {
			 // Schedule an alert-only notification.
		} else {
			 // Schedule a notification with a badge and sound.
		}
		let content = UNMutableNotificationContent()
		content.title = deadline.goal
		content.subtitle = NSLocalizedString("Course deadline is near", comment: "Alert about a course deadline approaching")
		content.body = course.name
		let alertDate = deadline.date.addingTimeInterval(TimeInterval(deadline.becomesHotDaysBefore - 24 * 60 * 60))
		var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: alertDate)
			
		let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
		let request = UNNotificationRequest(identifier: deadline.uuid.uuidString, content: content, trigger: trigger)
		
		// Schedule the request with the system.
		do {
			 try await center.add(request)
		} catch {
			log.error("Failed to schedule the notification for the deadline \(deadline.uuid): \(error)")
		}
	}
	
	func removeNotification(for deadline: Deadline) {
		let center = UNUserNotificationCenter.current()
		center.removePendingNotificationRequests(withIdentifiers: [deadline.uuid.uuidString])
	}
	
	func removeNotifications(for course: Course) {
		let deadlineIds = course.deadlines.map(\.self).map(\.uuid.uuidString)
		if !deadlineIds.isEmpty {
			let center = UNUserNotificationCenter.current()
			center.removePendingNotificationRequests(withIdentifiers: deadlineIds)
		}
	}

}
