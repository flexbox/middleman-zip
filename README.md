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
activate :zip, output_file: 'pkg/archive.zip'
```

### Options

```ruby
:input_dir    => 'build' # The directory that will be zipped.
                         # String. Default: 'build' (or whatever you specified
                         # as your build directory).

:output_file  => nil     # Path to the final zip file.
                         # String, has to end with '.zip'.
                         # Required if :zip_map option is not set.

:include_root => true    # Whether to include or not to include a root
                         # directory. If a string is provided it will be used
                         # as directory name.
                         # Boolean (true/false) or string. Default: true.

:moment       => :after  # Whether to zip files before or after build.
                         # Symbol, possible values: :after, :before.
                         # Default: :after

:zip_map      => nil     # Array of hashed, each hash with optional :input_dir,
                         # :include_root and :moment keys and required
                         # :output_file key. See above for allowed values.
                         # Array of hashed, Required if :output_file option
                         # is not set.
```

Example with `:zip_map` option:

```ruby
activate :zip, zip_map: [
  { output_file: 'pkg/archive.zip' },
  { input_dir: 'additional_files', output_file: 'pkg/additionals.zip' }
]
```

Options can be set in two ways:

```ruby
activate :zip, output_file: 'pkg/build.zip'

# or

activate :zip do |config|
  config.output_file: 'pkg/build.zip'
end
```

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## License

MIT. See [LICENSE](LICENSE).
