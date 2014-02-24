module Epicify

  # Note: This class only exists because, as of this writing, the modified_at
  # attribute of a project "does not reflect any changes in associations such
  # as tasks or comments that may have been added or removed from the
  # project." (from the Asana API docs).  If that changes in the future, we
  # should revisit the need for this class.

  class ProjectTasksCache < Struct.new(:data_dir, :project_id)

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
      FileUtils.mkdir_p(self.data_dir)
      File.open(_full_path_for_project_id(project_id()), 'w') do |file|
        file.write YAML.dump(data)
      end
    end

    def previously_cached_data_matches?(data)
      data.to_json == get.to_json
    end

    private

      def _full_path_for_project_id project_id
        self.data_dir + "/" + project_id.to_s
      end

  end

end
