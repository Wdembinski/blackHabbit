class AddressTag < ActiveRecord::Base
	belongs_to :address
	belongs_to :tag
end
