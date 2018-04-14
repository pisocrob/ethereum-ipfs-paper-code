require 'gruff'
require 'json'
require_relative 'scraper'


class Plotting

$file = 'ctx_list_partial.json'
#$file = 'ctx_list_500.json'

#ctx = {txid, block height, source code, contract id, block containing most recent TX to the contract}
$size, $one_hash_arr = Data.data(false, $file)
$size, $two_hash_arr = Data.data(true, $file)
$theme = {   # Declare a custom theme
  :colors => [
        '#f5bbbb',  # red
        '#b6d3b6',  # green
        '#bbbbf5',  # blue
        '#D1695E',  # red
        '#b2b2b2',  # black
        '#EFAA43',  # orange
        'white'
      ], # colors can be described on hex values (#0f0f0f)
  :marker_color => 'black', # The horizontal lines color
  :background_colors => %w(white white) # you can use instead: :background_image => ‘some_image.png’
}




def self.average_graph_growth_per_block
    length = $size.size
    av_size = $size.reduce(:+).to_f / length
    two_hash_size = []
    one_hash_size = []
    (0..$size.length-1).each do |i|
        two_hash_size.push($size[i]-$two_hash_arr[i])
        one_hash_size.push($size[i]-$one_hash_arr[i])
    end

    av_two_hash = two_hash_size.reduce(:+).to_f / length
    av_one_hash = one_hash_size.push.reduce(:+).to_f / length


    size_plot = []
    one_hash_plot = []
    two_hash_plot = []
    size = []
    inc_one = 0
    inc_two = 0
    inc_size = 0
    labels = {}

    (1..10000).each do |i|
        inc_one += av_one_hash
        one_hash_plot.push(inc_one)
        inc_two += av_two_hash
        two_hash_plot.push(inc_two)
        inc_size += av_size
        size.push(inc_size)
        if i % 1000 == 0
            labels[i.to_i] = i.to_s
        end
    end
        
    g = Gruff::Line.new('2028x1024')
    #g.title = 'Wow!  Look at this!'
    #g.labels = { 0 => '5/6', 1 => '5/15', 2 => '5/24', 3 => '5/30', 4 => '6/4',
    #             5 => '6/12', 6 => '6/21', 7 => '6/28' }
    g.labels = labels
    g.y_axis_label = "bytes"
    g.x_axis_label = "blocks"
    g.data 'Base', size
    g.data 'Two Hash', two_hash_plot
    g.data 'One Hash', one_hash_plot
    g.theme = $theme
    g.line_width = 4
    g.write('Average_growth_'+$file+'.png')
end

def self.real_values_graph
    two_hash_size = []
    one_hash_size = []
    test_arr = []
    labels = {}
    (0..$size.length-1).each do |i|
        two_hash_size.push($size[i]-$two_hash_arr[i])
        one_hash_size.push($size[i]-$one_hash_arr[i])
        if i % 100 == 0
            labels[i.to_i] = i.to_s
        end
    end

    puts "Largest Contract is: "+$size.max.to_s+" | Array pos "+$size.find_index($size.max).to_s

    g = Gruff::Bar.new('2028x1024')
    #g.title = 'Wow!  Look at this!'
    g.labels = labels
    g.data 'Base', $size
    g.data 'Two Hash', two_hash_size
    g.data 'One Hash', one_hash_size
    g.theme = $theme
    g.write('Real_size_'+$file+'.png')
end

def self.real_values_compare_hashes
    two_hash_size = []
    one_hash_size = []
    labels = {}
    (0..$size.length-1).each do |i|
        two_hash_size.push($size[i]-$two_hash_arr[i])
        one_hash_size.push($size[i]-$one_hash_arr[i])
        if i % 100 == 0
            labels[i.to_i] = i.to_s
        end
    end

    g = Gruff::Bar.new('2028x1024')
    #g.title = 'Wow!  Look at this!'
    g.labels = labels
    #g.data :Base, size_arr
    g.data 'Two Hash', two_hash_size
    g.data 'One Hash', one_hash_size
    g.theme = $theme
    g.write('real_values_compare_hashes'+$file+'.png')
end

def self.real_values_two_hash_size
    two_hash_size = []
    one_hash_size = []
    test_arr = []
    labels = {}
    (0..$size.length-1).each do |i|
        two_hash_size.push($size[i]-$two_hash_arr[i])
        one_hash_size.push($size[i]-$one_hash_arr[i])
        if i % 100 == 0
            labels[i.to_i] = i.to_s
        end
    end

    g = Gruff::Line.new('2028x1024')
    #g.title = 'Wow!  Look at this!'
    g.labels = labels
    #g.data :Base, $size
    g.data 'Two Hash', two_hash_size
    #g.data :OneH, one_hash_size
    g.theme = $theme
    g.write('Real_two_hash_size_'+$file+'.png')
