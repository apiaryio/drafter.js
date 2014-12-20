# Drafter

Snow Crash parser harness

## Introduction

Drafter takes API Blueprint on its input, parses it, manipulates the API Blueprint AST and makes it available through Drafter's (ex Snow Crash) bindings.

Want to know more? See [the card](https://trello.com/c/lS76AEU3/21-drafter).

## Installation & CircleCI

Becuase one of Drafter's dependencies ([Boutique](https://github.com/apiaryio/boutique/)) lives in private GitHub repository and has no public `npm` package, it's referenced by Git URL in `package.json` and you can experience some issues while installing or testing.

You need to have access to both repositories and you need to give CircleCI some extended permissions over all your repositories to enable testing on their machines: **Project Settings > Checkout SSH keys > Add User GitHub Key**
