# encoding: shift_jis



=begin

def askDatePart(tag)
  print "#{tag}:"
  month = $stdin.gets.chomp
  if month.size != 2
      puts "\nsize gotta be 2\n".red
      return askDatePart tag
  end
  tag
end

print "year?"
year = $stdin.gets.chomp
month = askDatePart "month"
day = askDatePart "day"
dir = "//Gn-fs11/pad/restaurant/00_share/【共通資料】/リリースチェック/#{year}年/#{month}月"
released = "#{dir}/リリース済み"

def ask(tag)
  print "#{tag}:"
  res = $stdin.gets.chomp
  if res == ""
      puts "\nBlank\n".red
      return ask tag
  end
  return res
end

service = ask "service"
mission = ask "mission"
who     = ask  "who"

template = "/benri/data/template.xls"

title   = "#{year}#{month}#{day}_【#{service}】_#{mission}手順書_#{who}.xls"

local_file   =  "/benri/data/#{title}"
remote_file  =  "#{dir}/#{title}"
release_file =  "#{release}/#{title}"

if File.directory?(dir) == false
    puts "non exist: #{dir}".red
end
if File.directory?(relased) == false
    puts "non exist: #{released}".red
end


def exec_rwork()
    print "[c:create e:edit p:push rep:report rel:released]"
    res = $stdin.gets.chomp

    case res
    when "c"
       FileUtils.cp template, "#{local_file}"    
       if File.exists? "#{local_file}"
          puts "\n\ndone!!\n\n"
       end
    when "e"
       system "start #{local_file}".gsub("/","\\") 
    when "p"
       FileUtils.cp local_file, remote_file
    when "rep"
       # sample 
       system "start http://10.19.33.134/p-ticket/issues/18513"  
       system "start http://10.19.33.134/p-ticket/projects/server_access/issues/new"
    when "rel"
       File.mv remote_file, release_file
    end 
    exec_rwork
end


=end
