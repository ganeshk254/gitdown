#!/usr/bin/ruby
# Download all the repositories the user contributed to or part of.
# This includes the user personal repositories and the organizations repositories.
require 'uri'
require 'json'
require 'optparse'
require 'net/http'

# Get the command line options
OptionParser.new do |opts|
  opts.banner = "Usage: gitdown.rb [options]"

  opts.on("-t", "--token access_token","access token to talk to github api") do |token|
    $token = token
  end

  opts.on("-e", "--endpoint optional github api endpoint", "Github/Enterprise api endpoint") do |api|
    $api = api
  end

  opts.on("-h", "--help", "Display this screen") do
    puts opts
    exit
  end
end.parse!

# Set the api to public github endpoint if not provided
if $api == nil
  $api = "https://api.github.com"
end

# Remove the trailing slash from URL if provided
if $api[-1] == "/"
  $api = $api[0..-2]
end

# Fail if the personal access token is not provided
if $token == nil
  puts "Please provide a github personal access token at https://github.com/settings/tokens 
        or similar for Enterprise editions."
  exit 1
end

$repos_urls = Array.new       #Variable to hold all the available repos

# Make an authenticated call to github api for the endpoint and return the response.
def git_api_response(url)
  puts "Getting #{url}"
  begin
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url)
    request["authorization"] = "token #{$token}"
    request["cache-control"] = "no-cache"
    response = http.request(request)
    return response
  rescue Exception => e
    puts "The GitHub API call failed - 
        #{e.message}
        ---- Backtrace ----
        #{e.backtrace}"
    exit 1
  end
end

# Get the user owned repositories
def get_user_repos
  url = URI("#{$api}/user/repos")
  response = git_api_response(url)
  if response.kind_of? Net::HTTPSuccess
    user_repos = JSON.parse(response.body)
    user_repos.each do |repo|
      repo_url = repo['html_url']
      $repos_urls << repo_url
    end
  else
    puts "Could not get user repos."
    exit 1
  end
end

# Get the organizations and their repositories
def get_org_repos
  url = URI("#{$api}/user/orgs")
  response = git_api_response(url)
  if response.kind_of? Net::HTTPSuccess
    orgs = JSON.parse(response.body)
    orgs.each do |org|
      org_repos_url = org['repos_url']
      url = URI(org_repos_url)
      response = git_api_response(url)    # Get the repositories under the org
      if response.kind_of? Net::HTTPSuccess
        org_repos = JSON.parse(response.body)
        org_repos.each do |repo|
          $repos_urls << repo['html_url']
        end
      else
        puts "Could not get organizations repositories."
        exit 1
      end
    end
  else
    puts "Could not get organizations."
    exit 1
  end
end

get_user_repos()      # Get the user owned repositories
get_org_repos()       # Get the user's organization repositories

$repos_urls = $repos_urls.uniq
# Clone all repositories
$repos_urls.each do |repo|
  protocol, repo = repo.split("://")
  `git clone #{protocol}://#{$token}@#{repo} #{repo}`
end
