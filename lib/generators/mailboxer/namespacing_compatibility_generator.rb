class Mailboxer::NamespacingCompatibilityGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  source_root File.expand_path('../templates', __FILE__)
  require 'rails/generators/migration'

  FILENAME = 'mailboxer_namespacing_compatibility.rb'

  source_root File.expand_path('../templates', __FILE__)

  def create_model_file
    migration_template FILENAME, "db/migrate/#{FILENAME}"
  end

  def self.next_migration_number path
    unless @prev_migration_nr
    @prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
    else
    @prev_migration_nr += 1
    end
    @prev_migration_nr.to_s
  end
end
