//
//  DeadlineErrors.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 15.10.2024.
//

import Foundation

enum DeadlineErrors: Error {
	case invalidDate(String)
	case fileDoesNotExist
	case fileSaveError
	case fileDeleteError(String)
}

extension DeadlineErrors: LocalizedError {
	var errorDescription: String? {
		switch self {
			case let .invalidDate(error: error):
				let errorString = NSLocalizedString("Date issue: %@", comment: "")
				return String(format: errorString, error)
			case .fileDoesNotExist:
				return NSLocalizedString("File does not exist, cannot read it.", comment: "When reading course deadline file")
			case .fileSaveError:
				return NSLocalizedString("Failed to save the course deadlines, please check app permissions.", comment: "When trying to save the deadline file")
			case let .fileDeleteError(error: errorCode):
				let errorString = NSLocalizedString("Could not delete the file: %@", comment: "")
				return String(format: errorString, errorCode)
		}
	}
}
