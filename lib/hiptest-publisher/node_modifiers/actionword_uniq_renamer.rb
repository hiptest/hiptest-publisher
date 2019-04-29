module Hiptest
  module NodeModifiers
    class ActionwordUniqRenamer
      def self.add(project)
        self.new(project).make_uniq_names
      end

      def initialize(project)
        @project = project
      end

      def make_uniq_names
        @project.children[:libraries].children[:libraries].each do |library|
          library.children[:actionwords].each do |actionword|
            existing_names = library.children[:actionwords].reject{|aw| aw == actionword}.map(&:uniq_name)
            new_name = find_uniq_name(actionword.children[:name], existing_names)
            actionword.uniq_name = new_name
          end
        end
      end

      def find_uniq_name(name, existing)
        return name unless existing.include?(name)

        index = 1
        new_name = ""

        loop do
          new_name = "#{name} #{index}"

          break unless existing.include?(new_name)
          index += 1
        end

        new_name
      end
    end
  end
end
