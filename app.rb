require 'sinatra'
require 'sinatra/rest'

require 'models'
require 'haml'

use Rack::Lint
use Rack::Reloader

rest Post

get '/' do
  @posts = Post.all
  haml :index
end