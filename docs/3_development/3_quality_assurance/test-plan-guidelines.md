# Test Plan Guidelines

A test plan is imperative for creating alignment on strategy and understanding of each team member’s role in the testing process. Every project should have an agreed upon test plan that documents how the software will be tested and how risks will be mitigated. 

The sections described below are applicable to most test plans and can be used as a guide.
 
---

### [Project Name] Test Plan

- Version: 1.0
- Author:
- Date updated: 

### Test objective:
- Write a brief summary of the overall test effort for the project

### Scope of testing definition:

- Add specific details on what will be tested and what types of tests they will be. For example, manual and/or automated
- For any automated tests please state what levels of the [test pyramid](https://martinfowler.com/articles/practical-test-pyramid.html#TheTestPyramid) they cover (Unit / Integration / Service / User Interface etc)

### Resources / Roles & Responsibilities:
- Outline all the people who will be involved with the testing effort and what their responsibility is within it
- If the test effort/acceptance testing is shared with a client make it explicitly clear here what that will entail (it's always best practice to not make any assumptions).

### Tools description:
Include details of the test tools that will be used.
Examples: 

- Bug tracking tool (eg GitHub issue)
- Test Case Management (eg Notion)
- Test Automation tools (eg Visual studio code)
- Programming languages
- Test Automation frameworks (eg Jest, Cypress)
- CI/CD tool (usually this would be GitHub actions)
- Version control (usually this would be GitHub)

### Deliverables:

- Outline anything that will be delivered at the end of the testing process. Examples: “test scenarios report”, "performance test results" “test case library”

### Test Environment & CI
- Add details here on where / when / how the tests are executed in CI
- List the environments required to run the tests (development, staging etc)

### Test Data:
- Add details outlining any data requirements for testing and details on how to setup/clear down after testing
- If any private/confidential data is involved include details on how this will be managed securely

### Bug template:
- Provide a link to the template or document what a bug issue needs to contain (eg environment, version, browser/device, reproduction steps, evidences)

### Risk & Issues:
- Outline any potential issues that could happen during the testing phase. 
- Declare any known risks issues that do not have a solution / include details here on any plans to mitigate known risks

