require File.expand_path('../server_manager', __FILE__)

module Neo4j
  module RakeTasks
    # Represents and manages a server on Windows
    class WindowsServerManager < ServerManager
      def neo4j_binary_filename
        'Neo4j.bat'
      end

      def neo4j_shell_binary_filename
        'Neo4jShell.bat'
      end

      def install
        super

        return unless nt_admin?

        system_or_fail(neo4j_command_path(:install))
        puts 'Neo4j Installed as a service.'
      end

      def validate_is_system_admin!
        return if nt_admin?

        fail 'You do not have administrative rights to stop the Neo4j Service'
      end

      protected

      def download_url(version)
        "http://dist.neo4j.org/neo4j-#{version}-windows.zip"
      end

      def extract!(zip_path)
        each_file_in_zip(zip_path) do |file|
          f_path = @path.join(file.name)
          FileUtils.mkdir_p(File.dirname(f_path))
          begin
            file.extract(f_path) unless File.exist?(f_path)
          rescue
            puts "#{file.name} failed to extract."
          end
        end
      end

      def start_argument(wait)
        nt_admin? ? super : ''
      end

      private

      def each_file_in_zip(zip_path)
        Zip::File.open(zip_path) do |zip_file|
          zip_file.each do |file|
            yield file
          end
        end
      end

      def nt_admin?
        system_or_fail('reg query "HKU\\S-1-5-19"').size > 0
      end
    end
  end
end
