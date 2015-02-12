class searchCache < ActiveRecord::Base
	# validates :title, presence: true, length: { minimum: 5 }
	# validates :slug, presence: true, format: { with: /\A[a-zA-Z-]+\z/, message: "Only Letters Please." }
	# validates :content, presence: true, length: { minimum: 100 }
	



	validates :name, presence: true, length: { minimum: 1 }
	validates :value, presence: true, length: { minimum: 1 }
	validates :expires_in, presence: true









end
