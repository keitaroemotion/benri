# copy file to one directory to another
#
# research (diff)
#
#
# coding: utf-8
require 'colorize'
require 'FileUtils'
require 'git'
require 'net/ssh'
require 'net/scp'

$appdir = "benri\\bin"

require "\\#{$appdir}\\lib\\iter.rb"
require "\\#{$appdir}\\lib\\history.rb"
require "\\#{$appdir}\\lib\\grep.rb"
require "\\#{$appdir}\\lib\\edit.rb"
require "\\#{$appdir}\\lib\\util.rb"
require "\\#{$appdir}\\lib\\clean.rb"
require "\\#{$appdir}\\lib\\scp.rb"
require "\\#{$appdir}\\lib\\scpx.rb"
require "\\#{$appdir}\\lib\\troop.rb"
require "\\#{$appdir}\\lib\\conf.rb"
require "\\#{$appdir}\\lib\\git.rb"
require "\\#{$appdir}\\lib\\comment.rb"
require "\\#{$appdir}\\lib\\vim.rb"
require "\\#{$appdir}\\lib\\rwork.rb"

config  = "\\#{$appdir}\\list"
$scpinfo  = "\\#{$appdir}\\scpinfo"

targetfile = ""

$cons        = Array.new
$commands    = Array.new
$reverse = false
$report = Hash.new
$key  = ""
$from = ""
$to   = ""

optarg =  ARGV[0]

$vim_app = "\\benri\\tool\\vim\\vim" 
$sshinfo = "/benri/sshlogin.info"
$editlog = "\\#{$appdir}\\recently_edited_files.log"
$keycache = "\\#{$appdir}\\key"
$groupRootDir = "\\#{$appdir}\\groups"

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
    puts "#{appname} [git]  ... git"
    puts "#{appname} [comment]  ... comment"
    puts "#{appname} [rwork]  "
    puts
end

$args = Array.new 

def is_number? string
  true if Float(string) rescue false
end

def executeAPI(config)
    if config == nil
        exit "ERROR: config nil".red
    end

    if ARGV.size == 0
        dispHelpMenu
        print "choose option: "
        optarg = $stdin.gets.chomp
        if optarg.strip.include? " "
            $args = optarg.split(' ');
            optarg = $args[0] 
            $args  = $args[1..optarg.size-1]
        end
    else
        optarg = ARGV[1] 
    end

    if optarg.start_with? "/"
      $args[1] = optarg.gsub("/","")  
      executeEdit $args, config, $vim_app
      return executeAPI(config)
    end

    case optarg 
    when "key"
        key = getKeyInput config
        if key != -1
          puts
          puts "Congrats! your key is #{key}".green
          puts 
        end
    when "help", "h", "-h"
        dispHelpMenu
    when "history", "his"
        executeHistory $editlog
    when "conf"
        execConf config
    when "grep"
        executeGrep config
    when "cd"
        executeIter  ""
    when "edit"
        executeEdit $args, config, $vim_app
    when "clean"
        executeClean config
    when "scp"
        executeScpx $groupRootDir, $sshinfo, $vim_app
    when "local"
        targetfile = optarg
    when "rwork"
         # encoding: UTF-8
         Encoding.default_external = 'UTF-8'
         execute_rwork
    when "git"
        executeGit $args
    when "comment", "com"
        executeComment config, $vim_app
    when "compile", "c"
        return 
    else
    end
    executeAPI config
end

executeAPI config


