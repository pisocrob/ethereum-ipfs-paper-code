require 'open-uri'
require 'nokogiri'
require 'json'
require_relative 'Opcodes'
require 'digest'

#32 byte hash + 1 byte signifier overhead
$hash_size = 33
class Data
    extend Opcodes
    def self.scrape(first, sample)
        #ctx = {txid, block height, source code, contract id, block containing most recent TX to the contract}
        first_block = first
        last_block = first+sample-1

        doc = ""
        b_url = "https://etherscan.io/txs?block="
        tx_url = "https://etherscan.io/tx/"
        c_url = "https://etherscan.io/address/"

        ctx_list = []
        begin
        (first_block..last_block).each do |b| 
            doc = Nokogiri::HTML(open(b_url+b.to_s))
            if doc.css('body a[@class = "btn btn-default btn-xs logout"]').to_s.include? 'Last'
                p_no = doc.css('body a[@class = "btn btn-default btn-xs logout"]').xpath('@href[contains(., "p=")]').to_s[-1].to_i
            else
                p_no = 0
            end
            (1..p_no).each do |page|
                p_doc = Nokogiri::HTML(open(b_url+b.to_s+"&p="+page.to_s))
                p_doc.css('body table tbody tr').each do |td| 
                    if td.css('img').to_s.include? "application-table"
                        txid = td.css('span[@class = "address-tag"]')[0].css('a').xpath('text()').to_s
                        doc2 = Nokogiri::HTML(open(tx_url+txid.to_s))
                        bcs = doc2.css('div.tab-content div.col-sm-9.cbs textarea#inputdata').xpath('text()').to_s
                        c_id = doc2.css('div.tab-content div.col-sm-9.cbs')[5].css('a')[0].xpath('text()').to_s
          
                        doc3 = Nokogiri::HTML(open(c_url+c_id.to_s))
                        last_use = doc3.css('body table')[2].css('td[@class = "hidden-sm"] a').xpath('text()').first.to_s
                        ctx = {"txid" => txid, "bh" => b, "bcs" => bcs, "c_id" => c_id, "last_used" => last_use}
                        ctx_list.push(ctx)
                    end
                end
            end
            
        puts (b-(first-1)).to_s+" blocks done: "+b.to_s
        end

        puts "Scraping done"
        File.open('ctx_list.json', 'w') do |file|
            ctx_list.each do |c|
                file.puts c.to_json
            end
        file.close
        end

        puts "Written to: ctx_list.json"
        rescue => e
            puts e
            puts "Error Scraping. Writing available data to file: ctx_list_partial.json"
            File.open('ctx_list_partial.json', 'w') do |file|
                ctx_list.each do |c|
                    file.puts c.to_json
                end
            end
        end
    end

    def self.saving(hash_both=true, code)
        code = code.join("\n")
        code = code.split("STOP", 2)
        if code.length == 2
            init_code = code[0].split("\n")
            init_code.push("STOP")
            rt_code = code[1].split("\n")
        else
            init_code = []
            rt_code = []
        end
        if hash_both == true
            init_size = init_code.length+push_bytes(init_code)
            rt_size = rt_code.length+push_bytes(rt_code)
            init_saving = init_size-$hash_size
            if init_saving < 1 then init_saving=0 end

            rt_saving = rt_size-$hash_size
            if rt_saving < 1 then rt_saving=0 end

            base_size = rt_size + init_size

            return base_size, init_saving, rt_saving

        elsif hash_both == false
            init_size = init_code.length+push_bytes(init_code)
            #puts "INIT SIZE "+init_size.to_s
            rt_size = rt_code.length+push_bytes(rt_code)
            #puts "RT SIZE "+rt_size.to_s
            saving = 0
            if rt_size > 33 then saving = rt_size-$hash_size end
            #if rt_saving < 1 then rt_saving=0 end

            total_size = rt_size+init_size
            #one_hash_saving = rt_size-$hash_size-init_size

            return total_size, saving
        end
            
    end

    def self.size_of(code)
        code = code.join("\n")
        code = code.split("STOP", 2)
        if code.length == 2
            init_code = code[0].split("\n")
            init_code.push("STOP")
            rt_code = code[1].split("\n")
        else
            init_code = []
            rt_code = []
        end
        init_size = init_code.length+push_bytes(init_code)
        rt_size = rt_code.length+push_bytes(rt_code)

        return init_size, rt_size
    end

    def self.convert(code)
        #Add check to remove 0x if present at start of hex string
        #Doesn't check for 'metropolis codes' at the moment

        code_arr = code.scan(/.{2}/)
        #if code_arr[0] = "0x" then code_arr = code_arr.shift end
        opcodes = gen_list
        conversion = []
        i = 0
        while i < code_arr.length do
            #puts code_arr[i].to_i(16)
            if code_arr[i].to_i(16) > 95 && code_arr[i].to_i(16) < 128
                #puts "PUSH "+(code_arr[i].to_i(16)-95).to_s
                conversion.push("PUSH "+(code_arr[i].to_i(16)-95).to_s)
                i += code_arr[i].to_i(16)-95

            else
                if opcodes["0x"+code_arr[i]] != nil
                    #puts opcodes["0x"+code_arr[i]]
                    conversion.push(opcodes["0x"+code_arr[i]])

                else
                    #puts code_arr[i]
                    conversion.push("0x"+code_arr[i].to_s)
                end
            
            end
            i+=1
        end
        return conversion
    end

    def self.data(hash_both=true, f)
        data = []
        file = File.read(f) rescue  "File not Found"
        file.each_line do |l|
            data.push(JSON.parse(l))
        end
        init_t = 0
        rt_t = 0
        size_t = 0
        hash_init_t = 0
        hash_rt_t = 0
        if hash_both == true
            two_hash_savings = []
            size_arr = []
            counter_x = 0
            tis = 0
            trts = 0
            largest_i = 0
            largest_rt = 0
            data.each do |d|
                size, init, rt = saving(true, convert(d["bcs"]))
                init_t += init
                rt_t += rt
                #if rt <= 0 then puts "rt "+rt.to_s end
                #if init <= 0 then puts "init "+init.to_s end
                size_t += size
                two_hash_savings.push(init+rt)
                size_arr.push(size)
                is, rts = size_of(convert(d["bcs"]))
                if is > largest_i then largest_i = is end
                if rts > largest_rt then largest_rt = rts end
                if is > rts then counter_x += 1 end
                tis += is
                trts += rts
            end

        puts "Init code is bigger than runtime code on "+counter_x.to_s+" occasions"
        puts "Biggest init code: "+largest_i.to_s+" Biggest runtime code: "+largest_rt.to_s
        puts "Total init size is: "+tis.to_s+" Total runtime size is: "+trts.to_s 
        puts "Two hash savings: "+"init: "+init_t.to_s+" rt: "+rt_t.to_s+" Total: "+(init_t+rt_t).to_s+" Size: "+(size_t-(rt_t+init_t)).to_s
        puts "Base size: "+size_t.to_s
        return size_arr, two_hash_savings 
        elsif hash_both == false
            rt_t = 0
            size_t = 0
            init_t = 0
            one_hash_savings = []
            size_arr = []
            data.each do |d|
                size, rt = saving(false, convert(d["bcs"]))
                size_t += size
                rt_t += rt
                one_hash_savings.push(rt)
                size_arr.push(size)
            end
            puts "Single hash total saving: "+(rt_t).to_s+" Size: "+(size_t-rt_t).to_s
            puts "Base size: "+size_t.to_s
            return size_arr, one_hash_savings
        end
    end

    private
        def  self.push_bytes(arr)
            bytes = 0
            arr.each do |b|
                if b.include? "PUSH"
                    bytes += b.split(" ")[1].to_i
                end
            end
            return bytes
        end
    end




