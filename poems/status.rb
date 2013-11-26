require 'forecast_io'
require 'json'
require 'yaml'
require 'pathname'
require 'active_support/time'
require 'google_places'
require "geo-distance"

GOOGLE_KEY = "AIzaSyC6Nikc4HTkRkPksWkEbPj3PIPcXhatIt8"
PLACE_SEARCH_RADIUS = 100

class Status
	attr_accessor :forecast, :num_phrases, :lat, :lng

	def initialize(params)
		ForecastIO.api_key = params[:forecast_key]
		self.lat = params[:lat].to_f
		self.lng = params[:lng].to_f
		self.forecast = ForecastIO.forecast(lat,lng)
		self.num_phrases = params[:num_phrases]	
	end

	def message
		selected_phrases = 0
		phrases = [hour_phrase, sunrise_phrase, temperature_phrase, cloud_phrase, precipitation_phrase, sunset_phrase].select{|p| !p.empty?}

		selected_phrases = []
		while selected_phrases.length < num_phrases
			rand_index = rand( phrases.length )
			selected_phrases << phrases[rand_index]
			phrases.delete_at(rand_index)
		end

		selected_phrases.join(" ")
	end

	def cloud_phrase
		Status.phrases_for_closest_value("clouds", forecast.currently.cloudCover).sample
	end

	def precipitation_phrase
		if(forecast.daily.data[0].keys.include?("precipType"))
			precipitation_type = forecast.daily.data[0]["precipType"]
			if(forecast.daily.data[0]["precipIntensity"] < 0.1)
				Status.phrase_hash[precipitation_type]["light"].sample
			else
				Status.phrase_hash[precipitation_type]["heavy"].sample
			end
		else
			return ""
		end
	end

	def time_with_timezone( timestamp ) # expects time since epoch as in forecast.currently.time
		Time.zone = forecast.timezone
		Time.zone.at timestamp
	end

	def hour_phrase
		Status.phrases_for_closest_value("time", time_with_timezone(forecast.currently.time).hour).sample
	end

	def temperature_phrase
		Status.phrases_for_closest_value("temperature", 
										 forecast.currently.apparentTemperature).sample
	end

	def sunrise_phrase
		mins_to_sunrise = ( Time.now.to_i - forecast.daily.data[0].sunriseTime)/60.0
		phrases = Status.phrases_within_range("sunrise", mins_to_sunrise)
		if(phrases)
			return phrases.sample
		else
			return ""
		end
	end

	def sunset_phrase
		mins_to_sunset = ( Time.now.to_i - forecast.daily.data[0].sunsetTime)/60.0
		phrases = Status.phrases_within_range("sunset", mins_to_sunset)
		if(phrases)
			return phrases.sample
		else
			return ""
		end
	end

    def self.phrases_within_range(string, value)
    	hash = Status.phrase_hash[string]
		sorted_keys = hash.keys.sort
		if(value < sorted_keys.first || value > sorted_keys.last)
			return false
		else
			return self.phrases_for_closest_value(string,value)
		end
    end

    def self.phrases_for_closest_value(string, value)
    	hash = Status.phrase_hash[string]
    	key = hash.keys.min_by{|x| (x - value).abs}
    	hash[key]
	end

    def self.phrase_hash
    	@@phrase_hash ||= YAML.load(open(File.expand_path(File.dirname(__FILE__)) + "/phrases.yml").read)
    end

    def places_result
    	return @places_result if @places_result

    	client = GooglePlaces::Client.new(GOOGLE_KEY)
    	spots = client.spots(lat,lng, :radius => PLACE_SEARCH_RADIUS)
    	GeoDistance.default_algorithm = :haversine
    	spots.sort! do |a,b| 
			GeoDistance.distance(lat,lng,a.lat,a.lng).distance <=> GeoDistance.distance(lat,lng,b.lat,b.lng).distance
		end
		puts spots.inspect

		@places_result = spots[0].name

    	return @places_result
    end

end