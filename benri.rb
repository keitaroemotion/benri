# copy file to one directory to another
#
# research (diff)
#
#
require 'colorize'
require 'FileUtils'
require '\copyx\lib\iter.rb'

targetfile = ""


optarg =  ARGV[0]

rootdir = "\\Users\\sugano-k\\Fabrica\\Conf\\copyx"
config  = "#{rootdir}\\list"

$editlog = "\\copyx\\recently_edited_files.log"
$keycache = "\\copyx\\key"


def writeKeyCache(key)
   f = File.open($keycache, "w")
   f.puts key
   f.close
end

def getlist(config)
    list = Hash.new
    File.open(config, "r").each do |line|
        lsp  = line.split(" ")
        $key  = lsp[0]   
        $from = lsp[1]
        $to   = lsp[2]
       list[$key] = [$from, $to]
    end
    return list
end

def get_path(list, key, istmp)
   if istmp
       writeKeyCache(key)
   end
   if list[key][1].include? ":/"
       return list[key][0]
   else
       return list[key][1]
   end
end


def addToEditLog(line)
    File.open($editlog, "r").each do |l|
      if l.strip.chomp == line.strip.chomp
          return  
      end
    end
end



def dispHelpMenu()
    appname="benri" 
    puts ""
    puts "#{appname} [local]      ... file directory deployment"
    puts "#{appname} [key]        ... altkey"
    puts "#{appname} [conf]  ... edit dir location settings"
    puts "#{appname} [edit] [option:key]  ... edit files"
    puts "#{appname} [clean] ... garbage starts with tilda"
    puts "#{appname} [scp]   ... use scp"
    puts "#{appname} [grep]   ... "
    puts "#{appname} [history]   ...  edited file history"
    puts "#{appname} [help]  ... show help"
    puts "#{appname} [cd]  ... iter"
    puts
end

$args = Array.new 

if ARGV.size == 0
    dispHelpMenu
    print "choose option: "
    optarg = $stdin.gets.chomp
    if optarg.strip.include? " "
        $args = optarg.split(' ');
        optarg = $args[0] 
        $args  = $args[1..optarg.size-1]
    end

end

def askkey(list, istmp=false)
    print "which key? "
    res = $stdin.gets.chomp
    if list.keys.include? res
       path = get_path list, res, istmp
       $path_ini = path
       return res
    else
       return askkey(istmp)
    end
end

def getKeyInput(config, istmp=false)
    list = getlist config
    list.keys.each do |key|
        puts
        print "key: "
        print "#{key} ".green
        print "from: #{list[key][0]} "
        print "to: #{list[key][1]} "
        puts
    end
    return askkey(list, istmp) 
end


def altkey(thekey, config)
    puts
    print "#{thekey}".cyan
    puts 
    puts
    print "Alt Key? [Y/n] "
    res = $stdin.gets.chomp.downcase
    if res == "y"
        key =getKeyInput(config)
    else
        key = thekey
    end
end

case optarg 
when "key"
    key = getKeyInput config
    
    puts
    puts "Congrats! your key is #{key}".green
    puts 
    #altkey thekey, config
    abort
when "help", "h", "-h"
    dispHelpMenu
    abort
when "history", "his"
    system "cat #{$editlog}"
    print "[edit History:h  File:f] "
    case $stdin.gets.chomp.downcase
    when "h"
        system "vim #{$editlog}"
    when "f"
        list = Array.new
        i = 0
        File.open($editlog, "r").each do |line|
           print "#{i})"
           puts " #{line}".green
           list.push line
           i = i+1
        end
        print "which? "
        res = $stdin.gets.chomp.to_i
        system "vim #{list[res]}"
    end
    abort
when "conf"
    system "vim #{config}"
    abort
when "grep"
    list = getlist config
    mems = Hash.new
    list.keys.each do |key|
        from = list[key][0]
        to   = list[key][1]
        if (from+to).include? ":/"
        else
        puts
        print "key: "
        print "#{key} ".green
        print "#{to} "
        mems[key] = to
        puts
        end
    end
    print "which? "
    $res = $stdin.gets.chomp
    dest = mems[$res]

    def grep(dest)
        print "keyword: "
        kw = $stdin.gets.chomp
        $gri = 0
        $gr_result = Hash.new

        def findGrep(dest, kw)
            Dir["#{dest}/*"].each do |file|
                if File.directory? file
                    findGrep file, kw
                else
                    begin
                    File.open(file, "r:UTF-8").each do |line|
                        if line.downcase.include? kw.downcase
                           $gr_result[$gri] = file
                           $gri = $gri+1
                           break
                        end
                    end
                    rescue
                    end
                end
            end
        end

        findGrep dest, kw

        $gr_result.keys.each do |key|
            puts "#{key}) "+$gr_result[key].green
        end


        if $gr_result.size > 0
            print "which to edit? [quit:q] "
            res = $stdin.gets.chomp
            if res != "q"
                res = res.to_i
                system "vim #{$gr_result[res]}"
                addToEditLog $gr_result[res]
    #            system "echo #{$gr_result[res]} >> #{$editlog}"
            end
        else
            puts
            puts "NOT FOUND: '#{kw}' !!".red
        end
        grep dest
    end
    grep dest
    abort
