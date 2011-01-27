---
layout: default
title: "BetaBuilder: iOS Adhoc deployment made easy."
---

Deploying beta releases of your iPhone app to your users is a drag. BetaBuilder is a collection of Rake tasks, distributed as a Ruby gem, that make deploying your adhoc app builds easy - you don't even need to launch Xcode!

# Getting started: building your project

The first step is to install the gem. You'll need a working installation of Ruby and Rake - the good news is, OSX, as of Leopard, ships with a perfectly usable installation. From a terminal:

    $ sudo gem install betabuilder
    
Now you need to create what is known as a `Rakefile` - like a `Makefile` but for Rake. If you haven't used Rake before or aren't familiar with Ruby, then I recommend [this excellent introduction to Rake](http://martinfowler.com/articles/rake.html).

In the root of your project, create a new file called simply `Rakefile` and open it up in your favourite text editor. Let's assume that our app's Xcode target is called "AwesomeApp" and your Xcode adhoc build configuration is imaginatively called "Adhoc". Paste the following into your Rakefile:

{% highlight ruby %}
require 'rubygems'
require 'betabuilder'

BetaBuilder::Tasks.new do |config|
  config.target        = "AwesomeApp"
  config.configuration = "Adhoc" 
end
{% endhighlight %}

Now, back to the terminal. Run `rake -T` to view a list of the available tasks. You should see something like this:

    $ rake -T

    rake beta:archive              # Build and archive the app
    rake beta:build                # Build the beta release of the app
    rake beta:package              # Package the beta release as an IPA file

The task descriptions should be fairly self-explanatory, but you can consider them analogous to the following Xcode operations:

### `beta:build` 
This will build your app just as if you had hit **Build** in Xcode, using the `xcodebuild` utility.

### `beta:archive` 
This is the same as **Build and Archive** in Xcode. It uses the same location as Xcode by default for archives but this can be customised if you prefer to keep your archived builds elsewhere (perhaps a Dropbox share). 

You can also configure BetaBuilder to automatically archive each build to avoid having to remember to run this task explicitly.

### `beta:package` 
This builds your app and packages it in an IPA file. It is the same as exporting a build from Xcode Organiser and choosing **Save to Disk**. 

# Distributing your app

OK, so you can now build your project. Big deal, right? What good is a build that hasn't been distributed to anybody? That's where BetaBuilder _deployment strategies_ come in. BetaBuilder currently supports two strategies out of the box: web-based and via [TestFlight](http://testflightapp.com). It is also possible to write your own (more information on this coming soon - in the meantime, please check the source code).

## Deploying to a private website

The simplest strategy is to simply upload your IPA to a website that only your beta testers can access, along with an HTML index file with links to the build and a manifest file. Your beta users can open this page on their device and if they are running at least iOS 4.0, install your latest beta with a single tap.

To use the web-based deployment strategy, you'll need to have SSH access to the server that will host your deployed build. Let's take a look at an example configuration:

{% highlight ruby %}
BetaBuilder::Tasks.new do |config|
  ...
  config.deploy_using(:web) do |web|
    web.deploy_to = "http://www.example.com/myapps/awesomeapp/"
    web.remote_host = "example.com"
    web.remote_directory = "/var/www/example.com/myapps/awesomeapp"
  end
end
{% endhighlight %}

Using the above configuration, BetaBuilder will generate an index.html and manifest file, as well as your IPA, and upload them, using `scp` to the remote directory specified on the remote host. You would then point your beta testers at the `deploy_to` URL.

If you now run `rake -T`, you'll see some new tasks:

    rake beta:deploy               # Deploy the beta using your chosen deployment stra...
    rake beta:prepare              # Prepare your app for deployment
    rake beta:redeploy             # Deploy the last build

### `rake beta:deploy`

This one is self-explanatory. It will build and package your app and deploy it using your configured deployment strategy.

### `rake beta:prepare`

If your chosen deployment strategy has an intermediate step, this task will perform that step without actually deploying. The Testflight strategy (see below) has no preparation step. 

For the web strategy, this will create the "payload" ready to upload to your server (the IPA, manifest and index page) but it won't actually do the upload. This is useful if you do not have SSH access to your server and need to upload the package manually (for instance, via FTP or Dropbox).

## Deploying to TestFlight

[TestFlight](http://testflightapp.com) is a recently launched service that is _free_ to developers that enables you to manage your beta testers (and group them into distribution lists), upload your application builds and notify your testers of the build. Your testers can then launch the TestFlight web app and install all of the latest beta versions of apps that they are testing with a single tap.

TestFlight takes out a lot of the pain in deploying and managing beta releases of your apps but it still requires you to manually build and archive your app and upload your IPA file. Not with BetaBuilder. Using the TestFlight deployment strategy, you can build, package and upload your app directly to TestFlight.

To get started, you'll need a TestFlight account, as well as your account API key and team API key. This is what a TestFlight deployment strategy looks like:

{% highlight ruby %}
config.deploy_using(:testflight) do |tf|
  tf.api_token  = "YOUR_API_TOKEN_GOES_HERE"
  tf.team_token = "YOUR_TEAM_TOKEN_GOES_HERE"
end
{% endhighlight %}

When you run `rake deploy`, you'll be prompted for the release notes for that build. If you have the `$EDITOR` environment variable configured, this editor will be launched and you can enter your release notes here (save and close to continue). Otherwise, you will be prompted to enter the release notes directly at the prompt.

It is also possible to have your release notes generated programatically for you. For more about this, please check the Reference page.

# Credits

The original work on BetaBuilder and the web-based deployment strategy was heavily inspired by (and borrows some template code from) the [iOS BetaBuilder](http://www.hanchorllc.com/2010/08/24/introducing-ios-beta-builder/) project by Hunter Hillegas. I wrote BetaBuilder because I wanted a fully automated solution to deploying adhoc builds but if you're looking for a GUI app, then check his project out. I should also thank Hunter for allowing me to use the name BetaBuilder for this project.

The code is open source and is licensed under the [MIT license](http://www.opensource.org/licenses/mit-license.php). The source code is [available on GitHub](https://github.com/lukeredpath/betabuilder). If you have any suggestions for features or enhancements or want to contribute some bug fixes, patches or pull requests are welcome.
