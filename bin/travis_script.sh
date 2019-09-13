echo "Running local gem"
bundle exec ruby -I lib bin/hiptest-publisher --help

rake install
echo "== Running hiptest-publisher --help"
hiptest-publisher --help

echo "== Running rspec"
CODECLIMATE_REPO_TOKEN=4c579687b0754f976610c89a4ef11c1c95c10b0ee378597d6ddd646fab8af06c bundle exec rspec spec
