class DomainCache < ActiveRecord::Base
	include Namecoin
	has_many :histories
	has_many :abnormal_names


	def self.resetIdSeq
		sql = "ALTER SEQUENCE domain_caches_seq RESTART WITH 1;"
		if (ActiveRecord::Base.connection.execute(sql))
			puts "AbnormalName ID sequence reset"
		else
			puts "Error: AbnormalName ID Sequence reset failed"
		end
	end




	def populateDomainCache
		begin
		  while doneIndicator >= 100

		    h = NamecoinRPC.new('http://user:test@127.0.0.1:8337')
		    # pry 
		    response = h.name_scan lastEntry,100
		    doneIndicator = response.count
		    lastEntry = response.last["name"].force_encoding("ISO-8859-1").encode("UTF-8")

		    response.each do |singleResponse|
		      next if singleResponse["name"] == lastEntry
		      name=singleResponse["name"].to_s.force_encoding("ISO-8859-1").encode("UTF-8")
		      value=singleResponse["value"].to_s.force_encoding("ISO-8859-1").encode("UTF-8")
		      expires_in=singleResponse["expires_in"]
		      # puts name=singleResponse["name"]
		      # puts value=singleResponse["value"]
		      # puts expires_in=singleResponse["expires_in"]

		      puts "=================================Cycle #{counter} #{name} ================================="

		        # if name.match /'/
		        #    name.sub!(/'/,'&rsquo')
		        # end
		        # if value.match /'/
		        #    value.sub!(/'/,'&rsquo')
		        # end
		        if value==nil || value.class!=String then
		          value=nil
		        end
		        if expires_in.class!=Fixnum then
		          expires_in=0
		        end

		        # res  = conn.exec("INSERT INTO cache1 values('#{name}','#{value}','#{expires_in}')")
		        res  = conn.exec("INSERT INTO domain_caches (name, value, expires_in) values ($$'#{name}'$$,$$'#{value}'$$,'#{expires_in}')")
		    end               #select * from cache1 where name = $$'!'$$; example query
		                      # select * from cache1 where name like '%dot%'; just cute basic search.
		    counter+=1
		  end
		end
	end

end