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

