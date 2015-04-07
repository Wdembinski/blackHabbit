class Tag < ActiveRecord::Base
	has_many :address_tags, dependent: :destroy
	has_many :addresses, through: :address_tags,source: :address
	Cats=[ Tag.new(title:"Inactive",description:"This appears to be Inactive"), Tag.new(title:"Uncategorized",description:"This address is uncategorized"), Tag.new(title:"Connection Failed",description:"Attemps to connect to this addres have recently failed"), Tag.new(title:"Active",description:"This address is active"), Tag.new(title:"SSL Connection Failure",description:"connection attempts resulted in an SSL certificate error"), Tag.new(title:"Name Server",description:"This address appears to be a name server"), Tag.new(title:"ip_4" ,description:"This address appears to be an ip4 address"), Tag.new(title:"ip_6",description:"This address appears to be an ip6 address"), Tag.new(title:"Bit Message",description:"This looks like an bit message address"), Tag.new(title:"email",description:"This looks like an email address"), Tag.new(title:"URL" ,description:"This appears to be a normal url!")]
	def self.base_tags
		Cats.each {|x| x.save}
	end
end
