require 'buildr/git_auto_version'
require 'buildr/top_level_generate_dir'
require 'buildr/single_intermediate_layout'
require 'buildr/jacoco'
require 'buildr/gwt'

JEE_GWT_JARS = [:javax_inject, :javax_jsr305, :findbugs_annotations, :javax_validation, :javax_validation_sources]
GIN_JARS = [:gwt_gin, :google_guice, :aopalliance, :google_guice_assistedinject]
APPCACHE_GWT_JARS = [:gwt_appcache_client, :gwt_appcache_linker, :gwt_appcache_server]
GWT_JARS = JEE_GWT_JARS + GIN_JARS + [:gwt_user] + APPCACHE_GWT_JARS
JEE_JARS = [:javaee_api, :javax_jsr305, :findbugs_annotations]
JACKSON_DEPS = [:jackson_core, :jackson_mapper]
PROVIDED_DEPS = JACKSON_DEPS + JEE_JARS
INCLUDED_DEPENDENCIES = [:gwt_servlet, :gwt_appcache_server, :gwt_cache_filter]

desc 'GWT Contacts: Sample application showing off our best practices'
define 'gwt-contacts' do
  project.group = 'org.realityforge.gwt.contacts'

  compile.options.source = '1.8'
  compile.options.target = '1.8'
  compile.options.lint = 'all'

  desc 'GWT Contacts: Client-side component'
  define 'client' do
    Domgen::Build.define_generate_task([:gwt_client, :gwt_rpc_shared, :gwt_rpc_client, :gwt_client_jso])

    compile.with GWT_JARS

    test.using :testng
    test.with :mockito

    package(:jar)
    package(:sources)

    iml.add_gwt_facet({'org.realityforge.gwt.sample.contacts.ContactsDev' => true,
                       'org.realityforge.gwt.sample.contacts.Contacts' => false},
                      :settings => {:compilerMaxHeapSize => '1024'},
                      :gwt_dev_artifact => :gwt_dev)
  end

  desc 'GWT Contacts: Server-side component'
  define 'server' do
    Domgen::Build.define_generate_task([:ee_data_types, :ee, :jpa_test_persistent_test_module, :gwt_rpc_shared, :gwt_rpc_server, :jpa_test_module])

    compile.with PROVIDED_DEPS + INCLUDED_DEPENDENCIES

    test.using :testng
    test.with :mockito

    test.compile.with :guiceyloops,
                      :google_guice,
                      :aopalliance,
                      :google_guice_assistedinject,
                      :postgresql_jdbc,
                      :eclipselink
    package(:jar)

    iml.add_jpa_facet
    iml.add_ejb_facet
  end

  desc 'GWT Contacts: Web component'
  define 'web' do
    gwt_dir =
      gwt(%w(org.realityforge.gwt.sample.contacts.Contacts),
          :dependencies => [project('client').compile.dependencies,
                            # The following picks up both the jar and sources
                            # packages deliberately. It is needed for the
                            # generators to access classes in annotations.
                            project('client')],
          :java_args => %w(-Xms512M -Xmx512M -XX:PermSize=128M -XX:MaxPermSize=256M),
          :draft_compile => (ENV['FAST_GWT'] == 'true'))

    webroots = {}
    webroots[_(:source, :main, :webapp)] = '/' if File.exist?(_(:source, :main, :webapp))
    webroots[_(:source, :main, :webapp_local)] = '/'
    assets.paths.each { |path| webroots[path.to_s] = '/' if path.to_s != gwt_dir.to_s }

    iml.add_web_facet(:webroots => webroots)

    package(:war).tap do |war|
      war.with :libs => [INCLUDED_DEPENDENCIES, project('server')]
    end
  end

  # Remove the IDEA generated artifacts
  project.clean { rm_rf _(:artifacts) }

  doc.using :javadoc, {:tree => false, :since => false, :deprecated => false, :index => false, :help => false}
  doc.from projects('client', 'server')

  ipr.add_exploded_war_artifact(project,
                                :war_module_names => [project('web').iml.id],
                                :jpa_module_names => [project('server').iml.id],
                                :ejb_module_names => [project('server').iml.id],
                                :dependencies => [INCLUDED_DEPENDENCIES, projects('server')])
  ipr.add_gwt_configuration(project, :gwt_module => 'org.realityforge.gwt.sample.contacts.Contacts', :vm_parameters => '-Xmx3G', :shell_parameters => '-port 8888', :launch_page => 'http://127.0.0.1:8080/gwt-contacts')

  iml.add_jruby_facet
end
