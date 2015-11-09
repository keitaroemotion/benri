def findGrep(dest, kw)
    Dir["#{dest}/*"].each do |file|
        if File.directory? file
            findGrep file, kw
        else
            begin
            File.open(file, "r:UTF-8").each do |line|
                if line.downcase.include? kw.downcase
                   $gr_result[$gri] = file
                   $gri = $gri+1
                   break
                end
            end
            rescue
            end
        end
    end
end

def grep(dest)
    print "keyword: "
    kw = $stdin.gets.chomp
    $gri = 0
    $gr_result = Hash.new
    
    findGrep dest, kw

    $gr_result.keys.each do |key|
        puts "#{key}) "+$gr_result[key].green
    end

    if $gr_result.size > 0
        print "which to edit? [quit:q] "
        res = $stdin.gets.chomp
        if res != "q"
            res = res.to_i
            system "vim #{$gr_result[res]}"
            addToEditLog $gr_result[res]
        end
    else
        puts
        puts "NOT FOUND: '#{kw}' !!".red
    end
    grep dest
end

def executeGrep(config)
    list = getlist config
    mems = Hash.new
    list.keys.each do |key|
        from = list[key][0]
        to   = list[key][1]
        if (from+to).include? ":/"
        else
        puts
        print "key: "
        print "#{key} ".green
        print "#{to} "
        mems[key] = to
        puts
        end
    end
    print "which? "
    $res = $stdin.gets.chomp
    dest = mems[$res]
    grep dest
end