when "cd"
    executeIter  ""
when "edit"
    if $args[0] == nil
        $args[0] = ""
    end
    tmp_key_option = $args[0]
    puts tmp_key_option.yellow
    def editDirectory(file, path, config, key, term)
        if File.directory? file
            if File.basename(file).downcase.start_with? term.downcase
                 puts file.red
                 print "Browse This Folder? [Y/n]: "
          res = $stdin.gets.chomp.downcase
          if res == "y"
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
             browse file
          end
        end
      edit file, term, config, key
      #next
      end
    end


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

            def do_edit(path, config, key)
                print "enter term[quit:q]: "
                term = $stdin.gets.chomp 
                if term.downcase == "q"
                    abort
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
                                print "> "
                        
                                case $stdin.gets.chomp.downcase 
                                when "k"
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

                                            Net::SSH.start(host, user, opt) do |session|
                                              session.scp.upload! from, dest 
                                            end

                                            #system "scp #{from} #{to}"

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
                                    editFile path, term, config, key, file
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
                    abort  
                end
            end
            do_edit path, config, key
        end
        editcommand config, tmp_key_option 

    rescue SystemExit, Interrupt
    end
    editcommand config, tmp_key_option 

    abort
when "clean"
    list = getlist config
    list.keys.each do |key|
        print "key: "
        print "#{key} ".green
        print "to: #{list[key][1]} "
        puts
    end
    print "which key?: "
    key = $stdin.gets.chomp
    to   = list[key][1]

    def cleanDir(dir)
        Dir["#{dir}/*".gsub("//","/")].each do |file|
            if File.directory? file
                cleanDir file  
            end
            remove file    
        end
        Dir["#{dir}/.*~".gsub("//","/")].each do |file|
            remove file    
        end
    end

    def remove(file)
       if(file.end_with?("~"))
            puts "removed: #{file}".red
            FileUtils.rm file
        end 
    end

    cleanDir to
    abort
when "scp"
    list = getlist config
    list.keys.each do |key|
        if (list[key][0]+list[key][1]).include? ":/"
            puts
            print "key: "
            print "#{key} ".green
            print "from: #{list[key][0]} "
            print "to: #{list[key][1]} "
            puts
        end
    end
    
    def pull(fromSCP, to, term)
        if fromSCP.include? (":/")
            Dir["#{to}/*".gsub("//","/")].each do |file|
                relative_path = file.gsub(to, "")
                fromSCPFile =  "#{fromSCP}/#{relative_path}".gsub("//","/")
                toFile   =  "#{to}/#{relative_path}".gsub("//","/")
                if File.directory? to
                   pull fromSCPFile, toFile, term
                end
                if File.basename(toFile).downcase.start_with? term.downcase
                    command = "scp #{fromSCPFile} #{toFile.gsub('/','\\')}"
                    print "#{command}?[Y/n] :"
                    case $stdin.gets.chomp.downcase 
                    when "y"
                        system command
                    when "q" 
                        abort
                    end
                end
            end
        end
    end

    def getLocalPath()
        if $from.include? ":/"
            return $to
        else
            return $from
        end
    end

    def send(from, toSCP, term)
        if toSCP.include?(":/")
            require 'date'

            Dir["#{from}/*".gsub("//","/")].each do |file|
                relative_path = file.gsub(from, "")
                fromFile    =  "#{from}/#{relative_path}".gsub("//","/")
                toSCPFile   =  "#{toSCP}/#{relative_path}".gsub("//","/")
                stash_base = getLocalPath()+"/.stash/#{$datetime}"
                stash_base = (stash_base+"/"+from.gsub(getLocalPath(), ""))
                stash_dir  = (stash_base).gsub("//","/").gsub('/','\\')
                stash_file = "#{stash_dir}\\#{relative_path}".gsub("//","/").gsub('/','\\').gsub("\\\\","\\")

                if File.directory?(fromFile) == true
                   send(fromFile, toSCPFile, term)
                end
#                puts "#{fromFile}"
                if File.basename(fromFile).downcase.start_with? term.downcase
                    print "scp "
                    print "#{fromFile.gsub('/','\\')} ".yellow
                    print "#{toSCPFile}".green
                    puts
                    puts
                    print "#{File.basename(toSCPFile)}".magenta
                    puts
                    puts
                    command = "scp #{fromFile.gsub('/','\\')} #{toSCPFile}"
                    backup_command = "scp  #{toSCPFile} #{stash_file}"
                    print "[Backup]: "
                    puts "#{backup_command}".magenta
                    FileUtils.mkdir_p stash_dir
                    print "Execute?[Y/n] :"
                    case $stdin.gets.chomp.downcase 
                    when "y"
                       system backup_command
                       puts "| Backup Completed! |".green
                       system command
                       puts "| Deploy Completed! |".green
                       print "Continue? [Y/n]"
                       if $stdin.gets.chomp.downcase == "n"
                             abort
                       else  
                       end
                    when "q" 
                        abort
                    end
                end
            end
        end
    end

    $datetime = Time.now.to_s.gsub(" ","").gsub(":","")
    print "which key?: "
    key = $stdin.gets.chomp
    from = list[key][0]
    to   = list[key][1]
    $from = from
    $to   = to
    def execute(from, to)
        print "enter term: "
        term = $stdin.gets.chomp 

        pull from, to, term
        send from, to, term
        print "Another File? [Y/n]: "
        if $stdin.gets.chomp.downcase == "y"
            execute from, to
        else
            abort
        end
    end
    execute from, to
    abort
