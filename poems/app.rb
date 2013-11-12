require 'sinatra'
require 'forecast_io'
require 'json'


#42.36024,-71.08745
FORECAST_KEY = "23b22b200d5ff8700237a133c6d39b5e"

get "/:lat,:lng" do
	ForecastIO.api_key = FORECAST_KEY
	puts(params[:lat] + "," + params[:lng])
	forecast = ForecastIO.forecast(params[:lat].to_f,params[:lng].to_f)
	forecast.to_json
end