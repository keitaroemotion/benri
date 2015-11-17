
#require "\\#{$appdir}\\lib\\git.rb"

def usevim(file, vimapp)
  system "#{vimapp} #{file} "
end

def browse(file, vimapp) 
    hub = Array.new
    i = 0
    Dir["#{file}/*"].each do |file|
        print "#{i}) "
        puts File.basename(file).magenta
        hub.push file
        i = i+1
    end
    print "which?[v:new File] "
    res = $stdin.gets.chomp
    case res
    when "v"
        print "New File Name:"
        usevim "#{file}\\#{$stdin.gets.chomp}", vimapp
    else
        res = res.to_i
        usevim hub[res], vimapp
    end
    print "another? [Y/n] "
    res = $stdin.gets.chomp
    case res
    when "y"
        browse file
    else
    end
end

def editDirectory(file, path, config, key, term, vimapp)
    if File.directory? file
        if File.basename(file).downcase.start_with? term.downcase
             puts file.red
             print "Browse This Folder? [Y/n]: "
      res = $stdin.gets.chomp.downcase
      if res == "y"
         browse file
      end
    end
  edit file, term, config, key, vimapp
  end
end

def grepOption(current_dir) 
    $list = Hash.new 
    def doGrep(current_dir, kw)      
        Dir["#{current_dir}/*".gsub("//","/")].each do |_file|
            if _file.end_with? "~"
                next
            end
            if File.directory? _file
                doGrep(_file, kw)
            else
                listPerFile = Array.new
                File.open(_file, "r:UTF-8").each do |line|
                    begin
                        if line.strip.chomp.downcase.include? kw.downcase
                            listPerFile.push line
                        end
                    rescue
                        print "[READ FAILURE] "
                        puts _file.cyan
                    end
                end
                if listPerFile.size != 0
                    $list[_file] = listPerFile
                end
            end
        end
    end
    print "word? "
    word = $stdin.gets.chomp
    print "["
    print " #{current_dir}".magenta
    puts "]"
    doGrep current_dir, word
    puts "[Hit] "+$list.keys.size.to_s
    i = 0
    listcopy = Array.new
    $list.keys.each do |_file|
       filename =  File.basename(_file)
       print "#{i})"
       print filename.yellow
       puts  " #{$list[_file]}".red
       listcopy.push _file
       i = i+1
    end
    print "open[q:quit][/:search]:"
    res =  $stdin.gets.chomp.downcase
    case res
    when "q"

    when "/"
        grepOption current_dir.chomp
    else  
       usevim listcopy[res.to_i], vimapp
    end
end

def envim(file, vimapp)
    begin
        usevim file, vimapp
        dir = File.dirname(file)
        filename = File.basename file
        swp1 = "#{filename}~"
        swp2 = ".#{filename}.swp"
        swpfile1 = "#{dir}/#{swp1}"
        swpfile2 = "#{dir}/#{swp2}"
        if File.exist? swpfile1
            FileUtils.rm "#{swpfile1}"
        end
        if File.exist? swpfile2
           FileUtils.rm  " #{swpfile2}"
        end
    rescue
    end
end

