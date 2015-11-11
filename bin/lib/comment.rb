
def isLineTarget(line)
  return (line.include?(" function ") || line.include?(" class "))
end

def hasComment(i,lines) 
  (0..i).each do |x|
    r = i -x  
    liner = lines[r].strip
    #puts liner.cyan
    if liner != ""
       if liner.include?("*")  #too simple...
          return true
       end
       if liner.start_with?("}")  
          return false 
       end
    end
  end
  return false
end

def search(dir, hash=Hash.new) #php only

   Dir["#{dir}/*".gsub("//","/")].each do |file|
       if File.directory? file
           hash = search(file, hash)
       else
         if file.end_with?(".php") == false
           next
         end
         lines = File.open(file, "r:UTF-8").each_line.to_a
         contents = Array.new
         (0..lines.size-1).each do |i|
             line = lines[i]
             if (isLineTarget(line) && !hasComment(i, lines))
                 contents.push line
             end
         end
         if contents.size > 0
             hash[file] = contents
         end
       end
   end
   return hash
end

def executeComment(config, vimapp)
  list = getlist config
  keyInFile = ""
  if File.exist?($keycache)
     begin
       keyInFile = File.open($keycache, "r").each_line.to_a[0].strip.chomp
     rescue
     end
     key = (keyInFile == "") ? getKeyInput(config, false) : keyInFile
  end

  print "YOUR KEY : ["
  print " #{key} ".magenta
  puts "]"

  path = get_path list, key, false
  hash = search  path 
  hash.keys.each do |file|
    puts "#{File.basename(file)} " .yellow
    puts "\n#{File.dirname(file)}\n " .cyan
    print "edit?[Y/n][q]:"  
    case $stdin.gets.chomp.downcase 
    when "y"
      usevim(file, vimapp)
    when "n"
    when "q"
      break
    else
    end
  end
end
