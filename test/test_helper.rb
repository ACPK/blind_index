require "bundler/setup"
require "active_record"
require "attr_encrypted"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

# TODO remove after next attr_encryptor release
ActiveSupport::Deprecation.silenced = true

if ENV["VERBOSE"]
  ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
end

ActiveRecord::Migration.create_table :users do |t|
  t.string :encrypted_email
  t.string :encrypted_email_iv
  t.string :encrypted_email_bidx
  t.string :encrypted_email_ci_bidx
end

class User < ActiveRecord::Base
  attr_encrypted :email, key: "0"*32

  blind_index :email, key: "1"*32
  blind_index :email_ci, key: -> { "2"*32 }, attribute: :email, expression: ->(v) { v.try(:downcase) }

  validates :email, uniqueness: true
  # not ideal
  validates :encrypted_email_ci_bidx, uniqueness: true
end