def executeEdit(argment_inputs, config, vimapp)
    puts vimapp.cyan

    if argment_inputs[0] == nil
        argment_inputs[0] = ""
    end

    tmp_key_option = argment_inputs[0]
    puts tmp_key_option.yellow

    begin
        def editcommand(config, tmp_key_option, vimapp)

            istmp = ((tmp_key_option != "") && (tmp_key_option != nil))

            if istmp == true
                key = tmp_key_option 
            else
                keyInFile = ""
                if File.exist?($keycache)
                    begin
                        keyInFile = File.open($keycache, "r").each_line.to_a[0].strip.chomp
                    rescue
                    end
                end
                key = (keyInFile == "") ? getKeyInput(config, false) : keyInFile
            end

            tmp_key_option = ""

            print "YOUR KEY : ["
            print " #{key} ".magenta
            puts "]"

            list = getlist config

            if list.size == 0
               puts 
               puts "You haven't registered any directories!!! ".red
               return 
            end

            path = get_path list, key, istmp
            
            if path == -1
                puts "--------"
              puts list.to_s.red  
              path = get_path list, getKeyInput(config, false), istmp
            end

            $path_ini = path

            def do_edit(path, config, key, vimapp, term="nil")
                if(term=="nil")
                    print "enter term[quit:q][g:grep]: "
                    term = $stdin.gets.chomp 
                    case term.downcase 
                    when "q"
                        return
                    when "g"
                        grepOption $path_ini
                        return
                    end
                end

                def edit(path, term, config, key, vimapp)
                    Dir["#{path}/*".gsub("//","/")].each do |file|
                        editDirectory(file, path, config, key, term, vimapp)
                        def editFile(path, term, config, key, file, vimapp)
                            if File.basename(file).downcase.start_with? term.downcase
                                puts
                                puts "#{File.basename(file)}".green
                                puts
                                puts "DIR: #{File.dirname(file)}"
                                puts 
                                puts "[v:EDIT]"
                                puts "[n:New File]"
                                puts "[k:Next]"
                                puts "[q:quit]"
                                puts "[c:copy]"
                                puts "[r:rename]"
                                puts "[l:location check]"
                                puts "[d:delete] "
                                puts "[pec:parse error check] "
                                puts "[f:functions] "
                                puts "[s:send]"
                                puts "[clean]"
                                puts "[ll: listup dir]"
                                puts "[g:grep]"
                                puts "[t: troops]"
                                puts "[ga:grep all]"
                                print "[gadd: git add] ".yellow
                                print "[grm: git add] ".yellow
                                print "[gcom: git commit] ".yellow
                                puts "[gpush: git push]".yellow
                                puts "[se:show encoding]"
                                puts "[ce:convert encoding]"
                                puts "[/..:search]"
                                print "> "
                                _oper = $stdin.gets.chomp.downcase 
                                case _oper
                                when "ll"
                                  system "start #{File.dirname(file).gsub('/','\\')}" 
                                when "norm"
                                   Encoder.encodeDirectory $path_ini
                                   editFile path, term, config, key, file, vimapp
                                when "grm"
                                   gitrm $path_ini, file
                                   editFile path, term, config, key, file, vimapp
                                when "gpush"
                                   gitpush $path_ini
                                   editFile path, term, config, key, file, vimapp
                                when "gcom"
                                   gitcom $path_ini
                                   editFile path, term, config, key, file, vimapp
                                when "gadd"
                                   gitadd $path_ini, file
                                   editFile path, term, config, key, file, vimapp
                                when "t"
                                   base = "/benri/bin/nakama"  # not good
                                   FileUtils.mkdir_p base 
                                   executeTroops base, file 
                                   editFile path, term, config, key, file, vimapp
                                when "k"
                                when "ga"
                                   grepOption $path_ini
                                   editFile path, term, config, key, file, vimapp
                                when "g"
                                   grepOption File.dirname(file)
                                   editFile path, term, config, key, file, vimapp
                                when "clean"
                                  def doClean(dir)
                                     Dir["#{dir}/*".gsub("//","/")].each do |path|
                                        if File.directory?(path)
                                            doClean path
                                            next
                                        end
                                        if ((path =~ /.*\.swp$/) || (path.end_with?("~")))
                                           begin
                                             FileUtils.rm path
                                           rescue
                                           end
                                        end
                                    end
                                  end
                                  doClean $path_ini
                                  editFile path, term, config, key, file, vimapp
                                when "pec"
                                    lines = File.open(file, "r:UTF-8").each_line.to_a
                                    rightCurlyBracketCount = 0
                                    leftCurlyBracketCount = 0
                                    lines.each do |line|
                                        line = line.strip.chomp
                                        if line.start_with?("for(")
                                            print "[=>foreach?]"
                                            puts line.red
                                        end
                                        if line.strip.include?("{")
                                            leftCurlyBracketCount += line.count('{')
                                        end
                                        if line.strip.include?("}")
                                            rightCurlyBracketCount += line.count('}')
                                        end

                                        if line.end_with?("{")
                                        elsif line.end_with?("}")
                                        elsif (line.end_with?(",") && line.include?(" => ")) 
                                        elsif (line.end_with?(":") && line.start_with?("case ")) 
                                        elsif (line.start_with?("default ")) 
                                        else
                                            if !line.end_with?(";") 
                                                if (line == "")
                                                elsif line.start_with? "/"
                                                elsif line.start_with? "*"
                                                else
                                                    print "[Semicolon Omitted] "
                                                    puts line.red
                                                end
                                            end
                                        end
                                        rightBracketCount = line.count('(')
                                        leftBracketCount  = line.count(')')
                                        if rightBracketCount != leftBracketCount
                                            print "[Bracket Disparity] "
                                            puts line.red
                                        end
                                    end
                                    if rightCurlyBracketCount != leftCurlyBracketCount 
                                        print "[Curly Bracket Disparity]"
                                    end

                                when "se" # show encoding
                                      
                                when "ce" # change encoding
                                    print "[u:UTF-8]"
                                    enc = $stdin.gets.chomp
                                    case enc 
                                    when "u"
                                      list = File.open(file,"r:UTF-8").read
                                      f = File.open(file,"w:UTF-8")
                                      f.puts list
                                      f.close
                                    end

                                    puts
                                    puts "ENCODING...".yellow
                                    puts
                                    p File.binread(file)
                                    puts
                                    puts "\nDONE\n".green
                                    editFile path, term, config, key, file, vimapp
                                when "s"
                                    list = getlist config
                                    from = list[key][0]
                                    to = list[key][1]
                                    if ((from+to).include?(":/") == false)
                                        puts
                                        puts "this option doesnt work! " .red
                                        puts
                                        editFile path, term, config, key, file, vimapp
                                    else
                                        if from.include? ":/"
                                            from = list[key][1]
                                            to = list[key][0]
                                        end
                                        relative = file.gsub(from, "")
                                        from = file
                                        to = "#{to}/#{relative}".gsub('//','/')
                                        print "scp "
                                        print"#{from} ".green
                                        puts "#{to}".cyan
                                        print "Send? [Y/n]: "
                                        case $stdin.gets.chomp.downcase
                                        when "y"
                                            tsp = to.split(':/')
                                            tspp = tsp[0].split('@')
                                            user = tspp[0]
                                            host   = tspp[1]
                                            dest =  "/"+ tsp[1]
                                            scpinfo = "/benri/bin/scpinfo"
                                            def readScpInfo(scpinfo)

                                               if File.exist?(scpinfo) == false
                                                   usevim scpinfo, vimapp
                                                   return 
                                               end

                                               hash = Hash.new 
                                               File.open(scpinfo, "r:UTF-8").each_line do |line|
                                                   lsp = line.split('|')
                                                   if lsp.size == 2
                                                     hash[lsp[0].strip.chomp] = lsp[1].strip.chomp
                                                   end
                                               end
                                               return hash
                                            end
                                            
                                            oss = readScpInfo(scpinfo)

                                            opt = {
                                               :keys       => oss["keys"],
                                               :passphrase => oss["passphrase"]
                                            }

                                            begin
                                                Net::SSH.start(host, user, opt) do |session|
                                                     session.scp.upload! from, dest 
                                                end
                                            rescue
                                               system "scp -r "+File.dirname(from).gsub("/","\\")+" "+File.dirname(to) 
                                            end

                                        when "n"
                                        else
                                        end

                                        editFile path, term, config, key, file, vimapp
                                    end
                                when "n"
                                    print "New File Name:"
                                    usevim "#{File.dirname(file)}\\#{$stdin.gets.chomp}", vimapp
     
                                when "f"
                                    def extract(line)
                                        return line.gsub("private", "").gsub("public", "").gsub("protected","").gsub("function","").gsub("{","")
                                    end

                                    backup = "#{File.basename(file)}.backup1"
                                    def enlistFunctions(file, backup, config, path, term, key)
                                        FileUtils.cp file, backup
                                        f = Array.new
                                        File.open(backup, "r:UTF-8").each do |line|
                                            f.push line
                                        end
                                        f.each do |line|
                                           if  line.include? " function "  
                                               line = line.strip
                                               if line.start_with? "private"
                                                   line = extract line
                                                   puts "[ private ] #{line}".cyan
                                               elsif line.start_with?  "protected"
                                                   line = extract line
                                                   puts "[protected] #{line}".magenta
                                               elsif line.start_with? "public"
                                                   line = extract line
                                                   puts "[ public  ] #{line}".green
                                               end
                                           end
                                        end
                                        puts

                                        editFile path, term, config, key, file, vimapp
                                    end

                                    enlistFunctions file, backup, config, path, term, key
                                    begin 
                                        #system "del #{backup.gsub('/','\\')}"
                                    rescue
                                    end
                                when "v"
                                    envim file, vimapp
                                    addToEditLog file
                                    editFile path, term, config, key, file, vimapp
                                when "l" 
                                    def seeloc(dir)
                                        #base = File.basename(file)
                                        theBase = File.basename(dir)
                                        arr = Array.new
                                        x = 0
                                        Dir["#{dir}/*"].each do |f|
                                            print "["
                                            print theBase.green
                                            print "]"
                                            print "["
                                            print "#{x}"
                                            print "] "
                                            arr.push File.basename(f)
                                            puts File.basename(f).magenta
                                            x = x+1
                                        end
                                        print "where? [..:prev q:quit] "
                                        res = $stdin.gets.chomp
                                        case res
                                        when "q"
                                        when ".."
                                            seeloc File.dirname(dir)
                                        else
                                            num = res.to_i
                                            newdir = "#{dir}/#{arr[num]}"
                                            if File.directory? newdir
                                               seeloc newdir
                                            else
                                               usevim newdir, vimapp
                                               seeloc dir
                                            end
                                        end
                                    end
                                    seeloc File.dirname(file)
                                when "d"
                                   system "del #{file.gsub('/','\\')}"
                                when "r" 
                                    print "New Name: "
                                    copy = File.dirname(file)+"/"+ $stdin.gets.chomp
                                    FileUtils.mv(file, copy) 
                                    print "Show?: [Y/n] "
                                    if $stdin.gets.chomp.downcase == "y"
                                        system "dir #{File.dirname(file).gsub('/','\\')}"
                                    end
                                when "c" 
                                    puts
                                    puts "This command allows copy only in same directory!".red
                                    puts
                                    print "New Name: "
                                    copy = File.dirname(file)+"/"+ $stdin.gets.chomp
                                    FileUtils.cp(file, copy) 
                                    print "Open?: [Y/n] "
                                    if $stdin.gets.chomp.downcase == "y"
                                        usevim copy, vimapp
                                    end
                                when "q" 
                                    executeAPI config
                                else
                                    if _oper.start_with? "/"
                                        do_edit $path_ini, config, key, vimapp, _oper.gsub("/","")
                                    else
                                        editFile path, term, config, key, file, vimapp
                                    end
                                end
                            end
                        end
                        editFile path, term, config, key, file, vimapp
                    end
                end

                edit path, term, config, key, vimapp

                print "Edit another file?[Y/n]: "
                if $stdin.gets.chomp.downcase == "y"
                    do_edit path, config, key, vimapp
                else
                    executeAPI config
                end
            end
            do_edit path, config, key, vimapp
        end
        editcommand config, tmp_key_option, vimapp
    end
end
