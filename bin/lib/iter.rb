
require "colorize"


def dispPwd(link)
    print "["
    print "#{File.basename(link)}".magenta
    print "] "
end

def removeGarbage(link, filename)
    puts "#{link} #{filename}".cyan
    garbage = "#{link}/#{filename}~"
    garbage2 = "#{link}/.#{filename}.swp"
    if File.exist? garbage
        system "del #{garbage}".gsub("/","\\")
    end
    if File.exist? garbage2
        system "del #{garbage2}".gsub("/","\\")
    end
end
def doIter(token, hash, links)
     File.open($config, "r").each do |line|
         begin
             lsp = line.split(" ")
             key = lsp[0]
             link = lsp[1]
             comment = ""
             (2..lsp.size-1).each do |i|
                 comment += lsp[i]+" "
             end
             hash[key] = [link, comment]
         rescue
         end
     end

     hash.keys.each do |k|
         if ((token == nil) || k.start_with?(token))
             print "key:"
             print "#{k}".cyan
             print "| "
             print "#{hash[k][1]}".green
             puts
         end
     end
     if token == ""
         print "choose key:[c:C_DIR q:quit] "
         keyfrag     = $stdin.gets.chomp
         

         case keyfrag
         when "q"
             return
         when "c"
             link = "c:/"
             openLink link
         end

         if keyfrag == ""
             print "All? [Y/n] "
             if $stdin.gets.chomp.downcase == "y"
             else
                 return 
                 #executeIter ""
             end
         end
     else
         keyfrag = token
     end

     if hash.keys.include? keyfrag
         links[keyfrag] = hash[keyfrag]
     else
         hash.keys.each do |k|
             if k.start_with? keyfrag
                 link = hash[k][0]
                 comm = hash[k][1]
                 links[k] = [link,  comm]
             end
         end
     end


     if links.size == 0
         puts "LINK IS NIL".red
         openLink $location_cash
     elsif links.size > 1
         i = 0
         keypair=Array.new
         links.keys.each do |key|
             keypair.push key
             print "#{i}) "
             print "#{key} ".yellow
             print "#{links[key][0]}".cyan
             print "   # ".magenta
             puts "#{links[key][1]}".magenta
             i = i + 1
         end
         print "which?:[Menu:m] "
         res = $stdin.gets.chomp
         if res == "m"
             return 
         end
         res = res.to_i
         uri = links[keypair[res]][0]

         if uri.start_with? "http"
            system "start #{uri}"
         else
            openLink uri
         end
     else
         if links[links.keys[0]][0].start_with? "http"
            system "start #{links[links.keys[0]][0]}"
         else
            openLink links[links.keys[0]][0]
         end
     end
 end

