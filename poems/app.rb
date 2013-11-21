require 'sinatra'
require 'json'
require './status.rb'
use Rack::Logger

# Cambridge: 42.36024,-71.08745
# Portland: 45.5200,122.6819
# Thailand (rain likely): 15.3500,101.0333
FORECAST_KEY = "23b22b200d5ff8700237a133c6d39b5e"

get "/:lat,:lng,:num_phrases" do
	request.logger.info params.inspect

	status = Status.new({:lat => params[:lat], 
						 :lng => params[:lng], 
						 :forecast_key => FORECAST_KEY,
						 :num_phrases => params[:num_phrases].to_i})

	if params["debug"]
		{"message" => status.message, 
		 "location" => {"lat" => params[:lat], "lng" => params[:lng]},
		 "forecast" => {"temperature" => status.forecast.currently.apparentTemperature, 
		 				"time" => status.time_with_timezone(status.forecast.currently.time),
		 				"clouds" => status.forecast.currently.cloudCover,
		 				"precipType" => status.forecast.daily.data[0]["precipType"],
		 				"precipIntensity" =>  status.forecast.daily.data[0]["precipIntensity"]}}.to_json
	else 
		status.message
	end
end