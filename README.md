# BetaBuilder, a gem for managing iOS ad-hoc builds

BetaBuilder is a simple collection of Rake tasks and utilities for managing and publishing Adhoc builds of your iOS apps. 

If you're looking for the OSX BetaBuilder app -- to which this gem owes most of the credit -- you can find it [here on Github](http://github.com/HunterHillegas/iOS-BetaBuilder).

## Motiviation

The problem with using a GUI app to create the beta packages is that it is yet another manual step in the process of producing an ad-hoc build for your beta testers. It simplifies some steps but it still requires running Build and Archive in Xcode, saving the resulting build as an IPA package, running the Beta Builder app, locating the IPA, filling in the rest of the fields and generating the deployment files. Then you need to upload those files somewhere.

As a Ruby developer, I use Rake in most of my projects to run repetitive, often build or test-related tasks and it's equally as useful for non-Ruby projects as it is for Ruby ones.

This simple task library allows you to configure once and then build, package and distribute your ad-hoc releases with a single command.

## Usage

To get started, if you don't already have a Rakefile in the root of your project, create one. If you aren't familiar with Rake, it might be worth [going over some of the basics](http://rake.rubyforge.org/) but it's fairly straightforward.

You can install the BetaBuilder gem from your terminal (OSX 10.6 ships with a perfectly useful Ruby installation):

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
    end
    
Now, if you run `rake -T` in Terminal.app in the root of your project, the available tasks will be printed with a brief description of each one:

    rake beta:build     # Build the beta release of the app
    rake beta:package   # Package the beta release as an IPA file

To deploy your beta to your testers, some additional configuration is needed (see the next section).

Most of the time, you'll not need to run the `beta:build` task directly; it will be run automatically as a dependency of `beta:package`. Upon running this task, your ad-hoc build will be packaged into an IPA file and will be saved in `${PROJECT_ROOT}/pkg/dist`, along with a HTML index file and the manifest file needed for over-the-air installation.

If you are not using the automatic deployment task, you will need to upload the contents of the pkg/dist directory to your server.

To use a namespace other than "beta" for the generated tasks, simply pass in your chosen namespace to BetaBuilder::Tasks.new:

    BetaBuilder::Tasks.new(:my_custom_namespace) do |config|
    end
    
This lets you set up different sets of BetaBuilder tasks for different configurations in the same Rakefile (e.g. a production and staging build).

## Automatic deployment with deployment strategies

BetaBuilder allows you to deploy your built package using it's extensible deployment strategy system; the gem currently comes with support for simple web-based deployment or uploading to [TestFlightApp.com](http://www.testflightapp.com). Eventually, you will be able to write your own custom deployment strategies if neither of these are suitable for your needs.

### Deploying your app with TestFlight

By far the easiest way to get your beta release into the hands of your testers is using the excellent [TestFlight service](http://testflightapp.com/), although at the time of writing it is still in private beta. You can use TestFlight to manage your beta testers and notify them of new releases instantly.

TestFlight provides an upload API and betabuilder uses that to provide a `:testflight` upload strategy. This strategy requires two pieces of information: your TestFlight API token and your team token:

    config.deploy_using(:testflight) do |tf|
      tf.api_token  = "YOUR_API_TOKEN"
      tf.team_token = "YOUR_TEAM_TOKEN"
    end
    
Now, instead of using the `beta:package` task, you can run the `beta:deploy` task instead. This task will run the package task as a dependency and upload the generated IPA file to TestFlight. 

You will be prompted to enter the release notes for the build; TestFlight requires these to inform your testers of what has changed in this build. Alternatively, if you have a way of generating the release notes automatically (for instance, using a CHANGELOG file or a git log command), you can specify a block that will be called at runtime - you can do whatever you want in this block, as long as you return a string which will be used as the release notes, e.g.

    config.deploy_using(:testflight) do |tf|
      ...
      tf.generate_release_notes do
        # return release notes here
      end
    end

### Deploying to your own server

BetaBuilder also comes with a rather rudimentary web-based deployment task that uses SCP, so you will need SSH access to your server and appropriate permissions to use it. This works in the same way as the original iOS-BetaBuilder GUI app by generating a HTML template and manifest file that can be uploaded to a directly on your server. It includes links to install the app automatically on the device or download the IPA file.

You will to configure betabuilder to use the `web` deployment strategy with some additional configuration:

    config.deploy_using(:web) do |web|
      web.deploy_to = "http://beta.myserver.co.uk/myapp"
      web.remote_host = "myserver.com"
      web.remote_directory = "/remote/path/to/deployment/directory"
    end
    
The `deploy_to` setting specifies the URL that your app will be published to. The `remote_host` setting is the SSH host that will be used to copy the files to your server using SCP. Finally, the `remote_directory` setting is the path to the location to your server that files will be uploaded to. You will need to configure any virtual hosts on your server to make this work.

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
