require 'sinatra'
require 'json'
require './status.rb'


#42.36024,-71.08745
FORECAST_KEY = "23b22b200d5ff8700237a133c6d39b5e"

get "/:lat,:lng" do
	status = Status.new({:lat => params[:lat], 
						 :lng => params[:lng], 
						 :forecast_key => FORECAST_KEY})

	status.temperature_phrase
end