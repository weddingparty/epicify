module Epicify

  class ProjectTasksCache < Struct.new(:project_id)

    def get
      data = nil
      filename = _full_path_for_project_id project_id()
      if File.exists? filename
        File.open(filename) do |file|
          data = YAML.load(file.read)
        end
      end
      data
    end

    def set data
      FileUtils.mkdir_p(_data_dir)
      File.open(_full_path_for_project_id(project_id()), 'w') do |file|
        file.write YAML.dump(data)
      end
    end

    private

      def _full_path_for_project_id project_id
        _data_dir + "/" + project_id.to_s
      end

      def _data_dir
        ".asana_project_tasks_cache"
      end

  end

end
