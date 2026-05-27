# Manual Test Case Guidelines

A manual test case is a set of actions that can be followed to prove the validity of a known requirement. They are most commonly used to ascertain that a piece of functionality is working correctly but can also be tied to validating other requirements from a product's various stakeholders. 

The most important purpose of the test case is to provide instruction on how to put something into a testable state and to provide clear criteria that help definitively determine whether that state passes or fails the expectation. By having a repeatable collection of test cases, that you know when to reference and execute, you can reduce uncertainty, risk and increase efficiency in your project. 

The test cases are "living documentation" in the sense that they need to be updated alongside the product as it evolves. They can also become the blueprint of future automated tests. 
 
---

:::note
In smaller scope or more focused situations, for instance validating operations of a dApp, it may be possible to simply reference and validate a list of "User scenarios". These describe a very specific high level action / flow that a user can make. The scenario title itself is usually descriptive enough to not need to know further steps. 

It is best to choose test cases for managing your validation when the complexity is high, there's multiple systems or components, specific environmental factors to consider, and / or there's specific test data to be used.
:::


### Test Suites 

Once a library of test cases has been created you have the ability to create collections comprised of specific test cases.  A collection of test cases is known as a test suite. 

The amount of test suites you need to have is completely dependent on the needs of the product or project. You may want to execute a different set of test cases at different points in time. For example you may want to create smaller "smoke" test suites comprised of only critical functionality that you use post deployment as a sanity check or you may want to execute the entirety of the test cases together as a fully exhaustive "regression" test prior to release.  

### How to start

If you are unsure where to begin writing your first test case you can follow the pattern below to help narrow your focus

- Breakdown the application or system into logical components such as Smart Contracts / Backend, SDK, Desktop UI, Mobile UI etc. 
- Underneath each component list it's major features
- Prioritize which components or features hold the most importance
- Underneath each feature create a list of the specific requirements
- Now think of which product states will help validate those specific requirements and start designing testable scenarios around them. 

:::note
We design positive test cases around what an application or system can do because the things that it can't are theoretically endless. A test case assertion concludes as a "pass" when something works as intended or meets expectations and "fails" when it doesn't. 

 There may be specific instances where "negative" test cases are required. Perhaps a small amount of operations need to be specifically checked to ensure they cannot be performed in the application or system under test. In these instances the "pass" and "fail" criteria are inverted from a positive test case
:::

### Common test case structure

You can use the fields below as a prompt when beginning to create your tests cases. Omit anything that isn't necessary in your case with the exception of "Steps" and "Assertions", this are fundamental and the most critical pieces of every test case.

**Test Title:** A title that outlines the test's main purpose

**Component:** A description of which component(s) this test is related to

**Feature:** Name of the feature that the test is helping to validate

**Priority (optional):** If you're creating several test suites it is good to consider priority level as not all tests will hold the same value.

**Can be automated?:** As the test may one day be automated it can be useful to declare this upfront if it's already known. This can save time in the future by negating the need to review and find automation candidates. 

**Environment:** Name of the specific environment for this test, for example "integration", "staging"

**Test Data (optional)** : List here any specific test data that is required in order to be able to perform the test

**Prerequisites (optional):** List here any other tasks that need to be complete prior to beginning the test

**Steps:** List here all the steps required to put the application or system into a testable state. Consider the audience, who will be executing this test, and be descriptive. Do not leave any ambiguity that could make it hard for someone else to understand.

**Assertions** List here the determining criteria that ensures what is being checked / validated meets expectations. 

**Notes (optional):** Any other custom / unique information related to the test that does not fall into any other standard sections. For instance, in automated test cases we use tear down functions to "tidy up" the environment / data at the end of test execution. Maybe in some situations, after a manual test, this could also be applicable.

### Example Test Case

- **Title:** User can successfully mint a test ERC20 on the "Goerli" network
- **Component:** UI (Desktop)
- **Feature:** Faucet 
- **Priority:** Critical
- **Can be automated?:** Yes  

- **Environment:** Staging
- **Test Data (optional):** Use test account `0xdc23f52868...`
- **Prerequisites (optional):** smart contracts have been deployed to the network

**Steps:**

1. Navigate to the faucet homepage
2. Choose "Goerli" as the network
3. Choose "ERC20Tst" as a token type
4. Enter the valid destination address of the test account configured in Metamask
5. Click on the Mint button
6. Confirm transaction in Metamask

**Assertions:**
- Confirm a transaction complete confirmation message is displayed for the user
- Confirm the balance of the receiving account was increased by correct amount 
- Confirm the balance of the debited account was decreased by correct amount 
