#!/usr/bin/env ruby
#

require "yaml"

CONFIG = YAML.load_file("config.yml") 

paths = CONFIG['include']
exclude = CONFIG['exclude']

def scan_file(path)
    begin
        line_num = 1
        File.open(path, "r") do |infile|
            while (line = infile.gets)
                if index = line.index(/\p{Cyrillic}/) then
                    puts "#{line_num}: start at #{index}" 
                end
                line_num = line_num + 1
            end
        end
    rescue => err
        puts "Exception: #{err}"
        #err
    end
end

def rscan_dir(root_path, exclude)
    if File.directory?(root_path) then
        #puts root_path
        Dir.foreach root_path do |path|
            unless path == '.' || path == '..' then
                next_path = "#{root_path}/#{path}"
                if File.directory?(next_path) then
                    rscan_dir(next_path, exclude) unless path == '.' || path == '..'
                else
                    fl_exclude = false
                    exclude.each do |regs|
                        if File.fnmatch("**/#{regs}", next_path, File::FNM_PATHNAME | File::FNM_DOTMATCH) then
                            fl_exclude = true
                            break
                        end
                    end
                    unless fl_exclude then
                        puts "File: #{path}\n"
                        scan_file next_path
                    end
                end
            end
        end
    end
end


paths.each { |path| rscan_dir(path, exclude) }

