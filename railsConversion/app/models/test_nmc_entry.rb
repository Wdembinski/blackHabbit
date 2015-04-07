  include Namecoin
  include Crawl
  require 'json'


class TestNmcEntry < ActiveRecord::Base
  has_many :abnormal_jsons,dependent: :destroy
  has_many :json_histories,dependent: :destroy
  has_many :nmc_addresses,dependent: :destroy
  has_many :addresses, through: :nmc_addresses
  has_many :tags, through: :addresses
  accepts_nested_attributes_for :addresses










end