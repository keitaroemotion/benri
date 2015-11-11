# group file content 
# 1) target: target directory to put files on
# 2) file_root : file local root directory to deploy
# 2) file_path : file (relative) paths to deploy 
# 3) direct_deploy : true false

def addToArr(line, arr=Array.new)
    lsp = line.split('|')
    if lsp.size == 2
      key   = lsp[0].strip.chomp
      value = lsp[1].strip.chomp
      arr.push  [key, value]
    else
      puts "|Parse Error| #{line}" .red
    end
    return arr
end

def readGroupFile(groupRootDir, group)
    args = Array.new
    groupFile = fitSeparators "#{groupRootDir}/#{group}"
    if File.exist?(groupFile) == false
        puts "\n#{group} does not exist. \n".red
    else
      File.open(groupFile, "r:UTF-8").each_line do |line|
        args = addToArr line, args 
      end
    end
    return args
end

def usevim(file, vimapp)
  system "#{vimapp} #{file} "
end

def fitSeparators(path)
    return path.gsub("//","/")
end

def getValue(value)
  print "#{value}?: "
  res = $stdin.gets.chomp
  return res == "" ? getValue : res
end

def getDeployFlag(res)
  return  res == "y" ? "true" : "false"
end

def getTarget()
  user = getValue "user"   
  host = getValue "host"
  path = getValue "path"
  return fitSeparators "#{user}@#{host}:/#{path}"
end

def askWhich(delegates, rootdir)
  if delegates.size > 0
    i = 0
    puts
    puts "#{rootdir}".yellow
    puts
    delegates.each do |delegate|
      print "#{i}) "
      print File.dirname(delegate).gsub(rootdir, "").green
      print "/"
      print File.basename(delegate).cyan
      puts
      i = i+1
    end
  
    print "which? > "
    ret = $stdin.gets.chomp  #actually need to validate the input later...(is_numeric)
    return delegates[ret.to_i]
  end
end

#nw at latest /12  release
#Fri not possible /16 QC
#tomorrow  git review
# ketsu

def getFileValue(rootDir, keyword, delegates=Array.new)
  files = Dir["#{rootDir}/*".gsub("//","/")]

  files.each do |file|
      if File.directory? file
         delegates = getFileValue(file, keyword, delegates) 
      else
         basename = File.basename(file)
         if basename.downcase.start_with? keyword.downcase
           delegates.push file 
         end
      end
  end
  return delegates
end

def askIfPathOkay(res)
  def find(res)  
    if File.directory?(res) == false
      puts "\n\n#{File.basename(res)} is directory!\n\n".red
      return askIfPathOkay res
    end
    files = Dir[fitSeparators("#{res}/*")]
    files.each do |file|
      puts File.basename(file).cyan
    end

    print "[which?][b] >"
    _res = $stdin.gets.chomp.downcase
    if _res == "b"
      return askIfPathOkay(res) 
    end

    files.each do |file|
      bname = File.basename(file).downcase
      if bname == _res
        return askIfPathOkay file 
      end
      if bname.start_with? _res
        print "#{bname}? [Y/n] "
        _res = $stdin.gets.chomp.downcase
        if _res == "y" 
          return askIfPathOkay file 
        end
      end
    end
    puts "not selected...."
    return askIfPathOkay res
  end

  print "\n#{res} ".magenta
  print "\n\n[OK?] [Y:yes F:forward B:backward Q:quit]"
  _res = $stdin.gets.chomp.downcase.strip
  case _res 
  when "y"
    return res
  when "b"
    find File.dirname(res)
  when "f"
    find res
  when "q"
      return getLocalSourceRootDir
  when "" 
      return askIfPathOkay res
  else
      return askIfPathOkay (res+"/"+_res).gsub("//","/")
  end
end

