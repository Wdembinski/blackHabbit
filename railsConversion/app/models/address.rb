class Address < ActiveRecord::Base
	extend Crawl
	# scope :name_servers, where(subscribed_to_newsletter: true)
	has_many :address_links,dependent: :destroy
	has_many :hyperlinks, through: :address_links
	has_many :ns_addresses,dependent: :destroy
	has_many :address_tags,dependent: :destroy
	has_many :tags, through: :address_tags
	has_many :nmc_addresses,dependent: :destroy
	has_many :nmc_chain_entries, through: :nmc_addresses
	accepts_nested_attributes_for :nmc_chain_entries

	def self.investigate_addresses
		name_server_cycle
	end
end
