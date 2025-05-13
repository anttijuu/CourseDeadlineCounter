# Course Deadlines

## What Is This?

Course Deadlines is a tool that instructors can use to make course deadlines more visible to students, keeping everybody aware of the deadlines, throughout the course implementation. Students may also use the same app, and add their own deadlines to the app also, for all the courses they are taking.

ℹ️ The app is localized to English and Finnish, most the screenshots in this document are in English. Language is selected automatically based on your Mac's language settings.

## And What For?

Course deadlines are usually announced at the introductory lecture of the course. Even though the deadlines are also in the materials and/or the course website, it sometimes may happen that when the deadline comes, there are some who are surprised that it "came so soon". The assignments are not even nearly ready, which causes issues in passing the courses and stressful situations.

This tool was built for teachers to show all the relevant course deadlines in one list. For example, when opening the weekly lecture, the teacher can share the app screen and remind the students about the upcoming deadlines as well as other later deadlines. Obviously, if a *student* wishes to use this tool for managing their own course deadlines, that is more than recommended.

The app notifies about the approaching deadlines, if user gives the permission to use alerts. For details on displaying the alert, see editing a deadline below.


## Functionality and User Interface

Some notes about the app with deadline examples seen below:

![App screenshot](images/mainview.png)

* On the left, there is a list of courses user has added.
  * You can add new courses using the button above the course list in the toolbar.
* You can switch between the courses you have added, using the list.
  * Both the mouse (trackpad) and keyboard navigation works.
* In the course details view on the right, deadlines for the selected course are sorted by the date, last one at the end.
* Past deadlines are shown in gray, future deadlines with default accent color, unless the conditions below apply:
  * Deadlines highlighted in red are *approaching soon*. 
  * Deadlines in orange and with the warning symbol, are directly impacting the course success, when they are missed.
    * If the deadline is missed, either the course is failed or missing it impacts the grade (to worse, obviously). See below for additional discussion on this.
* The symbol for the deadline is something you can specify yourself, using Apple's [SF symbols](https://developer.apple.com/sf-symbols/). See details below.
* Use the toolbar button on top to create a new course or add a new deadline to the course.
* To edit or delete a course or a deadline, select the row first, and then swipe right (to edit) or left (to delete) an item.
  * If your mouse does not support swiping, use the right button and a context menu will appear.
  * When deleting, confirmation is displayed first.

The app saves the course deadlines to the user's Document folder, in `Documents/CourseDeadlines`, each course stored in separate JSON file. This way, teacher or students can share the course deadlines easily among themselves. Just be aware that if the teacher makes changes to the deadlines after publishing the file, the updated file should be shared again.

Additional benefit of using JSON as the file format is that anyone can implement a similar app with any other language to whichever platform they prefer, supporting this file format.

> Note that the current version is not yet aware of new files added to the folder when the app is running. New files (courses) are listed only after application restart.
 

## Editing a course and adding deadlines

To add a new course, press the toolbar button above the course list and enter the course name and the starting date. The starting date is used to calculate how many percent of the course has been passed, relative to the last deadline of the course. After saving, you can edit the course details by swiping the course row to right:

![Edit course swiping](images/edit-course-swipe.png)

To move a course to the Trash, swipe to the left (confirmation will be asked before deletion):

![Edit course swiping](images/delete-course-swipe.png)

When you have added a new course, you may add new deadlines and/or edit them. Press the new deadline button (above the course details in the toolbar), and a new deadline is added to the list of deadlines. Then just edit the deadline details.


## Editing the deadlines 

Select the row in the course deadlines list, and then swipe right. You will see the edit deadline button:

![edit row](images/edit-deadline-swipe.png)

Press the edit button and you may then edit the details of the deadline:

![edit row](images/edit-deadline.png)

* Enter the symbol you wish to use for the deadline. Download the [SF symbols](https://developer.apple.com/sf-symbols/) app to view suitable symbols you would like to use with the deadline.
* Give a description, the goal of the deadline.
* Select the date and time for it.
* Specify how many days before the deadline it becomes highlighted ("hot"). This also determines when the alert for the deadline is shown.
* Use the checkbox to specify if the deadline is a "deal breaker"; that is if the student misses it, there are consequences. If you decide *all* deadlines are deal breakers, then just either ignore this setting or check this box for all deadlines in the course.

Then press the Save button, and you will have a new deadline for the course.

When saving the deadline, Mac will ask  for the permission (the first time) to display alerts. If the user allows this, the alert for the deadline is shown when it comes near:

![Deadline alert](images/deadline-notification.png)
 
If the deadline is set to, for example, Friday next week at 16:00 hrs, and the deadline becomes "hot" one day before the deadline, the alert is shown on Thursday next week at 16:00 hrs. No further alerts for the deadline are shown, unless the deadline is edited.

You may revoke or configure the notification permissions for the app using the macOS Settings app.

To delete a deadline, select the line and swipe to the left (confirmation will be asked before deletion):

![Edit course swiping](images/delete-deadline-swipe.png)

The notifications for the deadline are cancelled when deleting it. Also if you delete the course, all deadline notifications are cancelled.


## Planned Features

- [ ] Observing the folder where the course files are, in case user copies new files there from elsewhere, or edits a course file with a text editor. The course list can then be updated automatically, without the need to restart the app. Alternatively, add a refresh button but that is kind of blah.
- [ ] Share button to send the course.json file to someone.
- [ ] Selecting the deadline symbol from a list of (limited) options shown as icons instead of text (e.g. hammer, notepad, seal, person, person.2, graduationcap.fill,...).


## Contributing

If you find any bugs, please report them to me, either by using the GitHub Issues or send me a message, somehow. 

You may also fork the repo, create a branch, fix the bug, create an issue and then submit a pull request in GitHub from your branch, fixing the issue (or adding a feature).

## License

MIT License 

Copyright (c) 2024-2025 Antti Juustila

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
