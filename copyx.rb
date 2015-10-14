

# copy file to one directory to another
#
#
#

# research (diff)
#
require 'colorize'
require 'FileUtils'

targetfile = ARGV[0]

rootdir = "\\Users\\sugano-k\\Fabrica\\Conf\\copyx"
config  = "#{rootdir}\\list"

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

case targetfile 
when "help", "h", "-h"
    puts "copyx ... file directory deployment"
    puts "copyx [help]  ... show help"
    puts "copyx [conf]  ... edit dir location settings"
    puts "copyx [edit]  ... edit files"
    puts "copyx [clean] ... garbage starts with tilda"
    puts "copyx [scp]   ... use scp"
    abort
when "conf"
    system "vim #{config}"
    abort
when "edit"
    list = getlist config
    list.keys.each do |key|
        puts
        print "key: "
        print "#{key} ".green
        print "from: #{list[key][0]} "
        print "to: #{list[key][1]} "
        puts
    end
    def get_path(list)
        print "which key?: "
        key = $stdin.gets.chomp
        if list.keys.include? key
          to   = list[key][1]
          path = to
        else
          print "the key you requested does not exist!!\n"
          get_path list
        end
        return path
    end
    path = get_path list
    def do_edit(path)
        print "enter term: "
        term = $stdin.gets.chomp 

        def edit(path, term)
            Dir["#{path}/*".gsub("//","/")].each do |file|
                if File.directory? file
                   edit file, term
                end
                if File.basename(file).downcase.start_with? term.downcase
                    print "#{file}?[Y/n] :"
                    case $stdin.gets.chomp.downcase 
                    when "y"
                        system "vim #{file}"
                    when "q" 
                        break 
                    end
                end
            end
        end

        edit path, term

        print "Edit another file?[Y/n]: "
        if $stdin.gets.chomp.downcase == "y"
            do_edit path
        else
            abort  
        end
    end
    do_edit path
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
        puts "#{fromSCP} #{to}"
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
                stash_base = getLocalPath()+"/stash/#{$datetime}"
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
                    print "from: "
                    puts  "#{fromFile.gsub('/','\\')}".yellow
                    print "to: "
                    print "#{toSCPFile}".green
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
                       system command
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
  print "key: "
  print "#{key} ".green
  print "from: #{list[key][0]} "
  print "to: #{list[key][1]} "
  puts
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



