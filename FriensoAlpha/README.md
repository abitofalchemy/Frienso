Frienso
=======

Frienso iOS Nu

Version History
---------------
ver 1.4 build 3.1   Added ability to save a resource (contact) and access it via the circle of Friends
                    button, we can decide where else to make this available.
                    -  Fixed the sections view in the CoreCircle viewcontroller
                    -  Fully logout and reset the local database is working 
                    -  

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
* Add event creation
  Create a full event
    Go for a run, etc.
    {working} - added a button to top left of right bar button, need to connect it to an event generation
    VC
    {working} - basic notifications alert-views
    
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
* icons
    # http://www.blog.montgomerie.net/iphone-images-from-character-glyphs
* style
    # http://www.cs.uakron.edu/~collard/cs489iOS/notes/IOSUITextKit.md
* other
    # http://stackoverflow.com/questions/10571786/how-to-update-existing-object-in-core-data/10572134#10572134