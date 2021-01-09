---
title: "How I got into testing: Unit Testing"
author: "Mohannad Najjar"
date: 2017-10-14T15:22:15.000Z
tags:
  - github
  - learning
  - phpunit
  - testing
---

Recently I started discovering software testing tools, unit testing, end-to-end/integration/acceptance testing, test-driven-devlopment, and this whole new world to me. As a beginner, I felt it's good to document how I got into this point. before, I was ignoring testing topics and thinks of it as a mystified world that I may or may not reach sometime in the future.

### Unit Testing
#### 1- Contributing to Laravel:
Oneday between November 2016 to May 2017, while I was working on a [laravel]( https://laravel.com) 5.3 project, I had to add a logger for tracking changes in some user-defined settings, sometimes it was easier to use the [getDirty()](https://laravel.com/api/5.5/Illuminate/Database/Eloquent/Model.html#method_isDirty) method on Laravel's Eloquent Model, sometimes it's not that simple and I had to do stuff manually.

I tried to use [diff method on Laravel's Collections](https://laravel.com/docs/5.4/collections#method-diff), then I realized that the results is not expected. `diff` method looks only for the values, without any respect to the keys of this values, and I want to track the changes per key & value together.

However, I ended up doing things like this:
```php
    // TLDR;
    function log_model_change($newModel, $oldModel, $message, $level = "info")
    {
        $oldData = $oldModel->toArray();
        $newData = $newModel->toArray();

        $dirtyValues= collect(array_diff_assoc($oldData, $newData))->except('updated_at')->toArray();

        $dirtyFields = array_keys($dirtyValues);
        $oldChangedData = collect($oldData)->only($dirtyFields)->toArray();
        $newChangedData = collect($newData)->only($dirtyFields)->toArray();
        if (! empty($newChangedData)) {
             // log here $oldChangedData and $newChangedData
        }
    }
// I know, This seems too complicated, unreadable
```
At this point, the ignoring-keys issue in `diff` are stuck in my mind. Internally, `diff` uses php's `array_diff` but what should be used is  `array_diff_assoc` if not by default, at least optionally in a different method, I have to look into this later.

After I finished the project, I came back to research this issue, and decided to submit a pull request to make laravel Collections uses `array_diff_assoc`, and I came up with this:
```php
    class Collection implements ...
    {
        public function diffAssoc($items)
        {
            return new static(array_diff_assoc($this->items, $this->getArrayableItems($items)));
        }
    }
```
Before submitting it, I was exploring the previous PRs to know how to format my PR and "be one of them", and at this point from the discussions I read, I got to the reasonable point: **Your PR should not break the tests. and if it's a new feature, you should include tests for it.**

Somehow I felt devastating, I wanted to contribute to laravel but someone threw this "testing" wall into my face. I put it on hold for a while.

But, "**Confront the beast that haunts you.  Only then will you find peace**". So I did, started reading about unit testing and testing in PHP and PHPUnit, watching [laracasts](https://laracasts.com) courses about it.

Writing the test for it in the Collection test suite, was simply:
```php
    public function testDiffAssoc()
    {
        $c1 = new Collection(['id' => 1, 'first_word' => 'Hello', 'not_affected' => 'value']);
        $c2 = new Collection(['id' => 123, 'foo_bar' => 'Hello', 'not_affected' => 'value']);
        $this->assertEquals(['id' => 1, 'first_word' => 'Hello'], $c1->diffAssoc($c2)->all());
    }

```

After ensuring all the tests are passing. On 15-Jun-2017 I [submitted the PR](https://github.com/laravel/framework/pull/19604), few hours later Taylor (creator of laravel) accepted it and merged it, and I was: " :sweat_smile: Oh Really? Wasn't expected that!", if we didn't count a simple [translating file on unmaintained project](https://github.com/tantaman/Strut/pull/366), this is my first PR ever, and it's also my first encounter with the world of testing.

> (P.S: Lucky me, my PR lasted as the latest one while Jeffrey Way was recording the episode: [How Do I: Contribute to Laravel: From Start to PR](https://laracasts.com/series/how-do-i/episodes/20). It felt good to see it there!)

#### 2- Writing a package
Few days later, I wanted to write a package for something I always do in any fresh project, setting up helpers for Marking and retrieving the active item in a list of items, while keeping the code readable as mush as possible.

I wrote the package ([mohannadnaj/active-state](https://github.com/MohannadNaj/active-state)) with it's tests, and since it's my first package ever, I spent time and tried so hard to "do it right" by rewriting the code multiple times. this package was my first real use of testing and PHPUnit.
#### Then ..
I was amazed by how PHPUnit makes it easy for me to consider -simultaneously- the different usage scenarios for my package. and I got that amazing moment when you change something that will break only one test assertion while the rest are passing. You can imagine how is it feels when you write down all your fears, and the test runner checking it for you one by one, and gives the "green" light: you are good to go, you don't have to worry about this.
I'm still trying to learn the best practices in this area, I want to overcome the "unit testing is a spelling checker" type of problems arises while learning. and to chose my pick on testing patterns and design.
