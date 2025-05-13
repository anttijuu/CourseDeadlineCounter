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
	
	func updateNotification(deadlineID: String, name: String, date: Date, courseName: String) async {
		log.debug("Initiating notification update for deadline \(name)")
		let center = UNUserNotificationCenter.current()
		
		do {
			if try await center.requestAuthorization(options: [.alert, .badge, .sound]) == true {
				log.info("Has authorization for notifications")
			} else {
				return
			}
		} catch {
			log.error("Error in requesting authorization: \(error)")
			return
		}
		
		let settings = await center.notificationSettings()

		// Verify the authorization status.
		guard (settings.authorizationStatus == .authorized) ||
					(settings.authorizationStatus == .provisional) else {
			log.info("Not authorized to create notifications!")
			return
		}

		if settings.alertSetting == .enabled {
			log.debug("Alerts enabled")
		} else {
			 // Schedule a notification with a badge and sound.
			log.debug("Alert badge and sound enabled (?)")
		}
		let content = UNMutableNotificationContent()
		content.title = name
		content.subtitle = NSLocalizedString("Course deadline is near", comment: "Alert about a course deadline approaching")
		content.body = courseName
		let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
			
		let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
		let request = UNNotificationRequest(identifier: deadlineID, content: content, trigger: trigger)
		
		// Schedule the request with the system.
		do {
			 try await center.add(request)
		} catch {
			log.error("Failed to schedule the notification for the deadline \(deadlineID): \(error)")
		}
	}
	
	func removeNotification(for deadline: Deadline) {
		log.debug("Starting to remove a notification for deadline \(deadline.goal)")
		let center = UNUserNotificationCenter.current()
		center.removePendingNotificationRequests(withIdentifiers: [deadline.uuid.uuidString])
	}
	
	func removeNotifications(for course: Course) {
		let deadlineIds = course.deadlines.map(\.self).map(\.uuid.uuidString)
		if !deadlineIds.isEmpty {
			log.debug("Starting to remove a notifications for course \(course.name)")
			let center = UNUserNotificationCenter.current()
			center.removePendingNotificationRequests(withIdentifiers: deadlineIds)
		}
	}

}
