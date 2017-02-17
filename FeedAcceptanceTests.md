# Feed Acceptance Tests

### Testing in Simulator
To run Graffiti in Simulator, click the play button in the top left. You need to set your location in simulator:

`Debug > Location > Custom Location`

Then select custom location and set the latitude to `todo` and longitude to `todo`

#### Feed Layout
* When there are no posts for a given location, the feed displays a message that there are no posts.
* Each post in the feed shows how long ago it was posted
* Display rating
* Display default tag (profile picture)
* Display the post message

#### Voting on Posts
* The upvote button turns green when you tap it to upvote
* If you tap the upvote button when you have already upvoted a post, the vote is ignored
* The downvote button turns red when you tap it to downvote
* If you tap the downvote button when you have already downvote a post, the vote is ignored

### Refreshing the Feed
* pull down on the feed to refresh Posts
* For now, we do not support automatically refreshing the feed as the user moves. We expect users to pull to refresh to see if there are any new posts.
