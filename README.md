# Middleman-Zip

`middleman-zip` is an extension for the [Middleman](http://middlemanapp.com/) static site generator that allows you to zip directories.

## Installation

First, you need to have the `middleman` gem installed and a `middleman` project created. If you don't here's how:

```
$ gem install middleman
$ middlman init my_project
```

Add `gem 'middleman-zip'` to your project's `Gemfile` and run `bundle install`.

## Configuration

Add the following to the `config.rb` of your Middleman project:

```ruby
activate :middleman_zip, input_dir: 'build', output_file: 'pkg/build.zip',
                         include_root: true, moment: :after

# or

activate :middleman_zip do |config|
  config.input_dir: 'build'
  config.output_file: 'pkg/build.zip'
  config.include_root: true
  config.moment: :after
end
```

### Options

```ruby
:input_dir    => 'build'         # The directory that will be zipped.
                                 # String. Default: 'build' (or whatever you 
                                 # specified as your build directory).

:output_file  => 'pkg/build.zip' # Path to the final zip file.
                                 # String, has to end with '.zip'.
                                 # Default: 'pkg/build.zip'.

:include_root => true            # Whether to include or not to include a
                                 # root directory. If a string is provided it
                                 # will be used as directory name.
                                 # Boolean (true/false) or string. 
                                 # Default: true.

:moment       => :after          # Whether to zip files before or after build.
                                 # Symbol, possible values: :after, :before.
                                 # Default: :after
```

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## License

MIT. See [LICENSE](LICENSE).
