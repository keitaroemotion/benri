#base = "/copyx/nakama"   
#FileUtils.mkdir_p base 

def executeTroops(base, file) 
  def getTroops(base)
    troops = Hash.new
    nakamas = Dir["#{base}/*"]
    if nakamas.size > 0
      nakamas.each do |file|
        troops[File.basename(file)] = File.open(file, "r:UTF-8").each_line.to_a
      end
    end
    return troops 
  end

  def dispTroops(base)
      puts " --- |Troops| --- "
      getTroops(base).each do |troop|
          print "> "
          puts troop[0].green
      end
      puts
  end

  def specifyTroop(base)
    dispTroops  base
    print "which troop? "
    ans = $stdin.gets.chomp.downcase
    (base+"/"+ans).gsub("//","/") 
  end

  def addToTroop(base, file)
    troop = specifyTroop base
    lines = Array.new
    if File.exist? troop
      lines = File.open(troop, "r:UTF-8").each_line.to_a
    end
    alreadyReg = false
    lines.each do |line|
      if line.strip.chomp == file.strip.chomp
        alreadyReg = true
      end
    end

    if alreadyReg == false
      f = File.open(troop, "a")  
      print "add #{file} ? [Y/n]".red
      if $stdin.gets.chomp.downcase == "y"
        f.puts file
      end
      f.close
      puts "| REGISTERED! |".green
    else
      puts "already registered!".red
    end
  end

  def findTroop(file, base)
     print "[ "
     print File.basename(file).magenta
     print " ]"
     puts
     arr = Array.new
     getTroops(base).each do |hash| #file, sols
         if hash[1].include? "#{file}\n"
             arr.push hash[0]
         end
     end
     arr
  end
  def findFriends(file, base)
     arr = Array.new
     getTroops(base).each do |hash| #file, sols
         if hash[1].include? "#{file}\n"
             arr.push hash[1]
         end
     end
     arr
  end

  def editTroop(base, file)
     puts specifyTroop(base).cyan
  end

  def dropTroop(base, file)
      dispTroops  base
  end
  
  puts "[a:add to troop]"
  puts "[e:edit troop]"
  puts "[r:remove from troop]"
  puts "[l:list troops]"
  puts "[n:list soldiers]"
  puts "[d:drop troop]"
  print ">"
  case $stdin.gets.chomp.downcase
  when "a"
    addToTroop(base, file)
  when "r"
    dropTroop(base, file)
  when "e"
    editTroop(base, file)
  when "d"
    dispTroops  base
    print "which?:"
    res = $stdin.gets.chomp
    target = "#{base}/#{res}"
    if File.exist? target
      File.open("#{target}", "r:UTF-8").each do |f|
        puts f.red
      end
      print "del #{res}? "
      FileUtils.rm target
    else
      puts "ntot exist!".red
    end
  when "l"
    dispTroops  base
  when "n"
     friends = findFriends file, base
     print "| FRIENDS OF"
     print " #{File.basename(file)}".green
     puts "|"
     friends.each do |t|
       print "> "
       t.each do |tt|
         puts tt.to_s.cyan
       end
     end
  when "f"
     yourtroop = findTroop file, base
     yourtroop.each do |t|
         puts t.green
     end
     if yourtroop.size == 0
        puts "YOU ARE LONELY."
     end
  end
  executeTroops(base, file) 
end
