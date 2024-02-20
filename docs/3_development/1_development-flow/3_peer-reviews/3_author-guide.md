---
sidebar_position: 3
---
# Author guide

The guide for authors is a mix of Google’s code review best practices and our own. We still recommend that you read Google’s [version](https://google.github.io/eng-practices/review/developer/).

## Communication

While platforms like GitHub allow selecting peer reviewers, additionally ask a teammate on the relevant team communication channel for a review. This ensures the request is clear and gives transparency to the rest of your team if commentary or considerations need to be made.

## Walkthroughs

Walkthroughs are peer programming for reviews. If possible or required, ask for a walkthrough within your team. If your teammate has the capacity, reviewing together allows you to share the context of your work with your reviewer.

## Requesting Reviews

If a project isn't setup with [codeowners](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/about-code-owners) when you open a code change request, and mark it ready for review, you'll need to get your peers to review it. Every repository should have two different GitHub teams added to it:
- `project_name-admins` 
  - This team is typically comprised of the project's administrative staff or senior developers who have overarching control and responsibilities over the repository. Members of this team are usually responsible for more critical aspects of the project, such as:
      - Approving or merging code change requests that may have significant implications on the project's direction or stability.
      - Managing access permissions for the repository, ensuring that contributors have the appropriate level of access according to their roles and responsibilities.
      - Configuring repository settings, including protection rules for branches, integration of CI/CD pipelines, and setting up or modifying codeowner rules.
      - Handling administrative tasks such as managing team memberships, resolving conflicts, and enforcing coding standards or guidelines.
  - Essentially, this team acts as the gatekeepers of the project, ensuring that changes align with the project's goals and maintain its integrity.
- `project_name`
  - This team usually consists of the regular contributors or developers working on the project. They may have varying levels of experience and responsibility, but all contribute to the development and progress of the project. The roles of this team typically involve:
    - Writing code, fixing bugs, and implementing new features or enhancements.
    - Reviewing code submitted by peers to ensure quality, consistency, and that it adheres to the project's coding standards.
    - Participating in discussions about the project's direction, design decisions, and potential improvements.
  - When a code change request is marked ready for review without specific codeowners set up, requesting a review from the project_name team allows the whole team to receive a notification. This practice encourages collective code review and collaboration, ensuring that multiple eyes review the changes before they are merged into the main codebase. It helps maintain code quality and fosters a collaborative team environment.

By structuring GitHub teams in this way, projects can benefit from clear separation of responsibilities, efficient management of access controls, and an inclusive environment where all team members are encouraged to participate in the review process.

## We are working on a feature, how to start

We should always start with the main part of the code change, the one that is the core of the whole feature.

**We might create a code change request immediately after we are comfortable with the main part to get early feedback.** We should just remember to explicitly describe such requests.

The alternative is highly inefficient where we build the entire feature only to find out that our foundation is wrong and consequently all the secondary code around that foundation is wasted.

We can still work on secondary code while the main feature is being reviewed because we must get the feedback in 1 business day.

## Small and focused code change requests

### Why write small code change requests

- Small code changes have a lower mental load. In contrast, large are heavy energy drainers.
- Reviewed more quickly. It’s easier for a reviewer to find five minutes several times to review small code changes than to set aside a 45+ minute block to review a large code change.
- Reviewed more thoroughly. With large changes, reviewers and authors tend to get frustrated by large volumes of detailed commentary shifting back and forth — sometimes to the point where important points get missed or dropped.
- Less likely to introduce bugs. Since we’re making fewer changes, it’s easier for us and our reviewer to reason effectively about the impact of the code change.
- Less wasted work if they are rejected. If we write a huge code change request and then our reviewer says that the overall direction is wrong, we’ve wasted a lot of work.
- Less blocking on reviews. Sending self-contained portions of our overall change allows us to continue coding while we wait for our current code change in review.

### What is small and focused

The right size for a code change request is one self-contained change. This means that:

- The code change makes a minimal change that addresses just one thing + tests. This is usually just one part of a feature, rather than a whole feature at once.
- The system will continue to work well for its users and for the developers after the code change request is checked in.
- The code change is not so small that its implications are difficult to understand. If we add a new API, we should include a usage of the API in the same code change request so that reviewers can better understand how the API will be used.

The right question to ask ourselves is: is this change related to this code change or can live on its own. If this can live on its own, we should address this in a separate code change request.

:::note
Keep in mind that although we have been intimately involved with our code, reviewers often have no context. What seems like an acceptably-sized code change to us might be **overwhelming to our reviewers**.
:::

### Separate out refactorings

Focused refactorings should always be a separate code change, containing only refactoring and nothing else! No fixes and features!

There are some cases where we find that refactoring makes sense along with a feature or a bugfix, but the resulting code change requests should be very small (e.g. if you can do both in less than 50 changed lines, that’s usually ok).

### When are large code changes okay

- Small changes across many files, like renaming a function or changing a contract
- Deletion
- Generated code
- Anything that we can scan easily

### Can’t make it small enough

Sometimes we will encounter situations where it seems like our code change has to be large. This is very rarely true. Authors who practice writing small code changes can almost always find a way to decompose functionality into a series of small changes.

Before writing a large code change, consider whether preceding it with a refactoring-only code change could pave the way for a cleaner implementation. 

:::note
If all of these options fail (which should be extremely rare) then get consent from your reviewers in advance to review a large code change, so they are warned about what is coming.
:::

## Before creating a code change request

We should check every line one more time. [Double-check](/development/development-flow/peer-reviews/reviewer-guide). JetBrains tools have a nice diff, or we can open a draft PR on GitHub and check everything there.

We can't emphasize more how important that is for the team. We shouldn't just throw out our code change request to reviewers as soon as we stop coding and hope for the best, but rather invest some time and see if we can improve anything. There is nothing more time-consuming for a team than millions of comments and code change rewrites.

## How to handle reviewer comments

### We should not take it personally

The goal of a review is to maintain the quality of our codebase and our products. When a reviewer provides a critique of your code, we should think of it as their attempt to help us, the codebase, and ChainSafe, rather than as a personal attack on us or our abilities.

:::note
We should **never respond in anger to code review comments.** That is a serious breach of professional etiquette that will live forever in the code review tool. Even if reviewers expressed their frustration first.
:::

### We should fix the code before commenting

If a reviewer says that they don’t understand something in our code, our first response should be to clarify the code itself! If the code can’t be clarified, we should add a code comment that explains why the code is there. If a comment seems pointless, only then should our response be an explanation in the code review tool.

### Authors can never ever resolve conversations

Only the original reviewer who wrote the comment can resolve the conversation.

### The proper way of addressing reviewers comments in commits

All the changes after the code review should go commit-by-commit and not in a single commit with a message “Addressed comments / PR changes / ...”. This way the reviewer can see what we did and why we did it.
Also, it'd be good to leave a link to the commit in the actual conversation.

This is better because reviewers know that we actually commit our changes. Emoji reactions and other comments don’t necessarily mean the author actually committed changes.

:::note
We should never ever introduce new code and refactorings (even moving code around) when addressing changes. Because this will just make it harder for reviewers to do their re-review. Remember that our target is to finish the re-review in a single day. Refactoring should be addressed in a new code change request.
:::

## When can we merge

We can merge only if all the conversations are resolved and all reviewers approve the code change request. In some cases, reviewers can approve without resolving comments, but the best practice here is for reviewers to resolve all the comments.

## References

https://google.github.io/eng-practices/review/developer/
