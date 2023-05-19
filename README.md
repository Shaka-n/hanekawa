# Hanekawa

A discord bot based on a series of jokes between friends. 

The bulk of the code can be found in lib/hanekawa. The app implements the Consumer/Surpervisor paradigm as defined by [Nostrum](https://github.com/Kraigie/nostrum). Nostrum itself is used as a wrapper for handling the WebSockets connection to the Discord Gateway API.

As of now there is one slash command implemented: `/movienight`. This has been broken out into the additional subcommands `schedule`, `reschedule`, `cancel`, and `next`. These correspond to their respective context functions in `lib/hanekawa/movie_nights.ex`. 

A user schedules a movie night by typing `/movienight schedule 1/30/23` in Discord, optionally providing a title for the movie. This persists a movie night record in the database. An Oban worker runs once a day at midnight to check if there is a movie night scheduled for that day. If there is, it will enqueue another Oban job to send a notification to the Discord channel later in the day (when users are awake).

The Phoenix/web elements are largely unused at the moment. The intention is to eventually provide a web UI for users to review commands and other data about their server. This is on hold for the time being, due to privacy concerns.

For a (perhaps overly) detailed account of my thought process as I worked on this, check out [my blog](https://shaka-n.github.io). Check out this post in particular to see my [project overview document](https://shaka-n.github.io/general/2023/05/15/developing-a-personal-project-part-3.html)