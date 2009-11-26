require 'rubygems'
require 'sinatra'
require 'models'
require 'haml'
require 'rack-flash'

use Rack::Static, :urls => ["/theme", "/img"], :root => "public"
use Rack::Session::Cookie, :secret => "3458f7dsoiay3h45hjvfd7862873jfwghf2346"
use Rack::Flash

PAGES = {
  "login" => "/",
  "logout" => "/logout",
  "home" => "/home"
}
 
configure :test do
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db_test.sqlite3")
  DataMapper.auto_migrate!
end

before do
  @user = User.get(session[:user_id])
  unless @user || request.path_info == PAGES['login']
    flash[:error] = 'Please login first.'
    redirect PAGES["login"]
  end
end

get PAGES["login"] do
  redirect PAGES["home"] if session[:user_id]
  haml :login
end

post PAGES["login"] do

  @user = User.authenticate(params[:username], params[:password])
  session[:user_id] = @user ? @user.id : nil
  if @user
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

get PAGES['logout'] do
  session[:user_id] = nil
  flash[:notice] = 'You have logged out successfully.'
  redirect PAGES["login"]
end