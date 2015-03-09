class AbnormalName < ActiveRecord::Base
	belongs_to :domain_caches
	def self.resetIdSeq
		sql = "ALTER SEQUENCE abnormal_names_id_seq RESTART WITH 1;"
		if (ActiveRecord::Base.connection.execute(sql))
			puts "AbnormalName ID sequence reset"
		else
			puts "Error: AbnormalName ID Sequence reset failed"
		end
	end
end