#Remix greeter motral creation code hex:
#Data.saving(true, Data.convert("6060604052341561000f57600080fd5b6040516103a93803806103a983398101604052808051820191905050336000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055508060019080519060200190610081929190610088565b505061012d565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f106100c957805160ff19168380011785556100f7565b828001600101855582156100f7579182015b828111156100f65782518255916020019190600101906100db565b5b5090506101049190610108565b5090565b61012a91905b8082111561012657600081600090555060010161010e565b5090565b90565b61026d8061013c6000396000f30060606040526004361061004c576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806341c0e1b514610051578063cfae321714610066575b600080fd5b341561005c57600080fd5b6100646100f4565b005b341561007157600080fd5b610079610185565b6040518080602001828103825283818151815260200191508051906020019080838360005b838110156100b957808201518184015260208101905061009e565b50505050905090810190601f1680156100e65780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff161415610183576000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16ff5b565b61018d61022d565b60018054600181600116156101000203166002900480601f0160208091040260200160405190810160405280929190818152602001828054600181600116156101000203166002900480156102235780601f106101f857610100808354040283529160200191610223565b820191906000526020600020905b81548152906001019060200180831161020657829003601f168201915b5050505050905090565b6020604051908101604052806000815250905600a165627a7a72305820257cb196bc83dfe4b1f068aaa23aecbedb1b575b306bd1687d13f4c94cc91b910029"))
#Data.data(false, "ctx_list_500.json")
#Data.data(true, "ctx_list_500.json")
#Original scraping test:
#Data.scrape(5000000, 1)

#First full sampling:
#Data.scrape(5000000, 20000)
#start: 16:36 (3k blocks)

#problem block"
#Data.scrape(5000000, 500)
