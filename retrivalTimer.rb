
require 'open3'

sf = 'testfiles.txt'

ipfs_hash = File.readlines(sf)


times = []
ipfs_hash.each do |f|
    t1 = Time.now
    sto, ste, status = Open3.capture3("ipfs get "+f)
    t2 = Time.now
    times.push(t2-t1)
    puts sto
end
puts times
puts "Average: "+(times.reduce(:+) / times.size.to_f).to_s