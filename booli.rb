require 'digest/sha1'

require 'rubygems'
require 'httparty'

class Booli
  include HTTParty
  format :json
  base_uri 'api.booli.se'
  default_params :format => 'json'
  
  @@appname = ""
  @@appkey = ""
  
  def self.default_options
    callerId = @@appname
    time = Time.new.strftime('%Y-%m-%dT%H:%M:%S%z')
    key = @@appkey
    unique = "%.16x"%rand(9**20)
    auth = {
      :callerId=> @@appname,
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
  
  def self.find
    Booli.new
  end
  
  def self.appname=r
    @@appname = r
  end
  
  def self.appkey=r
    @@appkey=r
  end
  
end

Name = 'Lekstuga'
Key = '37Ervct1G7tLatJmje5s0S9YVlzfcxW6Dr19MHmh'

Booli.appname = Name
Booli.appkey = Key

Booli.find.geo(59.331176, 18.059978, 20).each do |a|
  p a
end
#puts Booli.default_options.inspect