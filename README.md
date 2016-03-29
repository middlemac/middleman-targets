middleman-targets readme
========================
[![Gem Version](https://badge.fury.io/rb/middleman-targets.svg)](https://badge.fury.io/rb/middleman-targets)

`middleman-targets`

 : This gem provides the ability to generate multiple targets by outfitting
   Middleman with additional command line options. The provided helpers make
   it simple to control content that is specific to each target, based on the
   target name or based on feature sets for each target.

   It is standalone and can be used in any Middleman project.


Install the Gem
---------------

Install the gem in your preferred way, typically:

~~~ bash
gem install middleman-targets
~~~

From git source:

~~~ bash
rake install
~~~


Documentation
-------------

The complete documentation leverages the features of this gem in order to better
document them. Having installed the gem, read the full documentation in your
web browser:

~~~ bash
middleman-targets documentation
cd middleman-targets-docs/
bundle install
bundle exec middleman server
~~~
   
And then open your web browser to the address specified (typically
`localhost:4567`).


Quick Documentation
-------------------

[Middleman](https://middlemanapp.com/) 4.1.6 or newer is required. Earlier
point versions of Middleman do not have the necessary support for this
extension.

Once setup and configured, you can build multiple targets like so:

~~~ bash
bundle exec middleman build --target mytarget
~~~

Or:

~~~ bash
bundle exec middleman build_all
~~~

Or:

~~~ bash
bundle exec middleman serve --target mytarget
~~~

Added Features
--------------

To support multiple targets and features, flexible configuration and helpers are
available, including

- Enhanced `image_tag` support chooses target-specific assets for you.
- Enhanced `image_tag` support conditionally includes assets specific to
  targets or features that you designate.
- The `target_name?()` helper allows you to selectively include or exclude
  content on a per-target basis.
- The `target_feature?()` helper allows fined-grained control over included
  content by managing features of a target instead of a target per se.
- Front matter `target` and `exclude` arrays can ensure entire pages are
  included or excluded on a target and/or feature specific basis.
- …and more.


Middlemac
---------

  This Middleman extension is a critical part of
[Middlemac](https://github.com/middlemac), the Mac OS X help building system
for Mac OS X applications. However this gem is not Mac OS X specific and can be
useful in any application for which you want to generate multiple targets.


License
-------

MIT. See `LICENSE.md`.


Changelog
---------

See `CHANGELOG.md` for point changes, or simply have a look at the commit
history for non-version changes (such as readme updates).