def getLocalSourceRootDir()
     print "[Source Root Directory]: "
     res = $stdin.gets.chomp
     if res == ""
         puts "\n\n Blank Path!!! \n\n".red
         return getLocalSourceRootDir
     end
     home = %x( echo %home% )
     home = home.gsub("\\","/").chomp.strip.gsub("C:","")
     res = res.gsub("~",home).gsub("//","/")
     if File.directory?(res) 
         res = askIfPathOkay(res)
         if File.directory?(res) 
             return res
         else
             puts "\n\nROOT DIR HAVE TO BE DIRECTORY!!! \n\n".red
             return getLocalSourceRootDir
         end
     elsif File.directory?(File.dirname(res))
         def findInDir(dir, name)
           if name == ""
               print "which? "
               name = $stdin.gets.chomp
           end

           Dir["#{dir}/*"].each do |file|
             if File.directory?(file) == false
                 next
             end
             if File.basename(file).downcase.start_with? name.downcase
                puts file.cyan
                print "This?[y/n][f] "
                _res = $stdin.gets.chomp.downcase
                if (_res == "f")
                   Dir["#{file}/*"].each do |f|
                       puts File.basename(f).cyan
                   end
                   print "which?:[b] "
                   res = $stdin.gets.chomp.downcase
                   if res == "b"
                     Dir["#{File.dirname(file)}/*"].each do |f|
                       puts File.basename(f).cyan
                     end  
                     return findInDir(File.dirname(file), "")
                   else
                     return findInDir(file, res)
                   end
                end
                if (_res == "y")
                    puts file.green
                    return file
                end
             end
           end
           #puts "\n\nNOT FOUND!!! #{dir}\n\n".red
           return getLocalSourceRootDir
         end

         return findInDir(File.dirname(res), File.basename(res))
     end
     puts "The following Directory does not exist!!\n".red
     puts "#{res}".red
     puts ""
     getLocalSourceRootDir
end

def getRootDir()
  root = getLocalSourceRootDir
  puts
  print "[ROOT DIRECTORY SET]".yellow
  print "#{root}".cyan
  puts
  return root
end

def getFiles(root, files=Array.new)
    print "[File Name]: "
    fileValue = askWhich(getFileValue(root, $stdin.gets.chomp), root)
    puts "[File Selected]#{fileValue}"
    print "[Okay?][Y/n]:"
    if $stdin.gets.chomp.downcase == "y"
      files.push "file_path|" + fileValue.gsub(root, "")
      print "next?[Y/n]"
      return $stdin.gets.chomp.downcase == "y" ? getFiles(root, files) : files
    end
    getFiles(root, files)
end

def dispGroupFileContent(groupFile)
  puts "\n[FileName: #{File.basename(groupFile)}]\n"
  File.open(groupFile, "r:UTF-8") .each_line do |line| 
    if line.include? "|"  
      ls =  line.chomp.split('|')
      print "#{ls[0]}".green
      print "|"
      puts "#{ls[1]}".cyan
    end
  end
  puts 
end

def setGroupName()
  print "[group name]:"  
  res = ($stdin.gets+"").chomp.strip.downcase
  return res == "" ? setGroupName : res
end

