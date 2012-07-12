require 'sinatra'
# require_relative 'address'
# require_relative 'results'
require_relative 'manager'

# class UI
  get '/' do
    @a = Manager.new("Mountain View", "San Francisco")
    erb :form
  end

  get '/results' do
    erb :results
  end

  post '/' do
    params.inspect
  end
# end

#ui = UI.new