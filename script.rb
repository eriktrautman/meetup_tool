# Necessary if you actually want to use bundler 
# to handle your gems via the Gemfile
# It basically changes the load path
require 'rubygems'
require 'bundler/setup'


require 'typhoeus'
require 'json'
require 'rMeetup'

# For better debugging
require 'pry-byebug'
require 'pp' # Lets us prettyprint with `pp(some_json_object)`

def as_one_line_string(r)
  print "#{r.members} Members".ljust(15)
  print "  :::  "
  print "#{r.name}"[0..29].ljust(30)
  print "  :::  "
  print "#{r.city}, #{r.state}, #{r.country}"[0..19].ljust(20)
  puts
end

def as_sparse_string(r)
  puts "***********************************************"
  puts "#{r.name}, #{r.link}"
  puts "Members: #{r.members}"
  puts "Location: #{r.city}, #{r.state}, #{r.country}"  
end

def as_string(r)
  puts "***********************************************"
  # 
  puts "#{r.name}, #{r.link}"
  puts "Members: #{r.members}"
  puts "Created: #{r.created}"  # #{DateTime.strptime(r.created,'%s')}"
  # puts "Category: #{r.category.name}"
  puts "Primary Topic: #{r.primary_topic}"
  puts "Location: #{r.city}, #{r.state}, #{r.country}"
  puts "Permissions:  List >> #{r.list_mode}, Join >> #{r.join_mode}"
end

# name,link,members,created,primary_topic,city,state,country,list_mode,join_mode
def as_csv(r)
  [
    r.name.gsub(","," "),
    r.link,
    r.members,
    r.created,
    r.primary_topic,
    r.city,
    r.state,
    r.country,
    r.list_mode,
    r.join_mode
  ].join(",")
end

# Counts up all the members by a specific geography, 
# e.g. state or city
def total_members_by(geo, results)
  totals = results.each_with_object(Hash.new(0)) do |res,counts|
    next unless ["us","ca"].include?(res.country)
    counts[res.send(geo.to_sym)] += res.members.to_i
  end
  puts "TOTAL: #{totals.values.inject(:+)}"
  
  totals = totals.sort_by { |geo,count| -count }
  puts "Total members by #{geo.to_s}: "
  totals.each do |k,v|
    puts "#{k}: #{v}"
  end
end

# Counts up groups by a specific geography, 
# e.g. state or city
def count_by(geo, results)
  totals = results.each_with_object(Hash.new(0)) do |res,counts|
    # binding.pry
    next unless ["us","ca"].include?(res.country)
    counts[res.send(geo.to_sym)] += 1
  end
  puts "TOTAL: #{totals.values.inject(:+)}"

  totals = totals.sort_by { |geo,count| -count }

  puts "Total groups by #{geo.to_s}: "
  totals.each do |k,v|
    puts "#{k}: #{v}"
  end
end

# It won't let you filter by just a country since they use
# proximity to figure out the radius so you need a unique 
# identifier like city, state, AND country or just Zip.
RMeetup::Client.api_key = ENV["API_KEY"]
results = RMeetup::Client.fetch(:groups,{:topic => "ruby", :order => "members", :page => 200, :fields => "list_id,list_addr"})
puts "Result count: #{results.size}"
puts "\n***********************************************\n"
total_members_by(:city, results)
puts "***********************************************\n"
# count_by(:state, results)
# puts "***********************************************"

results.each do |result|
  # puts as_string(result)
  # puts as_sparse_string(result)
  puts as_csv(result)
  # as_one_line_string(result)
end
  # puts "***********************************************"
