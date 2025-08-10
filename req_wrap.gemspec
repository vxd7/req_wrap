# frozen_string_literal: true

require_relative 'lib/req_wrap/version'

Gem::Specification.new do |spec|
  spec.name = 'req_wrap'
  spec.version = ReqWrap::VERSION
  spec.authors = ['vxd7']
  spec.email = ['vxd732@protonmail.com']

  github_repo = 'https://github.com/vxd7/req_wrap'

  spec.summary = 'Wrapper for HTTP requests testing and prototyping'
  spec.description = <<~DESCRIPTION
    Plain Ruby wrapper for HTTP requests testing and prototyping with simple environment management.
    Supports encrypted environment definitions. Features optional commandline interface and
    request definition generation.
  DESCRIPTION

  spec.homepage = github_repo
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = github_repo

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[tmp/ bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '~> 8.0.0'
  spec.add_dependency 'dotenv', '~> 3.1.0'
  spec.add_dependency 'http', '~> 5.3.1'
end
