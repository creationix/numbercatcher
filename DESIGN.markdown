Ask about complex types like IP address
Ask about disable flags for users and groups
Ask about activity tracking
Ask about set range history
Ask about separate username, name, and email or all in one
Ask about certain groups not being visible to certain users
Ask about "Forgot your password" feature





Notes from first presentation:

 - They like traditional OO concepts with nouns for classes, proper inheritance usage, polymorphism.
 - Interested in "team" concept. (Currently they're moving to agile methods and so it's in flux)
 - Interested in LDAP plugin.  A good design should make this easy.
 








Models - These are the main tables in the database and the model classes.  There may be more support tables for the many-to-many relationships, but this should be all the entities in the system. We'll want an ERD diagram of all the database tables as well as UML diagrams for all the models.

  user - Individual login
    user_id
    name
    password
    email
    is_admin
  
  set - A group of numbers (IE port numbers on machine A)
    id
    name
    type
  
  sequence - A range for a NumberSet
    number_set_id - Foreign key to NumberSet
    min
    max
  
  reservation - A single reserved number
    number_set_id
    number
    user_id
  
  log - A log of all activity
    id
    action
    timestamp
    note
    owner_id
    operator_id
    set_id
    number

Views - I'll draw mockups for these using Balsamic Mockup.  This will help everyone see the structure of the system.
  Layout
    ui theme
    footer with legal text, copyright, help link, etc

  Header - On every page except for the login screen
    Username/group of logged in user
    breadcrumbs of activity history.  This will show the current location in the hierarchy of the numbers.  Clicking a link will backup to that point.
      Index(SetListing)
      Index(SetListing) -> Number Set
      Index(SetListing) -> Number Set -> Number Details

  LoginScreen
    large logo
    form
      username - text field
      password - password field
      login - submit button
      
  SetListing - This page shows a listing of all sets along with some aggregate information like number of reserved numbers, the number type, and  the total number in the range.  This would allow for a quick scan to see that a particular machine is running out of free ports without running the report for each set. Also this page would be navigation for the rest of the system.  There should be a logout button somewhere and a link somewhere on each line to enter that set
  
  SetPage - This page shows detailed information about a single set of numbers.  It will show the type and the ranges of available numbers.  Also it will have a search form and listing of all reserved numbers for it.  There will be links on each line to the NumberPage for that number.
  
  NumberPage - This page shows details for a single number.  Here a person will be able to reserve the number, an admin can override it.
  
  Logging - All three levels of pages will have an optional log of activity at the bottom of the page.  The log will be filtered to only show activity for that page.  This should probably be ajaxed in on demand, and paginated some how.
  
  UserManagementPage - This page will show a listing of all users.  Admins will use this page to create new users and delete existing users as well as edit existing accounts.
  
  UserPage - This page shows information about a user's account.  Here they can change their name, password, and view logs specific to them.  Also will be a listing of all the numbers they have reserved.
  
  HelpPage - This page will show some basic documentation about how to use the site.  There will be a link to it on the bottom of every page.  We can either make the content context sensitive to the page being shown, or just have a single page of docs that we show on every page the same.
  
  CSV export.  Every table will have a csv export icon next to it.  This will be true for all the listings and the log listings.

Controllers - sequence diagrams, Controller classes.  There should be a controller for each of the 7 pages with public methods to handle all incoming http requests and optionally private helper methods

  Login
    validate form (username, password)
      validates with database and either assigns session or returns to login screen with error message
      
  Logout - This action if called from the logout button on any internal page.  It invalidates the user session and redirects to the login page

  We need to define the actions of all the controllers (basically all the points in which the html page will make requests to the server.)  This includes loading of all pages, csv generation of any table, and the ajax for the on-demand log viewing.
      
  ...

Flesh out use cases - We need to find all the possible paths a user can take through the system and document them properly.

Draw sequence diagrams of the use cases.
