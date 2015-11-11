def executeClean(config)
    list = getlist config
    list.keys.each do |key|
        print "key: "
        print "#{key} ".green
        print "to: #{list[key][1]} "
        puts
    end
    print "which key?: "
    key = $stdin.gets.chomp
    to   = list[key][1]

    def cleanDir(dir)
        Dir["#{dir}/*".gsub("//","/")].each do |file|
            if File.directory? file
                cleanDir file  
            end
            remove file    
        end
        Dir["#{dir}/.*~".gsub("//","/")].each do |file|
            remove file    
        end
    end

    def remove(file)
       if(file.end_with?("~"))
            puts "removed: #{file}".red
            FileUtils.rm file
        end 
    end

    cleanDir to
end
