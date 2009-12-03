require 'rubygems'
require 'sinatra'
require 'models'
require 'haml' 
require 'rack-flash'

use Rack::Static, :urls => ["/theme", "/img"], :root => "public"
use Rack::Session::Cookie, :secret => "3458f7dsoiay3h45hjvfd7862873jfwghf2346"
use Rack::Flash

PAGES = {
  :login => "/",
  :logout => "/logout",
  :home => "/home",
  :sets => "/sets",
  :users => "/users",
  :help => "/help"
}
 
configure :test do
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db_test.sqlite3")
  DataMapper.auto_migrate!
end

#DataMapper.auto_migrate!
#
#user = User.new(:username => "admin")
#user.name = "Admin"
#user.password = "password"
#user.is_admin = true
#user.save

before do
  content_type "text/html", :charset => 'utf-8'
  
  @user = User.get(session[:user_id])
  unless @user || [PAGES[:login], PAGES[:help]].include?(request.path_info)
    flash[:error] = 'Please login first.'
    redirect PAGES[:login]
  end
  if request.path_info == PAGES[:login]
    @links = nil
  elsif @user
    @links = [
      [:home, "My Profile"],
      [:sets, "Number Sets"],
      [:users, "User Administration"],
      [:logout, "Logout"]
    ]
  else
    @links = [
      [:login, "Login"]
    ]
  end
end

get PAGES[:login] do
  redirect PAGES[:home] if @user
  haml :login
end

post PAGES[:login] do

  @user = User.authenticate(params[:username], params[:password])
  session[:user_id] = @user ? @user.id : nil
  if @user
    flash[:notice] = "Login successful"
    redirect PAGES[:home]
  else
    flash[:error] = "Incorrect credentials.  Please try again"
    redirect PAGES[:login]
  end
end

get PAGES[:logout] do
  session[:user_id] = nil
  flash[:notice] = 'You have logged out successfully.'
  redirect PAGES[:login]
end

get PAGES[:home] do
  haml :home
end

get PAGES[:help] do
  haml :help
end

get PAGES[:users] do
  @users = User.all
  haml :users
end

post PAGES[:users] do
  unless @user.is_admin
    flash[:error] = "You are not authorized to add new users"
  else    
    user = User.new(params[:new_user])
    password = "changeme"
    user.password = password
    user.save
    if user.valid?
      flash[:notice] = "New user created with password #{password.inspect}"
    else
      errors = user.errors.full_messages;
      flash[:error] = "Problem#{errors.length == 1 ? '' : 's'} in creating new user: #{errors.join(', ')}"
    end
  end    
   redirect PAGES[:users]
end

get "#{PAGES[:users]}/:user_id" do |user_id|
  @user_data = User.get(user_id)
  haml :user_details
end

put "#{PAGES[:users]}/:user_id" do |user_id|
  user_data = params[:user]
  unless user_id.to_i == @user.id || @user.is_admin
    flash[:error] = "You are not authorized to do this"
  else 
    if user_data[:password] != user_data[:password2]
      flash[:error] = "Passwords do not match"
    else
      edit_user = User.get(user_id)
      unless user_data[:password] == ""
        edit_user.password = user_data[:password]
      end  
      edit_user.username = user_data[:username]
      edit_user.name = user_data[:name]
      edit_user.save
     
      if edit_user.valid?
        flash[:notice] = "User data successfully saved"
      else
        errors = edit_user.errors.full_messages;
        flash[:error] = "Problem#{errors.length == 1 ? '' : 's'} in updating user: #{errors.join(', ')}"
      end
    end    
  end     
  redirect "#{PAGES[:users]}/#{user_id}"  
end

delete "*/reservations/:reservation_id" do |redirect, reservation_id|
  reservation = Reservation.get(reservation_id)
  if reservation
    unless reservation.user.id == @user.id || @user.is_admin
      flash[:error] = "You are not authorized release this reservation!"
    else
      reservation.destroy!
      flash[:notice] = "Reservation deleted!"
    end
  else
    flash[:error] = "Invalid reservation cannot be deleted!"
  end
  redirect redirect
end

get PAGES[:sets] do
  @sets = Numberset.all
  haml :sets
end

post PAGES[:sets] do
  set = Numberset.new(params[:new_set])  
  set.save
  if set.valid?
    flash[:notice] = "New set created named #{set.name.inspect}"
    redirect "#{PAGES[:sets]}/#{set.id}"
  else
    errors = set.errors.full_messages;
    flash[:error] = "Problem#{errors.length == 1 ? '' : 's'} in creating new set: #{errors.join(', ')}"
    redirect PAGES[:sets]
  end  
end

get "#{PAGES[:sets]}/:set_id" do |set_id|
  @set = Numberset.get(set_id)
  sequences = @set.sequences
  reservations = @set.reservations
  
  # Split the ranges so that they don't overlap the reservations
  reservations.each do |reservation|
    for sequence in sequences do
      if reservation.number == sequence.min
        sequence.min += 1
        break
      elsif reservation.number == sequence.max
        sequence.max -= 1
        break
      elsif reservation.number > sequence.min && reservation.number < sequence.max
        sequences.delete sequence
        sequences << Sequence.new(:min => sequence.min, :max => reservation.number - 1)
        sequences << Sequence.new(:min => reservation.number + 1, :max => sequence.max)
        break
      end
    end
  end
  
  # Merge the two lists and sort
  @set_data = (sequences + reservations).sort do |a, b|
    (a.respond_to?(:number) ? a.number : a.min) <=>
    (b.respond_to?(:number) ? b.number : b.min)
  end
  
  haml :set_details
end

not_found do
  haml :not_found
end


