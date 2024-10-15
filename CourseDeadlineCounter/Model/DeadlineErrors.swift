//
//  DeadlineErrors.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 15.10.2024.
//

import Foundation

enum DeadlineErrors: Error {
	case invalidDate
	case fileDoesNotExist
	case fileSaveError
}
