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

      file_writer.write_to_file(File.join(@cache_dir, filename), I18n.t("caching_data")) { content }
    end

    def cache_for(url)
      return if @cache_duration <= 0

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

      return nil if cached_filename.nil?

      full_path = File.join(@cache_dir, cached_filename)
      @reporter.show_verbose_message(I18n.t(:using_cache, full_path: full_path))
      File.read(full_path)
    end

    def clear_cache
      expired_files.map do |filename|
        FileUtils.rm(File.join(@cache_dir, filename))
      end
    end

    private

    def file_writer
      FileWriter.new(@reporter)
    end

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
  end
end
