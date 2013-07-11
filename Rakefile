require 'rake/testtask'

task :default => [:specs]

RAILS_VERSIONS = %w(rails32 rails40)

desc "Run all specs"
task :specs => RAILS_VERSIONS.map { |v| 'specs:'+v }

namespace :specs do
  test_files = FileList['spec/*_spec.rb']
  RAILS_VERSIONS.each do |rails_version|
    desc "Test against against #{rails_version}"
    task rails_version do
      test_files.each do |spec|
        sh "ruby -I spec/rails/#{rails_version} -I lib #{spec} -e ''"
      end
    end
  end
end

desc "Add magic encoding to all source files in the project"
task :magic do
  require File.expand_path('../rake/magic_encoding', __FILE__)
  MagicEncoding.apply
end