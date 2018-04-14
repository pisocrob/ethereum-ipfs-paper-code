range = Integer(ARGV[0])-1

(0..range).each do |x|
    File.delete(x.to_s)
end