# BetaBuilder, a gem for managing iOS ad-hoc builds

BetaBuilder is a simple collection of Rake tasks and utilities for managing and publishing Adhoc builds of your iOS apps. 

It is inspired by and owes a lot of credit to [Hunter Hillegas](http://www.hanchorllc.com/2010/08/24/introducing-ios-beta-builder/) who created the original OSX Beta Builder utility.

## Motiviation

The problem with using a GUI app to create the beta packages is that it is yet another manual step in the process of producing an ad-hoc build for your beta testers. It simplifies some steps but it still requires running Build and Archive in Xcode, saving the resulting build as an IPA package, running the Beta Builder app, locating the IPA, filling in the rest of the fields and generating the deployment files. Then you need to upload those files somewhere.

As a Ruby developer, I use Rake in most of my projects to run repetitive, often build or test-related tasks and it's equally as useful for non-Ruby projects as it is for Ruby ones.

This simple task library allows you to configure once and then build, package and distribute your ad-hoc releases with a single command.

## Usage

To get started, if you don't already have a Rakefile in the root of your project, create one. If you aren't familiar with Rake, it might be worth [going over some of the basics](http://rake.rubyforge.org/) but it's fairly straightforward.

You can install the BetaBuilder gem from your terminal (OSX 10.6 works with a perfectly useful Ruby installation):

    $ gem install betabuilder

At the top of your Rakefile, you'll need to require `rubygems` and the `betabuilder` gem (obviously).

    require 'rubygems'
    require 'betabuilder'
    
Because BetaBuilder is a Rake task library, you do not need to define any tasks yourself. You simply need to configure BetaBuilder with some basic information about your project and it will generate the tasks for you. A sample configuration might look something like this:

    BetaBuilder::Tasks.new do |config|
      # your Xcode target name
      config.target = "MyGreatApp"

      # the Xcode configuration profile
      config.configuration = "Adhoc" 
      
      # where the distribution files will be uploaded to
      config.deploy_to = "http://yourwebsite.com/betas/"
    end
    
Now, if you run `rake -T` in Terminal.app in the root of your project, the available tasks will be printed with a brief description of each one:

    rake beta:build     # Build the beta release of the app
    rake beta:deploy    # Deploy the beta to your server
    rake beta:package   # Package the beta release as an IPA file

To deploy a beta to your server, some additional configuration is needed (see the next section).

Most of the time, you'll not need to run the `beta:build` task directly; it will be run automatically as a dependency of `beta:package`. Upon running this task, your ad-hoc build will be packaged into an IPA file and will be saved in ${PROJECT_ROOT}/pkg/dist, along with a HTML index file and the manifest file needed for over-the-air installation.

If you are not using the automatic deployment task, you will need to upload the contents of the pkg/dist directory to your server.

## Automatic deployment

BetaBuilder also comes with a (rather rudimentary) automatic deployment task that uses SCP so you will need SSH access to your server and appropriate permissions to use it. You will also need one extra line of configuration in your Rakefile, specifying the path on the remote server where the files will be copied to:

    config.remote_directory = "/var/www/yourwebsite.com/betas"
    
Now, instead of using the `beta:package` task, you can run the `beta:deploy` task instead. This task will run the package task as a dependency and upload the pkg/dist directory to the remote directory you have configured (again, you will need to ensure that you have the correct permissions for this to work).

## License

This code is licensed under the MIT license.

Copyright (c) 2010 Luke Redpath

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