def makeGroupFile(groupRootDir)
  groupName = setGroupName 
  groupFile = fitSeparators( "#{groupRootDir}/#{groupName}")

  init_target = ""
  init_target_r = ""
  init_files = Array.new
  init_deploy = ""
  init_root = ""

  if File.exist? groupFile
    dispGroupFileContent groupFile  
    print "the group "   
    print "#{groupName}".cyan
    lines = File.open(groupFile, "r:UTF-8").each_line.to_a
    lines.each do |line|
        lsp = line.split("|")
        if lsp.size < 2
            next
        end
        val =  lsp[1].strip.chomp
        case lsp[0].strip.chomp
        when "file_root"
          init_root = val
        when "file_path"
          init_files.push line
        when "target_r"
          init_target_r = val  
        when "target"
          init_target = val  
        when "deploy"
          init_deploy = val
        end
    end
    puts
    puts
  end

  def putex(val)
      if val != ""  
        print "CURRENT VALUE ["
        print val.cyan
        print "] "
        puts
      end
  end
  putex(init_target)
  print "[Set Temporary Directory][Y:yes]"
  target = ($stdin.gets.chomp.downcase == "y") ? getTarget : init_target      
  if target.include? "www"
    abort "Hell No.".red
  end
 # target.include?("/www")
 #   abort "HELL NO".red
 # end
  puts
  
  putex("size: "+init_files.size.to_s)
  print "add files? [y:Yes]"

  if init_root == ""
    root = getRootDir()
  else
    root = init_root
  end

  files = $stdin.gets.chomp.downcase == "y" ?  getFiles(root) : Array.new
  init_files.each do |ff|
    files.push "#{ff}"
  end
  puts
  putex(init_deploy)
  print "deploy directly? [Y:yes]"
  res = $stdin.gets.chomp.downcase
  deploy = (init_deploy == "" ) ? getDeployFlag(res) : init_deploy

  target_r = ""
  if res != "y" 
    putex(init_target_r)
    print "[Set Target RootDir][Y/n]"
    res = $stdin.gets.chomp.downcase
    if res == "y"
       print "Path:"
       res = $stdin.gets.chomp.downcase
       target_r = res
    else
       target_r = init_target_r
    end
  end

  files.push "target_r|#{target_r}"
  files.push "target|#{target}"
  files.push "deploy|#{deploy}"
  files.push "file_root|#{root}"

  f = File.open(groupFile, "w")
  puts
  files.each do |line|           
    f.puts line
    print "[WRITTEN] ".green
    puts line.gsub("|"," ==> ").yellow
  end
  f.close
  puts "\nWriting Completed\n".red
end


def backUpRemoteFiles()
end

def showGroupNames(groupRootDir)
  files = Dir[fitSeparators("#{groupRootDir}/*")]
  if files.size == 0
    puts "\nNo Group Files Found".red
    return
  else
    files.each do |file|
      print "[GROUP] ".cyan
      puts File.basename(file)
    end
  end
end

def chooseGroup(groupRootDir)
  puts
  showGroupNames groupRootDir
  puts
  print "which Group? > "
  res = $stdin.gets.chomp
  puts
  return res
end

def getPackageDir(rootDir)
  return "#{rootDir}/.spy_dir"
end

def getRemoteBaseDir(target, rootDir)
   #return "#{target}/#{File.basename(rootDir)}".gsub("//","/").split(':')[1]
   return "#{target}".gsub("//","/").split(':')[1]
end

def makeNinjaScript(remoteBaseDir, remoteRootDir, packageDir, files)
   chown   =  "" 
   contents  = Array.new
   rollbacks = Array.new
  
   base=remoteBaseDir
   back="#{remoteBaseDir}/backups"
   root=remoteRootDir

   xxx = Array.new

   # backup
   files.each do |file|
     xxx.push  "mkdir -p #{back}/#{File.dirname(file)}".gsub("//","/")
     contents.push  "cp #{root}/#{file} #{back}/#{file}".gsub("//","/")
   end

   # deploy
   files.each do |file|
     contents.push  "cp #{base}/#{file} #{root}/#{file}".gsub("//","/")
   end

   # rollback
   files.each do |file|
     rollbacks.push  "cp #{back}/#{file} #{root}/#{file}".gsub("//","/")
   end

   def writeContents(file, contents)
     commands = Array.new  
     str = ""
     contents.each do |content|
       xsp =  content.split(' ')
       #print "#{xsp[0]} "
       #print "#{xsp[1]} ".green
       #puts "#{xsp[2]} ".yellow
       commands.push content.strip.chomp
     end
     return commands
   end

   xxxf     =  "#{packageDir}/ninNin.dirmk.sh" 
   ninja    =  "#{packageDir}/ninNin.ninja.sh" 
   rollBack =  "#{packageDir}/ninNin.backup.sh" 

   return {
    "deploy"   =>  writeContents(ninja,    contents),
    "mkdir"    =>  writeContents(xxxf,    xxx ),
    "rollback" =>  writeContents(rollBack ,rollbacks)
   }

