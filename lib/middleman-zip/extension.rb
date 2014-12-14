require 'zip'
require 'pathname'

module Middleman
  module Zip
    class ZipExtension < Extension
      attr_accessor :after_queue, :before_queue, :middleman_build_dir

      option :input_dir, :middleman_build_dir, 'The directory that will be zipped.'
      option :output_file, nil, 'Path to the final zip file.'
      option :include_root, true, 'Whether to include or not to include a root directory. If a string is provided it will be used as directory name.'
      option :moment, :after, 'Whether to zip files before or after build.'
      option :zip_map, nil, 'Array of hashes with :input_dir, :output_file, :include_root and :moment keys.'

      def initialize(app, options_hash = {}, &block)
        super
        self.middleman_build_dir = app.config.build_dir
        self.after_queue = self.before_queue = []
        prepare_and_validate_options
        build_queues
      end

      def after_build(builder)
        do_zip(:after, builder) if after_queue.any?
      end

      def before_build(builder)
        do_zip(:before, builder) if before_queue.any?
      end

      private

      def prepare_and_validate_options
        if !options.zip_map.nil?
          # Use advanced mode with :zip_map option
          prepare_and_validate_options_for_advanced_mode
        elsif !options.output_file.nil?
          # Use simple mode with :input_dir, :output_file, :include_root and :moment options.
          prepare_and_validate_options_for_simple_mode
        else
          fail_with('Either :copy_map or :output_file option must be set.')
        end
      end

      def prepare_and_validate_options_for_advanced_mode
        fail_with(':zip_map option must be an array.') unless options.zip_map.is_a?(Array)
        fail_with(':zip_map option must have at least one entry.') if options.zip_map.size < 1

        options.zip_map.each_with_index do |el, i|
          fail_with(':zip_map option may have only hashes as array elements.') unless el.is_a?(Hash)
          el[:input_dir] ||= :middleman_build_dir
          options.zip_map[i] = check_and_prepare(el[:input_dir], el[:output_file], el[:include_root], el[:moment])
        end
      end

      def prepare_and_validate_options_for_simple_mode
        options.zip_map = [check_and_prepare(options.input_dir, options.output_file, options.include_root, options.moment)]
      end

      def check_and_prepare(input_dir, output_file, include_root, moment)
        input_dir = middleman_build_dir if input_dir == :middleman_build_dir
        fail_with(':input_dir option must be a string') unless input_dir.is_a?(String)
        fail_with(':input_dir option must point to a directory') unless File.directory?(input_dir)
        fail_with(':output_file option must be a string.') unless output_file.is_a?(String)
        fail_with(':output_file option must end with `.zip`') unless File.extname(output_file) == '.zip'
        include_root ||= true
        fail_with(':include_root option must be `false`, `true` or a string') unless [true, false].include?(include_root) or include_root.is_a?(String)
        include_root = File.basename(output_file, File.extname(output_file)) if include_root == true
        moment ||= :after
        fail_with(':moment option must be `:after` or `:before`') unless [:after, :before].include?(moment)
        { input_dir: input_dir, input_dir_path: File.expand_path(input_dir), output_file: output_file, output_file_path: File.expand_path(output_file), include_root: include_root, moment: moment }
      end

      def build_queues
        options.zip_map.each do |el|
          self.after_queue << el if el[:moment] == :after
          self.before_queue << el if el[:moment] == :before
        end
      end

      def do_zip(moment, builder)
        builder.source_paths << Dir.pwd unless builder.source_paths.include?(Dir.pwd)
        queue = moment == :after ? after_queue : before_queue
        queue.each do |el|
          builder.remove_file(el[:output_file_path])
          builder.empty_directory(File.dirname(el[:output_file_path]))
          write_zip_file(el[:input_dir_path], el[:output_file_path], el[:include_root])
          builder.say_status :done, "#{el[:input_dir]} zipped to #{el[:output_file]}", :green
        end
      end

      def write_zip_file(input_dir, output_file, include_root)
        entries = Dir.entries input_dir
        %w[. ..].each { |x| entries.delete(x) }
        io = ::Zip::File.open(output_file, ::Zip::File::CREATE)
        io.mkdir(include_root) if include_root
        write_zip_entries(input_dir, entries, '', io, include_root || '')
        io.close
      end

      def write_zip_entries(input_dir, entries, path, io, root = '')
        entries.each do |e|
          zip_file_path = File.join(*[root, path, e].reject(&:empty?))
          disk_file_path = File.join(*[input_dir, path, e].reject(&:empty?))
          if File.directory?(disk_file_path)
            io.mkdir(zip_file_path)
            subdir_entries = Dir.entries(disk_file_path)
            %w[. ..].each { |x| subdir_entries.delete(x) }
            write_zip_entries(input_dir, subdir_entries, File.join(*[path, e].reject(&:empty?)), io, root)
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
