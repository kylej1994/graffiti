Contributing to Graffiti
========================
The guide itself is open for contribution.  Nothing in here is universal law.  Just make a pull request. :wink:

If you need to get up to speed with git, [this](https://www.atlassian.com/git/tutorials/syncing) is a terrific guide.  Even if you know the basics, it's worth checking out at some point for the advance stuff.  It's the guide I use every time I forget how to rebase or revert. :sob:

Workflow
--------
1. create [**issue**](#issues)
2. create [**branch**](#branches) to implement/fix issue
3. create [**pull request**](#pull-requests) to merge branch

[This](https://guides.github.com/introduction/flow/) is a great overview.

Issues
------
The Github issue tracker is a huge resource so get [familiar](https://guides.github.com/features/issues/) with it.  Ideally, all features and bugs should be detailed in issues.

### Why

The biggest reason is that this provides an excellent **platform to discuss implementations**!

Also, it allows us to:

1. Assigned to team members
2. Referenced in other issues and pull requests
3. Organized with labels
4. Grouped in [Milestones](https://help.github.com/articles/about-milestones/)

Issues are great.

Branches
--------

```
graffiti
└── master
    └── dev
        └── [feature]
```

### Master Branch
The graffiti repo will have a master branch and many feature branches.  The master branch holds to canonical "master" copy of our code.

**You are not allowed to commit directly to master** *for the most part*

Instead, a feature branch should be forked off of master.  The change can be made in that feature branch.  When finished, a pull request to merge the brach back into master can be create to be reviewed.  For more information see  [Pull Request](#pull-requests).

### Dev Branch
As an extra layer of precaution, we will only be branching and merging to and from a dev branch.  We will then merge this dev branch with master at the end of iterations.  This will keep our master production ready.

### Feature Branches
In general, a feature should be a specific feature to implement or bug to fix.  If the feature is related to a specific issue, it is good practice to reference it in the branch name.  For example, if the new branch fixes issue #12, call it "issue12".

Pull Requests
-------------

### Work Flow:
1. Merge master into feature branch
2. Run tests
3. Create pull request to master
    * if the branch relates to specific issue [reference](https://github.com/blog/957-introducing-issue-mentions) it in the PR description
3. Assign a code reviewer from your team
    1. code reviewer comments
    2. implement changes/discuss
    3. repeat
4. reviewer (not **not** branch owner) confirms the merge

### Why
This forces every line of code to be:
1. reviewed
2. understood by at least two people

### Work in Progress Pull Requests
Sometimes it is nice to discuss an implementation before it is ready to be merged.

In that case, create a WIP (Work in Progress) Pull request so that you can get your code reviewed and commented on.  A WIP pull request is just a normal pull request with "WIP" in the title so people know it isn't ready to merge yet.

You can leave this PR open until you are ready to merge (it will continue to track your changes).  At which point, remove "WIP" from the title and alert a reviewer that it's ready.

Additional info
---------------
* [Great Git Guide](https://www.atlassian.com/git/tutorials/syncing)
* [Github Workflow](https://guides.github.com/introduction/flow/)
* [Github issues](https://guides.github.com/features/issues/)
* [Github pull requests](https://help.github.com/articles/about-pull-requests/)
