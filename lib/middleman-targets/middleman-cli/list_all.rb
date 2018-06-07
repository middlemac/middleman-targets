require 'middleman-cli'

################################################################################
# Envelops the class necessary to provide the `list_all` command.
################################################################################
module Middleman::Cli

  ###################################################################
  # class Middleman::Cli::ListAll
  #  List all targets.
  ###################################################################
  class ListAll < Thor::Group
    include Thor::Actions
    check_unknown_options!

    ############################################################
    # List all targets.
    # @return [Void]
    ############################################################
    def list_all
      # The first thing we want to do is create a temporary application
      # instance so that we can determine the valid targets.
      app = ::Middleman::Application.new do
        config[:exit_before_ready] = true
      end
      config = app.config.clone
      app.shutdown!

      config[:targets].each do |target|
        out_path = ''
        requested_target = target[0]
        if (build_dir = config[:targets][requested_target][:build_dir])
          out_path = sprintf(build_dir, requested_target.to_s)
        else
          out_path = "#{config[:build_dir]} (#{requested_target.to_s})"
        end

        out_path = File.expand_path(out_path)

        say "#{requested_target.to_s}, #{out_path}", :cyan
        
      end
    end
    
    Base.register(self, 'list_all', 'list_all', 'Lists all targets')

  end # class ListAll

end # Module Middleman::Cli