end

def self.real_values_graph_growth
    two_hash_size = []
    two_hash = 0
    one_hash_size = []
    one_hash = 0
    size_arr = []
    size = 0
    labels = {}
    (0..$size.length-1).each do |i|
        two_hash += ($size[i]-$two_hash_arr[i])
        two_hash_size.push(two_hash)
        one_hash += ($size[i]-$one_hash_arr[i])
        one_hash_size.push(one_hash)
        size += $size[i]
        size_arr.push(size)
        if i % 200 == 0
            labels[i.to_i] = i.to_s
        end
    end

    g = Gruff::Line.new('2028x1024')
    #g.title = 'Wow!  Look at this!'
    g.labels = labels
    g.y_axis_label = "bytes"
    g.x_axis_label = "CCTX"
    g.data 'Base', size_arr
    g.data 'Two Hash', two_hash_size
    g.data 'One Hash', one_hash_size
    g.theme = $theme
    g.line_width = 4
    g.write('real_values_growth_'+$file+'.png')
end

def self.real_values_graph_cut(x, y)
    from = x
    to = y
    
    two_hash_size = []
    one_hash_size = []
    test_arr = []
    labels = {}
    (from..to).each do |i|
        two_hash_size.push($size[i]-$two_hash_arr[i])
        one_hash_size.push($size[i]-$one_hash_arr[i])
        if i % 100 == 0
            labels[i.to_i] = i.to_s
        end
    end
    g = Gruff::Bar.new('2028x1024')
    #g.title = 'Wow!  Look at this!'
    g.labels = labels
    g.data 'Base', $size[from-1,to-1]
    g.data 'Two Hash', two_hash_size
    g.data 'One Hash', one_hash_size
    g.theme = $theme
    g.write('Real_size_'+$file+'_cut.png')
end

def self.total_size_plot
    two_hash = 0
    one_hash = 0
    size = 0
    labels = {}
    (0..$size.length-1).each do |i|
        two_hash += ($size[i]-$two_hash_arr[i])
        one_hash += ($size[i]-$one_hash_arr[i])
        size += $size[i]
    end

    g = Gruff::Bar.new('2028x1024')
    #g.title = 'Wow!  Look at this!'
    #g.labels = { 0 => 'Two hash', 1 => 'One hash', 2 => 'base size' }
    #g.labels = { 0 => '5/6', 1 => '5/15', 2 => '5/24', 3 => '5/30', 4 => '6/4',
    #             5 => '6/12', 6 => '6/21', 7 => '6/28' }
    g.data "Base", size
    g.data "Two hashes", two_hash
    g.data "One Hash", one_hash
    g.show_labels_for_bar_values = true
    g.theme = $theme
    g.write('total_size_plot_'+$file+'.png')
end

def self.latency_bar
    g = Gruff::Bar.new('2028x1024')
    #g.title = 'Wow!  Look at this!'
    g.labels = {'66' => '214', '1053' => '287', '4000' => '421', '1000000' => '456'}
    g.data '66', 516
    g.data '1503', 533
    g.data '19014', 536
    g.data '1000000', 578
    g.y_axis_label = "ms"
    g.maximum_value = 580  # Declare a max value for the Y axis
    g.minimum_value = 0   # Declare a min value for the Y axis
    g.y_axis_increment = 50  # Points shown on the Y axis

    #g.show_labels_for_bar_values = true
    g.theme = $theme
    g.write('latency_bar.png')
end

def self.code_size_stacked
    
    g = Gruff::StackedBar.new('2028x1024') 

    g.sort = false
    g.y_axis_label = "bytes"
    #g.maximum_value = 100 
    #g.minimum_value = 0 
    #g.y_axis_increment = 10
    g.labels = {0 => 'Base', 1 => 'One hash', 2 => 'Two hash'}
    g.data('init',[183871,183871,46106])
    g.data('runtime',[1293963,230170,44649])
    #g.sort = false
    g.theme=$theme

    g.write('total_size_bar_stacked.png')
end

def self.write_size
    File.open('size_list.txt', 'w') do |file|
            $size.each do |c|
                file.puts c
            end
        end
end

end
Plotting.real_values_graph
#Plotting.real_values_compare_hashes
#Plotting.real_values_two_hash_size

#Plotting.real_values_graph_growth
#Plotting.average_graph_growth_per_block

#Plotting.real_values_graph_cut(70,180)
#Plotting.total_size_plot
#Plotting.latency_bar
#Plotting.write_size

#Plotting.code_size_stacked