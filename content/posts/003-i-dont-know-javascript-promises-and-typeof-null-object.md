---
title: "I don't know JavaScript: Promises & typeof null == \"object\""
author: "Mohannad Najjar"
date: 2017-10-26T21:00:00.000Z

tags:
  - testing
---

My plan for this blog isn't to make it a place to vent anger and frustration, don't count this post as one, this post is about sharing learning experience and impressions.

Last night I spent around 6 hours to investigate an issue in a failing javascript test, simply because I didn't realize that this condition may ever pass:
``` js
if(typeof null == 'object') ....
```

I mean, Seriously ? that wasn't expected at all. :/

I know it's common for beginners to get into this kind of issues, it is part of the process, and I'm not actually criticizing the inner workings of javascript -which is something I know nothing about- or making a stupid judgement.
### The Component:
I was writing a [VueJs](vuejs.org) component with a `saveChanges` method that uses [axios](https://github.com/axios/axios) to make a http request:
``` js
    methods: {
      saveChanges() {
        this.is_updated = false
        axios
        .post(this.update_target, this.requestParams)
        .then(response => {
          console.log('success!!')
          // do stuff
          // ...
          if (typeof this.handlerInstance == 'object') {
            this.handlerInstance.$emit('saved-changes', response.data)
          }
          // ...
          this.is_updated = true
        })
        .catch(error => {
          console.log('error!!')
        })
      }
    }
  
```
 
 
### The Tests:
  
  using [moxios](https://github.com/axios/moxios) for mocking axios requests, let's consider the following tests:

``` js
// Passing Test
it(`after successful update: emit 'updated-data' event if there is a handler instance`, (done) => {
  // Arrange
  createVue() // set up a vm instance for our component

  vm.handlerInstance = EventBus

  spy('$emit', EventBus) // sinon.spy on method `$emit` on the object `EventBus`

  // Assert
  let assertion = () => {
    expect(EventBus.$emit.calledWith('updated-data')).toBeTruthy()
    done()
  }

  // Act
  submitSuccessfulUpdate() // set up a moxios stub request, then call vm.saveChanges() method
  moxios.wait( assertion )
})
  
// Failing Test
it('after successful update: change updated state', (done) => {
  createVue() // set up a vm instance for our component

  submitSuccessfulUpdate() // set up a moxios stub request, then call vm.saveChanges() method

  moxios.wait(() => {
    expect(vm.is_updated).toBeTruthy()
    done()
  })
})

```

It should be as simple & straightforward as that, **BUT, WHY THE SECOND TEST IS FAILING??**
### The Problem:
The thing is, it's not only an issue of failure test, on our `vm.saveChanges` method we are outputting to the console in both `then` and `catch` cases, and I'm getting the both outputs!! the second test outputs:
``` shell
success!!
error!!
```
And I was: WTH is wrong here :/ ?? this is unusual for me! it's going through both the `resolve/then` and `reject/catch` methods of axios's promise.
``` js
axios
.post(...)
.then(response => {
  console.log('success!!')
})
.catch(error => {
  console.log('error!!')
})
```

### The Solution:
Turns out, in our `resolve/then` method, the condition 
``` js
  if (typeof this.handlerInstance == 'object') {
    this.handlerInstance.$emit('saved-changes', response.data)
  }
```
always is passing, even if `this.handlerInstance` is null. it will try to call out the `$emit` method on that's null object, and this error will make the promise go to the `catch` method!

fixing this condition to:
``` js
if (this.handlerInstance == null) //...
```
solve it to me, that's it!

### Lesson Learned:

#### 1- Checking for nullable objects
`typeof nullableObject == 'object'` is not a reliable way of checking if an object is set or null, checking if `nullableObject == null` among other ways, is at least a better way to go.

and this issue is a known one, as you can see from [one of the StackOverflow questions related to it](https://stackoverflow.com/questions/18808226/why-is-typeof-null-object).

Quoting Dipak Ingole from the SO answer:

> A "fix" was proposed for ECMAScript (via an opt-in). It would have resulted in:
> `typeof null === 'null'`
>  ... but this change was [rejected](https://archive.is/sPyGA), due to issues with code using this specific "quirk" to test for null.


#### 2- Promises
`Promise.then().catch()` is not the same as `Promise.then(resolve, reject)`.

quoting K. Scott Allen from his blog: [JavaScript Promises and Error Handling](http://odetocode.com/blogs/scott/archive/2015/10/01/javascript-promises-and-error-handling.aspx):

> There can be a difference in behavior between the following two code
> snippets:
> `.then(doWork, errorHandler)`
> … and …
> `.then(doWork)`
> `.catch(errorHandler)`
> 
> In the first code snippet, if the success  handler throws an exception or rejects a promise, execution will not go into the error handler since the promise was already resolved at this level. With catch, you can always see an unhandled error from the previous success handler.

Hallelujah!

#### P.S: What I did in this 6 Hours?

The code examples here is a fixed ones for this post, it's not the real component & tests. Debugging the failing tests was interesting journey inside multiple suspects.

One way of trying to debug it, I was injecting the following code throughout the whole `axios` calls inside my application:
``` js
 let rand = Math.floor(Math.random() * 100)
 console.log(`|rand started ${rand} -----`)
 axios.post(...)
 .then((response) => {
     console.log(`then: ${rand}`)
     // ..
 })
 .catch((error) => {
     console.log(`catch: ${rand}`)
     // ..
 })
 console.log(`----- rand end ${rand}|`)
```

List of the innocent suspects that was somehow investigated:

  1. moxios
  2. promise-polyfill
  3. promise
  4. axios
  5. babel
  6. karma-runner
  7. node version
  8. windows 7
  9. my luck
  10. sleeping bills
  11. god


