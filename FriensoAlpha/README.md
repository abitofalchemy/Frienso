Frienso
=======

Frienso iOS Alpha

Version History
---------------

* ver 1.6 build 77
    Tweaks to the Welcome View and this is the most solid version of Frienso we have to date.
    17Jul14/SA: Purged the Parse database, added checks to ensure that if an event is turned OFF
    locally, but its state on the cloud doesn't get flipped correctly, it retries and takes
    as ground truth the state on the phone of the user that triggers it.

* ver 1.5 build 76
    16Jul14/SA: Fixed issues with login and registering a new account; fixed problems with 
    synching an existing coreCircle; and made sure that the coreCircle is correctly updated/
    copied to the CoreData Friends/Contacts List.
    Tested behavior for WatchMe and HelpMe alerts!

    15Jul14/SA: Fixing the sync from parse using Udayan's code in Profile/Core Friends
    copyCoreCircleToCoreFriendsEntity is fixed to create and edit the core list more accurately

* ver 1.5 build 74

    14Jul14/SA New distribution build 

    13Jul14/SA: Behavior when HelpMeNow is triggered is now working, this means triggering a helpMeNow
    request shows a timer VC and after that can be canceled if needed, or if it times out PN are sent
    to CoreFriends, then if the user goes back to the home view, the user can choose to contact friends
    and or turn off the HelpMeNow alert/alarm.

    13Jul14/SA: Fixed the problem of a null phone number when contacting your friends in the
    FriensoQuickCircle VC.
* ver 1.5 build 71

    09Jul14/SA: Working redesign after HelpMeNow notifications are sent.
    10Jul14/SA: Need to make sure group SMS is working on the Help now vc

    25Jun14/SA: Minor tweaks to the Friens & Contacts list view, disclosure detail button
                    shows emergency contact ph#, tapping on the cell ask if you want to dial or SMS
                        
    25Jun14/SA: Removed the text from the Drawer to show if there are pending requests, now
                    it's just a dot that changes blue if pending requests and grayed out if 0 (Chad's
                    suggestion, which I like and wanted to do for a while now any way).


    25Jun14/SA: When a new user registers the coreCircle isn't available on the Friends
                    list, so I made sure that when the user hits to 'back' button to end the coreCircle
                    creation -- the friends are added to the CoreFriends entity in coredata.

    30Jun14/SA: Modified the welcome view that provides a brief introduction to the app
                    when first installed.
                    
    03Jun14/SA: Fixed the way the welcome view is integrated at installation time;
                    - {basic done} Adding more interaction to the mapview pins;
					

* ver 1.5 build 61  - Moved bubbles back to the mapView (but will only show one for a friend with an ongoing
                    alert/event)
                    - Added a fullscreen button to the mapView; button is toggling the mapview between default
                    and FS.
                    - Switched the Settings button with the WatchMe now button!
                    - Merged with Udayan's commits
                    - Added a pending requests drawer+slider 
                    - Added code to fetch a user (pfuser) and model pendingRequests, followed through to make
                    sure tha accepting a requests triggers the appropriate set of actions; currently we pick up
                    anyone with an ongoing watchMe request.
                    - Changed colum in Parse:Frienso:TrackRequest from RecepientsPh to RecipientPh
                    - Finished tracking requests of type 'WatchMe'
                    - {bug} Fixed a problem in the quick-coreFriends-view, there was an issue with nicknames being nil.
                    FriensoQuickCircle VC is now pulling unique names of friends that current user is Watching
                    - {bug} fixed problem with drawer not working on iPhone4
                    - {bug} fixed problem with frienso user with current event, if not in one's coreCircle, then do 
                    nothing with it.
                    - Fixed issue with one's ongoing event (WatchMe) not sticking, now it sticks if the user navigates
                    out of the app and returns, or kills it and reopens it, the bit will set the WatchMe switch ON
                    
                    - Feature: cached the university/campus emergency contacts on first install
                    - Fix: cache friends outside of your coreCircle; we query to see what users have a coreCircle
                    with our contact info in their coreCircle
                    - Feature: scroll up makes the table view go to fullscreen mode and a button at the top brings it
                    back to normal size and poistion.
                    
                    - 18Jun14/SA:  Fixed a problem with the WatchMe events crashing.
                    
                    - 19Jun14/SA:  Fixed problem: After accepting to 'Wactch' a coreFriend, reopening/
                    relaunching app was putting the user back in Watch request mode; now accepted requests
                    stick to the mapView
                    - Bypassing the coreFriendRequest (not working for me:Sal) to look at local corefriends
                    dictionary to determine list of friends to send watchMe requests.
                    
                    - 23Jun14/SA: Added a refresh button to the mapview & updates the pendingRequestsDrawer
                    (UI) and how it handles requests under diff. case scenarios (i.e. when a friend turns
                    Off or On their watchMe switch).

