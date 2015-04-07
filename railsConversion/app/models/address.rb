class Address < ActiveRecord::Base
	extend Crawl
	# scope :name_servers, where(subscribed_to_newsletter: true)
	has_many :address_tags,dependent: :destroy
	has_many :tags, through: :address_tags
	has_many :nmc_addresses,dependent: :destroy
	has_many :nmc_chain_entries, through: :nmc_addresses
	accepts_nested_attributes_for :nmc_chain_entries

	def self.investigate_addresses
		name_server_cycle
		Address.where(categorized: false).find_in_batches do |batch|
			puts  "  Building batch..."

			batch.each do |addressObj|

				if is_email?(clean_possible_address(addressObj["address"]))
					
					$white_list.push({addressObj:addressObj,categories:Crawl::Standard_Categories["Email"]})
	        batch.delete_if {|x| x["address"] ==  addressObj["address"]}

				elsif is_bit_message?(clean_possible_address(addressObj["address"]))
					$white_list.push({addressObj:addressObj,categories:Crawl::Standard_Categories["Bit Message"]})
					batch.delete_if {|x| x["address"] ==  addressObj["address"]}
				else
					whiteList_or_blackList(addressObj) #Should either be ip address or url by now, in which case, they get categorized in this method.
					batch.delete_if {|x| x["address"] ==  addressObj["address"]}
				end
			end
			puts "  Commit the batch!!!"
 			commit_white_list
			commit_black_list
		end
	end
end
