def browse(file) 
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
        system "vim #{file}\\#{$stdin.gets.chomp}"
    else
        res = res.to_i
        system "vim #{hub[res]}"
    end
    print "another? [Y/n] "
    res = $stdin.gets.chomp
    case res
    when "y"
        browse file
    
    else
    end
end

def editDirectory(file, path, config, key, term)
    if File.directory? file
        if File.basename(file).downcase.start_with? term.downcase
             puts file.red
             print "Browse This Folder? [Y/n]: "
      res = $stdin.gets.chomp.downcase
      if res == "y"
         browse file
      end
    end
  edit file, term, config, key
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
       system "vim #{listcopy[res.to_i]}"
    end
end
def envim(file)
    begin
        system "vim #{file}"
        dir = File.dirname(file)
        filename = File.basename file
        swp1 = "#{filename}~"
        swp2 = ".#{filename}.swp"
        swpfile1 = "#{dir}/#{swp1}"
        swpfile2 = "#{dir}/#{swp2}"
        if File.exist? swpfile1
            system "del #{swpfile1}"
        end
        if File.exist? swpfile2
            system "del #{swpfile2}"
        end
    rescue
    end
end
def executeEdit(argment_inputs, config)
    if argment_inputs[0] == nil
        argment_inputs[0] = ""
    end
    tmp_key_option = argment_inputs[0]
    puts tmp_key_option.yellow

    begin
        def editcommand(config, tmp_key_option)

            if tmp_key_option == nil
                tmp_key_option = ""
            end
            thekey = ""
            if tmp_key_option == ""
                if File.exist?($keycache)
                    begin
                        thekey = File.open($keycache, "r").each_line.to_a[0].strip.chomp
                    rescue
                    end
                end
                if thekey == ""
                    key = getKeyInput(config, false)
                else
                    key = thekey
                end
            else
                key = tmp_key_option 
            end

            print "YOUR KEY : ["
            print " #{key} ".magenta
            puts "]"

            list = getlist config
            istmp = (tmp_key_option != "") 
            path = get_path list, key, istmp
            $path_ini = path

            def do_edit(path, config, key, term="nil")
                if(term=="nil")
                    print "enter term[quit:q]: "
                    term = $stdin.gets.chomp 
                    if term.downcase == "q"
                        return
                    end
                end

                def edit(path, term, config, key)
                    Dir["#{path}/*".gsub("//","/")].each do |file|
                    #Dir["#{path}/*".gsub("//","/")].each_cons(3) do |prev, file, juxta|
                        editDirectory(file, path, config, key, term)
                        def editFile(path, term, config, key, file)
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
                                puts "[g:grep]"
                                puts "[ga:grep all]"
                                puts "[/..:search]"
                                print "> "
                                _oper = $stdin.gets.chomp.downcase 
                                case _oper
                                when "k"
                                when "ga"
                                   grepOption $path_ini
                                   editFile path, term, config, key, file
                                when "g"
                                   grepOption File.dirname(file)
                                   editFile path, term, config, key, file
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

                                when "s"
                                    list = getlist config
                                    from = list[key][0]
                                    to = list[key][1]
                                    if ((from+to).include?(":/") == false)
                                        puts
                                        puts "this option doesnt work! " .red
                                        puts
                                        editFile path, term, config, key, file
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
                                            require 'net/ssh'
                                            require 'net/scp'

                                            opt = {
                                              :keys       => "/Users/sugano-k/.ssh/id_rsa",
                                              :passphrase => "moomin"
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

                                        editFile path, term, config, key, file
                                    end
                                when "n"
                                    print "New File Name:"
                                    system "vim #{File.dirname(file)}\\#{$stdin.gets.chomp}"
     
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
                                        #print "[Next:Y/n Quit:q] "
                                        #case $stdin.gets.chomp.downcase 
                                        #when "n"

                                        editFile path, term, config, key, file
                                        #enlistFunctions file, backup, config
                                        #when "q"
                                        #   editcommand config 
                                        #end
                                    end

                                    enlistFunctions file, backup, config, path, term, key
                                    begin 
                                        #system "del #{backup.gsub('/','\\')}"
                                    rescue
                                    end
                                     

                                when "v"
                                    
                                    envim file

                                    addToEditLog file

                                    editFile path, term, config, key, file

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
                                               system "vim #{newdir}"
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
                                        system "vim #{copy}"
                                    end
                                when "q" 
                                    do_edit $path_ini, config, key
                                else
                                    if _oper.start_with? "/"
                                        do_edit $path_ini, config, key, _oper.gsub("/","")
                                    else
                                        editFile path, term, config, key, file
                                    end
                                end
                            end
                        end
                        editFile path, term, config, key, file
                    end
                end

                edit path, term, config, key

                print "Edit another file?[Y/n]: "
                if $stdin.gets.chomp.downcase == "y"
                    do_edit path, config, key
                else
                    executeAPI config
                    abort
                end
            end
            do_edit path, config, key
        end
        editcommand config, tmp_key_option 
    end
end
