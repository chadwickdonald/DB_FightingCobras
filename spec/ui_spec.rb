require 'sinatra'
# Sinatra::Application.environment = :test
# Bundler.require :default, Sinatra::Application.environment
require './ui.rb'
require 'rspec'
require 'capybara'
require 'capybara/dsl'

Capybara.app = Sinatra::Application

RSpec.configure do |config|
  include Capybara::DSL
end

# def selector string
#   find :css, string
# end

describe "ui" do
  context "homepage" do
    it "should have a header that states the title of the app" do
      visit '/'
      p page.text# .should have_content ("I'm not on the page")
      # find('h1').should have_content "Bart or Drive?"
      # puts selector('h2').text
      # selector('h2').has_content?("bart")
    end
  end
end