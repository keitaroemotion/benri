require 'rubygems'
require 'git'
require 'colorize'


def enlist(list, func, res=Array.new)
  begin  
    list.each do |log|
      res.push func.call(log)
    end
    return res
  rescue Error => e
    puts "\n error at enlist #{e} \n"  
  end
end


def dispCommitList(logs)
  i = 0
  logs.each do |log|
    print "#{i}) "
    print log.sha[0..7].green
    print " "
    puts log.message.red
    i = i + 1
  end
end

def isPlus(d)
  return d.start_with? "+"
end

def isMinus(d)
  return d.start_with? "-"
end

def isNone(d)
  return !(d.start_with? "+") || (d.start_with?("-"))
end

def showPlus(d)
  if isPlus(d)
    puts d.green
  end
  d
end

def showMinus(d)
  if isMinus(d)
    puts d.red
  end
  d
end

def add(g, file)
  g.add file
  puts "\n\n#{file} added!! \n\n".green
end

def gitpush(working_dir)
  g = Git.open(working_dir)
  remotes = Array.new
  i = 0
  g.remotes.each do |remote|
      print "#{i}) "
      puts "#{remote.to_s}".cyan
      remotes.push remote
      i = i+1
  end
  print "which? "
  res = $stdin.gets.chomp.to_i
  remname = remotes[res]
  target_remote = g.remote(remname)

  i = 0
  branches = Array.new
  g.branches.each do |branch|
    print "#{i}) "  
    puts branch.to_s.green
    branches.push branch
    i = i+1
  end
  print "which? "
  res = $stdin.gets.chomp.to_i
  target_branch = branches[res]

  puts "\n\ngit push #{remname} #{target_branch}\n\n" .yellow
  print "OK?[Y/n] "
  res = $stdin.gets.chomp.downcase
  if res == "y"
    g.push remname, target_branch
  end
end

def gitrm(working_dir, file)
  g = Git.open(working_dir)
  g.remove file
end

def gitadd(working_dir, file)
  g = Git.open(working_dir)
  add(g, file)
end

def gitcom(working_dir)
  g = Git.open(working_dir)
  print "message:"
  msg = $stdin.gets.chomp
  if msg == ""
    puts "\n\nmsg nil\n\n".red 
    gitcom(working_dir)
  else
    g.commit msg
    puts "\n\nCOMMITED\n\n"
  end
end


def showElse(d)
  if isNone(d)
    puts d
  end
  d
end

def dispDiff(diff) 
  diff.each do |d|
    showPlus(showMinus(showElse(d)))
  end
end

def extractTargetDiff(diff, func, arr=Array.new)
  begin  
    diff.each do |d|
      if (func.call(d))
        arr.push d
      end
    end
    return arr
  rescue
    puts "\nerror at extractTargetDiff\n"  
  end
end

def checkOut(g, version)
  g.log  
  #return g.checkout(version)
end

def compareHashes(g, logs, hashes=Array.new)
  begin 
    if hashes.size == 0

      dispCommitList(logs)
      print "Select hashes[space separated:]"
      res = $stdin.gets.chomp.strip

      idx1 = logs.size-1
      idx2 = res.to_i 
      if res.include?(" ")  
        resSp = res.split(' ')
        idx1 = resSp[0].to_i
        idx2 = resSp[1].to_i     
      end

      puts 

      if (idx1 == idx2)
        puts "\n\nHashes Same!!!\n\n".red
        return compareHashes(g, logs)
      end

      print "#{logs[idx1].sha[0..7]} ".cyan
      puts "| #{logs[idx1].message} ".magenta
  
      print "#{logs[idx2].sha[0..7]} ".yellow
      puts "| #{logs[idx2].message} ".magenta
  
      diff = g.diff(logs[idx1].sha, logs[idx2].sha)
      return [diff.to_s.split("\n"), diff.stats, logs[idx1].sha, logs[idx2].sha]
    else
      puts
      puts hashes[0].magenta
      puts hashes[1].yellow
      puts

      diff = g.diff(hashes[0], hashes[1])
      return [diff.to_s.split("\n"), diff.stats, hashes[0], hashes[1]]
    end
  rescue
    puts "\nError at compareHashes\n"  
  end
end


def gitOpen(dir)
  Encoding.default_external = 'UTF-8'
  return Git.open(dir)
end

def getGitLog(g)
  Encoding.default_external = 'UTF-8'
  return enlist(g.log,      Proc.new { |log| log  }) # since.. cond
end

def getGitBranches(g)
  return {
    :local    => enlist(g.branches.local,  Proc.new { |log| log  }),
    :remotes  => enlist(g.branches.remote, Proc.new { |log| log  })
  }
end

def executeGit(working_dir)

  if File.exist?(working_dir) == false
    puts "\n\nFile Not Found\n\n".red  
    return  
  end

  Encoding.default_external = 'UTF-8'

  g = Git.open(working_dir)
  g.index
  puts g.dir

  logs       = enlist(g.log,      Proc.new { |log| log  }) # since.. cond
  log_hashes = enlist(g.log,      Proc.new { |log| log.sha  })
  local_branches   = enlist(g.branches.local,  Proc.new { |log| log  })
  remote_branches  = enlist(g.branches.remote, Proc.new { |log| log  })

  puts log_hashes
  puts local_branches
  puts remote_branches

  diff = compareHashes g, logs
  #dispDiff diff[0]

  plus  = extractTargetDiff(diff[0], Proc.new {|d| isPlus(d) } )
  minus = extractTargetDiff(diff[0], Proc.new {|d| isMinus(d) } )

  diff[1].keys.each do |x|
    puts x
  end
  #puts plus.to_s.green
  #puts minus.to_s.red

end
