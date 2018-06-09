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
      # Determine the valid targets.
      app = ::Middleman::Application.new do
        config[:exit_before_ready] = true
      end
      app_config = app.config.clone
      app.shutdown!
      
      # Because after_configuration won't run again until we
      # build, we'll fake the strings with the one given for
      # the default. So for each target, gsub the target for
      # the initial target already given in config.
      app_config[:targets].each do |target|
        target_org = app_config[:target].to_s
        target_req = target[0].to_s
        path_org = app_config[:build_dir]
        path_req = path_org.reverse.sub(target_org.reverse, target_req.reverse).reverse
        say "#{target_req}, #{File.expand_path(path_req)}", :cyan
      end        
    end
    
    Base.register(self, 'list_all', 'list_all', 'Lists all targets')

  end # class ListAll

end # Module Middleman::Cli

