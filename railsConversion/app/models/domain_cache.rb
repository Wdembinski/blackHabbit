class DomainCache < ActiveRecord::Base
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
end