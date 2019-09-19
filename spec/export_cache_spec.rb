require_relative 'spec_helper'
require_relative '../lib/hiptest-publisher/export_cache'
require_relative '../lib/hiptest-publisher/formatters/console_formatter'


describe Hiptest::ExportCache do
  subject { Hiptest::ExportCache.new(cache_dir, cache_duration, reporter: reporter) }

  let(:reporter) { Reporter.new }

  let(:cache_dir) {
    @cache_dir_created = true
    Dir.mktmpdir
  }

  let(:cache_duration) { 60 }
  let(:one_hour_ago) { Time.now - 3600 }
  let(:fifteen_minutes_ago) { Time.now - 900}
  let(:one_second_ago) { Time.now - 1 }


  after(:each) {
    if @cache_dir_created
      FileUtils.rm_rf(cache_dir)
    end
  }

  def cached_files
    Dir
      .entries(cache_dir)
      .select {|f| File.file?(File.join(cache_dir, f))}
  end

  def file_content(filename, dir: nil)
    dir ||= cache_dir

    File.read(File.join(dir, filename))
  end

  context "#initialize" do
    before do
      allow_any_instance_of(Hiptest::ExportCache).to receive(:clear_cache).and_return(true)
    end

    it "calls clear_cache" do
      cache = Hiptest::ExportCache.new('.', 0)
      expect(cache).to have_received(:clear_cache).once
    end
  end

  context "#cache" do
    it "caches the content of the downloaded file in cache-dir" do
      subject.cache('http://example.com/something.xml', 'Here is some XML content')
      cached_name = cached_files.first

      expect(file_content(cached_name)).to eq('Here is some XML content')
    end

    it "creates cache dir if it does not exist" do
      new_cache_path = File.join(cache_dir, "plopidou")

      cache = Hiptest::ExportCache.new(new_cache_path, 60, reporter: reporter)
      cache.cache('some-url', 'some-content')

      expect(Dir.entries(cache_dir)).to include("plopidou")
    end

    context "when cache_duration is 0" do
      let(:cache_duration) { 0 }

      it "does not write content to file" do
        subject.cache('http://example.com/something.xml', 'Here is some XML content')
        expect(cached_files).to be_empty
      end

      it "does not create cache dir if it does not exist" do
        new_cache_path = File.join(cache_dir, "plopideux")

        cache = Hiptest::ExportCache.new(new_cache_path, 0, reporter: reporter)
        cache.cache('some-url', 'some-content')

        expect(Dir.entries(cache_dir)).not_to include("plopideux")
      end
    end

    context "when cache_dir is not writable" do
      let(:read_only_dir) {
        path = File.join(cache_dir, "read-only")
        Dir.mkdir(path, 0555)
        path
      }

      it "fails silently" do
        cache = Hiptest::ExportCache.new(read_only_dir, 0, reporter: reporter)

        expect {
          cache.cache('some-url', 'some-content')
        }.not_to raise_error
      end
    end
  end

  context "#cache_for" do
    context "when the cache directory does not exist" do
      it "returns nil" do
        new_cache_path = File.join(cache_dir, "plopidou")
        cache = Hiptest::ExportCache.new(new_cache_path, 60, reporter: reporter)

        expect(cache.cache_for('some-file')).to be_nil
        expect(Dir.entries(cache_dir)).not_to include("plopidou")
      end
    end

    context "when cache_duration is 0" do
      let(:cache_duration) { 0 }

      it "returns nil" do
        subject.cache("my-file", "my-file")

        expect(subject.cache_for("my-file")).to be_nil
      end
    end

    context "when a cached file exists" do
      before do
        subject.cache('my-other-file', "Some other content")
      end

      context "but matches another export" do
        it "returns nil" do
          expect(subject.cache_for('my-file')).to be_nil
        end
      end

      context "and matches the requested export" do
        before do
          subject.cache('my-file', "Some old content", date: one_hour_ago)
        end

        context "and has expired" do
          it "returns nil" do
            expect(subject.cache_for('my-file')).to be_nil
          end
        end

        context "and is still valid" do
          before do
            subject.cache('my-file', "Some fresh content")
          end

          it "returns its content" do
            expect(subject.cache_for('my-file')).to eq("Some fresh content")
          end
        end
      end

      it "displays the file used in verbose mode" do
        now = Time.now
        allow(reporter).to receive(:show_verbose_message)

        subject.cache('my-file', "Some fresh content", date: now)
        subject.cache_for('my-file')

        expect(reporter).to have_received(:show_verbose_message)
          .with(I18n.t(:using_cache, full_path: "#{cache_dir}/7cc853aedf961e7aafbc04f09e44446c-#{now.to_i}"))
          .once
      end
    end

    context "when multiple valid cached file exists" do
      before do
        subject.cache('my-file', "Some fresh content", date: one_second_ago)
        subject.cache('my-file', "Some fresher content")
      end

      it "returns the most recent ones content" do
        expect(subject.cache_for('my-file')).to eq("Some fresher content")
      end
    end
  end

  context "#clear_cache" do
    it "removes expired files" do
      subject.cache('expired', 'expired', date: one_hour_ago)
      subject.cache('expired-1', 'expired-1', date: fifteen_minutes_ago)

      subject.clear_cache
      expect(cached_files).to be_empty
    end

    it "does not remove non-expired files" do
      subject.cache('not-expired', 'not-expired')

      subject.clear_cache
      expect(cached_files.length).to eq(1)
    end
  end
end
