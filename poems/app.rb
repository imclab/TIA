require 'sinatra'
require 'json'
require './status.rb'


# Cambridge: 42.36024,-71.08745
# Portland: 45.5200,122.6819
# Thailand (rain likely): 15.3500,101.0333
FORECAST_KEY = "23b22b200d5ff8700237a133c6d39b5e"

get "/:lat,:lng" do
	status = Status.new({:lat => params[:lat], 
						 :lng => params[:lng], 
						 :forecast_key => FORECAST_KEY})

	status.temperature_phrase
end

get "/json/:lat,:lng" do
	status = Status.new({:lat => params[:lat], 
						 :lng => params[:lng], 
						 :forecast_key => FORECAST_KEY})
	{"message" => status.message}.to_json
end