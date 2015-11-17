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


def fitSeparators(path)
    return path.gsub("//","/")
end

def getValue(value)
  print "#{value}?: "
  res = $stdin.gets.chomp
  finish res
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
    finish ret
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
    finish _res
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
        finish _res
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
     finish res
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
                finish _res
                if (_res == "f")
                   Dir["#{file}/*"].each do |f|
                       puts File.basename(f).cyan
                   end
                   print "which?:[b] "
                   res = $stdin.gets.chomp.downcase
                   finish _res
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
    print "[File Name[q: Quit]]: "

    res = $stdin.gets.chomp.downcase

    if res == "q"
      return files 
    end

    fileValue = askWhich(getFileValue(root, res), root)
    puts "[File Selected]#{fileValue}"
    print "[Okay?][Y/n]:"
    res = $stdin.gets.chomp.downcase 
    if res == "q"
      return files 
    end

    if res == "y"
      files.push "file_path|" + fileValue.gsub(root, "")
      print "next?[Y/n]"
      res = $stdin.gets.chomp.downcase
      if res == "q"
        return files 
      end
      return res == "y" ? getFiles(root, files) : files
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
  finish res
  return res == "" ? setGroupName : res
end

def setFileRoot()
  print "[file root]:"  
  res = ($stdin.gets+"").chomp.strip.downcase
  finish res
  return res == "" ? setFileRoot : res
end

def putex(val, msg="")
  if val != ""  
    print "\nCURRENT VALUE [#{val.cyan}]"
    print (msg != "" ? "[#{msg}]\n".red : "\n")
  end
end

def getFileRoot(init_root)
  print "Enter Local File Root[q]: "
  res = $stdin.gets.chomp
  finish res
  res = res.gsub("\\","/").gsub("//","/").gsub("c:","").gsub("C:","")
  if res.downcase == "q"
      return init_root
  end
  if File.directory? res
      return res
  else
      puts "\n!!!INVALID!!!\n"
      return getFileRoot init_root
  end
end

def makeGroupFile(groupRootDir)
  # show  
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

  putex(init_root, "your local repo")
  print "[Set Local Root File Directory To Deploy][Y:yes][q]"
  resp = $stdin.gets.chomp.downcase
  resp == "q" ? return : ""

  if(resp == "y") 
     root = getFileRoot(init_root)
  else
     root = init_root
  end
  puts root.magenta
  putex(init_target, "remote repo (dummy)")
  print "[Set Temporary Directory][Y:yes]"
  res = $stdin.gets.chomp.downcase
  finish res
  target = (res == "y") ? getTarget : init_target      
  
  if target.include? "www"
    abort "Hell No.".red
  end
  puts
  
  putex("size: "+init_files.size.to_s, "files to deploy")
  print "add files? [y:Yes]"
  res = $stdin.gets.chomp.downcase
  finish res
  files = res == "y" ?  getFiles(root) : Array.new
  init_files.each do |ff|
    files.push "#{ff}"
  end
  puts
  
  def removeFiles(files)
    oldfiles = files
    print "Wanna Remove Some Files? [Y/n]"
    res = $stdin.gets.chomp.downcase
    finish res
    if res == "y"
      def clean(files)  
        files.each do |f|
          puts f.cyan
          print "Remove ? [Y/n/q]" 
          case $stdin.gets.chomp.downcase 
          when "y"
            files.delete f  
            puts "[DELETED!! ]#{f}".red
          when "q"
            return files  
          else
          end
        end
        return files
      end
      files = clean files
      puts
      puts "------------------|YOUR DIRECTORY|-------------------"
      files.each do |ff|
        puts ff.cyan
      end
      puts
      puts "------------------------=======================------"

      print "OK? [Y/n]"
      if  $stdin.gets.chomp == "n"
        return removeFiles(oldfiles)
      end
    end
    return files
  end

  files = removeFiles(files)

  deploy = ""

  target_r = ""


 # if res != "y" 
   putex(init_target_r, "remote source directory (sensitive)")
   print "[Set Target RootDir][Y/n]"
   res = $stdin.gets.chomp.downcase
   if res == "y"
      print "Path[q]:"
      res = $stdin.gets.chomp.downcase
      if res == "q"
        target_r = init_target_r
      else
        target_r = res
      end
   else
      target_r = init_target_r
   end
