OSXTERMINAL = "osxterminal"  # root name-space for git config

require 'erb'
# ugly. bad
require File.join(File.dirname(__FILE__), '../lib', 'git.rb')
require File.join(File.dirname(__FILE__), '../lib', 'terminal.rb')

namespace :terminal do
  
  desc "Sets up git so terminal.app responds to git checkout ...uses config/osx-terminal.yml"
  task :git_init => [:git_config, :git_hook]
  
  desc "Sets up git config based on config/osx.yml to work with terminal.app"
  task :git_config=>[:git_set_settings_set, :git_set_background_colors] 
  
  desc "Writes git config background colors"
  task :git_set_background_colors do
    (osx_config["background_colors"] || []).each do |color_spec|
      case color_spec
      when Hash
        branch = color_spec.to_a[0][0]
        color  = color_spec.to_a[0][1]
        puts "Setting git config backgroundcolor for: #{branch}"
        Git.set(OSXTERMINAL, branch, :backgroundcolor, color)
      else
        puts "Setting git config default backgroundcolor"
        Git.set(OSXTERMINAL, :backgroundcolor, color_spec)
      end
    end
  end
  
  
  desc "Writes the git_settings_set to the git config if they exist"
  task :git_set_settings_set do
    if osx_config["settings_set"]
      puts "Setting git config settingsset"
      Git.set(OSXTERMINAL, :settingsset, osx_config["settings_set"]) 
    end
  end
  
  desc "Writes git post-checkout hook that will execute after backing up existing"
  task :git_hook do
     Git.hook("post-checkout", File.join(File.dirname(__FILE__), '../lib', 'post-checkout'))
  end
  
  
  desc "Opens terminal window and tabs as per osx-terminal.yml"
  task :start=>[:open_tabs] do
    if Git.exists?
      if osx_config["sync"]
        puts "syncing git branch..."
        ruby ".git/hooks/post-checkout"
      end
    else
      puts "No git for this app"
    end
    if (cu = osx_config["cleanup"]) && tabs
      tabs_to_move =  cu == true ? (-1* tabs.length) : cu.to_i
      puts "Cleaning up (#{ tabs_to_move})"
      Terminal.move( tabs_to_move)
    end
    # this will close whatever is current
    # hence, getting cleanup correct is important
    Terminal.close if osx_config["close"]
  end
  
  desc "Opens new tabs and runs shell commands as spec'ed in yml"
  task :open_tabs do
    tabs.each do |tab|
      puts "New tab for: #{tab["title"].inspect}"
      Terminal.tab.new(:title=>tab["title"], :settings_set=>tab["settings_set"]).do_script(tab["cmds"])
    end
  end
  
end

#
# pwd is rails root. ugly... fix in rails 3
#


def tabs
  osx_config["tabs"]
end

def osx_config
  config_file = File.join(RAILS_ROOT, "config", "osx-terminal.yml")
  YAML.load(ERB.new((IO.read( config_file))).result)
end