* ver 1.5 build 25  - Fixed minor issues with the Profile & CoreCircle views; redoing the way the user
                    logs in or registers!
                    - Fixed bugs related to the hidding of the bootom tool-bar
                    - Redesigned the way the login comes up and the way views go from welcome to the
                    homeview
                    - Added another view to handle status of your friends (core and other you watch)
                    - Currently, we can access their location on a map if location is available
                    - Fixed issue with duplicates when querying for a list of those uWatch (you in their
                    micro network)
                    - Fixed the way a new user registers and creates a CoreGroup (micro-Circle): changed the
                    navigation, so that it is under the control of the Home view (FriensoViewController).

* ver 1.5 build 21    Got rid of the Options/Watching list (it is now integrated in the CoreCircle list)
                    CoreCircle list now shows your CoreCircle and those uWatch.
                    Eliminated the icon to 'Chat' with friends, this is now available when you list the CoreCircle.
                    - {working} Interact with your CorCircle contacts
                    - {Fixed} the Resources view: when resource is already cached, don't allow to save it


* ver 1.5 build 19    Redesign of the Friends/Map view, added bubbles of your core-friends
                    Got SMS working when you list Those you are Watching

* ver 1.4 build 3.2   Added ability to save a resource (contact) and access it via the circle of Friends
                    button, we can decide where else to make this available.
                    -  Fixed the sections view in the CoreCircle viewcontroller
                    -  Fully logout and reset the local database now working 
                    -  Added a help view to the Home page (experimenting with this feature)
                    -  Fixed the 'Watching' (which we might want to rename to something like On Watch, 
                    or something) to click on these cells and engage in comm with them.

* ver 1.4 build 2.0   Adding resources view to Home View

* ver 1.4 build 1.0   New layout after input from team;

* ver 1.3 build 1.0   Updates to the friends list (coreData), we cache coreFriends location locally
                    When app is launched, the user's current location and his/her friends' are cached
                    Also when the user clicks on the quick-view of his/her circle, the user's current loc is updated
                    When the Map view is loaded, 1) the user's current location is update and the friends' locations are cached
                    Added *basic* event creation with local alarms
                    
* ver 1.2 build 1.0   Added location information @ user signup or login
                    Fixed issued when creating a new account and building your core friends group
                    Added Mapping of your core Friends
                    Added icon (working, not final)

* ver 1.1 build 1.1   Fixed issues with Setup Core Circle and Profile images
                    Fixed bug when you login and your already stored coreCircle of friends isn't fetched elegantly, now it's fetched and stored locally.
                    When a single core circle friend is updated, the whole set of core friends is correctly update in the cloud.
                    Connected the privacy policy and terms of use buttons to a web link that will host the document for now.

* ver 1.1 build 1.0   Fixes: Added more functionality to the Profile view; user can edit it.
                    Worked on the About view and have functionality working.
                    Settings View updated with more functionality working.


* ver 1.0 build 1.0   Initial release



Working On
----------
* SA: WatchMe switch triggers (internal alarms) and push notifications
      - Remind the user that this event is active (bring attention to an active state)

* SA: Managing and maintaining 'Requests'; at install accepting more than 1 causes problems & crash
      - Test case: 
* SA: QuickCircleVC fetch list of incoming Core Friend requests & add to Core Data

* SA: Fix bugs
        (1) fix detecting if WatchMe events come from a user in you friends list
        Future versions of this should be push-notifications driven

* NY: Push notifications for WatchMe and CoreFriend requests
* NY/SA:  Finish the PanicVC
* UK: Finishing the bubble actions on the mapviw (i.e. initiate phone call or SMS)
* UK/NY:  In app chatting with QuickBlocks

ToDo
----
* When a user initiates a HelpMeNow event the user should see the location of his/her
                    friends.  While it goes agains't the request/accept/reject theme these requests require
                    access one's network location to make the best decision/choices possible with all 
                    possible information available.
