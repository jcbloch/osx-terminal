require 'rubygems'  # Rails console safe ???

# will NOT crash if gem is missing on Load, only on run
# so-- if you are NOT on osx, don't run this code

begin
 require 'appscript'
 # to install:  see http://appscript.sourceforge.net/rb-appscript
rescue LoadError
  Appscript = false
rescue MissingSourceFileError
  Appscript = false
end


class Terminal
  
  def self.available?
    # this actually "loads" the appscriot stuff, so it can be slow
    (Appscript && app && process ? true : false) rescue false
  end
  
  @@window = 1
  @@tab = "selected_tab"
  @@new_cmd = "n" # for a window
  
  def self.new(options={})
    process.keystroke( @@new_cmd, :using => :command_down)
    options.to_a.each do |k,v|
      self.send("#{k}=", v)
    end
    self
  end
  
  def self.app
    @@app ||= Appscript.app("Terminal")
  end
  
  def self.process
    # always runs on top most target / window / tab
    @@process ||=Appscript.app("System Events").processes["Terminal"]
  end
  
  def self.title=(title)
    return self if !title
    # this only works on the current active window
    process.keystroke("I", :using => :command_down)
    process.windows[1].tab_groups[1].text_fields[1].value.set(title)
    process.keystroke("\t")
    process.keystroke("\r")
    close
  end
  
  def self.title(title)
    self.title =title
    self
  end
  
  def self.move(n)
    c = n > 0 ? "}" : "{"
    n.abs.times { process.keystroke(c, :using => :command_down) }
    self
  end
  
  def self.settings_set=(settings_set)
    self.target.current_settings.set( app.settings_sets[settings_set] ) if settings_set
    self
  end
  
  def self.do_script(*cmds)
    # args should be all strings...
    cmds.each do |cmd|
      app.do_script(cmd, :in => self.target)
    end
    self
  end
  
  def self.close
    # closes TOP window, whatever it is...
    process.keystroke("w", :using => :command_down)
    self
  end
  
  def self.window(n=nil)
    @@window = n ? n.to_i : 1
    @@new_cmd = "n"
    self
  end
  
  def self.tab(n=nil)
    @@tab =  n ? n : :selected_tab
    @@new_cmd = "t"
    self
  end
  
  def self.target
    # target "window" (really a tab)
    case @@tab
    when Integer
      app.windows[@@window].tabs[@@tab] 
    when "selected_tab", :selected_tab, :selected
      app.windows[@@window].selected_tab
    else
      # current tab for window-- usually same as selected
      app.windows[@@window]
    end
  end
  
end