#  end

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

def quit(res)
  if res.downcase == "q"
      puts " CANCELLED ".red
      return true 
  end
  return false
end

def finish(res)
  if quit(res)
     abort 
  end
end

def chooseGroup(groupRootDir)
  puts
  showGroupNames groupRootDir
  puts
  print "which Group? > "
  res = $stdin.gets.chomp
  finish res 
  puts
  return res
end

def getPackageDir(rootDir)
  return "#{rootDir}/.spy_dir"
end

def getRemoteBaseDir(target, rootDir)
   return "#{target}".gsub("//","/").split(':')[1]
end

def makeNinjaCommands(remoteBaseDir, remoteRootDir, packageDir, files)
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

   def writeContents(contents)
     commands = Array.new  
     str = ""
     contents.each do |content|
       xsp =  content.split(' ')
       commands.push content.strip.chomp
     end
     return commands
   end

   return {
    "deploy"   =>  writeContents(contents),
    "mkdir"    =>  writeContents(xxx),
    "rollback" =>  writeContents(rollbacks)
   }

end

def packageFiles(rootDir, files, target, target_r)
    packageDir = getPackageDir(rootDir)
    FileUtils.mkdir_p packageDir
    com = makeNinjaCommands(getRemoteBaseDir(target, rootDir), target_r, packageDir, files)

    files.each do |file|
        filename = File.basename(file) 
        destDir  = "#{packageDir}/#{File.dirname(file)}".gsub("//","/")
        FileUtils.mkdir_p destDir 
        theFile = "#{rootDir}/#{file}".gsub("//","/")
        if File.exist? theFile
          FileUtils.copy "#{theFile}", destDir
        else
          puts "[FILE NOT FOUND] #{theFile}"
        end
    end
    return [ packageDir , com]
end

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
  finish res 
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
           print "which?[q] "
           r =  $stdin.gets.chomp

           if r.downcase == "q"
             return false 
           end
           return askKeyPath(arr[r.to_i], word, hash)
        elsif File.exist? res
           hash[word] = res
           print "[WRITTEN] "
           puts  "#{res}\n".green
           return hash
        else
           puts "\n\n#{res} doesn't exist \n\n".red
           print ">"
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
      finish res
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
          res = ask(term, opt)
          if res != false
              opt = res
          end
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

def getScpRLoginInfo(spydir, target, destRdir, opt)
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

  return { 
     :opt  => opt_tmp,
     :host => host,
     :user => user,
     :dir  => dir
  }

end

def compress(path)
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

def scp_r(spydir, destRdir, target, opt, com, isrb)
  begin
    opt = getScpRLoginInfo(spydir, target, destRdir, opt)

    deploys  = com["deploy"]
    mkdir    = com["mkdir"]
    rollbacks = com["rollback"]

    gzpath = compress(spydir)

    dir = opt[:dir]

    dest = "#{dir}/spy.zip".gsub("//", "/")
    puts
    puts "====    RESULT   ======"
    puts

    if dir.include? "/home/www"
      puts "\n\nINSANE\n\n".red
      abort
    end


    Net::SSH.start(opt[:host], opt[:user], opt[:opt]) do |ssh|

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
        def printTo()
          print "  [dest] ".green
        end
        def printFrom()
          print "  [from] ".cyan
        end

        def decoratePath(path, tag)
            tag  =  "/#{tag}/"
            def dispPerEach(path, tag, color)
              ps = path.split(tag)
              if ps.size != 2
                if color == 0
                  printFrom
                  puts path.cyan  
                else
                  printTo
                  puts path.green
                end
                return 
              end

              if color == 0
                head = ps[0].cyan
                tail = ps[1].cyan
                printFrom
              else
                head = ps[0].green
                tail = ps[1].green
                printTo
              end

              print head
              print tag.yellow
              print tail

            end
            tokens = path.gsub("cp ","").strip.split(" ")

            dispPerEach(tokens[0], tag, 0)
            dispPerEach(tokens[1], tag, 1)
        end

        deploys.each do |c|
          print c.include?("/backups/")  ? "[BACKUP]\n".yellow  : "[DEPLOY]\n" 
          decoratePath c, "backups"
          tmp = File.dirname(c.gsub("cp","").strip.split(' ')[1])
          print  ssh.exec!("mkdir -p #{tmp}")
          puts  ssh.exec!(c)
        end
      end
    end
  rescue Exception => e
      puts "\n\n#{e}\n\n".red
  end
