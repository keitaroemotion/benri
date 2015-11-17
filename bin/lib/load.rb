
require 'fileutils' #tmp

def readReposPath(library_dir)
  #if File.exist?(library_dir) == false
  #   puts "\n\n#{library_dir} does not exist.\n\n".red
  #end
  return "//gn-fs11/pad/restaurant/00_share/shared/data/application/benri/system/lib"
end

def mkdir(dir)
  if File.directory? dir
    FileUtils.mkdir_p dir
  end
  return dir
end

def uploadLibraries(appdir, library_dir="")
  Dir["#{appdir}/*".gsub("//","/")].each do |file|
    begin  
      fileName = File.basename(file)  
      if fileName.end_with? "~"
        next
      end
      FileUtils.cp "#{appdir}/#{fileName}", "#{readReposPath(library_dir)}/#{fileName}"    
    rescue Exception => e
      puts "[FAILED] #{file}".red  
      puts "\n#{e.message}\n"
    end
  end
end

def downloadLibraries(appdir, library_dir="")
  reposDir = readReposPath(library_dir)
  Dir["#{reposDir}/*"].each do |file|
    fileName = File.basename(file)  
    if (fileName.end_with?("~") ||  fileName.include?("load.rb"))
        next
    end
    begin
      FileUtils.cp "#{reposDir}/#{fileName}", "#{appdir}/#{fileName}"    
      load "#{appdir}/#{fileName}" 
      puts "[LIBRARY] #{File.basename(file)}".yellow  
    rescue Exception => e 
      puts file
      puts "\n#{e.message}\n".red
      puts "\n\n#{e.backtrace}\n\n".red
    end
  end


  puts "\n\nupdate completed!\n\n".green
end

# test part
#
#uploadLibraries "/benri/bin/lib", "xxx"
