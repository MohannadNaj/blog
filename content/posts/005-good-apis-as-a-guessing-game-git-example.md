---
title: "Good APIs as a Guessing Game: Git example"
author: "Mohannad Najjar"
date: 2017-11-19T21:00:00.000Z
tags:
  - git
  - npm
  - API Design
---

I like it in npm that we can do stuff like:

``` shell
npm install --save first_package second_package third_package ...

```

With the white space as a separator.

Recently I discovered that we can do the same in Git for removing multiple branches at once:

``` shell
git branch -d first_branch second_branch third_branch ...

```

I'm happy I discovered this feature with guessing it only, not after searching it and reading [the stackoverflow post related to it](https://stackoverflow.com/questions/3670355/can-you-delete-multiple-branches-in-one-command-with-git).

I always like it to guess the API of whatever the technology I'm using. I do believe that good APIs usage and names can be guessed by humans.

Usually guessing the API is the first thing I do before googling. Specially if the IDE will try to search the function/property name in the autocomplete suggestions.

I like This "guessing-the-API" habit for this reasons:

- **It affects my relationship with the program.**

I'm serious.

I feel more comfortable, confident, and solid user of the program when I "get it right" without reading the docs or googling it. Sometimes you only need this psychological feeling to get things done.

- **It will give me a sense of evaluating how far/close I'm to the program**.

If I got it all the way wrong, no guess was even remotely close to how it's working, this is an indicator to me of one of the followings: I should oneday go back to the docs and read it. or the API is not good enough.

- **Sometimes it will give you an idea for a nice PR to contribute**.

It's nice for the APIs to have aliases to meet the different mindsets of their users, without turning it into unstandardized mess.

__________

Notable -maybe obvious?- downside of guessing the API is: sometimes you think you are getting it right, but you are not.

You will use it and you will see the expected results, you will go forward, you will discover later that there is a bug related to a limitation of that guessed API, something you didn't consider before.
