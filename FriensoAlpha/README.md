Frienso
=======

Frienso iOS Alpha

Version History
---------------

ver 1.5 build 25    - Fixed minor issues with the Profile & CoreCircle views; redoing the way the user
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

ver 1.5 build 21    Got rid of the Options/Watching list (it is now integrated in the CoreCircle list)
                    CoreCircle list now shows your CoreCircle and those uWatch.
                    Eliminated the icon to 'Chat' with friends, this is now available when you list the CoreCircle.
                    - {working} Interact with your CorCircle contacts
                    - {Fixed} the Resources view: when resource is already cached, don't allow to save it


ver 1.5 build 19    Redesign of the Friends/Map view, added bubbles of your core-friends
                    Got SMS working when you list Those you are Watching

ver 1.4 build 3.2   Added ability to save a resource (contact) and access it via the circle of Friends
                    button, we can decide where else to make this available.
                    -  Fixed the sections view in the CoreCircle viewcontroller
                    -  Fully logout and reset the local database now working 
                    -  Added a help view to the Home page (experimenting with this feature)
                    -  Fixed the 'Watching' (which we might want to rename to something like On Watch, 
                    or something) to click on these cells and engage in comm with them.

ver 1.4 build 2.0   Adding resources view to Home View

ver 1.4 build 1.0   New layout after input from team;

ver 1.3 build 1.0   Updates to the friends list (coreData), we cache coreFriends location locally
                    When app is launched, the user's current location and his/her friends' are cached
                    Also when the user clicks on the quick-view of his/her circle, the user's current loc is updated
                    When the Map view is loaded, 1) the user's current location is update and the friends' locations are cached
                    Added *basic* event creation with local alarms
                    
ver 1.2 build 1.0   Added location information @ user signup or login
                    Fixed issued when creating a new account and building your core friends group
                    Added Mapping of your core Friends
                    Added icon (working, not final)

ver 1.1 build 1.1   Fixed issues with Setup Core Circle and Profile images
                    Fixed bug when you login and your already stored coreCircle of friends isn't fetched elegantly, now it's fetched and stored locally.
                    When a single core circle friend is updated, the whole set of core friends is correctly update in the cloud.
                    Connected the privacy policy and terms of use buttons to a web link that will host the document for now.

ver 1.1 build 1.0   Fixes: Added more functionality to the Profile view; user can edit it.
                    Worked on the About view and have functionality working.
                    Settings View updated with more functionality working.


ver 1.0 build 1.0   Initial release





ToDo
----
* Add alarm timer to AlertEvent 
* Cache Univ Emergency Contacts from a separate Parse class
* Don't track users: {track only when user has an event going}
* Async update locations from cloud
+Add fullscreen button to map
+Add Horizontal scroll for the Active users & the rest of your friends.

* Add event creation -------------
  Create a full event
    Go for a run, etc.
    {working} - added a button to top left of right bar button, need to connect it to an event generation
    VC
    {working} - basic notifications alert-views

* {bug} When user changes its core circle, we need only one record to be updated (not inserted or created new)

* {bug} When user sings in, if there are networking issues, the auto-sync which fetches the users stored coreFriends group is delayed (maybe even fails).  To fix this we could force a sync, else we could 
    retry until it succeeds, but then the user will have to wait.
    If a forced sync is done, we need cancel the auto attemps to sync
* Cache the coreF group current locations and show those until we can update them from cloud
    Try to make this work at searchviewcontroller or at FriensoQuickCircle
    ...
* Cache Resources and update if new from Parse!



* Handle Parse time-outs
    Trap parse calls to the network - network outage
* Input validation for user profile editing


Tasks Done / Project Log:
-------------------------
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