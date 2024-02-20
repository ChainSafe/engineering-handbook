---
sidebar_position: 3
---
# Reviewer Guide

The following guide for reviewers is mostly a condensed and customized version of [Google’s code review best practices](https://google.github.io/eng-practices/review/reviewer/). For additional context, we recommend reading the full guide, but here are the most important points.

## The goal of the code review

In general, reviewers should favor approving a code change request once it is in a state where it definitely improves the overall code health of the system being worked on, even if the code change isn’t perfect.

There is no such thing as “perfect” code — there is only better code. Reviewers should not require the author to polish every tiny piece, but rather reviewers should balance out the need to make forward progress compared to the importance of the changes they are suggesting.

Reviewers can always leave comments — nitpicking, preferences, or comments that teaches engineers something new — but they should prefix those comments with “nit:” (nitpicking) suggesting to authors that they can ignore such comments.

## Principles

- Technical facts and data overrule opinions and personal preferences.
- If there are a few equally valid options when it comes to software design, we should respect the author’s creativity.
- A style guide is an absolute authority. Then the current codebase. Then the author’s preference. More often than not, we will have an older codebase that is not aligned with our style guides. It is up to the team to decide the overall strategy when addressing such cases.

## What to look for in a code review

### Good things

If we see something nice in the code change request we should leave a comment. Code review is too focused on mistakes. If we encourage people when they do something good there is a higher chance they will repeat them. Don’t forget to add why you like it. Why is always important.

### Design

The most important thing to cover in a review is the overall design of the code change request and readability. Do the interactions of various pieces of code in the request make sense? Does this change belong in our codebase, or in a library?

Readability is even more important than DRY.

### Functionality

Does this code change do what the developer intended? Is what the developer intended good for the users of this code? The “users” are usually both end-users and developers (who will have to “use” this code in the future)

### Complexity

Is the code change more complex than it should be? We should check this at every level of the code change request — are individual lines too complex? Are functions too complex? “Too complex” usually means “can’t be understood quickly by code readers”. It can also mean that developers are likely to introduce bugs when they try to call or modify this code.

:::note
A particular type of complexity is **over-engineering**, where developers have made the code more generic than it needs to be, or added functionality that isn’t presently needed by the system. Reviewers should be especially vigilant about over-engineering.
:::

We should encourage engineers to solve the problem they know needs to be solved now, not the problem that the developer speculates might need to be solved in the future. The future problem should be solved once it arrives and we can see its actual shape and requirements in the physical universe.

If we can’t understand the code, it’s very likely that other developers won’t either! It is often that the code is too complex, not understanding the code and asking for clarification is the right thing to do.

### Naming

Did an engineer pick good names for everything? A good name is long enough to fully communicate what the item is or does, without being so long that it becomes hard to read.

### Comments

Are all the comments actually necessary? Usually, comments are useful when they explain why some code exists, and should not be explaining what some code is doing. The exceptions are regular expressions and hard-to-understand algorithms; ‘what’ is desirable with such code.

### Every line

In the general case, we should look at every human-written line of code that we have been assigned to review.  Obviously, some code deserves more careful scrutiny than other code, but we should at least be sure that we understand what all the code is doing.

### Context

Sometimes it is important to understand the underlying context. Often it's a good practice to pull code changes and check how they sit in the overall surroundings and files/structure.

## Navigating a code change request

We should always start with the main part of the code change request, the one that does the heavy lifting. This will give us a better context later when we start reviewing supporting and secondary changes.

If we see issues with the main part we should stop and send our comments immediately to the author. In fact, reviewing the rest of the request might be a waste of time, because if the design problems are significant enough, a lot of the other code under review is going to disappear and not matter anyway. This will also give an opportunity for engineers to start on any major re-work of the code change as soon as possible.

## Speed of the code review

### Why should code reviews be fast

Because the team is the most important! If code reviews are slow, few things will happen for sure:

- the author will start working on something else while waiting, and keep forgetting the context
- the author will finally get the reviewer’s feedback, but now he is in the middle of something else. Days will creep in.
- then the author will need to refresh his memory and address changes, making the reviewer forget about the context.
- the team will lose time and small cracks of frustration and unhappiness will appear in the team.

This is only worse if more reviewers are assigned. We will waste significant time on this context switching. It is a very inefficient process!

### How fast should code reviews be

If we are not in the middle of a focused task, we should do a code review shortly after it comes in.

One business day is the maximum time it should take to respond to a code review request (i.e., the first thing the next morning).

Following these guidelines means that a typical code change request should get multiple rounds of review (if needed) within a single day.

:::note
If we are in the middle of a focused task, such as writing code, we shouldn’t interrupt ourselves to do a code review. Instead, we should wait for a breakpoint in our work to respond to code change request.
:::

### Fast responses

When we talk about fast code reviews, we are mainly talking about the response time. We should take time when reviewing the actual code change request. We need to fully understand the code. Ideally, the whole process should be fast. Remember, the code change doesn’t have to be perfect!

:::note
If we are too busy to do a full review, we can still send a quick response that lets the developer know when we will get to it. Or we can suggest another reviewer! We should delegate, and don’t allow the code change request to sour for days.
:::

### Large code change requests

Are unacceptable and reviewers have the right to break the fast code review rule. Usually the way-to-go is to ask the author to split the code change into smaller requests (all branches should be branched from single/main branch for that feature). This way, all requests can be reviewed in a single day and when they're merged, the feature is complete and large code change is more-or-less already reviewed, so we only need to do a simple final check.

## How to write code review comments

### 3 magic questions we should always ask ourselves

Always:

1. is it kind
2. is it an absolute truth
3. is it necessary

### Courtesy

In general, it is important to be [courteous and respectful](https://chromium.googlesource.com/chromium/src/+/master/docs/cr_respect.md) while also being very clear and helpful to the developer whose code we are reviewing. One way to do this is to be sure that we are always making comments about the code and never making comments about the developer.

> Bad: “Why did you use threads here when there’s obviously no benefit to be gained from concurrency?”

> Good: “The concurrency model here is adding complexity to the system without any actual performance benefit that I can see. Because there’s no performance benefit, it’s best for this code to be single-threaded instead of using multiple threads.”

### Use I messages

We should always formulate our feedback from our point of view by expressing our personal thoughts, feelings, and impressions because it’s hard for the author to argue against our personal feelings since they are subjective.

> Wrong: “You are writing cryptic code.”

> Right: “It’s hard for me to grasp what’s going on in this code.”

### Explain why

One thing we can notice about the “good” example from above is that it helps the developer understand why we are making our comment.

### Giving guidance

In general, it is the developer’s responsibility to fix a code change request, not the reviewer’s. We are not required to do a detailed design of a solution or write code for the developer.

We should also respect the author’s creativity, meaning that we should point problems but refrain from giving exact solutions. It is not fun for the authors if somebody else is telling them how to do something. Only if the author is stuck, we should give more guidance.

### Accepting explanations

If we ask a developer to explain a piece of code that we don’t understand, that should usually result in them rewriting the code more clearly. Occasionally, adding a comment in the code is also an appropriate response, as long as it’s not just explaining overly complex code.

Explanations written only in the code review tool are not helpful to future code readers. Except in situations where we are unfamiliar with the code, and others are.

## Handling pushback in code reviews

### Who is right

When a developer disagrees with our suggestions, we should take a moment to consider if they are correct. Often, they are closer to the code than we are, so they might really have a better insight. If we still think that we are right, we should explain further why. We should just remember to be polite and mature.

### Cleaning it up later

Often, authors will ask if they can clean something later. In the following days, or next code change requests. This really depends on what your process looks like and how strict it is. If it is not strict, this will rarely happen. We should be cautious when approaching will-do-it-later actions.

## Resolving conversations

The reviewer who started the conversation must be the one who resolves it. **Nobody else** can resolve the conversation.

## References

https://google.github.io/eng-practices/review/reviewer/

https://phauer.com/2018/code-review-guidelines/#be-humble
