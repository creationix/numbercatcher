require 'rubygems'
require 'sinatra'
require 'models'
require 'haml' 
require 'rack-flash'

use Rack::Static, :urls => ["/theme", "/img"], :root => "public"
use Rack::Session::Cookie, :secret => "3458f7dsoiay3h45hjvfd7862873jfwghf2346"
use Rack::Flash
 
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

# Set up session and basic security
before do
  content_type "text/html", :charset => 'utf-8'
  
  @user = User.get(session[:user_id])
  unless @user || ["/", "/help"].include?(request.path_info)
    flash[:error] = 'Please login first.'
    redirect "/"
  end
  if request.path_info == "/"
    @links = nil
  elsif @user
    @links = [
      ["/users/#{@user.id}", "My Profile"],
      ["/sets", "Number Sets"],
      ["/users", "User Administration"],
      ["/logout", "Logout"]
    ]
  else
    @links = [
      ["/", "Login"]
    ]
  end
end

# Show login page
get "/" do
  redirect "/users/#{@user.id}" if @user
  haml :login
end

# Process login request
post "/" do

  @user = User.authenticate(params[:username], params[:password])
  session[:user_id] = @user ? @user.id : nil
  if @user
    flash[:notice] = "Login successful"
    redirect "/users/#{@user.id}"
  else
    flash[:error] = "Incorrect credentials.  Please try again"
    redirect "/"
  end
end

# Process logout request
get "/logout" do
  session[:user_id] = nil
  flash[:notice] = 'You have logged out successfully.'
  redirect "/"
end

# Show online documentation
get "/help" do
  haml :help
end

# List all users
get "/users" do
  @users = User.all
  haml :users
end

# Create a new user
post "/users" do
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
   redirect "/users"
end

#
get "/users/:user_id" do |user_id|
  @user_data = User.get(user_id)
  haml :user_details
end

put "/users/:user_id" do |user_id|
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
  redirect "/users/#{user_id}"  
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

get "/sets" do
  @sets = Numberset.all
  haml :sets
end

post "/sets" do
  set = Numberset.new(params[:new_set])  
  set.save
  if set.valid?
    flash[:notice] = "New set created named #{set.name.inspect}"
    redirect "/sets/#{set.id}"
  else
    errors = set.errors.full_messages;
    flash[:error] = "Problem#{errors.length == 1 ? '' : 's'} in creating new set: #{errors.join(', ')}"
    redirect "/sets"
  end  
end

get "/sets/:set_id" do |set_id|
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

post "/sets/:set_id/reservations" do |set_id|
  number = params["number"].to_i
  
  # Find the next available number
  if params[:autoreserve]
    set = Numberset.get(set_id)
    res = set.reservations
    seqs = set.sequences
    for seq in seqs
      ((seq.min)..(seq.max)).each do |n|
        if res.none? { |reservation| reservation.number == n }
          number = n
          break
        end
      end
    end
  end
  
  reservation = Reservation.new(:number => number)
  reservation.numberset_id = set_id
  reservation.user_id = @user.id
  reservation.save
  if reservation.valid?
    flash[:notice] = "New reservation created"
  else
    errors = reservation.errors.full_messages;
    flash[:error] = "Problem#{errors.length == 1 ? '' : 's'} in reserving number #{number}: #{errors.join(', ')}"
  end
  
  redirect "/sets/#{set_id}"

end

not_found do
  haml :not_found
end


