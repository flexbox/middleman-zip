require 'zip'
require 'pathname'

module Middleman
  module Zip
    class ZipExtension < Extension
      attr_reader :orig

      option :input_dir, :middleman_build_dir, 'The directory that will be zipped.'
      option :output_file, 'pkg/build.zip', 'Path to the final zip file.'
      option :include_root, true, 'Whether to include or not to include a root directory. If a string is provided it will be used as directory name.'
      option :moment, :after, 'Whether to zip files before or after build.'

      def initialize(app, options_hash = {}, &block)
        super
        prepare_and_validate_options(app)
      end

      def after_build(builder)
        do_zip(builder) if options.moment == :after
      end

      def before_build(builder)
        do_zip(builder) if options.moment == :before
      end

      private

      def prepare_and_validate_options(app)
        @orig = {}

        options.input_dir = app.config.build_dir if options.input_dir == :middleman_build_dir
        fail_with(':input_dir option must be a string') unless options.input_dir.is_a?(String)
        @orig[:input_dir] = options.input_dir
        options.input_dir = File.expand_path(options.input_dir)
        fail_with(':input_dir option must point to a directory') unless File.directory?(options.input_dir)

        fail_with(':output_file option must be a string.') unless options.output_file.is_a?(String)
        fail_with(':output_file option must end with `.zip`') unless File.extname(options.output_file) == '.zip'
        @orig[:output_file] = options.output_file
        options.output_file = File.expand_path(options.output_file)

        fail_with(':include_root option must be `false`, `true` or a string') unless [true, false].include?(options.include_root) or options.include_root.is_a?(String)
        options.include_root = File.basename(options.output_file, File.extname(options.output_file)) if options.include_root == true

        fail_with(':moment option must be `:after` or `:before`') unless [:after, :before].include?(options.moment)
      end

      def do_zip(builder)
        builder.source_paths << Dir.pwd
        builder.remove_file(options.output_file)
        builder.empty_directory(File.dirname(options.output_file))
        write_zip_file
        builder.say_status :done, "#{orig[:input_dir]} zipped to #{orig[:output_file]}", :green
      end

      def write_zip_file
        entries = Dir.entries options.input_dir
        %w[. ..].each { |x| entries.delete(x) }
        io = ::Zip::File.open(options.output_file, ::Zip::File::CREATE)
        io.mkdir(options.include_root) if options.include_root
        write_zip_entries(entries, '', io, options.include_root || '')
        puts Dir.pwd
        io.close
      end

      def write_zip_entries(entries, path, io, root = '')
        entries.each do |e|
          zip_file_path = File.join(*[root, path, e].reject(&:empty?))
          disk_file_path = File.join(*[options.input_dir, path, e].reject(&:empty?))
          puts "e: #{e}\nzip: #{zip_file_path}\ndisk: #{disk_file_path}\n\n"
          if File.directory?(disk_file_path)
            io.mkdir(zip_file_path)
            subdir_entries = Dir.entries(disk_file_path)
            %w[. ..].each { |x| subdir_entries.delete(x) }
            # write_zip_entries(subdir_entries, zip_file_path, io, root)
            write_zip_entries(subdir_entries, File.join(*[path, e].reject(&:empty?)), io, root)
          else
            io.add(zip_file_path, disk_file_path)
          end
        end
      end

      def fail_with(msg, error = ArgumentError)
        raise StandardError, "[middleman-zip] #{msg}"
      end
    end
  end
end
