# Future Mind Take-Home Task

This repo contains a simplistic version of a loyalty program app. User collects points through
purchases and there are several rewards, which he can activate to claim them at the counter.
Activating a reward decreases his points balance.

## Task

The user stories to implement are:

1. As a user, when I click on an inactive reward, I want to activate it.  
2. As a user, when I click on an active reward, I want to deactivate it.  
3. As a user, when I activate or deactivate a reward, I want to see how my points balance has changed.  

**We ask you to implement these user stories in a way that you would do it in a regular, 
production-ready application using your best judgement when it comes to architecture, patterns,
development practices, optimal user experience etc.**

### Figma mockups

https://www.figma.com/file/dk9YXjwT5gPset1bDiJrH0/Task

### What will you find in this repository

To save your time, the skeleton for this function is already implemented.  
There's a view layer stub and there's a `RewardsAPI` (which simulates regular remote API).
What is left for you to fill is the connection between the view layer and `RewardsAPI` as well as 
making sure that the app looks like the provided design and behaves in a user-friendly manner.

### Other info

- the skeleton is for your convenience, if you want to implement it differently, go ahead, just 
  be prepared to talk about the solution you chose
- you can use different libraries or Swift features, e.g. if you are more familiar with async/await than Combine,
  you're encouraged to use them
- if you want to provide additional info about your solution in the Readme, feel free to do so
- don't hesitate to use AI as long as you understand the generated solution and can decide whether it fits the requirements

### Mock API

The `RewardsAPI` is a mock that simulates a regular asynchronous API interface. 
Just like the original, it might throw exceptions when something goes wrong. You should expect:

- `HttpError.badRequest` with code 400 when something is wrong with a request.
- `HttpError.resourceNotFound` with code 404 when for example incorrect URL is passed to load an image.
- `HttpError.serverUnavailable` 500 from time to time

### Key aspects we evaluate during the technical solution review
* functionality and responsiveness of the application
* code complexity and size – higher volume doesn't imply higher quality
* code quality, readability, and overall cleanliness
* handling of edge cases (including several non-obvious ones)
* appropriate and effective use of design patterns
* methods used to ensure the correctness and stability of implemented changes


## Solution

Please, check out to a new branch.

To send the solved task, please create a private repository on bitbucket and share it with: 
`p.sitek@futuremind.com`, `m.nowacki@futuremind.com`, `m.klimczak@futuremind.com`, `t.jurek@futuremind.com`.

If you have any questions, send them to the addresses above.


## TODO:
- handle inifinte loading 
- parse error better for UX
