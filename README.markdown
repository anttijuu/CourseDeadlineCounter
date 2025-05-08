# Course Deadlines

Course Deadlines is a tool that instructors can use to make course deadlines more visible to students, throughout the course implementation. Students may also use the same app, and add their own deadlines to the app also, for all the courses they are taking.

> The app is localized to English and Finnish, the screenshots in this document are in Finnish.

Many times it happens that deadlines are announced at the introductory lecture of the course. Even though the deadlines are also in the materials and/or the course website, it sometimes may happen that when the deadline comes, there are some who are surprised that it "came so soon" and the assignments are not even nearly ready.

This tool was built for teachers to show, in one small screen, all the relevant course deadlines. For example, in opening the weekly lecture, the teacher can share the app screen and remind the students about the upcoming deadlines as well as other later deadlines.

Some notes about the deadlines visible in the example below:

![App screenshot](screenshot.png)

* Deadlines are sorted by the date, nearest first.
* Deadlines highlighted in red are *approaching soon*. 
  * When entering the deadline to the course, you can specify how many days before the deadline becomes so important that it should be highlighed.
* Deadlines in orange and with the warning symbol are directly impacting the course success.
  * If the deadline is missed, either the course is failed or missing it impacts the grade (to worse, obviously).
* The symbol for the deadline is something you can specify yourself, using Apple's [SF symbols](https://developer.apple.com/sf-symbols/). See details below.
* You can switch between the courses you have entered, using the drop down list.

The app saves the course deadlines to the user's Document folder, in `Documents/CourseDeadlines`, each course stored in separate JSON file. This way, teacher or students can share the course deadlines easily among themselves. Just be aware that if the teacher makes changes to the deadlines after publishing the file, the updated file should be shared again.

Additional benefit of using JSON as the file format is that anyone can implement a similar app with any other language to whichever platform they prefer, supporting this file format.

## Adding or editing a course

Press the button on the screen, and enter the course name and the starting date. The starting date is used to calculate how many percent of the course has been passed, relative to the last deadline of the course.

When you have added a new course, you may add new deadlines and/or edit them. Press the New deadline button, select the row in the list, and swipe right. You will see the edit button:

![edit row](edit-row-screenshot.png)

Press it and you may then edit the details of the deadline:

![edit deadline](edit-deadline-screenshot.png)

* Enter the symbol you wish to use for the deadline. Download the [SF symbols](https://developer.apple.com/sf-symbols/) app to view suitable symbols you would like to use with the deadline.
* give a goal of the deadline, 
* the date and time for it,
* specify how many days before the deadline it becomes highlighted in red, and
* specify if the deadline is a deal breaker; that is if the student misses it, there are consequences.

Then press the Save button, and you will have a new deadline for the course.




