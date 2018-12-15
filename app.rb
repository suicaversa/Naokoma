require 'rubygems'
require 'bundler'
Bundler.setup(:default, :ci)

require 'sinatra'
require "google/cloud/text_to_speech/v1"

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

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

get '/speech/:text' do
  text_to_speech_client = Google::Cloud::TextToSpeech::V1.new
  input = {text: h(params[:text])}
  voice = {language_code: "ja-JP"}
  audio_config = {audio_encoding: Google::Cloud::Texttospeech::V1::AudioEncoding::MP3}
  response = text_to_speech_client.synthesize_speech input, voice, audio_config
  File.open File.dirname(__FILE__) + "/assets/audio/output.mp3", "w" do |file|
    file.write response.audio_content
  end
end

