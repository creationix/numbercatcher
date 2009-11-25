require 'rubygems'
require 'sinatra'
require 'models'
require 'haml'
require 'rack-flash'

use Rack::Session::Cookie
use Rack::Flash

PAGES = {
  "login" => "/",
  "home" => "/home"
}
 

get PAGES["login"] do
  haml :login
end

post PAGES["login"] do
  
  if user = User.authenticate(params[:username], params[:password])
    flash[:notice] = "Login successful"
    redirect PAGES["home"]
  else
    flash[:error] = "Incorrect credentials.  Please try again"
    redirect PAGES["login"]
  end
end

get PAGES['home'] do
  haml :home
end