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
    end.sort
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
      else
        # puts "#{name} - exists"
      end
    end
  end

  # last
  def rollback
    names = get_migration_names
    down_migration(names.last)
  end

  # all
  def full_rollback
    get_migration_names.reverse.each do |name|
      down_migration(name)
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

    puts "-- #{name} - UP"
    puts "#{up_sql}"

    execute_sql_file_content(up_sql)

    DbMigration.create({
      "name"      => name,
      "up_hash"   => Crypto::MD5.hex_digest(up_sql),
      "down_hash" => Crypto::MD5.hex_digest(down_sql),
    })

    puts "-- #{name} - UP - DONE\n"
  end

  def down_migration(name : String)
    down_sql = File.read(down_migration_path(name))

    puts "-- #{name} - DOWN"
    puts "#{down_sql}"

    execute_sql_file_content(down_sql)

    DbMigration.delete_all(where: {
      "name"      => name
    })

    puts "-- #{name} - DOWN - DONE\n"
  end

  def execute_sql_file_content(sql : String)
    DbMigration.execute_sql(transaction_start_sql)

    sql.split(/;\n/).each do |s|
      ss = s.strip
      if ss.size > 0
        DbMigration.execute_sql(s)
      end
    end

    DbMigration.execute_sql(transaction_end_sql)
  end

  def transaction_start_sql
    "BEGIN;"
  end

  def transaction_end_sql
    "COMMIT;"
  end
end
