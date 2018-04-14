require 'securerandom'
require 'open3'

#Use: ruby testFileGen.rb x y
#Where x is number of files to generate
#and y is the size in bytes

of = 'testfiles.txt'

max = Integer(ARGV[0])-1
bytes = Integer(ARGV[1])


name_arr = []

(0..max).each do |x|
    File.open(x.to_s, 'wb') do |f|
        f.write(SecureRandom.random_bytes(bytes))
        f.close
    end
    sto, ste, status = Open3.capture3("ipfs add "+x.to_s)
    begin
        puts sto
        name_arr.push(sto.split(' ')[1])
    rescue
    end    
end

times = []

File.open(of, 'w') do |f|
    name_arr.each do |e|
        f.puts(e)
    end
end

system "scp "+of+" moriarty:"