end

def retrieveBackup(spydir, destRdir, target, opt, com, files)
  opt = getScpRLoginInfo(spydir, target, destRdir, opt)
  local_target = "#{File.dirname(spydir)}/.localbackup"
  puts "info"
  puts opt[:host]
  puts opt[:user]
  puts opt[:opt]
  Net::SSH.start(opt[:host], opt[:user], opt[:opt]) do |ssh|
    files.each do |file|
      begin  
      _file  = "#{destRdir}/#{file}".gsub("//","/")
      _locfile = "#{local_target}/#{file}".gsub("//","/")
      FileUtils.mkdir_p (File.dirname("#{local_target}/#{file}".gsub("//","/")
))
      ssh.scp.download!(_file, _locfile, :recursive => true)
      rescue
          puts "NON #{file}".red
      end
    end
  end
  return local_target
end

def test(rollback, groupRootDir, sshinfo, vimapp)
    print "[rakugaki:r erase:e]"
    opt = $stdin.gets.chomp.downcase
    finish opt
    if (opt != "r" && opt != "e")
        puts "test failed bat option".red
        return 
    end

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
        
        def getFilePath(fileRoot, file)
          return "#{fileRoot}/#{file}".gsub("//","/")
        end
        opt = opt.strip
        if opt == "r"
          print "unique word:"
          res = $stdin.gets.chomp
          finish res
          unique = res  == "" ? "moomin" : res
          files.each do |file|
            fname = getFilePath(fileRoot, file)  
            f = File.open("#{fname}", "ab")
            if fname.end_with? ".php"  
              f.puts "//#{unique}"
            elsif fname.end_with? ".sh"
              f.puts "##{unique}"
            else 
              puts "[BAD] #{fname}".red
            end
            f.close
          end
        end

        if opt == "e"
          files.each do |file|
            file = getFilePath(fileRoot, file)  
            lines = File.open("#{file}", "rb").each_line.to_a

            def checkBottom(ls, i=1)
              line = ls[ls.size-i].strip.chomp
              if (line == ""  || line == nil)
                return checkBottom(ls, i+1)
              elsif (line.start_with?("#") || line.start_with?("//") )
                print "[ERASED] "
                puts  "#{line}" .green
                return ls[0..ls.size-i-1] 
              else
                return ls  
              end
            end

            lines = checkBottom lines
            tmp = "#{file}.tmp_suganokun"
            f= File.open(tmp, "wb")
            lines.each do |line|
              f.puts line
            end
            f.close
            FileUtils.cp tmp, file
            FileUtils.rm tmp
            #VimX.usevim file, vimapp      
          end
      end
    end
end


def interactive(rollback, groupRootDir, sshinfo, retrieveMode)
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
      backupdir = ""
      if retrieveMode == true
        backupdir = retrieveBackup(pdir[0], target_r, target, opt, pdir[1], files)
      else
        scp_r pdir[0], target_r, target, opt, pdir[1], rollback
      end
      return {
        :target_r  => target_r,
        :opt       => opt,
        :target    => target,
        :back      => backupdir,
        :fileRoot  =>fileRoot 
      }
    end
end

