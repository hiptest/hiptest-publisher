Gem::Specification.new do |s|
  s.name = 'zest-publisher'
  s.version = '0.0.2'
  s.date = '2014-05-15'
  s.summary = "Export your tests from Zest into executable tests."
  s.description = ""
  s.executables << 'zest-publisher'
  s.authors = ["Smartesting R&D"]
  s.email = 'zest@smartesting.com'
  s.files = `git ls-files -- lib/*`.split("\n")
  s.require_path = "lib"
  s.homepage = 'https://www.zest-testing.com'
  s.license = 'GPL 2'
  s.add_runtime_dependency 'parseconfig', '~> 1.0', '>= 1.0.4'
  s.add_runtime_dependency 'colorize', '~> 0.7', '>= 0.7.2'
  s.add_runtime_dependency 'i18n', '~> 0.6', '>= 0.6.9'
  s.add_runtime_dependency 'nokogiri', '~> 1.6', '>= 1.6.2.1'
end
