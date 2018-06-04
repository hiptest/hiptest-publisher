require 'hiptest-publisher/nodes'

module Hiptest
  module BehaveAddon
    def walk_actionwords(aws)
      base = super(aws)
      sorted_aws = aws.children[:actionwords]
        .sort_by {|aw|
          pattern = aw.children.fetch(:gherkin_pattern, "")
          [pattern.length, pattern]
        }.reverse

      @rendered_children[:sorted_actionwords] = sorted_aws.map {|aw| @rendered[aw]}
      return base
    end

    private

    def get_pattern(aw)
      name = aw.children["name"]
    end
  end
end
