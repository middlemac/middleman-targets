################################################################################
# extension.rb
#  This file constitutes the framework for the bulk of this extension.
################################################################################
require 'middleman-core'

class MiddlemanTargets < ::Middleman::Extension

  ############################################################
  # Define the options that are to be set within `config.rb`
  # as Middleman *application* (not extension) options.
  ############################################################
  define_setting :target, 'default', 'The default target to process if not specified.'
  define_setting :targets, { :default => { :features => {} } } , 'A hash that defines many characteristics of the target.'
  define_setting :target_magic_images, true, 'Enable magic images for targets.'
  define_setting :target_magic_word, 'all', 'The magic image prefix for asset substitution.'


  ############################################################
  # initialize
  ############################################################
  def initialize(app, options_hash={}, &block)

    super
    app.config[:target] = app.config[:target].to_sym

  end # initialize


  ############################################################
  # after_configuration
  #  Handle the --target cli setting.
  #############################################################
  def after_configuration

    return if app.config[:exit_before_ready]

    app.config[:target] = app.config[:target].downcase.to_sym
    requested_target = app.config[:target]
    valid_targets = app.config[:targets].each_key.collect { |item| item.downcase}

    if valid_targets.count < 1
      say 'middleman-targets is activated but there are no targets specified in your', :red
      say 'configuration file.', :red
      exit 1
    end

    if valid_targets.include?(requested_target)

      if app.config[:mode] == :server
        say "Middleman will serve using target \"#{requested_target}\".", :blue
      else
        if (build_dir = app.config[:targets][app.config[:target]][:build_dir])
          app.config[:build_dir] = sprintf(build_dir, requested_target)
        else
          app.config[:build_dir] = "#{app.config[:build_dir]} (#{requested_target})"
        end
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
  ############################################################
  def manipulate_resource_list(resources)

    resources.each do |resource|

      #--------------------------------------------------------
      #  valid_features
      #    Returns an array of valid features for this page
      #    based on the current target, i.e., features that
      #    are true for the current target. These are the
      #    only features that can be used with frontmatter
      #    :target or :exclude.
      #--------------------------------------------------------
      def resource.valid_features
        @app.config[:targets][@app.config[:target]][:features].select { |k, v| v }.keys
      end


      #--------------------------------------------------------
      #  targeted?
      #    Determines if the resource is eligible for
      #    inclusion in the current page based on the front
      #    matter `target` and `exclude` data fields:
      #      - if frontmatter:target is used, the target or
      #        feature appears in the frontmatter, and
      #      - if frontmatter:exclude is used, the target or
      #        enabled feature does NOT appear in the
      #        frontmatter.
      #
      #    In general you won't use this resource method
      #    because resources will already be excluded before
      #    you have a chance to check them, and so any
      #    leftover resources will always return true for
      #    this method.
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
  #  Helpers
  #    Methods defined in this helpers block are available in
  #    templates.
  ############################################################

  helpers do

    #--------------------------------------------------------
    # target_name
    #   Return the current build target.
    #--------------------------------------------------------
    def target_name
      @app.config[:target]
    end


    #--------------------------------------------------------
    # target_name?
    #   Is the current target `proposal`?
    #--------------------------------------------------------
    def target_name?( proposal )
      @app.config[:target] == proposal.to_sym
    end


    #--------------------------------------------------------
    # target_feature?
    #   Does the target have the feature `feature`?
    #--------------------------------------------------------
    def target_feature?( feature )
      features = @app.config[:targets][@app.config[:target]][:features]
      features.key?(feature.to_sym) && features[feature.to_sym]
    end


    #--------------------------------------------------------
    # target_value( key )
    #   Attempts to return arbitrary key values for the
    #   current target.
    #--------------------------------------------------------
    def target_value( key )
      target_values = @app.config[:targets][@app.config[:target]]
      target_values.key?(key) ? target_values[key] : nil
    end


    #--------------------------------------------------------
    # image_tag
    #   Override the built-in version in order to support:
    #    - automatic target-specific images. Note that this
    #      only works on local files.
    #    - target and feature dependent images.
    #    - absolute paths
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
    end


  end #helpers


  ############################################################
  # Instance Methods
  ############################################################


  #--------------------------------------------------------
  # target_specific_proposal( file )
  #  Returns a target-specific proposed file when given
  #  a user-specified file, and will return the same file
  #  if not enabled or doesn't begin with the magic word.
  #--------------------------------------------------------
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
 
 
  #--------------------------------------------------------
  # say
  #  Output colored messages using ANSI codes.
  #--------------------------------------------------------
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


end # class MiddlemanTargets
