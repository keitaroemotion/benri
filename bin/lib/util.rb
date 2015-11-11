def checkDir(dir)
    if (dir.include?(":/"))
    elsif (File.directory?("#{dir}") == false)
        abort "\ndir #{dir} does not exist\n".red
    end
end

def pop(array, i)
  if((array.size > i) && (i > -1))
    return array[i].strip
  end
  return ""
end

def windows(path)
  return path.gsub("/","\\")
end


def showOpt(list)
    list.keys.each do |key|
        if ((list[key][0]+list[key][1]).include?(":/") == false)
            print "key: "
            print "#{key} ".green
            print "from: #{list[key][0]} "
            print "to: #{list[key][1]} "
            puts
        end
    end
end


def fitPath(path)
  if path.include? ":/"
      return path
  end
  return path.gsub("/","\\")
end


def askkey(list, istmp=false)
    print "which key?[q:quit] "
    res = $stdin.gets.chomp
    if res.downcase == "q"
        return
    end
    if list.keys.include? res
       path = get_path list, res, istmp
       $path_ini = path
       return res
    else
       arr = Array.new 
       i = 0
       list.keys.each do |key| 
         if key.start_with? res
            arr.push key
            print "#{i}) "
            puts "#{key}".cyan
            i = i+1
         end
         if arr.size > 0
           print "above?:[q:quit] "
           res = $stdin.gets.chomp.downcase
           case res
           when "q"
               return -1
           else
             key = arr[res.to_i]
             path = get_path list, key, istmp
             $path_ini = path
             return key
           end
         else
           return -1
         end
         return askkey(list, istmp)
       end
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


def writeKeyCache(key, istmp=true)
  begin
    if(istmp == false) 
      f = File.open($keycache, "w")
      f.puts key
      f.close
    end
  rescue
    exit "error at writekeycache"  
  end
end

def getlist(config)
    list = Hash.new
    File.open(config, "r").each do |line|
       lsp  = line.split(" ")
       $key  = lsp[0]   
       $from = lsp[1]
       $to   = lsp[2]
       if $key != nil
         list[$key] = [$from, $to]
       end
    end
    return list
end

def get_path(list, key, istmp)
   begin
     writeKeyCache(key, istmp)
     if list.has_key?(key) == false
         puts "key does not exist: #{key}".red
         return -1
     end
     if list[key][1].include? ":/"
       return list[key][0]
     else
       return list[key][1]
     end
   rescue
     exit "listsize: #{list.size.to_s} key:#{key.to_s} ".red
   end
end


def addToEditLog(line)
    File.open($editlog, "r").each do |l|
      if l.strip.chomp == line.strip.chomp
          return  
      end
    end
end

