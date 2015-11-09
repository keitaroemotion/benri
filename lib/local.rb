def executeOldSchool(list)
    print "which key?: "
    key = $stdin.gets.chomp
    $from = list[key][0]
    $to   = list[key][1]

    if $from.include? ":/"
       $reverse = true
    end

    read($from, $to, "", true)
    exec targetfile, ARGV.size

    if $notes.size > 0
       $notes.each do |f|
          puts f.gsub($to, "").yellow
       end
    end
end


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
                addToEditLog toFile
            end
        end
    end
end

