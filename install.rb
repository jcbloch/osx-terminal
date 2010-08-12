#  install stuff assuming that this plugin is in vendor/plugins... sigh
#  try to back up-- use evil system dependant cp and back ticks.  this should only be used on a mac, anyway
example = File.join(File.dirname(__FILE__), 'lib', 'osx-terminal.yml')
target = File.join(RAILS_ROOT,"config","osx-terminal.yml")
puts "osx-terminal - Attemping to backup: #{target}"
`cp  #{target} #{target}.bak`
puts "osx-terminal - Creating: #{example}"
`cp -f #{example} #{target}`