when "local"
    targetfile = optarg
else
    puts
    abort "operation missing!".blink.red
end

$key  = ""
$from = ""
$to   = ""

list = getlist config

def checkDir(dir)
    if (dir.include?(":/"))
    elsif (File.directory?("#{dir}") == false)
        abort "\ndir #{dir} does not exist\n".red
    end
end

$cons        = Array.new
$commands    = Array.new

def pop(array, i)
  if((array.size > i) && (i > -1))
    return array[i].strip
  end
  return ""
end

def windows(path)
  return path.gsub("/","\\")
end

$reverse = false
$report = Hash.new

def read_single(from, to)
     # gotta do some appropriate process in scp
     oper = ""
     if((from+to).include?(":/"))
         oper =  "scp "
     else
         oper =  "copy "
     end
     print oper
     from = fitPath from
     to   = fitPath to
     if $reverse
        tmp  = from
        from = to
        to   = tmp
     end
     print from.yellow
     print " "
     print to.red
     puts
     return "#{oper} #{from} #{to}"
end

def fitPath(path)
  if path.include? ":/"
      return path
  end
  return path.gsub("/","\\")
end

def read(fromdir, toRootdir, filename, wash)
    reverse = false
    if fromdir.include? ":/"
        tmp         = fromdir 
        fromdir     = toRootdir
        toRootdir       = tmp
        reverse     = true
    else
        checkDir(fromdir)
    end

    Dir["#{fromdir}/*"].each do |each_path|
       relative_path = each_path.gsub(fromdir, "")
       fromFile =   "#{fromdir}/#{relative_path}".gsub("//","/")
       toFile   = "#{toRootdir}/#{relative_path}".gsub("//","/")
       if File.directory? fromFile 
          read fromFile, toFile, filename, wash
       end     

       if((wash == true) && File.exist?(fromFile))
           if File.exist?(toFile)
               diff =  %x(FC #{windows(fromFile)} #{windows(toFile)})
               if diff.include?("*****")
                   $report["#{fromFile}\n#{toFile}\n"] = diff
               end
           else
#               $report["#{fromFile}\n#{toFile}\n"] = "\n[New File]\n".cyan
           end
       elsif(File.exist?(fromFile) && (File.basename(fromFile) == targetfile.strip))
           if (toFile.include?(":/"))
                fromFile = fromFile.gsub("/","\\")
                $commands.push ["scp",  fromFile, toFile]
           else
                $commands.push ["copy",  fromFile.gsub("/","\\"), toFile.gsub("/","\\")]
           end
       end     
    end  
end

list.keys.each do |key|
    if ((list[key][0]+list[key][1]).include?(":/") == false)
        print "key: "
        print "#{key} ".green
        print "from: #{list[key][0]} "
        print "to: #{list[key][1]} "
        puts
    end
end

print "which key?: "
key = $stdin.gets.chomp
$from = list[key][0]
$to   = list[key][1]

if $from.include? ":/"
   $reverse = true
end

read($from, $to, "", true)
$notes = Array.new
def exec(targetfile, argsize)
    print "Show [All:a] [fileOnly:f] :" 
    res = $stdin.gets.chomp.downcase

    $report.keys.each do |key|
        ksp = key.split("\n");
        fromFile = ksp[0]
        toFile   = ksp[1]
        if fromFile.end_with? "~"
            next
        end
        if((argsize == 0) || File.basename(fromFile).downcase.start_with?(targetfile.downcase))
            puts key.yellow
            if res == "a"
                puts $report[key]
            elsif res == "f"
            end

            print "[quit:q][deploy:d][note:n][vi:v][filter:...*]>"
            res2 = $stdin.gets.chomp.downcase
            if res2.end_with? "*"
                exec res2.gsub("*",""), 1
                break 
            end

            case res2
            when "q"
                abort
            when "d"
                system read_single(fromFile, toFile);
                print "Next?[Y/n]: "
                if $stdin.gets.chomp.downcase  != "y"
                    abort
                end
            when "n"
                $notes.push toFile
            when "v"
                system "vim #{toFile}" 

                addToEditLog toFile
            end
        end
    end
end

exec targetfile, ARGV.size

if $notes.size > 0
   $notes.each do |f|
      puts f.gsub($to, "").yellow
   end
end



