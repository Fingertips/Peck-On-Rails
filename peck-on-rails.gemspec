Gem::Specification.new do |spec|
  spec.name = 'peck-on-rails'
  spec.version = '0.2.1'

  spec.author = "Manfred Stienstra"
  spec.email = "manfred@fngtps.com"

  spec.description = <<-EOF
    Peck-On-Rails is an extension for Peck to make testing Rails easier.
  EOF
  spec.summary = <<-EOF
    Peck-On-Rails adds useful helpers and context extensions to make
    testing Ruby on Rails apps easier.
  EOF

  spec.files = Dir.glob("{lib}/**/*") + %w(COPYING README.md)

  spec.has_rdoc = true
  spec.extra_rdoc_files = ['COPYING']
  spec.rdoc_options << "--charset=utf-8"

  spec.add_dependency('peck')
  spec.add_development_dependency('rails')
end