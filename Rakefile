task :default => [:specs]

desc "Run all specs"
task :specs do
  FileList['spec/*_spec.rb'].sort.each do |spec|
    sh "ruby -I lib #{spec} -e ''"
  end
end

desc "Add magic encoding to all source files in the project"
task :magic do
  require File.expand_path('../rake/magic_encoding', __FILE__)
  MagicEncoding.apply
end