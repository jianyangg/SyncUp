# README

# Team Details

---

### **Team Name:**

SyncUp 

### **Proposed Level of Achievement:**

Apollo 11

# Project Details:

---

## What is `SyncUp` ?

`SyncUp` is a project management application that encourages a smoother collaborative experience - through seamless calendar API integration, it automatically uses calendar data to suggest the best meeting times within a group. This is made possible through the [calendar_v3 library.](https://pub.dev/documentation/googleapis/latest/calendar_v3/calendar_v3-library.html#classes)

## Project Poster:

![Imgur](https://i.imgur.com/PXl30FR.png)

## Design plans and reasoning:

![Untitled](README%20b3b1cd45bde546b1949daffc7e3180eb/Untitled.png)

*****Fig 1: We decided to make the UI as clean as possible, with only 4 main pages after logging into the app:***** 

1. **Homepage** (For convenient access of any feature in the app.
2. **Self calendar page** (For viewing personal events)
3. **Groups page** (For managing groups, viewing Group Event Calendars, and scheduling group events
4. **Account page** (For general settings)

![Untitled](README%20b3b1cd45bde546b1949daffc7e3180eb/Untitled%201.png)

*Fig 2: The above diagram is a zoom-in on the initial design prototype for the general flow of group event creation in `SyncUp`:*

1. The user gives a few general details about the event such as name, duration, and selects a desired date range for the event to be held in.
2. The app performs the “Free-Slot-Finding” algorithm, by comparing it against the availabilities of the group members (which are automatically retrieved and synced with the members’ google calendars). It then lists out all the possible slots, along with the attendance rates listed at the side.
3. After a meeting is scheduled, invitation emails are sent out, and our app should indicate to the user whether or not they have accepted an invitation to a group event (which is scheduled on a ‘free’ time-slot of theirs.

## Main Features / Quick Walkthrough:

---

![Untitled](README%20b3b1cd45bde546b1949daffc7e3180eb/Untitled%202.png)

- For Milestone 2, we have only worked with Google Calendar API, so it is best advised to Sign In With Google, otherwise the features would not work as expected.

![Untitled](README%20b3b1cd45bde546b1949daffc7e3180eb/Untitled%201.jpeg)

- Allow access to calendar data when requested by google api.

![Untitled](README%20b3b1cd45bde546b1949daffc7e3180eb/Untitled%203.png)

- From the HomePage, use the navigation bar to navigate between pages.

![Untitled](README%20b3b1cd45bde546b1949daffc7e3180eb/Untitled%204.png)

- The Personal Calendar page pulls events from google calendar and formats them accordingly based on the event data - events created using SyncUp will be in bright orange whereas personal events will be in blue.

![Untitled](README%20b3b1cd45bde546b1949daffc7e3180eb/Untitled%205.png)

- From the Groups page, users can create or add themselves to groups.

![Untitled](README%20b3b1cd45bde546b1949daffc7e3180eb/Untitled%206.png)

- Within groups, users can schedule for events. Only Group Events will be displayed in the group calendar page. A more comprehensive demonstration for event creation can be found in our video.

![Untitled](README%20b3b1cd45bde546b1949daffc7e3180eb/Untitled%207.png)

- For now, in the account page, users can sign out, or request for a calendar synchronisation with google. As mentioned earlier, our MVP has only implemented integrations with google calendar API, so the syncing will only work if you are signed in with a google account, and have allowed SyncUp permissions to access and modify your calendar data.

*Note: for a more comprehensive demonstration, refer to our [video.](https://drive.google.com/file/d/10Npgv57ZQIYjrvMyE_42bKH9e9bbuplT/view?usp=drive_link)*

## Testing:

---

The main feature for testing is the “Free-Slot-Finding” algorithm that we have implemented.

A simple test of this algorithm is as follows:

**Objective: Schedule a meeting on 27th June, Tuesday between timothyleow12 and timothyleow14.**

![Untitled](README%20b3b1cd45bde546b1949daffc7e3180eb/Untitled%208.png)

![Untitled](README%20b3b1cd45bde546b1949daffc7e3180eb/Untitled%209.png)

- As we can see from the above, timothyleow14 has blocked out his time from 1430-1700, while timothyleow12 has blocked out his time from 0900-1330.
- The only common free timing they have is from 1330-1430 (Assuming that their desired meeting hours is 0900-1700).

In the group with 2 of them, an event scheduling is initiated from timothyleow12@gmail.com:

![Untitled](README%20b3b1cd45bde546b1949daffc7e3180eb/Untitled%2010.png)

![Untitled](README%20b3b1cd45bde546b1949daffc7e3180eb/Untitled%2011.png)

As expected, the app only suggests the time-slot on 27th June for 1330-1430. This shows that our app performs the algorithm correctly to only suggest common free timings of the users within the group.

# Motivation and Aim (from project proposal)

---

### **Motivation**

As university students, we understand the importance of collaboration when it comes to achieving academic success. However, the process of coordinating schedules with peers can be a major obstacle that often leads to frustration and wasted time. **The traditional method of coordinating schedules through multiple exchanges of texts and emails is not only time-consuming but also prone to errors and misunderstandings.**

Furthermore, the current situation of remote and hybrid learning has only added to the complexity of syncing up schedules. With students located in different time zones due to overseas exchanges, juggling different class schedules and extracurricular activities, finding a common meeting time has become an even greater challenge.

That's why our app is here to help. By providing a centralized platform for students to schedule and manage their meetings, the app streamlines the coordination process, reducing the time and effort required to find a suitable meeting time. With features like real-time availability updates and schedule-conflict management, students can quickly and easily find a time that works for everyone. Our app not only saves time but also promotes better communication among students, making the collaborative process hassle-free, be it for casual study groups, project groups, or even CCA interest groups.

### **Aim**

Our project aims to transform the way scheduling is done, making it a breeze for everyone involved. Our platform will also allow students from different faculties to have the opportunity to connect and collaborate on exciting projects together.

**User Stories**

1. Students will be able to form specialised groups with their friends, colleagues for project members.
2. Within a group, through seamless calendar integration, our platform will generate a joint virtual calendar based on the group members’ common availability. This will enable students to easily identify mutual availability with other individuals of interest and schedule meet-ups accordingly. The platform will also handle the polling of available time slots to make the process even smoother.
3. Students will be able to effortlessly network with others from different faculties and form groups on our platform. Our system allows groups to indicate their intention of recruiting members of certain interests, making it easy for like-minded individuals to connect with each other.
4. Depending on the purpose of the group, there will be additional features such as shared to-do lists and file-sharing/real-time collaboration.
