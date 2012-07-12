require 'rubygems'
require 'sinatra'
# require_relative 'address'
# require_relative 'results'

require_relative 'src/manager'

  get '/' do

    erb :form
  end

  get '/results' do
    @a=Manager.new(params["origin"], params["destination"], params["parking_cost"])
    results = @a.get_best
      if results[:fastest] == results[:driving]
        @fastest = {:mode => "Driving", :result => results[:driving]}
      else
        @fastest = {:mode => "Public Transit", :result => results[:transit]}
      end

      if results[:cheapest] == results[:driving]
        @cheapest = {:mode => "Driving", :result => results[:driving]}
      else
        @cheapest = {:mode => "Public Transit", :result => results[:transit]}
      end
      erb :results
  end

  post '/' do
    params.inspect
  end