end

def packageFiles(rootDir, files, target, target_r)
    packageDir = getPackageDir(rootDir)
    FileUtils.mkdir_p packageDir
    com = makeNinjaScript(getRemoteBaseDir(target, rootDir), target_r, packageDir, files)

    files.each do |file|
        filename = File.basename(file) 
        destDir  = "#{packageDir}/#{File.dirname(file)}".gsub("//","/")
        FileUtils.mkdir_p destDir 
        FileUtils.copy "#{rootDir}/#{file}".gsub("//","/"), destDir
    end
    return [ packageDir , com]
end


#$sshinfo = "/benri/sshlogin.info"

def splitLine(line)
   lsp = line.strip.chomp.split('=') 
   return {
       :key => lsp[0],
       :val => lsp[1]
   }
end

def setHome()
   home =  %x( echo %home% )
   return home.chomp.strip.gsub("\\","/")
end


def ask(word, hash)
  print "#{word}? [None=Enter]"
  res = $stdin.gets.chomp
  if res != ""
    if word == "key_path"  
      def askKeyPath(res, word, hash)  
        res = res.gsub("~",setHome).chomp
        if File.directory?(res) 
           i = 0
           arr = Array.new
           Dir["#{res}/*".gsub("//","/")].each do |file|
             arr.push file  
             print "#{i}) "
             puts file.magenta
             i = i+1
           end
           print "which? "
           r =  $stdin.gets.chomp.to_i
           return askKeyPath(arr[r], word, hash)
        elsif File.exist? res
           hash[word] = res
           print "[WRITTEN] "
           puts  "#{res}\n".green
           return hash
        else
           puts "\n\n#{res} doesn't exist \n\n".red
           $stdin.gets.chomp
           return askKeyPath(res, word, hash)
        end
      end
      return askKeyPath(res, word, hash)
    else
      hash[word] = res
      print "[WRITTEN] "
      puts  "#{res}\n".green
    end
  end
  return hash
end

def readSSHLoginInfo(sshinfo, opt)
    lines =  File.open(sshinfo, "r:UTF-8").each_line.to_a  
    lines.each do |line|
      if line.include?("=") == false
        next
      end
      lsp = line.split("=")
      opt[lsp[0]] = lsp[1]
    end
    return opt 
end

def setSSHLoginInfo(sshinfo)
    # key_path :keys ~/.ssh/.pub
    # key_path=
    # passphrase=
    # password=
    authentic_keys = ["key_path","passphrase","password"]

    if File.exist?(sshinfo)
      lines =  File.open(sshinfo, "r:UTF-8").each_line.to_a  
      opt = Hash.new
      if lines.size == 0
        puts " ----   KEYS   ----"  
        puts
        authentic_keys.each do |k|  
          puts "[#{k}]".yellow
        end
        puts
      end

      lines.each do |line|
          if line.include?("=") == false
              next
          end
          lsp = line.split("=")
          opt[lsp[0]] = lsp[1]
          print lsp[0].cyan
          print " ==> "
          print lsp[1].green
          puts
      end
   
      puts "\nAVAILABLE KEYS\n"
      authentic_keys.each do |k|  
          print "["
          print "#{k}".cyan
          print "]"
      end
      puts


      print "which?:[key]"
      res = $stdin.gets.chomp
      if authentic_keys.include? res
         opt = ask(res, opt)
      elsif res == ""
      else
         puts "that key #{res} doesn't exist.  " 
      end


      f = File.open(sshinfo, "w:UTF-8")
      opt.keys.each do |key|
          f.puts "#{key}=#{opt[key]}"
      end
      f.close
    else
    
      opt = Hash.new
      authentic_keys.each do |term|
          opt = ask(term, opt)
      end

      f = File.open(sshinfo, "w:UTF-8")
      opt.each do |o|
        f.puts "#{o[0]}|#{o[1]}"
        print "[REGISTERED] ".red
        puts "#{o[0]}|#{o[1]}".green
      end
      f.close 
      puts "\n[DONE]\n"
    end
