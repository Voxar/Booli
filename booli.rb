require 'digest/sha1'

Name = 'Lekstuga'
Key = '37Ervct1G7tLatJmje5s0S9YVlzfcxW6Dr19MHmh'



require 'rubygems'
require 'httparty'

class Booli
  include HTTParty
  format :json
  base_uri 'api.booli.se'
  default_params :format => 'json'
  
  def self.default_options
    callerId = Name
    time = Time.new.strftime('%Y-%m-%dT%H:%M:%S%z')
    key = Key
    unique = "%.16x"%rand(9**20)
    auth = {
      :callerId=> Name,
      :hash=>Digest::SHA1.hexdigest(callerId + time + key + unique),
      :time=>time,
      :unique=>unique
    }
    @default_options[:default_params].update(auth)
    @default_options
  end
  
  
  attr_reader :result, :query, :city
  
  def initialize
    clear
  end
  
  def clear
    @fetch = nil
    @query = {}
    @city = ""
    self
  end
  
  
  def type typ
    @query[:typ] = typ.to_s
    self
  end
  
  def price price
    @query[:price] = price.to_s
    self
  end
  
  def geo lat, long, radius
    @query[:centerLat] = lat
    @query[:centerLong] = long
    @query[:radius] = radius
    self
  end
  
  def area area
    @query[:boarea] = area
    self
  end
  
  def near city
    city="/"+city if city && city[0]!="/"
    @city = city
    self
  end

  def fetch(force=false)
    if @fetch.nil? || force
      query = @query.dup
      response = self.class.get("/listing#{@city}", :query => query, :format => :json)
      @fetch = response
    end
    
    @fetch
  end
  
  def each
    fetch()['booli']['content']['listings'].each { |r| yield r }
  end
  
end

Booli.new.type('lägenhet').price('5000-10000').near('Askersund').each do |a|
  p a
end
#puts Booli.default_options.inspect