* {SA}{bug} 19Jun14/SA: Friends requests accept caused a crash
* {NY} Finish panic view controller
* Async update locations from cloud {??}
+Add Horizontal scroll for the Active users & the rest of your friends.

* {*** bug; created an issue to track this on GitHub} When user changes its core circle, we need only one record to be updated (not inserted or created new)

* {bug} When user sings in, if there are networking issues, the auto-sync which fetches the users stored coreFriends group is delayed (maybe even fails).  To fix this we could force a sync, else we could 
    retry until it succeeds, but then the user will have to wait.
    If a forced sync is done, we need cancel the auto attemps to sync
* Cache the coreF group current locations and show those until we can update them from cloud
    Try to make this work at searchviewcontroller or at FriensoQuickCircle
    ...

* Handle Parse time-outs
    Trap parse calls to the network - network outage
* Input validation for user profile editing
* Document the project's app development

Tasks Done / Project Log:
-------------------------
* {SA} Add alarm timer to AlertEvent {no longer needed}
* {done} Cache Univ Emergency Contacts from a separate Parse class
    - but not from another class, yet just from the Resources class in Parse
* {done} Cache Resources and update if new from Parse!

* {19Jun14/SA}
  ** {fixed} bugs Sal was working on: (2) {done} fix toolbar in Options View mode, the options view button should be removed from these views. (3) {done} 18Jun14/SA  MapView doesn't show a map (issue on GitHub)
  ** {done} {SA}{bug} Looking into WatchMe events causing  a crash
  ** {done} SA: 19Jun14/SA: Need to fix adding new bubbles to mapview should detect other bubbles already on it
  ** {done} * Add event creation -------------
  WatchMe:  {bug} check that Parse class UserEvent updates the eventType   
    Create a full event
    Go for a run, etc.
    {working} - added a button to top left of right bar button, need to connect it to an event generation
    VC
    {working} - basic notifications alert-views

* {SA} Complete code for pending requests of diff types: watch, helpNow, and coreFriend
  ** Maintain the type of alert as we track it
  ** WatchMe is now working with Cloud-store; 18Jun14 - watchme crashes at the dialog box
  ** Accept request works
  ** Reject request ...

* {done : 10Jun14/SA} Don't track users: {track only when user has an event going}
* Add fullscreen button to map
* { Done } * Test/review 'new user registration' process
* { Done } Don't duplicate User if it is in CoreGroup or in the UWatchGroup
* { Done } Fully logout
* When app is launched, the user's current location and his/her friends' are cached
  Also when the user clicks on the quick-view of his/her circle, the user's current loc is updated
  When the Map view is loaded, 1) the user's current location is update and the friends' locations are cached
* What to save to Parse when user changes profile? ***
* {done: Add Location info} and Map
  Make sure location is created if new or updated if existing
  Add map view to homeview
* Finish(or finished?) re-doing the coreCircleSetup
* Finished the about
* 01Apr14:SA Profile fully working
* Connect methods: - (void) privacyPolicyView  & - (void) termsOfUserView
* Add a License agreement online accessible and link to web doc
* When selecting a new core friend: upload to Parse Correctly
* Need to replace coreFriends as a whole or update Parse record(s) when edited.
* Added functionality to User Profile Editing
* { Done } Fix Edit button in Profile
* { Done } Fix database duplicates
* { Done } Verify to call the right password

Referenced Work
----------------
* Github
  ** https://help.github.com/articles/syncing-a-fork
* Fonts
* Images
  # http://wpwide.com/paris-france-birds-eye-view-sunshine-wide-hd-wallpaper/
  # http://dudye.com/futuristic-aerial-metro-station-in-miami
* Colors
    # http://ios7colors.com
    # flatuicolors.com
* Mapping
    # https://developer.apple.com/library/ios/samplecode/MapCallouts/Introduction/Intro.html
    # http://www.highoncoding.com/Articles/804_Introduction_to_MapKit_Framework_for_iPhone_Development.aspx
* icons
    # http://www.blog.montgomerie.net/iphone-images-from-character-glyphs
* style
    # http://www.cs.uakron.edu/~collard/cs489iOS/notes/IOSUITextKit.md
    # http://www.behance.net/gallery/16217291/7-v1-Mobile-UI-Kit
* other
    # http://stackoverflow.com/questions/10571786/how-to-update-existing-object-in-core-data/10572134#10572134
