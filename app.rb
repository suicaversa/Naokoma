require 'rubygems'
require 'bundler'
Bundler.setup(:default, :ci)

require 'sinatra'
require 'net/http'
require 'uri'
require 'base64'

TEXT_TO_SPEECH_ENDPOINT = 'https://texttospeech.googleapis.com/v1/text:synthesize'
AUDIO_FILE_PATH = File.dirname(__FILE__) + '/assets/audio/output.raw'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

def gcloud_token
  @gcloud_token = `gcloud auth application-default print-access-token`.chomp
end

def speak
  audio_file = AUDIO_FILE_PATH
  `aplay #{audio_file}`
end

get '/' do
  erb :index
end

get '/speak' do
  audio_file = AUDIO_FILE_PATH
  `aplay #{audio_file}`

  { result: 'success' }.to_json
end

get '/photo' do
  html = "<img src='/output.jpg'>"
  html
end

get '/camera' do
  `fswebcam public/output.jpg`
end

get '/speech/:text' do
  text = params[:text]
  body = "{
    'input':{
      'text':'#{text}'
    },
    'voice':{
      'languageCode': 'ja-JP',
      'name': 'ja-JP-Standard-A'
    },
    'audioConfig':{
      'audioEncoding':'LINEAR16'
    }
  }"

  uri = URI.parse(TEXT_TO_SPEECH_ENDPOINT)
  request = Net::HTTP::Post.new(uri)
  request.content_type = "application/json; charset=utf-8"
  request["Authorization"] = "Bearer #{gcloud_token}"
  request["Content-Length"] = body.length.to_s
  request.body = body
  
  req_options = {
    use_ssl: uri.scheme == "https",
  }
  
  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end

  if response.code.to_s != '200'
    status response.code
    return { result: response.body }.to_json
  end

  response_json = JSON.parse(response.body)
  audio_data = Base64.decode64(response_json['audioContent'])
  File.open(AUDIO_FILE_PATH, 'w') do |f|
    f.puts audio_data
  end

  speak

  { result: 'success' }.to_json
end
