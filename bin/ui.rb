#!/usr/bin/ruby
# frozen_string_literal: true

# RegistryCrawler
# A script to quickly explore your docker registry.
require 'rubygems'
require 'bundler/setup'

require './lib/registry'
require 'ruby-progressbar'

def help
    puts '====================================================='
    puts '?                         | Display this help'
    puts 'q!                        | Close this app'
    puts 'conn: <registry url>      | Connect to registry'
    puts 'auth_uname: <username> | Set your username'
    puts 'auth_passwd: <password> | Set your password'
    puts 'c!                        | Update your connection'
    puts 'r:                        | Get all repositories'
    puts 't: <repository>           | List available tags'
    puts 'm: <repository> <tag>     | Get manifest by tag'
    puts 'msha: <repository> <sha>  | Get manifest by SHA256'
    puts 'dmsha! <repository> <sha> | DELETE manifest by SHA256'
    puts '====================================================='
    puts 'housekeeper!              | Search for images without'
    puts '                          | tags. Note that this may'
    puts '                          | take a while...'
    puts '====================================================='
end

puts 'Welcome to Cubuzz\'s Registry Explorer!'
help
puts

if !ARGV.empty? && (ARGV[0] == '--help' || ARGV[0] == '-?' || ARGV[0] == '-h')
    puts 'Command-Line Arguments:'
    puts '-? / -h / --help | This help message.'
    puts
    puts 'Otherwise you can use this as script'
    puts 'by passing in arguments using something'
    puts 'like printf.'
    abort
end

connection = nil
registry = ''
username = ''
password = ''

begin
    loop do
        print '> '
        command = gets.chomp
        if command == '?'
            help
        elsif command == 'q!'
            abort 'Goodbye!'
        elsif command.start_with?('auth_uname:')
            username = command.sub('auth_uname: ', '')
            puts "Username set to #{username}"
        elsif command.start_with?('auth_passwd:')
            password = command.sub('auth_passwd: ', '')
            puts "Password set to #{password}"
        elsif command.start_with?('conn:')
            registry = command.sub('conn: ', '')
            puts "Registry set to #{registry}"
        elsif command == 'c!'
            puts "Connecting to registry #{registry} as #{username}..."
            connection = Registry.new(registry, username, password)
        elsif command == 'r:'
            puts connection.repositories
        elsif command.start_with?('t:')
            repo = command.sub('t: ', '')
            puts connection.tags(repo)
        elsif command.start_with?('m:')
            cmd = command.sub('m: ', '').split(' ')
            response = connection.manifest(cmd[0], cmd[1])
            puts response.body
            puts '======' * 5
            puts "Docker-Content-Digest: #{Registry.parse_digest(response)}"
            puts '======' * 5
        elsif command.start_with?('msha:')
            cmd = command.sub('msha: ', '').split(' ')
            puts connection.manifest(cmd[0], cmd[1])
        elsif command.start_with?('dmsha!')
            cmd = command.sub('dmsha! ', '').split(' ')
            puts "#{'>' * 20} HOLD UP! #{'<' * 20}"
            puts "You're trying to delete #{cmd[0]} tagged with #{cmd[1]}"
            puts 'DUE TO A LIMITATION WITH THE DOCKER REGISTRY,'
            puts 'THE REFERENCED LAYERS WILL BE DELETED DESPITE'
            puts 'HAVING DIFFERENT TAGS!'
            puts '=' * 53
            puts 'Are you sure you want to do this? (Y/n)'
            connection.delete_manifest(cmd[0], cmd[1]) unless gets.chomp != 'Y'
        elsif command == 'housekeeper!'
            puts '=' * 53
            puts 'Starting housekeeper scan...'
            puts
            roaming = connection.repositories['repositories']
            progressbar = ProgressBar.create(
                title: 'Repositories',
                starting_at: 1,
                total: roaming.length + 1
            )
            roaming.each do |repository|
                puts "* #{repository} is not referencing any tags." if connection.tags(repository)['tags'].nil?
                progressbar.increment
            end
            puts
            puts "Scan concluded: #{roaming.length} repositories considered."
            puts '=' * 53
        else
            puts "Unrecognized command '#{command}'. Type ? for help."
        end
        puts
    end
rescue StandardError => e
    puts e.message
    puts e.backtrace
    puts
    puts 'Are you logged in?'
    puts 'Most errors occur when you\'re not properly authenticated.'
    puts 'Have you connected to the registry? (c!)'
    puts
    retry
end
