# Mailboxer 0.6.x [![](https://secure.travis-ci.org/ging/mailboxer.png)](http://travis-ci.org/ging/mailboxer)

This project is based on the need of a private message system for [ging
/ social\_stream](https://github.com/ging/social_stream). Instead of creating our core message system heavily
dependent on our development we are trying to implement a generic and
potent messaging gem.

After looking for a good gem to use we notice the lack of messaging gems
and functionality in them. Mailboxer tries to fill this emptiness giving
a powerfull and generic message system. It supports the use of
conversations with two or more recipients, send notification to a
recipient (intended to be used as system notifications “Your picture has
new comments”, “John Doe has updated its document”, etc.), emails the
messageable model (if configured to do so). It has a complete use of a
`Mailbox` object for each messageable with `inbox`, `sentbox` and
`trash`.

The gem is constantly growing and improving its functionality. As it is
used with our parallel development [ging / social\_stream](https://github.com/ging/social_stream) we are finding and fixing bugs continously. If you want
some functionality not supported yet or marked as TODO, you can create
an [issue](https://github.com/ging/mailboxer/issues) to ask for it. It will be a great feedback for us, and we
will know what you may find useful of the gem.

Mailboxer was born from the great, but outdated, code from [lpsergi /
acts*as*messageable](https://github.com/psergi/acts_as_messageable).

We are now working to make an exhaustive documentation and some wiki
pages in order to make even easier to use the gem at its full potencial.
Please, give us some time if you find something missing or [ask for
it](https://github.com/ging/mailboxer/issues).

Installation
------------

Add to your Gemfile:

````
gem ‘mailboxer’
````

Then run:

````
$ bundle update
````

Run install script:

````
$ rails g mailboxer:install
````

And don't forget to migrate you database:

````
$ rake db:migrate
````

Requirements
------------

We are now adding support for sending emails when a Notification or a
Message is sent to one o more recipients. So that, we must assure that
Messageable models have some specific methods. These methods are:

````ruby
#Returning any kind of identification you want for the model
def name
  return "You should add method :name in your Messageable model"
end
#Returning the email address of the model if an email should be sent for this object (Message or Notification).
#If no mail has to be sent, return nil.
def mailboxer_email(object)
  #Check if an email should be sent for that object
  #if true
  return "define_email@on_your.model"
  #if false
  #return nil
end
````

These names are explicit enough to avoid colliding with other methods, but as long as you need to change them you can do it by using mailboxer initializer. Just add or uncomment the following lines:

````ruby
#Configures the methods needed by mailboxer
config.email_method = :mailboxer_email
config.name_method = :name
````

You may change whatever you want or need. For example:

````ruby
config.email_method = :notifications_email
config.name_method = :display_name
````

Will use the method `notification_email(object)` instead of `mailboxer_email(object)` and `display_name` for `name`.

Using default or custom method names, if your model doesn't implement them, Mailboxer will use dummy methods not to crash but notify you the missing methods.

## Preparing your models

In your model:

````ruby
class User < ActiveRecord::Base
  acts_as_messageable
end
````

You are not limited to User model. You can use Mailboxer in any other model and use it in serveral different models. If you have ducks and cylons in your application and you want to interchange messages as if they where the same, just use act_as_messageable in each one and you will be able to send duck-duck, duck-cylon, cylon-duck and cylon-cylon messages. Of course, you can extend it for as many clases as you need.

Example:

````ruby
class Duck < ActiveRecord::Base
  acts_as_messageable
end
````

````ruby
class Cylon < ActiveRecord::Base
  acts_as_messageable
end
````

## Using The Mailboxer API

In order to mantain the README in a proper size and simplicity, all the
API is available in [Mailboxer wiki](http://rubydoc.info/gems/mailboxer/frames)

## Contributors
* [Roendal](https://github.com/ging/mailboxer/commits/master?author=Roendal) (Eduardo Casanova)
* [dickeyxxx](https://github.com/ging/mailboxer/commits/master?author=dickeyxxx) (Jeff Dickey)
* [tonydewan](https://github.com/ging/mailboxer/commits/master?author=tonydewan) (Tony Dewan)
* [plentz](https://github.com/ging/mailboxer/commits/master?author=plentz) (Diego Plentz)
* [laserlemon](https://github.com/ging/mailboxer/commits/master?author=laserlemon) (Steve Richert)

## License

Copyright © 2011 Eduardo Casanova Cuesta

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
