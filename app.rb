require 'rubygems'
require 'bundler'
Bundler.setup(:default, :ci)

require 'sinatra'
get '/' do
  'Put this in your pipe & smoke it!'
end

get '/hello' do
  `mplayer output.mp3`
end
