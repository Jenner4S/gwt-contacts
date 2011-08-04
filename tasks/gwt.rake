module Buildr
  module GWT

    class << self
      # The specs for requirements
      def dependencies
        ['com.google.gwt:gwt-dev:jar:2.3.0']
      end

      def gwtc_main(modules, source_artifacts, output_dir, options = {})
        cp = Buildr.artifacts(self.dependencies).each(&:invoke).map(&:to_s) + Buildr.artifacts(source_artifacts).each(&:invoke).map(&:to_s)
        style = options[:style] || "OBFUSCATED," # "PRETTY", "DETAILED"
        log_level = options[:log_level] #  ERROR, WARN, INFO, TRACE, DEBUG, SPAM, or ALL
        workers = options[:workers] || 2

        args = []
        if log_level
          args << "-logLevel"
          args << log_level
        end
        args << "-style"
        args << style
        args << "-localWorkers"
        args << workers
        args << "-war"
        args << output_dir
        if options[:compile_report_dir]
          args << "-compileReport"
          args << "-extra"
          args << options[:compile_report_dir]
        end

        if options[:draft_compile]
          args << "-draftCompile"
        end

        args += modules

        Java::Commands.java 'com.google.gwt.dev.Compiler', *(args + [{:classpath => cp, :properties => options[:properties], :java_args => options[:java_args]}])
      end
    end

    module ProjectExtension
      include Extension

      def gwt(module_name, options = {})
        output_dir = project._(:target, :generated, :gwt, module_name)
        task = file(output_dir) do
          artifacts = (project.compile.sources + project.resources.sources).collect do |a|
            a.is_a?(String) ? file(a) : a
          end
          dependencies = options[:dependencies] || project.compile.dependencies
          options = options.dup
          options[:compile_report_dir] ||= project._(:target, :main, :gwt, module_name)
          Buildr::GWT.gwtc_main([module_name], dependencies + artifacts, output_dir, options)
        end
        task.enhance [project.compile]
        task
      end
    end
  end
end

class Buildr::Project
  include Buildr::GWT::ProjectExtension
end