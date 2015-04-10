class NsAddress < ActiveRecord::Base
  belongs_to :address
  has_man :address_links
  has_many :hyperlinks, through: :address_links
end
