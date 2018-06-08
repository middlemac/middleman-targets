require 'middleman-core'

################################################################################
# This extension provides Middleman the ability to build and serve multiple
# targets, and includes resource extensions and helpers to take advantage of
# this new feature.
# @author Jim Derry <balthisar@gmail.com>
################################################################################
class MiddlemanTargets < ::Middleman::Extension

  ############################################################
  # Define the options that are to be set within `config.rb`
  # as Middleman *application* (not extension) options.
  ############################################################

  define_setting :target, 'default', 'The default target to process if not specified.'
  define_setting :targets, { :default => { :features => {} } } , 'A hash that defines many characteristics of the target.'
  define_setting :target_magic_images, true, 'Enable magic images for targets.'
  define_setting :target_magic_word, 'all', 'The magic image prefix for image substitution.'

  # @!group Middleman Configuration

  # @!attribute [rw] config[:target]=
  # Indicates the current target that is being built or served. When
  # set in `config.rb` it indicates the default target if one is not
  # specified on the command line.
  # @return [Symbol] The target from `config[:targets]` that should
  #   be used as the default.
  # @note This is a Middleman application level config option.


  # @!attribute [rw] config[:targets]=
  # A hash that defines all of the characteristics of your individual targets.
  # The `build_dir` and `features` keys in a target have special meanings;
  # other keys can be added arbitrarily and helpers can fetch these for you.
  # A best practice is to assign the same features to _all_ of your targets and
  # toggle them `on` or `off` on a target-specific basis.
  # @example You might define this in your `config.rb` like this:
  #     config[:targets] = {
  #       :free =>
  #           {
  #               :sample_key => 'People who use free versions don\'t drive profits.',
  #               :build_dir  => 'build (%s)',
  #               :features   =>
  #                   {
  #                       :feature_advertise_pro => true,
  #                       :insults_user          => true,
  #                       :grants_wishes         => false,
  #                   }
  #           },
  #
  #           :pro =>
  #           {
  #               :sample_key => 'You are a valued contributor to our balance sheet!',
  #               :features =>
  #                   {
  #                       :feature_advertise_pro => false,
  #                       :insults_user          => false,
  #                       :grants_wishes         => true,
  #                   }
  #           },
  #       }
  # @return [Hash] The complete definition of your targets, their
  #   features, and other keys-value pairs that you wish to include.
  # @note This is a Middleman application level config option.


  # @!attribute [rw] config[:target_magic_images]=
  # This option is used to enable or disable the target magic images feature.
  # If it's `true` then the `image_tag` helper will attempt to substitute
  # target-specific images instead of the specified image, if the specified
  # image begins with `:target_magic_word`.
  # @return [Boolean] Specify whether or not automatic target-specific
  #   image substitution should be enabled.
  # @note This is a Middleman application level config option.


  # @!attribute [rw] config[:target_magic_word]=
  # Indicates the magic image prefix for image substitution with the
  # `image_tag` helper when `:target_magic_images` is enabled. For example
  # if you specify `all-image.png` and `pro-image.png` exists, then the
  # latter will be used by the helper instead of the former.
  # @return [String] Indicate the prefix that should indicate an image
  #   that should be substituted, such as `all`.
  # @note This is a Middleman application level config option.


  # @!attribute [rw] config[:build_dir]=
  # Indicates where **Middleman** will put build output. This standard config
  # value will be treated as a *prefix*; for example if the current target is
  # `:pro` and this value is set to its default `build`, then the actual build
  # directory will be `build (pro)/`.
  #
  # If the `build_dir` key is present for any of the `config[:targets]`, they
  # will override this setting.
  # @return [String] Indicate the build directory prefix that should be
  #   used for build output.
  # @note This is a Middleman application level config option.


  # @!endgroup


  ############################################################
  # initialize
  # @!visibility private
  ############################################################
  def initialize(app, options_hash={}, &block)

    super
    app.config[:target] = app.config[:target].to_sym

  end # initialize


  ############################################################
  # after_configuration
  #  Handle the --target cli setting.
  # @!visibility private
  #############################################################
  def after_configuration

    app.config[:target] = app.config[:target].downcase.to_sym
    requested_target = app.config[:target]
    valid_targets = app.config[:targets].each_key.collect { |item| item.downcase}

    if (build_dir = app.config[:targets][app.config[:target]][:build_dir])
      app.config[:build_dir] = sprintf(build_dir, requested_target)
    else
      app.config[:build_dir] = "#{app.config[:build_dir]} (#{requested_target})"
    end

    if valid_targets.count < 1
      say 'middleman-targets is activated but there are no targets specified in your', :red
      say 'configuration file.', :red
      exit 1
    end

    return if app.config[:exit_before_ready]


    if valid_targets.include?(requested_target)

      if app.config[:mode] == :server
        say "Middleman will serve using target \"#{requested_target}\".", :blue
      else
        say "Middleman will build using target \"#{requested_target}\".", :blue
        say "Build directory is \"#{app.config[:build_dir]}\".", :blue
      end

    else

      if requested_target
        say "The target \"#{requested_target}\" is invalid. Use one of these:", :red
      else
        say 'No target has been specified. Use one of these:', :red
      end
      valid_targets.each { |t| say "  #{t}", :red }
      exit 1

    end

  end # after_configuration


  ############################################################
  #  Sitemap manipulators.
  #    Add new methods to each resource.
  # @visibility private
  ############################################################
  def manipulate_resource_list(resources)

    resources.each do |resource|

      #--------------------------------------------------------
      # Returns an array of valid features for a resource
      # based on the current target, i.e., features that
      # are true for the current target.
      # @return [Array] Returns an array of features.
      #--------------------------------------------------------
      def resource.valid_features
        @app.config[:targets][@app.config[:target]][:features].select { |k, v| v }.keys
      end


      #--------------------------------------------------------
      # Determines if the resource is eligible for inclusion
      # in the current target based on the front matter data
      # `target` and `exclude` fields.
      #
      #   * If **frontmatter:target** is used, the target or
      #     feature appears in the frontmatter, and
      #   * If **frontmatter:exclude** is used, the target or
      #     enabled feature does NOT appear in the
      #     frontmatter
      #
      # In general you won't use this resource method because
      # resources will already be excluded before you have a
      # chance to check them, and so any leftover resources
      # will always return `true` for this method.
      # @return [Boolean] Returns a value indicating whether
      #   or not this resource belongs in the current target.
      #--------------------------------------------------------
      def resource.targeted?
        target_name = @app.config[:target]
            ( !self.data['target'] || (self.data['target'].include?(target_name) || (self.data['target'] & self.valid_features).count > 0) ) &&
            ( !self.data['exclude'] || !(self.data['exclude'].include?(target_name) || (self.data['exclude'] & self.valid_features).count > 0) )
      end


      #========================================================
      #  ignore un-targeted pages
      #    Here we have the chance to ignore resources that
      #    don't belong in this build based on front matter
      #    options.
      #========================================================
      resource.ignore! unless resource.targeted?


      #========================================================
      #  ignore non-target images
      #    Here we have the chance to ignore images from other
      #    targets if :target_magic_images is enabled.
      #========================================================
      if @app.config[:target_magic_images] && resource.content_type && resource.content_type.start_with?('image/')
        targets = @app.config[:targets].keys
        targets.delete(@app.config[:target])
        keep = true
        targets.each { |prefix| keep = keep && File.basename(resource.path) !~ /^#{prefix}\-/i }
        unless keep
          resource.ignore!
          say "  Ignoring #{resource.path} because this target is #{@app.config[:target]}.", :yellow
        end
      end


    end # resources.each

    resources

  end # manipulate_resource_list


  ############################################################
  # Helpers
  #   Methods defined in this helpers block are available in
  #   templates.
  ############################################################

  helpers do

    #--------------------------------------------------------
    # Return the current build target.
    # @return [Symbol] Returns the current build target.
    #--------------------------------------------------------
    def target_name
      @app.config[:target]
    end


    #--------------------------------------------------------
    # Is the current target `proposal`?
    # @param [String, Symbol] proposal Specifies a proposed
    #   target.
    # @return [Boolean] Returns `true` if the current target
    #   matches the parameter `proposal`.
    #--------------------------------------------------------
    def target_name?( proposal )
      @app.config[:target] == proposal.to_sym
    end


    #--------------------------------------------------------
    # Does the target have the feature `feature` enabled?
    # @param [String, Symbol] feature Specifies a proposed
    #   feature.
    # @return [Boolean] Returns `true` if the current target
    #   has the features `feature` and the features is
    #   enabled.
    #--------------------------------------------------------
    def target_feature?( feature )
      features = @app.config[:targets][@app.config[:target]][:features]
      features.key?(feature.to_sym) && features[feature.to_sym]
    end


    #--------------------------------------------------------
    # Attempts to return arbitrary key values for the key
    #   `key` for the current target.
    # @param [String, Symbol] key Specifies the desired key
    #   to look up.
    # @return [String, Nil] Returns the value for `key` in
    #   the `:targets` structure, or `nil` if it doesn’t
    #   exist.
    #--------------------------------------------------------
    def target_value( key )
      target_values = @app.config[:targets][@app.config[:target]]
      target_values.key?(key) ? target_values[key] : nil
    end


    #--------------------------------------------------------
    # Override the built-in `image-tag` helper in order to
    # support additional features.
    #
    #   * Automatic target-specific images. Note that this
    #     only works on local files, and only if enabled
    #     with the option `:target_magic_images`.
    #   * Target and feature dependent images using the
    #     `params` hash.
    #   * Absolute paths, which Middleman sometimes bungles.
    #
    # Note that in addition to the options described below,
    # `middleman-targets` inherits all of the built-in
    # option parameters as well.
    #
    # @param [String] path The path to the image file.
    # @param [Hash] params Optional parameters to pass to
    #   the helper.
    # @option params [String, Symbol] :target This image
    #   tag will only be applied if the current target is
    #   `target`.
    # @option params [String, Symbol] :feature This image
    #   tag will only be applied if the current target
    #   enables the feature `feature`.
    # @return [String] A properly formed image tag.
    # @group Extended Helpers
    #--------------------------------------------------------
    def image_tag(path, params={})
      params.symbolize_keys!

      # We won't return an image at all if a :target or :feature parameter
      # was provided, unless we're building that target or feature.
      return if params.include?(:target) && !target_name?(params[:target])
      return if params.include?(:feature) && !target_feature?(params[:feature])

      params.delete(:target)
      params.delete(:feature)


      # Let's try to find a substitutable file if the current image name
      # begins with the :target_magic_word
      if @app.config[:target_magic_images]
        path = extensions[:MiddlemanTargets].target_specific_proposal( path )
      end
      
      # Support automatic alt tags for absolute locations, too. Only do
      # this for absolute paths; let the extension do its own thing
      # otherwise.
      if @app.extensions[:automatic_alt_tags] && path.start_with?('/')
        alt_text = File.basename(file[:full_path].to_s, '.*')
        alt_text.capitalize!
        params[:alt] ||= alt_text
      end

      super(path, params)
    end # @endgroup

  end #helpers


  ############################################################
  # Instance Methods
  # @group Instance Methods
  ############################################################


  #########################################################
  # Returns a target-specific proposed file when given
  #   a user-specified file, and will return the same file
  #   if not enabled or doesn't begin with the magic word.
  #
  # This method allow other implementations of `image-tag`
  #   to honor this implementation’s use of automatic
  #   image substitutions.
  # @param [String] path Specify the path to the image
  #   for which you want to provide a substitution. This
  #   image doesn’t have to exist in fact if suitable
  #   images exist for the current target.
  # @return [String] Returns the substitute image if one
  #   was found, otherwise it returns the original path.
  #########################################################
  def target_specific_proposal( path )
    return path unless @app.config[:target_magic_images] && File.basename(path).start_with?( @app.config[:target_magic_word])

    real_path = path.dup
    magic_prefix = "#{app.config[:target_magic_word]}-"
    wanted_prefix = "#{app.config[:target]}-"

    # Enable absolute paths, too.
    real_path = if path.start_with?('/')
                  File.expand_path(File.join(app.config[:source], real_path))
                else
                  File.expand_path(File.join(app.config[:source], app.config[:images_dir], real_path))
                end

    proposed_path = real_path.sub( magic_prefix, wanted_prefix )
    file = app.files.find(:source, proposed_path)
    
    if file && file[:full_path].exist?
      path.sub( magic_prefix, wanted_prefix )
    else
      path
    end

  end
 
 
  #########################################################
  # Output colored messages using ANSI codes.
  # @!visibility private
  #########################################################
  def say(message = '', color = :reset)
    colors = { :blue   => "\033[34m",
               :cyan   => "\033[36m",
               :green  => "\033[32m",
               :red    => "\033[31m",
               :yellow => "\033[33m",
               :reset  => "\033[0m",
    }

    if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
      puts message
    else
      puts colors[color] + message + colors[:reset]
    end
  end # say


  ############################################################
  # Instance Methods Exposed to Config
  # @group Instance Methods Exposed to Config
  ############################################################
  expose_to_config :middleman_target


  #########################################################
  # Expose the current target to config.rb.
  #########################################################
  def middleman_target
    @app.config[:target]
  end 


end # class MiddlemanTargets
