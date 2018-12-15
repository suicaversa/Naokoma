require 'rubygems'
require 'bundler'
Bundler.setup(:default, :ci)

require 'sinatra'
get '/' do
  'Put this in your pipe & smoke it!'
end

get '/hello' do
   audio_file = File.dirname(__FILE__) + '/assets/audio/output.mp3'
  `mplayer #{audio_file}`
end

get '/photo' do
  html = "<img src='/output.jpg'>"
  html
end

get '/camera' do
  `fswebcam public/output.jpg`
end
