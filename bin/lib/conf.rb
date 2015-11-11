def execConf(config)
        print "[d:Direct] [i:indirect]: "
        case $stdin.gets.chomp.downcase
        when "d"
          system "vim #{config}"
        when "i"
          def getInput()
            return $stdin.gets.chomp
          end
          def getInputDownCase()
            return $stdin.gets.chomp.downcase
          end


         def getHomeDir()
            uname =  %x( echo %username% )
            return ("/Users/#{uname.chomp.strip}/".gsub("//","/")).to_s.chomp.strip
         end

         def replaceWithHomeDir(dir)
             return dir.gsub("~", getHomeDir).gsub("//","/")
         end

          def getLocalRepos(ld="")
            if  ld== ""  
              print "local repository: "
              ld = replaceWithHomeDir(getInput)
            end

            def moveBackward(ld)
               return moveForward(File.dirname(ld))
            end

            def moveForward(ld)
              i = 0
              arr = Array.new
              dir = File.dirname(ld)
              Dir["#{dir}/*"].each do |name|
                print "#{i}) "  
                puts "#{File.basename(name)}".yellow
                arr.push name
                i = i+1
              end
              print "Number[..]:>"
              res = getInput
              if is_number? res
                return (res == "..") ? moveBackward(ld+"/?") : getLocalRepos(arr[getInput.to_i].gsub("//","/"))
              else
                arr.each do |a|  
                    if File.basename(a).start_with? res
                       print "#{a}? [y/n][.] "
                      case getInputDownCase 
                      when "y"
                          return getLocalRepos(a) 
                      when "."
                          return moveForward a+"/?"
                      end
                    end
                end
              end
            end

            if (ld.end_with? "?")
              return moveForward(ld)
            end

            if !(File.directory?(ld))
               print "that repository does not exist... #{ld}\n"
               return getLocalRepos
            end
            print "#{ld} ".green
            print "\ncorrect?[Y/n][.][..]: "
            case getInputDownCase 
            when "y"
              return ld
            when ".."
              return moveBackward ld+"/?"
            when "."
              return moveForward ld+"/?"
            else
              return getLocalRepos
            end
          end
          def getRemoteRepos()
              print "Wanna add remote repository? [Y/n]"
              if getInputDownCase == "n"
                return 
              end
              print "user: "
              user = getInput
              print "host: "
              host = getInput
              print "repos:"
              repos = getInput
              remote_path = "#{user}@#{host}:/#{repos}".gsub("//","/")
              print "#{remote_path} ".green
              print "correct?[Y/n]: "
              if getInputDownCase == "y"
                return remote_path
              else
                getRemoteRepos
              end   
          end
          print "[key name]: "
          key = getInput
          ld     =  getLocalRepos
          remote =  getRemoteRepos
          line =  "#{key} #{ld} #{remote}"
          puts line.green
         
          def writeToKeyList(config, line)
              f = File.open(config, "a") 
              f.puts line
              f.close
              puts
              puts "registered!".green
              puts
          end
          print "[OK?[Y/n]]: "
          getInputDownCase == "y" ? writeToKeyList(config, line) : ""
        else
          puts "input invalid"  .red
        end
end
