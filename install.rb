#  install stuff assuming that this plugin is in vendor/plugins... sigh
#  try to back up-- use evil system dependant cp and back ticks.  this should only be used on a mac, anyway
example = File.join(File.dirname(__FILE__), 'lib', 'osx-terminal.yml')
target = File.join(RAILS_ROOT,"config","osx-terminal.yml")
puts "Attemping to back up: #{target}"
`cp  #{target} #{target}.bak`
puts "Creating: #{example}"
`cp -f #{example} #{target}`