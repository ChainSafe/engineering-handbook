---
sidebar_position: 3
---
# PR Reviews

:::note
Document everything, communicate with your team transparently, review together.
:::

## Documentation

- Ensure readability is retained in code e.g. complex nested ternary operators should have a comment note
- Ensure adequate testing exists where needed
- PRs include a summary of work which outlines the objectives, decisions & considerations for the PR. Examples:
    - This PR's objective was to implement middleware for logging, this was completed however presentation & storage of logs is incomplete pending discussion. Certain components are outside of the logging scope at the moment.
    - This PR includes minor styling tweaks on the desktop & mobile navigation menus, refactored navigation list logic.

## Communication

Ask a teammate on the relevant team channel for a review, this ensures the request is clear as well as gives transparency to the rest of your team if commentary or considerations need to be made.

## Walkthroughs

Walkthroughs is peer programming for reviews, if possible/required, ask for a walkthrough if your teammate has capacity, reviewing together allows you to share context to your work with your reviewer.

## Requesting Reviews

If a project isn't setup with [codeowners](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/about-code-owners) when you open a pull request, and mark it ready for review, you'll need to get your peers to review it. Every repository should have two different GitHub teams added to it (at minimum): `project_name-admins` and `project_name`, request the **non admin** team for review will allow your whole team to receive a notification about your new pull request.

## Changelog

Assuming your project has releases, and is continually making updates, the project will need a changelog. When submitting a pr make sure to update the changelog reflecting the changes that your PR is making. This way, when a new release is made, there is already a changelog ready to go and no extra work is needed.

## Reviewer guide

