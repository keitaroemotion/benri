# copy file to one directory to another
#
# research (diff)
#
#
require 'colorize'
require 'FileUtils'
require '\copyx\lib\iter.rb'
require '\copyx\lib\history.rb'
require '\copyx\lib\grep.rb'
require '\copyx\lib\edit.rb'
require '\copyx\lib\util.rb'
require '\copyx\lib\clean.rb'
require '\copyx\lib\scp.rb'

targetfile = ""


$cons        = Array.new
$commands    = Array.new
$reverse = false
$report = Hash.new
$key  = ""
$from = ""
$to   = ""

optarg =  ARGV[0]

rootdir = "\\Users\\sugano-k\\Fabrica\\Conf\\copyx"
config  = "#{rootdir}\\list"

$editlog = "\\copyx\\recently_edited_files.log"
$keycache = "\\copyx\\key"

def dispHelpMenu()
    appname="benri" 
    puts ""
    puts "#{appname} [local]      ... file directory deployment"
    puts "#{appname} [key]        ... altkey"
    puts "#{appname} [conf]  ... edit dir location settings"
    puts "#{appname} [edit] [option:key]  ... edit files"
    puts "#{appname} [clean] ... garbage starts with tilda"
    puts "#{appname} [scp]   ... use scp"
    puts "#{appname} [grep]   ... "
    puts "#{appname} [history]   ...  edited file history"
    puts "#{appname} [help]  ... show help"
    puts "#{appname} [cd]  ... iter"
    puts
end

$args = Array.new 


def executeAPI(config)
    if ARGV.size == 0
        dispHelpMenu
        print "choose option: "
        optarg = $stdin.gets.chomp
        if optarg.strip.include? " "
            $args = optarg.split(' ');
            optarg = $args[0] 
            $args  = $args[1..optarg.size-1]
        end

    end

    case optarg 
    when "key"
        key = getKeyInput config
        puts
        puts "Congrats! your key is #{key}".green
        puts 
    when "help", "h", "-h"
        dispHelpMenu
    when "history", "his"
        executeHistory $editlog
    when "conf"
        system "vim #{config}"
    when "grep"
        executeGrep config
    when "cd"
        executeIter  ""
    when "edit"
        executeEdit $args, config
    when "clean"
        executeClean config
    when "scp"
        executeScp config
    when "local"
        targetfile = optarg
    else
    end
    executeAPI config
end
#list = getlist config

executeAPI config
#executeOldSchool list
