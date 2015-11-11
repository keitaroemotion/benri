
def executeHistory(editlog)
    system "cat #{editlog}"
    print "[edit History:h  File:f] "
    case $stdin.gets.chomp.downcase
    when "h"
        system "vim #{editlog}"
        executeHistory(editlog)
    when "f"
        list = Array.new
        i = 0
        File.open(editlog, "r").each do |line|
           print "#{i})"
           puts " #{line}".green
           list.push line
           i = i+1
        end
        print "which? "
        res = $stdin.gets.chomp.to_i
        system "vim #{list[res]}"
        executeHistory(editlog)
    end
end
