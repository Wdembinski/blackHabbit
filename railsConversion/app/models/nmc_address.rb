class NmcAddress < ActiveRecord::Base
	belongs_to :address
	belongs_to :nmc_chain_entry
	
end
