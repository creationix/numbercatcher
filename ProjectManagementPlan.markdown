# Project Management Plan
 
## TITLE PAGE (RC)

*TABLE OF CONTENTS*

*LIST OF FIGURES*

*LIST OF TABLES*

*EVIDENCE THE DOCUMENT HAS BEEN PLACED UNDER CONFIGURATION MANAGEMENT*

## ABSTRACT (RH)

 - brief summary of the plan

## INTRODUCTION (RC)

 - introduction to the entire plan
 - purpose and scope of the plan
 - brief overview of the product (including purpose, capabilities, scenarios for using the
product, etc)
 - description of the structure of the plan
 
## PROJECT ORGANIZATION (BT)

 - describe the way in which the development team is organized, the people involved, and
their roles on the project
 - include the rationale

## LIFECYCLE MODEL USED (BT)

 - describe the lifecycle model used
 - include the rationale

## RISK ANALYSIS (TN)

 - describe possible project risks, the likelihood of these risks arising, and the risk reduction
strategies that are proposed
 - include the rationale.

## HARDWARE AND SOFTWARE RESOURCE REQUIREMENTS (TC)

Given the constraints of this project, most importantly the fact that this needs to be a simple web accessible app that can be index by a google appliance, and our desire as students to learn cutting edge technologies, we have decided on the following technologies:

### Hosting

The app will be hosted on a [Linode][] VPS (Virtual Private Server).  This server will be running the latest [Ubuntu][] Linux in 32 bit mode.  This is an extremely common setup for small to medium websites, and will therefore be easy for Techtronix to deploy when the project is handed over to them.

### Back-end

The backend will be written in [Ruby 1.9][Ruby] using some popular framework.  Currently it's a choice between a [Sinatra][] backend with [RESTful][] resources added in or a stripped down [Rails][] app.  Both offer excellent community support and are easily installed on a stock linux server.

We'll be using [Sqlite3][] for the persistent data store.  This is a simple to use and very simple to deploy RDMS.  The backend of [Sqlite3][] doesn't even require a running daemon process.  It's simple a binary file on the hard-drive that is accessed via a [ruby library][sqlite3-ruby].  So from the application developer's point of view, it's a regular sql server that responds to the regular SQL commands and queries.  But from the system administrator's point of view, it's just a flat file and a [library][sqlite3-ruby] to install.  Performance is more than adequate for the use case of this software system.

### Source Control Management

Our source control will be done through [Git][].  [Git][] is a open source distributed version control system.  It's very popular in the [Ruby][] community and they even offer a free place to host your repositories.  We will host ours there at [Github][].  This allows for visual browsing of the code and documents.  Team members who are not yet comfortable with git can use the web interface to modify and commit changes directly.

### Front-end

The front-end will be served as pre-rendered html so that the google appliance can easily search and index it.  We will use [Less][] for [CSS][] and [HAML][] for the [XHTML][] generation.  We will probably use [jQuery][] for the [JavaScript][] framework.  The [XHTML][] generated will be semantically meaningful to give the most power to the Google engine.  All styling will be done through the [CSS][].

### Technology Summary

This closely models a traditional [Ruby][]/[Linux][Ubuntu] stack used in production websites throughout the world.  This benefits both Techtronix

[jQuery]: http://jquery.com/
[JavaScript]: http://en.wikipedia.org/wiki/JavaScript
[Linode]: http://www.linode.com/
[Ubuntu]: http://www.ubuntu.com/
[sqlite3-ruby]: http://sqlite-ruby.rubyforge.org/sqlite3/faq.html
[RESTful]: http://en.wikipedia.org/wiki/Representational_State_Transfer
[Sinatra]: http://www.sinatrarb.com/
[Rails]: http://rubyonrails.org/
[Sqlite3]: http://www.sqlite.org/
[XHTML]: http://www.w3schools.com/Xhtml/
[CSS]: http://www.w3.org/Style/CSS/
[Ruby]: http://www.ruby-lang.org/en/
[Git]: http://git-scm.com/
[Less]: http://lesscss.org/
[HAML]: http://haml-lang.com/
[Github]: http://github.com/creationix/numbercatcher/

## DELIVERABLES, SCHEDULE (RC)

 - describe the activities, dependencies between activities, the estimated time required to
reach each milestone, and the allocation of people to activities
 - include the rationale.

## MONITORING, REPORTING, AND CONTROLLING MECHANISMS (TN)

 - describe the management reports that should be produced, when these should be produced,
and the project monitoring and control mechanisms used
 - include the rationale

## PROFESSIONAL STANDARDS (RH)

 - describe the expected behavior of the team members related to scholastic dishonesty,
meeting schedule and quality expectations for tasks and deliverables. etc.
 - include the rationale

Included Appendix A:

The following provides a professional standards guideline for the teams. This guideline may be tailored. The professional standards must be agreed upon by each member in the team.

### Guideline:

On the first occurrence of unacceptable behavior, determine the circumstances involved, resolve the problem, and document the event in the meeting minutes.

On a second occurrence, notify the instructor of the problem. A meeting will be set up to evaluate the situation and resolve the problem.

On a third occurrence, again notify the instructor of the problem. A meeting will be set up to evaluate the situation and resolve the problem. At this point, the team will have the *option* of removing the team member. If removed, then the team member receives a pro-rated grade based on the number of weeks they have participated in the group.

Examples of unacceptable behavior may include not delivering on time, delivering poor quality work, missing team meetings, being unprepared for team meetings, disrespectful or rude behavior, etc. Reasons such as "too busy" or "I forgot", or "my dog ate my design model" are unacceptable.

Valid reasons that must be considered include those listed for obtaining an incomplete standing in a course (illness, death in the family, travel for business or academic reasons, etc.)

## REFERENCES (RC)

 - complete, correctly formatted using IEEE standard

