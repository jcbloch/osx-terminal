class Git
  
  def self.current_branch
    `cat .git/HEAD`.chomp.split("/").last rescue "*"
  end
  
  def self.get(*args)
    `git config --get #{var(args)}`.chomp
  end
  
  def self.set(*args)
     value = args.pop
    `git config #{var(args)} #{value.inspect}`
  end

  def self.var(arr)
    arr.length == 1 ? arr.first :  arr.map{|v| "\"#{v}\""}.join('.')
  end
  
  def self.exists?
    # this could be WAY better...
    ! `which git`.chomp.empty? && File.exists?('.git/config')
  end
  
  def self.hook(hook_file , source_path)
    # ex: hook_file =  "post-checkout"
    # git and file must exist, doh!
    hook_file_path = ".git/hooks/#{hook_file}"
    `cp #{hook_file_path} #{hook_file_path}.bak`
    `cp -f #{source_path} #{hook_file_path}`
    # do not use ruby chmod-- you might get wrong permissions
    # use whatever user is logged in...
    `chmod 755 .git/hooks/post-checkout`
  end

end