require 'fileutils'

module Hiptest
  class FileWriter
    def initialize(reporter)
      @reporter = reporter
    end

    def write_to_file(path, message)
      @reporter.with_status_message "#{message}: #{path}" do
        mkdirs_for(path)
        content = yield

        File.open(path, 'w') do |file|
          file.write(content)
        end
      end
    rescue => err
      @reporter.dump_error(err)
    end

    private

    def mkdirs_for(path)
      unless Dir.exists?(File.dirname(path))
        FileUtils.mkpath(File.dirname(path))
      end
    end
  end
end