end

def scp_r(spydir, destRdir, target, opt, com, isrb)
  opt_tmp = Hash.new
  puts "#{spydir} #{target}/#{destRdir}" .green
  ts = target.split("@")

  tssp = ts[1].split(":")
  host = tssp[0]
  user = ts[0]
  dir  = tssp[1]

  conv = {
    "key_path"    => :keys,
    "password"    => :password,
    "passphrase"  => :passphrase
  }

  opt.each do |h|
    opt_tmp[conv[h[0]]] =  h[1].chomp
  end
  opt = opt_tmp

  require 'zlib'
  require 'rubygems/package'


  def compress(path)
    gem 'rubyzip'
    require 'zip/zip'
    require 'zip/zipfilesystem'

    path.sub!(%r[/$],'')
    archive = File.join(path,File.basename(path))+'.zip'
    FileUtils.rm archive, :force=>true

    Zip::ZipFile.open(archive, 'w') do |zipfile|
      Dir["#{path}/**/**"].reject{|f|f==archive}.each do |file|
        zipfile.add(file.sub(path+'/',''),file)
      end
    end
    return archive
  end

  deploys  = com["deploy"]
  mkdir    = com["mkdir"]
  rollbacks = com["rollback"]

  gzpath = compress(spydir)

  dest = "#{dir}/spy.zip".gsub("//", "/")
  puts
  puts "====    RESULT   ======"
  puts

  if dir.include? "/home/www"
    puts "\n\nINSANE\n\n".red
    abort
  end

  puts "host:#{host} user:#{user} rollback:#{isrb}"  

  Net::SSH.start(host, user, opt) do |ssh|

    if isrb == true
      rollbacks.each do |c| 
        print "[REPAIR] "
        puts c.green
        puts ssh.exec!(c)
      end
    else
      puts ssh.exec!("rm -rf #{dir}/*")
      puts ssh.exec!("mkdir -p #{dir}")
      ssh.scp.upload!(gzpath, dest, :recursive => true)
      #chmod
      puts "FROM:#{gzpath} TO:#{dest}".yellow
      print "[COMPRESSED]\n ".green
      puts ssh.exec!("unzip #{dest} -d #{dir}").yellow
      puts "[UNZIPPED]".green
      puts ssh.exec!("ls #{dir}").cyan

      mkdir.each do |c|
        print "[MKDIR] "
        puts c.red
        puts ssh.exec!(c)
      end

      deploys.each do |c|
        print c.include?("/backups/")  ? "[BACKUP] ".yellow  : "[DEPLOY] " 
        puts  c.cyan
        tmp = File.dirname(c.gsub("cp","").strip.split(' ')[1])
        puts  ssh.exec!("mkdir -p #{tmp}")
        puts  ssh.exec!(c)
      end
    end
  end
end

def test(rollback, groupRootDir, sshinfo, vimapp)
    files = Array.new
    fileRoot = ""
    target   = ""
    target_r   = ""
    readGroupFile(groupRootDir, chooseGroup(groupRootDir)).each do |line|
      case line[0]  
      when "file_path" 
          files.push line[1]
      when "target_r"
          target_r   = line[1]
      when "target"
          target   = line[1]
      when "file_root"
          fileRoot = line[1] 
      end
    end
    if fileRoot == ""
      puts "\n\nfile root blank\n\n"
      return
    elsif target == ""
      puts "\n\ntarget missing\n\n"
      return
    elsif files.size == 0

    elsif files.size == 0
      puts "\n\nfile empty\n\n".red
      return
    else
        ff = ""
        files.each do |file|
            ff += "#{fileRoot}/#{file} ".gsub("//","/")
        end
        usevim ff, vimapp      
    end
