require 'bundler'
Bundler.require

ActiveRecord::Base.logger = nil #Logger.new(STDOUT)


ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')
require_all 'app'
