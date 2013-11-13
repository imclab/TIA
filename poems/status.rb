require 'forecast_io'
require 'json'
require 'yaml'
require 'pathname'

class Status


	attr_accessor :forecast

	def initialize(params)
		lat = params[:lat]
		lng = params[:lng]
		ForecastIO.api_key = params[:forecast_key]
		self.forecast = ForecastIO.forecast(params[:lat].to_f,params[:lng].to_f)	
	end

	def temperature_phrase
		Status.phrases_for_closest_value(Status.phrase_hash["current"]["temperature"], 
										 forecast.currently.apparentTemperature).sample
	end



	def sunrise_phrase
	end

	def sunset_phrase
		mins_to_sunset = ( Time.now.to_i - forecast.daily.data[0].sunsetTime)/60.0
		phrases = Status.phrases_within_range(Status.phrase_hash["current"]["sunset"], mins_to_sunset)
		if(phrases)
			return phrases.sample
		else
			return false
		end
	end


	def to_json
    	
    end

    def self.phrases_within_range(hash, value)
		sorted_keys = hash.keys.sort
		if(value < sorted_keys.first || value > sorted_keys.last)
			return false
		else
			return self.phrases_for_closest_value(hash,value)
		end
    end

    def self.phrases_for_closest_value(hash, value)
    	key = hash.keys.min_by{|x| (x - value).abs}
    	hash[key]
	end

    def self.phrase_hash
    	@@phrase_hash ||= YAML.load(open(File.expand_path(File.dirname(__FILE__)) + "/phrases.yml").read)
    end

end