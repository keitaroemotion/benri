class Encoder
  def self.encodeDirectory(dir, root)
    Dir["#{dir}/*".gsub("//","/")].each do |elem|
      File.directory?(elem) ? encodeDirectory(elem, root) : encode(elem)  
    end
    #print "[CONVERTED TO LF] ".yellow
    #puts "#{dir.gsub(root,'')}".green
  end


  def self.abbr(path)
      if path.size > 30
        return ("../"+ path[path.size-20 ..  path.size-1]).gsub("//","/")
      else
        return path
      end
  end

  def self.encode(path)
    tmp = ""  
    begin  

      path = path.gsub("\\","/")

      if path.end_with? "~"
          puts path
          FileUtils.rm path
      end

      file =File.open(path,'rb')
      input_text = file.read
      input_text = input_text.gsub(/\r/, "\n")

      tmp = path+".tmp.sugano_kun"

      begin
        f = File.open(tmp, 'wb')
        f.puts input_text
        f.close
        FileUtils.cp tmp, path
        FileUtils.rm tmp

        print "[CONVERTED TO LF] ".yellow
        puts abbr(path).cyan
      rescue
        print "[ENCODE FAILED]".red
        puts " #{abbr(path)}".magenta
      end
    rescue
      print "[ENCODE FAILED]".red
      puts " #{abbr(path)}".magenta
      
    end
    if File.exist? tmp
      FileUtils.rm tmp
    end
  end
end
