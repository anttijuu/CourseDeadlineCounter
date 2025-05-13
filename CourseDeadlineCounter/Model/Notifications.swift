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
	
	func updateNotification(deadlineID: String, name: String, alertDate: Date, deadlineDate: Date, courseName: String) async {
		
		var alertDate = alertDate
		guard alertDate > Date.now || deadlineDate > Date.now else {
			log.info("Deadline is before now, not sending notifications for past deadlines")
			return
		}
		// If alert is in the past, then set the alert to one hour from now or 24 hrs before the deadline,
		// whichever is earlier.
		if alertDate < Date.now {
			alertDate = min(Date.now.addingTimeInterval(60*60), deadlineDate.addingTimeInterval(-86400))
		}
		
		log.debug("Initiating notification update for deadline \(name)")
		let center = UNUserNotificationCenter.current()
		
		// Authorization
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
		
		// Remove possible old pending notification requests for this deadline
		let pendingRequests = await center.pendingNotificationRequests().filter( { $0.identifier == deadlineID })
		if pendingRequests.count > 0 {
			log.debug("Removing \(pendingRequests.count) old notification requests for this deadline")
			center.removeDeliveredNotifications(withIdentifiers: pendingRequests.map(\.identifier))
		}
		
		let content = UNMutableNotificationContent()
		content.title = name
		content.subtitle = NSLocalizedString("Course deadline is near", comment: "Alert about a course deadline approaching")
		content.body = String(format: NSLocalizedString("Deadline in %@ is on %@)", comment:"Notification with course name and actual deadline date and time as string"), courseName, deadlineDate.formatted(date: .complete, time: .complete))
		let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: alertDate)
		let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
		let request = UNNotificationRequest(identifier: deadlineID, content: content, trigger: trigger)
		
		// Schedule the request with the system.
		do {
			log.debug("Adding a notification request for the deadline")
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
