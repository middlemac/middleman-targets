require 'middleman-cli'

################################################################################
# Envelops the class necessary to provide the `build_all`/`all` commands.
################################################################################
module Middleman::Cli

  ###################################################################
  # class Middleman::Cli::BuildAll
  #  Build all targets.
  ###################################################################
  class BuildAll < Thor::Group
    include Thor::Actions
    check_unknown_options!

    ############################################################
    # Build all targets.
    # @return [Void]
    ############################################################
    def build_all

      # The first thing we want to do is create a temporary application
      # instance so that we can determine the valid targets.
      app = ::Middleman::Application.new do
        config[:exit_before_ready] = true
      end

      build_list = app.config[:targets].each_key.collect { |item| item.to_s }
      bad_builds = []

      build_list.each do |target|
        bad_builds << target unless Build.start(['--target', target])
      end
      unless bad_builds.count == 0
        say
        say 'These targets produced errors during build:', :red
        bad_builds.each { |item| say "  #{item}", :red}
      end
      bad_builds.count == 0

    end

    Base.register(self, 'build_all', 'build-all', 'Builds all targets')
    Base.map('all' => 'build_all')

  end # class BuildAll

end # Module Middleman::Cli

