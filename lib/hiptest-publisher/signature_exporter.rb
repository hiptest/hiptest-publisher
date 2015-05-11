require 'yaml'

module Hiptest
  class SignatureExporter
    def self.export_project(project)
      exporter = SignatureExporter.new
      exporter.export_actionwords(project).to_yaml
    end

    def export_actionwords(project)
      project.children[:actionwords].children[:actionwords].map {|aw| export_actionword(aw)}
    end

    def export_item(item)
      {
        'name' => item.children[:name],
        'uid' => item.children[:uid],
        'parameters' => export_parameters(item)
      }
    end
    alias :export_actionword :export_item
    alias :export_scenario :export_item

    def export_parameters(item)
      item.children[:parameters].map {|p| export_parameter(p)}
    end

    def export_parameter(parameter)
      {
        'name' => parameter.children[:name]
      }
    end
  end
end
