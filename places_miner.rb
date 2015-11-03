require 'sqlite3'
require 'set'
require 'addressable/uri'

db_path = ARGV[0]
db = SQLite3::Database.new(db_path)

# clustering by time
# top destinations from SERP

# top domains
top_domains = Hash.new(0)

db.execute('SELECT url FROM moz_historyvisits INNER JOIN moz_places ON moz_places.id = moz_historyvisits.place_id') do |row|
  top_domains[Addressable::URI.parse(row[0]).host] += 1
end

puts "== Top Domains =="

top_domains.sort_by { |host, count| count }.reverse.slice(0, 20).each_with_index do |domains, i|
  puts "#{i + 1}. #{domains[1]} - #{domains[0]}"
end

# top destinations after serp
top_search_destinations = Hash.new(0)

db.execute("SELECT p.url FROM moz_historyvisits hv INNER JOIN moz_historyvisits phv ON phv.id = hv.from_visit INNER JOIN moz_places p ON p.id = hv.place_id INNER JOIN moz_places pp ON pp.id = phv.place_id WHERE pp.url LIKE '%google.com/url%'") do |row|
  top_search_destinations[Addressable::URI.parse(row[0]).host] += 1
end

puts "\n== Top Domains after SERP =="

top_search_destinations.sort_by { |host, count| count }.reverse.slice(0, 20).each_with_index do |domains, i|
  puts "#{i + 1}. #{domains[1]} - #{domains[0]}"
end