def executeScpx(groupRootDir, sshinfo, vimapp, channel_cfg)
  begin  
    groupRootDir = groupRootDir.gsub("\\","/")
    if File.directory?(groupRootDir) == false
      FileUtils.mkdir_p groupRootDir  
    end
    puts
    puts "[see ssh info : sl]"
    puts "[set ssh info : l]"
    puts "[make deployPattern: m]".cyan
    puts "[read deployPattern: r]".cyan
    puts "[send    Files: f]".green
    puts "[test:          t]"
    puts "[git check:     g]".green
    puts "[rollback    : rb]".yellow
    puts "[direct_edit deployPattern: d]".red
    puts "[abort]"
    puts "[quit:q]"
    print "\n> "
    case $stdin.gets.chomp.downcase
    when "quit", "q"
        return
    when "abort"
        abort
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
    when "g"
      puts "init"
      def readChannelDir(channel_cfg, vimapp)
        puts ">> rcd"  
        chdir = ""  

        if File.exist?(channel_cfg) == false
          VimX.usevim(channel_cfg, vimapp)
        end

        Encoding.default_external = 'UTF-8'
        File.open(channel_cfg, "r").each do |line|
          if (line != nil) && (line.strip.chomp != "")
            puts line.yellow
            chdir = line
          end
        end
        if chdir == ""
            abort "\n\nchdir blank\n\n".red
        end

        return chdir.gsub("\\","/").strip.chomp
      end

      def compareBackupsWithOldVersion(g, working_dir, backupRoot, files, hash)  
        puts ">> compare"  
        #copy rootdir and targetFilesOnly (or all not nice)
        project = File.basename(working_dir)

        tmp = "#{File.dirname(working_dir)}/mouse/"
        tmp = tmp.gsub("//","/")
        puts "#{working_dir}/.git".yellow
        puts "#{tmp}/#{project}/clone.git".green

        #system ("git --git-dir #{tmpRoot}/.git checkout #{hash} ") #NON POSSUM
        #Git::clone("#{working_dir}/.git", "#{tmp}/#{project}/clone.git")
        abort
        #FileUtils.cp_r "#{working_dir}", tmp

        tmpRoot = "#{tmp}/#{project}"
        #system ("git --git-dir #{tmpRoot}/.git checkout #{hash} ") #NON POSSUM

        files.each do |file|
          file = file.split(",")[0] 
          fromFile = "#{backupRoot}/#{file}".gsub("//","/")
          #puts FileUtils.identical?("#{backupRoot}/#{file}", "#{tmpRoot}/#{file}")
        end
        FileUtils.rm_rf "#{tmp}"
      end

      # CREATOR SIDE
        # 1 glog
        #   select the oldest commit (hash)
        #   select the newest commit (none = most recent)
        # 2 gdiff (#oldest, #newest)
        # 3 write gdiff (as lists) to file (name carefully) 
        # 4 write oldest commit num to file
        # 5 write newest commit num to file
        #     write branch info
        # 6 locate 3 file to "specific repository" accessible to another person
        # 7 specific repository path saved to somewhere
        #
      def createDiffResult(working_dir, channel_cfg, vimapp, isReleaseOperator,backupRoot)

        remotedir = readChannelDir(channel_cfg, vimapp) + "/"+ File.basename(working_dir)
        puts remotedir.green
        if File.directory?(remotedir) == false
            FileUtils.mkdir_p remotedir
        end

        reportFile1 = "#{remotedir}/report"
        reportFile2 = "#{remotedir}/rdetail"
        lines = File.open(reportFile1, "r:UTF-8").each_line.to_a

        hashes = Array.new
        lines.each do |line|
            if line.start_with? "hash="
                hashes.push line.gsub("hash=","").strip.chomp
            end
        end

        g = gitOpen(working_dir)
  
        logs           = getGitLog(g)
        local_branches = getGitBranches(g)[:local]
        diff           =  compareHashes g, logs, hashes
        
        def getDiffDetails(diffinfo)
          puts "diffdetails"
          data = Array.new 

          diffinfo[:files].each do |file|
             print "["
             print file[0].cyan
             print "] "
             print "[+] #{file[1][:insertions]}".green
             print " "
             print "[-] #{file[1][:deletions]}".red
             puts
             # file, insertions, deletions
             data.push "file=#{file[0]},#{file[1][:insertions]},#{file[1][:deletions]}"
          end

          return data  
        end

        diff_details = getDiffDetails diff[1]
       
        puts "\n\n|||||||||||||||||||||||||WRITE|||||||||||||||||||||||||||||||||\n\n"

        puts "hash="+diff[2]
        puts "hash="+diff[3]
        diff_details.each do |d| 
            puts d
        end

        diffReportDir = "#{working_dir}/.diffreport"
        FileUtils.mkdir_p diffReportDir 

        #write diff detail to file   
        r_detail = "#{diffReportDir}/detail"

        puts ">> 222"
        f = File.open(r_detail, "w:UTF-8")
        diff[0].each do |l|
          f.puts l
        end
        f.close

        f = File.open(r_detail+".color", "w:UTF-8")
        diff[0].each do |l|
            if isPlus(l)
              f.puts l.green
            elsif isMinus(l)
              f.puts l.red
            else
              f.puts l
            end
        end
        f.close

        puts ">> 111"
        #write diff to file
        diffReport = "#{diffReportDir}/report"
        f = File.open(diffReport, "w:UTF-8")
        f.puts "hash="+diff[2]
        f.puts "hash="+diff[3]
        diff_details.each do |d| 
           f.puts d
        end
        f.close
        puts "\n\nWRITTEN\n\n".green

        if isReleaseOperator == false
          FileUtils.cp "#{diffReport}",  "#{reportFile1}"
          FileUtils.cp "#{r_detail}",  "#{reportFile2}"
        else
          metaOK   =  FileUtils.identical?(diffReport, reportFile1)
          detailOK =  FileUtils.identical?(r_detail, reportFile2)
   
          puts 
          print "[ OVERVIEWS  ] " #metaOK.to_s.red
          puts metaOK ? "IDENTICAL".green : "DIFFERENT".red
          print "[CODE DETAILS] "
          puts detailOK ? "IDENTICAL".green : "DIFFERENT".red
          puts
          def compare(file1, file2)
              puts ">> compare"
              lines1 = File.open(file1, "r:UTF-8").each_line.to_a
              lines2 = File.open(file2, "r:UTF-8").each_line.to_a
              def showInclusion(lines1, lines2, i)
                lines1.each do |line|
                  if lines2.include?(line) == false
                      if i == true
                        puts "[YOURS] "+ line.chomp.cyan
                      else
                        puts "[REMOTE] "+ line.chomp.yellow
                      end
                  end
                end
              end
              showInclusion(lines1, lines2, true)
              showInclusion(lines2, lines1, false)
          end
          compare diffReport, reportFile1
          compare r_detail, reportFile2
        end

        files = Array.new
        diff_details.each do |d| 
            if d.start_with? "file="
                files.push d.gsub("file=","").strip.chomp
            end
        end
        if hashes.size > 0
          #compareBackupsWithOldVersion(g, working_dir, backupRoot, files, hash)  
          #compareBackupsWithOldVersion(g, working_dir,backupRoot,files, hash[1])  
        end
      end

      # RELEASE OPERATOR SIDE
        # 1 (source fetched(pulled) from the GitLab server)
        # 2 set "specific repository" path 
        #   specific repository path saved to somewhere
        # 3 gdiff_compare 
        #   get branch info
        #     if branch info not identical, return error
        #   hold gdiff listed data into memory
        # 4 gdiff source file
        #   load diff data from specific repository
        #   compare (assert Equal)
        #   if non diff (or trivial)
        #      return OK
        #   if diff
        #      show ERROR DETAILS
        #      return ERROR
        # 5 if OK,
        #      retrieve OLDEST COMMIT FILE STATUS
        #      commit OLDEST COMMIT FILE STATUS with BACKUP DATA
      #
      def evaluateDiffResult()

      end

      #  :target_r => target_r,
      #  :opt      => opt,
      #  :target   => target,
      #  :back     => backupdir

      results     = interactive(true, groupRootDir, sshinfo, true)
      backupDir =   results[:back]
      print "[evalute:e, create:c]"
      res = $stdin.gets.chomp.downcase.strip
      finish res
      case res
      when "e"
        data = createDiffResult(results[:fileRoot], channel_cfg, vimapp, true, backupDir)
        #compareBackupsWithOldVersion(results[:fileRoot], backupDir,data[0], data[1])  
      when "c"
        createDiffResult(results[:fileRoot], channel_cfg, vimapp, false, backupDir)
      else
      end
    when "rb"
      interactive(true, groupRootDir, sshinfo, false)
    when "f"
      interactive(false, groupRootDir, sshinfo, false)
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
         res = $stdin.gets.chomp.downcase
         finish res
         if res == "y"
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
       showGroupNames groupRootDir
       makeGroupFile groupRootDir   
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
    executeScpx groupRootDir, sshinfo, vimapp, channel_cfg
  rescue Exception => e
    puts "\n\n#{e}\n\n".red
    return 
  end
end

