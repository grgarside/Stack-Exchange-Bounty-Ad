require 'sinatra'
require './se.rb'
require './bounty.rb'
require './cache.rb'

se = SE.new('y6kJ2wLn7yuN7ilUOvBRPw((')

bounty_image_cache = Cache.new(86400) do |domain, bounties, reputation|
  bounty_image(domain, bounties, reputation)
end

bounty_info_cache = Cache.new(3600) do |site|
  bounty_image_cache[site.bounties]
end



get '/bounty.png' do
  expires 0, :no_cache, :no_store, :must_revalidate
  begin
    content_type 'image/png'
    bounty_info_cache[se.site(request.referrer)].blob
  rescue SiteDoesNotExistError
    status 404
    send_file "./resources/invalid-referrer.png"
  end
end

get '/cache/:action/:which' do
  c = {'info' => bounty_info_cache, 'image' => bounty_image_cache}[params[:which]]
  case params[:action]
  when 'display'
    c.to_s
  when 'flush'
    c.flush
    "#{:name} cache flushed"
  end
end

get '/info' do
  se.info
end


get // do
  status 404
  "404: Not Found"
end

