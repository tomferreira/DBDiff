
require 'open3'
require 'tempfile'

class DB2Helper

  DELIMITER = "\a"

  def initialize( database_config, schemas )
    @database_config = database_config
    @schemas = schemas
  end

  def create_dumps( basedir )

    structure_dump_infos = {}

    @schemas.each do |schema|

      tempfile = Tempfile.new([schema, '.sql'], '/var/www/html/DBDiff/tmp')

      command = 
        "/opt/ibm/db2/V9.5/bin/db2look -d #{@database_config['database']} -e -z #{schema} -x -nofed -td #{DELIMITER} -i #{@database_config['username']} -w #{@database_config['password']} -o #{tempfile.path}"

      puts "Executing '#{command}' ..."

      Open3.popen3( command ) do |stdin, stdout, stderr, wait_thr|

        exit_status = wait_thr.value

        raise stderr.read if !exit_status.success? && stderr

      end

      puts "Converting encoding ..."

      content = tempfile.read.encode('UTF-8', 'ISO8859-1')

      filename = "#{basedir}/#{SecureRandom.uuid}.sql"

      File.open(filename, 'w+') { |f| f.write( reorder_statements( remove_trash_lines( content ) ) ) }

      structure_dump_infos[schema] = filename

    end

    structure_dump_infos

  end

private

  def remove_trash_lines( content )

    content
      .gsub( /-- This CLP file was created using DB2LOOK Version[^\n]*[\n]*/, '' )
      .gsub( /-- Timestamp: .+\n/, '' )
      .gsub( /-- Database [^\n]*[\n]*/, '' )
      .gsub( /--+[\n]+--[^\n]+\s*[\n]+--+[\n]*/, '' )
      .gsub( /-- DDL Statements[^\n]*[\n]*/, '' )
      .gsub( /CONNECT TO .+#{DELIMITER}[\n]*/, '' )
      .gsub( /GRANT\s+ROLE\s+\"[a-zA-Z0-9 _-]+\"\s+TO USER\s+\"[a-zA-Z0-9 _-]+\"\s*#{DELIMITER}[\n]*/, '' )
      .gsub( /SET CURRENT PATH = [\"[a-zA-Z0-9 _-]+\"\s*,?]+#{DELIMITER}[\n]*/, '' )
      .gsub( /SET CURRENT SCHEMA = \"[a-zA-Z0-9 _-]+\"\s*#{DELIMITER}[\n]*/, '' )
      .gsub( /ALTER TABLE \"[a-zA-Z0-9 _-]+\".\"[a-zA-Z0-9 _-]+\" ALTER COLUMN \"[a-zA-Z0-9 _-]+\" RESTART WITH \d+\s*#{DELIMITER}[\n]*/, '' )
      .gsub( /ALTER SEQUENCE \"[a-zA-Z0-9 _-]+\".\"[a-zA-Z0-9 _-]+\" RESTART WITH \d+\s*#{DELIMITER}[\n]*/, '' )
      .gsub( /CONNECT RESET\s*#{DELIMITER}[\n]*/, '' )
      .gsub( /COMMIT WORK\s*#{DELIMITER}[\n]*/, '' )
      .gsub( /TERMINATE\s*#{DELIMITER}[\n]*/, '' )

  end

  def reorder_statements( content )

    content.scan( /[^#{DELIMITER}]+/ ).map(&:strip).compact.sort_by!{|statement| statement.downcase }.join("\n\n")

  end

end
