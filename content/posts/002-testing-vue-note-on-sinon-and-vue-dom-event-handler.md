---
title: "Testing Vue: note on Sinon & Vue DOM Event Handler"
author: "Mohannad Najjar"
date: 2017-10-26T21:00:00.000Z
tags:
  - testing
---

One of the most outstanding features of vue is how templates bind event handlers to elements. alot of cool stuff that makes the template is really "cool" to read and look at!

Recently I was writing a test for a Vue component, and I noticed this issue. In short, the issue is: I can't spy on the `increment` method on the template:  `<input @click="increment">`.

### Background:
Vue offers different ways of binding event handlers to elements, for example: `<input v-on:click="counter++">` or `<input @click="counter++">` or `<input @click="methodName"` and many other options. You can read about it [the Event Handling section on the official Vue Guide](https://vuejs.org/v2/guide/events.html), and you can take a look at [the relative tests on the official vue repository](https://github.com/vuejs/vue/blob/v2.5.2/test/unit/modules/compiler/codegen.spec.js).

### Problem:

assuming we have the following simple counter component:
``` js
let Ctor = Vue.component('counter', {
  template: `<div>
  <button id="increment-btn" @click="increment">Increment!</button>
  <h4>{{counter}}</h4>
</div>`,
  data: () => {return {counter: 0}},
  methods: {
    increment() {
      this.counter++
    }
  }
})
```
Let's write a simple test for this component:
``` js
it('increment the counter', () => {
  const vm = new Ctor().$mount()

  vm.$el.querySelector('#increment-btn').click()

  expect(vm.counter).to.equal(1)
})
```
This passing test doesn't know about the `increment` method, it uses the querySelector directly to simulate a real user-click, and it's assertion based on the counter value.

**but what if we want to spy on `increment` method?**

[Sinon spies](http://sinonjs.org/releases/v4.0.1/spies/) have an awesome API, and in some cases, I want to spy on the method calls, while keeping the querySelector way of interacting with the DOM.

``` js
it('increment the counter 2', () => {
  const vm = new Ctor().$mount()
  
  sinon.spy(vm, 'increment')
  
  vm.$el.querySelector('#increment-btn').click()
  
  // callCount property added by sinon to return
  // number of times the method was called
  expect(vm.increment.callCount)
  .to.equal(1)
})

```
This is supposed to be working without any issues, but, it's not passing! the vm.increment.callCount is still zero!

### Solution:
Hmm, let's review how we set the call on the template:
``` js
<button id="increment-btn" @click="increment">
```
and for some reason it's not working, but, modifying it to be:
``` js
<button id="increment-btn" @click="increment()">
```
Ta-dah! now it's working!

----------

Switching from the [method event handler](https://vuejs.org/v2/guide/events.html#Method-Event-Handlers) to the [Method in inline handler](https://vuejs.org/v2/guide/events.html#Methods-in-Inline-Handlers) solved the issue for us!

Another way of working around this issue is to make the method event handler is not the direct action executer, it will call it, and then you spy on the direct action executer.

Component:
``` js
let Ctor = Vue.component('counter', {
  template: `<div>

  <button id="increment2-btn" @click="increment2">increment2!</button>
  <h4>{{counter}}</h4>
</div>`,
  data: () => {return {counter: 0}},
  methods: {
    increment2() {
      this.doIncrement()
    },
    doIncrement() {
      this.counter++
    }
  }
})
```
Test:
``` js
it('increment the counter 2', () => {
  const vm = new Ctor().$mount()

  sinon.spy(vm, 'doIncrement')

  vm.$el.querySelector('#increment2-btn').click()

  expect(vm.doIncrement.callCount)
  .to.equal(1)
})

```

Obviously, the first solution (inline methods) looks simpler, but sometimes your structure makes this workaround better for you.

I'm still curious about why is this happening. I was thinking that the cause of this behaviour is somehow related to the common ([Execute function while passing it](https://stackoverflow.com/questions/13286233/pass-a-javascript-function-as-parameter)) issue, but this is only an arbitrary guess. then I tried to read [the relative tests on the official vue repository](https://github.com/vuejs/vue/blob/v2.5.2/test/unit/modules/compiler/codegen.spec.js), and the Vue source code itself, but I got lost there.

Here is [the JSFiddle including the not-working test](https://jsfiddle.net/mohannadnaj/rn9hr7u6/).

<script async src="//jsfiddle.net/mohannadnaj/rn9hr7u6/embed/"></script>

and here is [another JSFiddle](https://jsfiddle.net/mohannadnaj/yaqgcf3o/) with the same issue.

<script async src="//jsfiddle.net/mohannadnaj/yaqgcf3o/embed/"></script>

