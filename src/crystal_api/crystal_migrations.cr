require "crypto/md5"

require "./crystal_model"
require "./crystal_service"

# It is custom SQL migration engine
# Load all files `.up.sql` from migration folder and executes them

crystal_model(
  DbMigration,
  id : (Int32 | Nil) = nil,
  name : (String | Nil) = nil,
  up_hash : (String | Nil) = nil,
  down_hash : (String | Nil) = nil
)
crystal_resource(db_migration, db_migrations, DbMigration)

class CrystalMigrations
  REGEXP = /\.up\.sql/

  getter :path

  def initialize(@path : String)
    # create internal table
    crystal_migrate_now_db_migration
  end

  def get_migration_names
    names = Dir.entries(@path).select do |f|
      fp = File.join([@path, f])
      File.file?(fp) && f =~ REGEXP
    end

    return names.map do |n|
      n.gsub(REGEXP, "")
    end
  end

  def get_executed_migrations
    DbMigration.fetch_all
  end

  def migrate
    migrations = get_executed_migrations
    names = get_migration_names

    names.each do |name|
      if migrations.select { |m| m.name == name }.size == 0
        up_migration(name)
      end
    end
  end

  def up_migration_path(name : String)
    File.join(@path, name + ".up.sql")
  end

  def down_migration_path(name : String)
    File.join(@path, name + ".down.sql")
  end

  def up_migration(name : String)
    up_sql = File.read(up_migration_path(name))
    down_sql = File.read(down_migration_path(name))

    DbMigration.execute_sql(up_sql)

    DbMigration.create({
      "name"      => name,
      "up_hash"   => Crypto::MD5.hex_digest(up_sql),
      "down_hash" => Crypto::MD5.hex_digest(down_sql),
    })
  end
end
