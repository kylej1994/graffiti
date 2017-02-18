# Feed Acceptance Tests

### Setting up the mock server:
`$ pip install Flask`

`$ cd server/mock`

`$ python __init__.py`

### Testing in Simulator
To run Graffiti in Simulator, click the play button in the top left. You can set your location in simulator:

`Debug > Location > Custom Location`

Then select choose whatever location you want. The mock server returns posts regardless of location.

#### Feed Layout
* When there are no posts for a given location, the feed displays a message that there are no posts.
* Each post in the feed shows how long ago it was posted
* Display rating
* Display default tag (profile picture)
* Display the post message
* With the mock server, there should be 10 posts, and they're all the same. They have all been upvoted.

#### Voting on Posts
* The vote buttons are colored to show how you voted on that post (ie: if you upvoted it, it is green)
* The upvote button turns green when you tap it to upvote
* If you tap the upvote button when you have already upvoted a post, the upvote is undone. The button turns black, and the rating decreases by 1.
* The downvote button turns red when you tap it to downvote
* If you tap the downvote button when you have already downvote a post, the vote is undone.
* If you downvote a post that you previously upvoted, the vote count decreases by 2 and the button turns read. The upvote button turns black.

### Refreshing the Feed
* pull down on the feed to refresh Posts
* For now, we do not support automatically refreshing the feed as the user moves. We expect users to pull to refresh to see if there are any new posts.
