---
title: "Maybe `git submodule` can be used as a package manager?"
author: "Mohannad Najjar"
date: 2017-11-12T21:00:00.000Z
tags:
  - git
  - package managers
  - dependencies
---

Few days ago I wanted to include [CreativeTim's awesome project (Light Bootstrap Dashboard)](https://github.com/creativetimofficial/light-bootstrap-dashboard/), into one of my bootstrap projects.

The scenario is: There is existing project, existing setup for admin dashboard, but now I want it to be more like the 'Light Bootstrap Dashboard'.

Light Bootstrap Dashboard project doesn't offer a direct way of achieving this, there is no npm package that I can pull -or maybe what I did here, is in fact the direct way of doing it?-. The documentation is a manual copy-paste files setup, I don't want to check all this files in my project.

What I did was:

1- Created a `third_party/` directory on my main project root.

2- Following the [Official Git Submodules tutorials](https://git-scm.com/book/en/v2/Git-Tools-Submodules), From the command line:
``` bash
git submodule add https://github.com/creativetimofficial/light-bootstrap-dashboard/ third_party/light-bootstrap-dashboard
```

3- Waiting for the clone to finish cloning from the remote repo, to the specified folder: `third_party/light-bootstrap-dashboard`. After that, now I see the actual repo inside my repo, this is cool!

4- At this point it came into my mind: What if this `submodule` project changed?! how I didn't consider that? is it going to have a different lifespan than my root project? (I was concerned, because the root project still and mostly will still use bootstrap 3 for a while, and bootstrap 4 is already out and the folks at creative-tim is expected to migrate to bootstrap 4)

Googling it, found the answer on [this SO post](https://stackoverflow.com/questions/7238426/understanding-git-submodule-and-freezing-it-at-a-specific-commit-hash-or-versi), and the confident accepted answer: `Freezing is the whole point of submodules!`

Yes, Let's continue.

5- opened the file [third_party/light-bootstrap-dashboard/dashboard.html](https://github.com/creativetimofficial/light-bootstrap-dashboard/blob/27b314d1fdeefee968d34b7055b0d742feddd135/dashboard.html) to checkout the structure and what to extract to integrate with my own project.

6- Among the libraries used in this project, there is [Bootstrap Notify](http://bootstrap-notify.remabledesigns.com/), [Chartist](https://gionkunz.github.io/chartist-js/), ..etc. I will pick up what I need from there, I don't have to use it all.

7- From my javascript entrypoint I Included the nessecary files:
``` js
require ("../../../third_party/light-bootstrap-dashboard/assets/js/chartist.min.js")
require ("../../../third_party/light-bootstrap-dashboard/assets/js/bootstrap-select.js")
require ("../../../third_party/light-bootstrap-dashboard/assets/js/bootstrap-notify.js")
require ("../../../third_party/light-bootstrap-dashboard/assets/js/light-bootstrap-dashboard.js")

// yeah, the multi-level navigation to the parent directory is annoying
```

8- From my sass entrypoint I included the nessecary files:
``` scss
// .....
// Light Bootstrap Dashboard
@import "../../../third_party/light-bootstrap-dashboard/assets/css/animate.min";
@import "../../../third_party/light-bootstrap-dashboard/assets/sass/light-bootstrap-dashboard";
@import "../../../third_party/light-bootstrap-dashboard/assets/css/pe-icon-7-stroke";

```

And, lucky me, using Webpack -through Laravel-mix-, I don't have to worry about copying the fonts, images, and all `url()` relative files called from `css` files. [Read More about this here](https://github.com/JeffreyWay/laravel-mix/blob/master/docs/css-preprocessors.md#css-url-rewriting).

------------

Now, That did it for me, Light-Bootstrap-Dashboard is integrated successfully, `git submodule` did what was expected. I don't have to track in my version control the package/theme/template files. maybe there is another ways better that I didn't discover yet, but for now I'm happy with this : )
