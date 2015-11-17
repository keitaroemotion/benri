

def normalizeFile(file)
    newLines = Array.new
    File.open(file, "r").each_line do |line|
      newLines.push line.encode(line.encoding, :universal_newline => true) 
    end

    f = File.open(file, "w")
    newLines.each do |line|
      f.puts line
    end
    f.close

    puts "\n\nnormalize done\n\n"
end

