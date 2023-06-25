# README

# Team Details

---

### **Team Name:**

`SyncUp`

### **Proposed Level of Achievement:**

Apollo 11

# Project Details:

---

## What is `SyncUp` ?

`SyncUp` is a project management application that encourages a smoother collaborative experience - through seamless calendar API integration, it automatically uses calendar data to suggest the best meeting times within a group. This is made possible through the [calendar_v3 library.](https://pub.dev/documentation/googleapis/latest/calendar_v3/calendar_v3-library.html#classes)

## Project Poster:

![Imgur](https://i.imgur.com/PXl30FR.png)

## Design plans and reasoning:

![Imgur](https://i.imgur.com/QI6j8Vb.png))

*****Fig 1: We decided to make the UI as clean as possible, with only 4 main pages after logging into the app:***** 

1. **Homepage** (For convenient access of any feature in the app.
2. **Self calendar page** (For viewing personal events)
3. **Groups page** (For managing groups, viewing Group Event Calendars, and scheduling group events
4. **Account page** (For general settings)

![Imgur](https://i.imgur.com/XpEIaMR.png)

*Fig 2: The above diagram is a zoom-in on the initial design prototype for the general flow of group event creation in `SyncUp`:*

1. The user gives a few general details about the event such as name, duration, and selects a desired date range for the event to be held in.
2. The app performs the “Free-Slot-Finding” algorithm, by comparing it against the availabilities of the group members (which are automatically retrieved and synced with the members’ google calendars). It then lists out all the possible slots, along with the attendance rates listed at the side.
3. After a meeting is scheduled, invitation emails are sent out, and our app should indicate to the user whether or not they have accepted an invitation to a group event (which is scheduled on a ‘free’ time-slot of theirs.

## Main Features / Quick Walkthrough:

---

<img src="https://i.imgur.com/vbjYKLQ.png" width="400" />

- For Milestone 2, we have only worked with Google Calendar API, so it is best advised to Sign In With Google, otherwise the features would not work as expected.

<img src="https://i.imgur.com/ZYSgZ3C.jpg" width="400" />

- Allow access to calendar data when requested by Google API.

<img src="https://i.imgur.com/SCxT10z.png" width="400" />

- From the HomePage, use the navigation bar to navigate between pages.

<img src="https://i.imgur.com/sYYz54C.png" width="400" />

- The Personal Calendar page pulls events from Google Calendar and formats them accordingly based on the event data - events created using SyncUp will be in bright orange whereas personal events will be in blue.

<img src="https://i.imgur.com/HLcdzhb.png" width="400" />

- From the Groups page, users can create or add themselves to groups.

<img src="https://i.imgur.com/AsWmII7.png" width="400" />

- Within groups, users can schedule events. Only Group Events will be displayed on the group calendar page. A more comprehensive demonstration of event creation can be found in our video.

<img src="https://i.imgur.com/oNsiHa6.png" width="400" />

- In the account page, users can sign out or request calendar synchronization with Google. Please note that our MVP has only implemented integrations with Google Calendar API, so syncing will only work if you are signed in with a Google account and have granted SyncUp permissions to access and modify your calendar data.

*Note: For a more comprehensive demonstration, refer to our [video.](https://drive.google.com/file/d/10Npgv57ZQIYjrvMyE_42bKH9e9bbuplT/view?usp=drive_link)*

## Testing:

---

The main feature for testing is the "Free-Slot-Finding" algorithm that we have implemented.

A simple test of this algorithm is as follows:

**Objective: Schedule a meeting on 27th June, Tuesday between timothyleow12 and timothyleow14.**

| ![Imgur](https://i.imgur.com/53b6aZW.png) | ![Imgur](https://i.imgur.com/zXAspVs.png) |
| :--------------------------------------: | :--------------------------------------: |
|        timothyleow14's Availability       |        timothyleow12's Availability       |

- As we can see from the above, timothyleow14 has blocked out his time from 1430-1700, while timothyleow12 has blocked out his time from 0900-1330.
- The only common free timing they have is from 1330-1430 (assuming that their desired meeting hours are 0900-1700).

In the group with both of them, an event scheduling is initiated from timothyleow12@gmail.com:

| ![Imgur](https://i.imgur.com/ufz3z5M.png) | ![Imgur](https://i.imgur.com/dy1MHoT.png) |
| :--------------------------------------: | :--------------------------------------: |
|        Group Event Scheduling Page        |       Suggested Time Slot: 27th June      |

As expected, the app only suggests the time slot on 27th June for 1330-1430. This shows that `SyncUp` correctly performs the algorithm to only suggest common free timings of the users within the group.

## Installation Instructions

To install SyncUp, please follow these steps:

1. Download the SyncUp APK file from the following link: [SyncUp APK](https://docs.google.com/spreadsheets/d/1hUErlQk9Z9O3w8OTrkZnbDOMF9CEwYTc1YUPhqLF26E/edit?usp=drive_link).

2. Transfer the APK file to your Android device using any preferred method, such as email, USB cable, or cloud storage.

3. On your Android device, go to **Settings**.

4. Navigate to **Security** or **Privacy** (the exact location may vary depending on your device).

5. Enable the **Unknown Sources** option. This allows the installation of apps from sources other than the Google Play Store.

6. Use a file manager app to locate the transferred SyncUp APK file on your device.

7. Tap on the APK file to start the installation process.

8. Review the permissions required by the app and tap **Install** to proceed with the installation.

9. Wait for the installation to complete.

10. Once the installation is finished, you can open SyncUp from your app drawer and start using it to manage your schedules and collaborate with others effectively.

Note: It's important to exercise caution when installing APK files from external sources. Ensure that you trust the source and that the APK file hasn't been tampered with for security reasons.

# Motivation and Aim (Milestone 1 and before)

---

### **Motivation**

As university students, we understand the importance of collaboration when it comes to achieving academic success. However, the process of coordinating schedules with peers can be a major obstacle that often leads to frustration and wasted time. **The traditional method of coordinating schedules through multiple exchanges of texts and emails is not only time-consuming but also prone to errors and misunderstandings.**

Furthermore, the current situation of remote and hybrid learning has only added to the complexity of syncing up schedules. With students located in different time zones due to overseas exchanges, juggling different class schedules and extracurricular activities, finding a common meeting time has become an even greater challenge.

That's why our app is here to help. By providing a centralized platform for students to schedule and manage their meetings, the app streamlines the coordination process, reducing the time and effort required to find a suitable meeting time. With features like real-time availability updates and schedule-conflict management, students can quickly and easily find a time that works for everyone. Our app not only saves time but also promotes better communication among students, making the collaborative process hassle-free, be it for casual study groups, project groups, or even CCA interest groups.

### **Aim**

Our project aims to transform the way scheduling is done, making it a breeze for everyone involved. Our platform will also allow students from different faculties to have the opportunity to connect and collaborate on exciting projects together.

**User Stories**

1. Students will be able to form specialized groups with their friends, colleagues, or project members.
2. Within a group, through seamless calendar integration, our platform will generate a joint virtual calendar based on the group members' common availability. This will enable students to easily identify mutual availability with other individuals of interest and schedule meet-ups accordingly. The platform will also handle the polling of available time slots to make the process even smoother.
3. Students will be able to effortlessly network with others from different faculties and form groups on our platform. Our system allows groups to indicate their intention to recruit members of certain interests, making it easy for like-minded individuals to connect with each other.
4. Depending on the purpose of the group, there will be additional features such as shared to-do lists and file-sharing/real-time collaboration.