The guide for reviewers is mostly a condensed version of [Google’s code review best practices](https://google.github.io/eng-practices/review/reviewer/). Some parts are just c/p, some parts are emphasized, some things are left out, and some are added or are different.

### The goal of the code review

In general, reviewers should favor approving a PR once it is in a state where it definitely improves the overall code health of the system being worked on, even if the PR isn’t perfect.

There is no such thing as “perfect” code — there is only better code. Reviewers should not require the author to polish every tiny piece, but rather reviewers should balance out the need to make forward progress compared to the importance of the changes they are suggesting.

Reviewers can always leave comments — nitpicking, preferences, or comments that teaches engineers something new — but they should prefix those comments with “nit:” (nitpicking) suggesting to authors that they can ignore such comments.

### Principles

- Technical facts and data overrule opinions and personal preferences.
- If there are a few equally valid options when it comes to software design, we should respect the author’s creativity.
- A style guide is an absolute authority. Then the current codebase. Then the author’s preference. More often than not, we will have an older codebase that is not aligned with our style guides. It is up to the team to decide the overall strategy when addressing such cases.

### What to look for in a code review

#### Good things

If we see something nice in the PR we should leave a comment. Code review is too focused on mistakes. If we encourage people when they do something good there is a higher chance they will repeat them. Don’t forget to add why you like it. Why is always important.

#### Design

The most important thing to cover in a review is the overall design of the PR and readability. Do the interactions of various pieces of code in the PR make sense? Does this change belong in our codebase, or in a library?

Readability is even more important than DRY.

#### Functionality

Does this PR do what the developer intended? Is what the developer intended good for the users of this code? The “users” are usually both end-users and developers (who will have to “use” this code in the future)

#### Complexity

Is the PR more complex than it should be? We should check this at every level of the PR — are individual lines too complex? Are functions too complex? “Too complex” usually means “can’t be understood quickly by code readers”. It can also mean that developers are likely to introduce bugs when they try to call or modify this code.

📢 A particular type of complexity is **over-engineering**, where developers have made the code more generic than it needs to be, or added functionality that isn’t presently needed by the system. Reviewers should be especially vigilant about over-engineering.

We should encourage engineers to solve the problem they know needs to be solved now, not the problem that the developer speculates might need to be solved in the future. The future problem should be solved once it arrives and we can see its actual shape and requirements in the physical universe.

If we can’t understand the code, it’s very likely that other developers won’t either! It is often that the code is too complex, not understanding the code and asking for clarification is the right thing to do.

#### Naming

Did an engineer pick good names for everything? A good name is long enough to fully communicate what the item is or does, without being so long that it becomes hard to read.

#### Comments

Are all the comments actually necessary? Usually, comments are useful when they explain why some code exists, and should not be explaining what some code is doing. The exceptions are regular expressions and hard-to-understand algorithms; ‘what’ is desirable with such code.

#### Every line

In the general case, we should look at every human-written line of code that we have been assigned to review.  Obviously, some code deserves more careful scrutiny than other code, but we should at least be sure that we understand what all the code is doing.

#### Context

Sometimes it is important to understand the underlying context. I personally often pull PRs and check how changes sit in the overall surroundings and files/structure.

### Navigating a PR

We should always start with the main part of the PR, the one that does the heavy lifting. This will give us a better context later when we start reviewing supporting and secondary changes.

If we see issues with the main part we should stop and send our comments immediately to the author. In fact, reviewing the rest of the PR might be a waste of time, because if the design problems are significant enough, a lot of the other code under review is going to disappear and not matter anyway. This will also give an opportunity for engineers to start on any major re-work of the PR as soon as possible.

### Speed of the code review

#### Why should code reviews be fast

Because the team is the most important! If code reviews are slow, few things will happen for sure:

- the author will start working on something else while waiting, and keep forgetting the context
- the author will finally get the reviewer’s feedback, but now he is in the middle of something else. Days will creep in.
- then the author will need to refresh his memory and address changes, making the reviewer forget about the context.
- the team will lose time and small cracks of frustration and unhappiness will appear in the team.

This is only worse if more reviewers are assigned. We will waste significant time on this context switching. It is a very inefficient process!

#### How fast should code reviews be

If we are not in the middle of a focused task, we should do a code review shortly after it comes in.

One business day is the maximum time it should take to respond to a code review request (i.e., the first thing the next morning).

Following these guidelines means that a typical PR should get multiple rounds of review (if needed) within a single day.

📢 If we are in the middle of a focused task, such as writing code, we shouldn’t interrupt ourselves to do a code review. Instead, we should wait for a breakpoint in our work to respond to PR.

#### Fast responses

When we talk about fast code reviews, we are mainly talking about the response time. We should take time when reviewing the actual PR. We need to fully understand the code. Ideally, the whole process should be fast. Remember, the PR doesn’t have to be perfect!

📢 If we are too busy to do a full review, we can still send a quick response that lets the developer know when we will get to it. Or we can suggest another reviewer! We should delegate, and don’t allow PR to sour for days.

#### Large PRs

Are unacceptable and reviewers have the right to break the fast PR rule. Usually the way-to-go is to ask the author to split the PR into smaller PRs (all branches should be branched from single/main branch for that feature). This way, all PRs can be reviewed in a single day and when they're merged, the feature is complete and large PR is more-or-less already reviewed, so we only need to do a simple final check.

### How to write code review comments

#### 3 magic questions we should always ask ourselves

Always:

1. is it kind
2. is it an absolute truth
3. is it necessary

#### Courtesy

In general, it is important to be [courteous and respectful](https://chromium.googlesource.com/chromium/src/+/master/docs/cr_respect.md) while also being very clear and helpful to the developer whose code we are reviewing. One way to do this is to be sure that we are always making comments about the code and never making comments about the developer.

> Bad: “Why did you use threads here when there’s obviously no benefit to be gained from concurrency?”

> Good: “The concurrency model here is adding complexity to the system without any actual performance benefit that I can see. Because there’s no performance benefit, it’s best for this code to be single-threaded instead of using multiple threads.”

#### Use I messages

We should always formulate our feedback from our point of view by expressing our personal thoughts, feelings, and impressions because it’s hard for the author to argue against our personal feelings since they are subjective.

> Wrong: “You are writing cryptic code.”

> Right: “It’s hard for me to grasp what’s going on in this code.”

#### Explain why

One thing we can notice about the “good” example from above is that it helps the developer understand why we are making our comment.

#### Giving guidance

In general, it is the developer’s responsibility to fix a PR, not the reviewer’s. We are not required to do a detailed design of a solution or write code for the developer.

We should also respect the author’s creativity, meaning that we should point problems but refrain from giving exact solutions. It is not fun for the authors if somebody else is telling them how to do something. Only if the author is stuck, we should give more guidance.

#### Accepting explanations

If we ask a developer to explain a piece of code that we don’t understand, that should usually result in them rewriting the code more clearly. Occasionally, adding a comment in the code is also an appropriate response, as long as it’s not just explaining overly complex code.

Explanations written only in the code review tool are not helpful to future code readers. Except in situations where we are unfamiliar with the code, and others are.

### Handling pushback in code reviews

#### Who is right

When a developer disagrees with our suggestions, we should take a moment to consider if they are correct. Often, they are closer to the code than we are, so they might really have a better insight. If we still think that we are right, we should explain further why. We should just remember to be polite and mature.

#### Cleaning it up later

Often, authors will ask if they can clean something later. In the following days, or next PRs. This really depends on what your process looks like and how strict it is. If it is not strict, this will rarely happen. We should be cautious when approaching will-do-it-later actions.

### Resolving conversations

The reviewer who started the conversation must be the one who resolves it. **Nobody else** can resolve the conversation.

### References

https://google.github.io/eng-practices/review/reviewer/

https://phauer.com/2018/code-review-guidelines/#be-humble



## Author guide

The guide for authors is a mix of Google’s code review best practices and our own. We still recommend that you read Google’s [version](https://google.github.io/eng-practices/review/developer/).

### We are working on a feature, how to start

We should always start with the main part of the PR, the one that is the core of the whole feature.

**We might create a PR immediately after we are comfortable with the main part to get early feedback.** We should just remember to explicitly describe such requests.

The alternative is highly inefficient where we build the entire feature only to find out that our foundation is wrong and consequently all the secondary code around that foundation is wasted.

We can still work on secondary code while the main feature is being reviewed because we must get the feedback in 1 business day.

### Small and focused PRs

#### Why write small PRs

- Small PRs have a lower mental load. In contrast, large PRs are heavy energy drainers.
- Reviewed more quickly. It’s easier for a reviewer to find five minutes several times to review small PRs than to set aside a 45+ minute block to review one large PR.
- Reviewed more thoroughly. With large changes, reviewers and authors tend to get frustrated by large volumes of detailed commentary shifting back and forth — sometimes to the point where important points get missed or dropped.
- Less likely to introduce bugs. Since we’re making fewer changes, it’s easier for us and our reviewer to reason effectively about the impact of the PR.
- Less wasted work if they are rejected. If we write a huge PR and then our reviewer says that the overall direction is wrong, we’ve wasted a lot of work.
- Less blocking on reviews. Sending self-contained portions of our overall change allows us to continue coding while we wait for our current PR in review.

#### What is small and focused

The right size for a PR is one self-contained change. This means that:

- The PR makes a minimal change that addresses just one thing + tests. This is usually just one part of a feature, rather than a whole feature at once.
- The system will continue to work well for its users and for the developers after the PR is checked in.
- The PR is not so small that its implications are difficult to understand. If we add a new API, we should include a usage of the API in the same PR so that reviewers can better understand how the API will be used.

The right question to ask ourselves is: is this change related to this PR or can live on its own. If this can live on its own, we should address this in a separate PR.

📢 Keep in mind that although we have been intimately involved with our code, reviewers often have no context. What seems like an acceptably-sized PR to us might be **overwhelming to our reviewers**.

#### Separate out refactorings

Focused refactorings should always be a separate PR, containing only refactoring and nothing else! No fixes and features!

There are some cases where we find that refactoring makes sense along with a feature or a bugfix, but the resulting PRs should be very small (e.g. if you can do both in less than 50 changed lines, that’s usually ok).

#### When are large PRs okay

- Small changes across many files, like renaming a function or changing a contract
- Deletion
- Generated code
- Anything that we can scan easily

#### Can’t make it small enough

Sometimes we will encounter situations where it seems like our PR has to be large. This is very rarely true. Authors who practice writing small PRs can almost always find a way to decompose functionality into a series of small changes.

Before writing a large PR, consider whether preceding it with a refactoring-only PR could pave the way for a cleaner implementation. 

📢 If all of these options fail (which should be extremely rare) then get consent from your reviewers in advance to review a large PR, so they are warned about what is coming.

### Before creating a PR

We should check every line one more time. [Double-check](#reviewer-guide). JetBrains tools have a nice diff, or we can open a draft PR on GitHub and check everything there.

We can't emphasize more how important that is for the team. We shouldn't just throw out our PR to reviewers as soon as we stop coding and hope for the best, but rather invest some time and see if we can improve anything. There is nothing more time-consuming for a team than millions of comments and PR rewrites.

### How to handle reviewer comments

#### We should not take it personally

The goal of a review is to maintain the quality of our codebase and our products. When a reviewer provides a critique of your code, we should think of it as their attempt to help us, the codebase, and Chainsafe, rather than as a personal attack on us or our abilities.

📢 We should **never respond in anger to code review comments.** That is a serious breach of professional etiquette that will live forever in the code review tool. Even if reviewers expressed their frustration first.

#### We should fix the code before commenting

If a reviewer says that they don’t understand something in our code, our first response should be to clarify the code itself! If the code can’t be clarified, we should add a code comment that explains why the code is there. If a comment seems pointless, only then should our response be an explanation in the code review tool.

#### Authors can never ever resolve conversations

Only the original reviewer can resolve the conversation.

#### The proper way of addressing reviewers comments in commits

All the changes after the code review should go commit-by-commit and not in a single commit with a message “Addressed comments / PR changes / ...”. This way the reviewer can see what we did and why we did it.
Also, it'd be good to leave a link to the commit in the actual conversation.

This is better because reviewers know that we actually commit our changes. Emoji reactions and other comments don’t necessarily mean the author actually committed changes.

📢 We should never ever introduce new code and refactorings (even moving code around) when addressing changes. Because this will just make it harder for reviewers to do their re-review. Remember that our target is to finish the re-review in a single day. Refactoring should be addressed in a new PR.

### When can we merge

We can merge only if all the conversations are resolved and all reviewers approve the PR. In some cases, reviewers can approve without resolving comments, but the best practice here is for reviewers to resolve all the comments.

### References

https://google.github.io/eng-practices/review/developer/
