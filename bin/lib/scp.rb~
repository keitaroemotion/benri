def executeScp(config)
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
end
