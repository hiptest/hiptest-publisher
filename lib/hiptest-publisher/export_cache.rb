require 'i18n'

require_relative 'formatters/reporter'
require_relative 'file_writer'


module Hiptest
  class ExportCache
    def initialize(cache_dir, cache_duration, reporter: nil)
      @cache_dir = cache_dir
      @cache_duration = cache_duration
      @reporter = reporter || Reporter.new

      clear_cache
    end

    def cache(url, content, date: nil)
      return if @cache_duration <= 0

      date ||= Time.now
      filename = "#{Digest::MD5.hexdigest(url)}-#{date.to_i}"

      make_cache_dir
      FileWriter.new(@reporter).write_to_file(File.join(@cache_dir, filename), "Caching export") { content }
    end

    def cache_for(url)
      hashed_url = Digest::MD5.hexdigest(url)
      expiry_date = (Time.now - @cache_duration).to_i

      cached_filename = cached_filenames
        .select do |filename |
          filename.start_with?("#{hashed_url}-") && !expired?(filename, expiry_date)
        end
        .sort do | f1, f2|
          timestamp_from_filename(f1) <=> timestamp_from_filename(f2)
        end
        .last

      cached_filename ? File.read(File.join(@cache_dir, cached_filename)) : nil
    end

    def clear_cache
      expired_files.map do |filename|
        FileUtils.rm(File.join(@cache_dir, filename))
      end
    end

    private

    def expired_files
      expiry_date = (Time.now - @cache_duration).to_i

      cached_filenames.select do |filename |
        expired?(filename, expiry_date)
      end
    end

    def cached_filenames
      Dir
        .entries(@cache_dir)
        .select { |entry| File.file?(File.join(@cache_dir, entry)) }
      rescue Errno::ENOENT => err
        []
    end

    def expired?(filename, expiry_date)
      timestamp_from_filename(filename) < expiry_date
    end

    def timestamp_from_filename(filename)
      m = filename.match(/\A[a-f0-9]{32}-(\d+)\Z/)
      m.nil? ? nil : m[1].to_i
    end

    def make_cache_dir
      FileUtils.mkdir_p(@cache_dir)
    rescue Errno::EPERM => err
      # TODO: handle this better
      @reporter.dump_error(err, I18n.t("errors.export_cache.cache_dir_not_creatable"))
      raise err
    end
  end
end
