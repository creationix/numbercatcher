require 'rubygems'
require 'sinatra'
require 'models'
require 'haml'

get "/" do
  haml :login
end

post "/" do
end
