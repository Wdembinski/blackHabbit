class PossibleAddressCategory < ActiveRecord::Base
	has_many :category_memberships, dependent: :destroy
	has_many :addresses, through: :category_memberships,source: :possible_address
end
