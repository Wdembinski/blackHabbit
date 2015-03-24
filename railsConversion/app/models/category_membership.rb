class CategoryMembership < ActiveRecord::Base
	belongs_to :possible_address
	belongs_to :possible_address_category
end