def openLink(link)
            if ((link == nil) || (link.strip == "") )
               dispPwd link
               print "PRESS ENTER: "
               $stdin.gets.chomp
               return 
            end
            puts link.yellow
            if link.start_with? "http"
            else
               if File.directory? link
                  link = link.gsub("\\","/")
                  i = 0
                  list = Array.new
                  keyword = ""
                  Dir["#{link}/*"].each do |file|
                      if ((keyword == "") || File.basename(file).include?(keyword))    
                          puts "#{i}) #{File.basename(file)}"
                          $location_cash =File.dirname(file)
                          i=i+1
                          list.push file
                          if i == 20

                             dispPwd link
                             print "Have one?:[Y/n][back:..][Menu:m][GO:g] "
                             res = $stdin.gets.chomp.downcase
                             case res
                             when "m"
                                 return 
                             when "y"
                                break 
                             when ".."
                                openLink File.dirname(link) 
                             when "n"
                                i = 0
                             when "pwd"
                                 puts link.red
                             when "g"
                                 print "search: "
                                 word = $stdin.gets.chomp
                                 Dir["#{link}/*".gsub("//","/")].each do |file| 
                                     if File.basename(file).downcase.include? word.downcase
                                         print "THIS "
                                         print "#{File.basename(file)}".green
                                         print " ?[Y/n] "
                                         res = $stdin.gets.chomp.downcase
                                         if res == "y"
                                             link = file
                                             $location_cash = link
                                             openLink $location_cash 
                                         end
                                     end
                                  end
                              end
                          end
                      end
                  end

                  dispPwd link
                  print "which one?:"
                  puts
                  puts "[back:..] [Menu:m]".yellow
                  puts "[Make New File:v]".yellow
                  puts "[Make Alias: r]".yellow
                  puts "[Copy: c]".yellow
                  puts "[Rename: mv]".yellow
                  puts "[Delete File: d]".yellow
                  puts "[Change Directory: cd]".yellow
                  print "> "
                  res = $stdin.gets.chomp

                  case res 
                  when "r" #register current directory to alias
                     lines = File.open($config , "r").each_line.to_a
                     print "key: "
                     key = $stdin.gets.chomp
                     uri = link
                     print "comment: "
                     comment = $stdin.gets.chomp
                     f = File.open($config, "w")
                     lines.each do |line|
                       f.puts line
                     end
                     f.puts "#{key} #{uri} #{comment}"
                     f.close       
                     puts "REGISTRATION COMPLETED!".red
                  when "cd"
                      print "search: "
                      word = $stdin.gets.chomp
                      Dir["#{link}/*".gsub("//","/")].each do |file| 
                          if File.basename(file).downcase.include? word.downcase
                              print "THIS "
                              print "#{File.basename(file)}".green
                              print " ?[Y/n] "
                              res = $stdin.gets.chomp.downcase
                              if res == "y"
                                  link = file
                                  $location_cash = link
                                  openLink $location_cash 
                              end
                         end
                       end
                  when ""
                     openLink $location_cash
                  when ".."
                     $location_cash =File.dirname(link)
                     openLink File.dirname(link) 
                  when "m"
                      return
                  when "mv"
                       print "Old File Name: ".red
                       old = $stdin.gets.chomp
                       print "New File Name: ".red
                       new = $stdin.gets.chomp
                       system "move #{link}\\#{old} #{link}\\#{new}".gsub("/","\\")
                  when "d"
                       print "Enter File Name: ".red
                       filename = $stdin.gets.chomp
                       puts link.red
                       system "del #{link}\\#{filename}".gsub("/","\\")
                  when "v"
                       print "Enter File Name: ".green
                       filename = $stdin.gets.chomp
                       system "vim #{link}\\#{filename}"
                       removeGarbage(link, filename)

                  when "c"
                       print "Which?: "
                       res = $stdin.gets.chomp.to_i
                       link = list[res.to_i]
                       copyFileDir =  File.dirname(link)
                       copyFileNames = File.basename(link).split('.')
                       copyFile     = "#{copyFileDir}\\#{copyFileNames[0]}_copy.#{copyFileNames[1]}"
                       system "copy #{link} #{copyFile}".gsub("/","\\")
                  else
                     openLink list[res.to_i]
                  end
              else
                  link = link.gsub("/","\\")
                  if File.basename(link).include? "."
                      system "start #{link}"
                  else
                      system "vim #{link}"
                      removeGarbage(File.dirname(link), File.basename(link))
                  end
              end
            end
            sleep 1
            openLink $location_cash
        end


$location_cash = ""


def executeIter(oper)
        $config = "/Users/sugano-k/Fabrica/Conf/link/list"
        key   = ""
        links = Hash.new
        hash = Hash.new

        #token = nil
        token = ""
        if oper == ""
           print "[add link:add previous location:p conf:c search:/[term] q:quit]"
           oper = $stdin.gets.chomp
        end

        case oper
        when "q"
          return     
        when "c"
          system  "vim #{$config}"
        when "add"
          print "link:"  
          link = $stdin.gets.chomp
          print "key:"
          key  = $stdin.gets.chomp
          print "description:"
          comment = $stdin.gets.chomp
          f = File.open($config, "a") 
          data = "#{key} #{link} #{comment}"
          f.puts(data);
          f.close
          puts "added: #{data}"
          executeIter(oper)
        when "p"
          openLink $location_cash
          executeIter(oper)
        else
          token=oper.gsub("/","")
          doIter token, hash, links
        end

    executeIter ""
end

