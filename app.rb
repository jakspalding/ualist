require 'bundler/setup'
require 'sinatra'
require 'sinatra/activerecord'
require 'haml'
require 'active_record'
require 'sanitize'

set :database, ENV['DATABASE_URL'] || 'sqlite3:/:memory:'

class Useragent < ActiveRecord::Base
  validates_presence_of :useragent
end

get '/' do
  logger.info "Got a request from #{request.user_agent}" 
  
  useragent = Sanitize.clean(request.user_agent)
  return if useragent != request.user_agent

  ua = Useragent.find_or_create_by_useragent(useragent)
  ua.last_accessed = DateTime.now

  if not ua.save
    logger.warn "Useragent wasn't saved."
    logger.warn ua.errors.inspect
  end

  @useragents = Useragent.order("last_accessed DESC").limit(30)

  haml :index
end
