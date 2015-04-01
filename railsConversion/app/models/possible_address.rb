class Address < ActiveRecord::Base
	extend Crawl
	belongs_to :nmc_chain_links
	has_many :category_memberships,dependent: :destroy
	has_many :categories, through: :category_memberships, source: :possible_address_category

	def self.investigate_addresses
		name_server_cycle
		PossibleAddress.where(categorized: false).find_in_batches do |batch|
			puts  "  Building batch..."

			batch.each do |addressObj|

				if is_email?(clean_possible_address(addressObj["address"])) #email addressses are almost 100% accurate on first go through with this thang.
					
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