end


def interactive(rollback, groupRootDir, sshinfo)
    files = Array.new
    fileRoot = ""
    target   = ""
    target_r   = ""
    readGroupFile(groupRootDir, chooseGroup(groupRootDir)).each do |line|
      case line[0]  
      when "file_path" 
          files.push line[1]
      when "target_r"
          target_r   = line[1]
      when "target"
          target   = line[1]
      when "file_root"
          fileRoot = line[1] 
      end
    end
    if fileRoot == ""
      puts "\n\nfile root blank\n\n"
      return
    elsif target == ""
      puts "\n\ntarget missing\n\n"
      return
    elsif files.size == 0

    elsif files.size == 0
      puts "\n\nfile empty\n\n".red
      return
    else
      pdir = packageFiles fileRoot,  files, target, target_r
      opt = readSSHLoginInfo(sshinfo, Hash.new)
      puts
      puts
      scp_r pdir[0], target_r, target, opt, pdir[1], rollback
    end
end

def executeScpx(groupRootDir, sshinfo, vimapp)
    groupRootDir = groupRootDir.gsub("\\","/")
    if File.directory?(groupRootDir) == false
      FileUtils.mkdir_p groupRootDir  
    end
    puts
    puts "[direct_edit scpStory: d]"
    puts "[see ssh info : sl]"
    puts "[set ssh info : l]"
    puts "[make scpStory: m]"
    puts "[read scpStory: r]"
    puts "[show scpStory: s]"
    puts "[send    Files: f]"
    puts "[test:          t]"
    puts "[rollback     : rb]"
    print "\n> "
    case $stdin.gets.chomp.downcase
    when "sl"
        puts "------------------------".magenta
        puts
        File.open(sshinfo, "r:UTF-8").each_line do |line|
            lsp = line.split('=')
            print lsp[0].green
            print " ==> "
            print lsp[1].cyan
            puts
        end
        puts "------------------------".magenta
    when "t"
        test(true, groupRootDir, sshinfo, vimapp)
    when "l"
        setSSHLoginInfo(sshinfo)
    when "rb"
      interactive(true, groupRootDir, sshinfo)
    when "f"
      interactive(false, groupRootDir, sshinfo)
    when "d"
       group = chooseGroup(groupRootDir)
       i = 0
       lines = readGroupFile(groupRootDir, group)
       lines.each do |line|
         print "#{i}) "  
         puts "#{line}".cyan
         i=i+1     
       end
       print "which to del? [q:quit] > "
       res = $stdin.gets.chomp
       if res.downcase == "q"
           return
       end
       def is_number? string
         true if Float(string) rescue false
       end 

       if is_number?(res)  
         con = lines[res.to_i] 
         puts con.to_s.green
         print "[DELETE?][Y/n] "
         if $stdin.gets.chomp.downcase == "y"
           f = File.open((groupRootDir+"/"+group).gsub("//","/"), "w")
           i = 0
           lines.each do |line|
             key = line[0]
             val = line[1]
             if res.to_i != i
               f.puts "#{key}|#{val}"
             else
               print "[DELETED!]".red
               print "  [#{key}]".yellow
               puts "===> #{val}".cyan
             end
             i = i+1
           end
           f.close
         end
       end
    when "m"
       makeGroupFile groupRootDir   
    when "s"
       showGroupNames groupRootDir
    when "r"
       res = readGroupFile(groupRootDir, chooseGroup(groupRootDir))
       c = 0
       res.each do |line|
           if line[0] == "file_path"
               c += 1
           end
           print line[0].green
           print " ===> "
           puts  line[1].cyan
       end
       puts
       print "FILES: "
       puts c.to_s.magenta
       puts 
    else
    end
    executeScpx groupRootDir, sshinfo, vimapp
end

