################################################################################
# Sample Project for middleman-targets
################################################################################

#==========================================================================
# Conflicting helpers
#  middleman-targets extends the built-in `image_tag` helper, but so do
#  some of Middleman's other extensions. To avoid issues, make sure you
#  activate those other extensions, first, before :MiddlemanTargets.
#==========================================================================
activate :automatic_image_sizes
activate :automatic_alt_tags


#==========================================================================
# Extension Setup
#  Note that middleman-targets adds configuration parameters to the base
#  Middleman application (supported feature in 4.0+); there are *not*
#  extension options.
#==========================================================================
activate :MiddlemanTargets

# Set the default target. This is the target that is used automatically
# when you `middleman build` or `middleman server` without using the
# `targets` CLI option.
config[:target] = :pro

# Setup your targets and their features. You can use any target names and
# feature names that you like, but keep in mind that the key :features is
# required for each of your targets.
#
# The key :build_dir for any target, if used, will override the global
# :build_dir setting. You can use a specific string for this setting, and
# this string can optionally include a single %s sprintf placeholder which
# will be filled with the target name.
#
# You can add your own keys to each target for your own uses; the
# `sample_key` below is an example of such. The generic `target_value()`
# helper can retrieve these values, or you can write your own helpers.
config[:targets] = {
  :free =>
      {
      :sample_key => 'People who use free versions don\'t drive profits.',
      :build_dir  => 'build (%s)',
      :features   =>
          {
          :feature_advertise_pro => true,
          :insults_user          => true,
          :grants_wishes         => false,
          }
      },

  :pro =>
      {
      :sample_key => 'You are a valued contributor to our balance sheet!',
      :features =>
          {
          :feature_advertise_pro => false,
          :insults_user          => false,
          :grants_wishes         => true,
          }
      },
}

# By enabling :target_magic_images and using middleman-targets' image helper,
# then target specific images will be used instead of the image you specify,
# *if* that image name is prefixed with :target_magic_word. For example, you
# might request "all-my_image.png", and "pro-my_image.png" (if it exists) will
# be used in your :pro target instead.
#
# Important: when this is enabled, images from *other* targets will *not* be
# included in the build! In the example above, *any* image prefixed with "free-"
# would not be included in the output directory.
config[:target_magic_images] = true
config[:target_magic_word] = 'all'

# Note that output will now use this directory as a *prefix*; if the target
# is :pro, then the actual build directory will be `build (pro)/`. If the
# build_dir key is present for any of the :targets, they will override this
# setting.
config[:build_dir] = 'build'


#==========================================================================
# Regular Middleman Setup
#==========================================================================

config[:relative_links] = true
activate :syntax


#==========================================================================
# Helpers
#  These helpers are used by the sample project only; there's no need
#  to keep them around in your own projects.
#==========================================================================

# Methods defined in the helpers block are available in templates
helpers do

  def product_name
    'middleman-targets'
  end

  def product_version
    '1.0.7.wip'
end

  def product_uri
    'https://github.com/middlemac'
  end

end

# Build-specific configuration
configure :build do
  # Minify CSS on build
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript
end
