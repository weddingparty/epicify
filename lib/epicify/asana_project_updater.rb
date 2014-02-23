module Epicify

  class AsanaProjectUpdater

    def initialize(project, asana_adapter)
      @project = project
      @asana_adapter = asana_adapter
    end

    def update

      @project.sections.each do |section|
        if section.is_overview?
          if @project.report_overview_name != @project.overview_section.name
            @asana_adapter.update_task_name section.id, @project.report_overview_name
          end
        else
          original_name = section.name()
          new_name = section.report_section_name()
          if new_name != original_name
            @asana_adapter.update_task_name section.id, new_name
          end
        end

        section.stories.each do |story|
          if story.name_was_changed?
            @asana_adapter.update_task_name story.id, story.name
          end
          story.added_tags.each do |tag|
            @asana_adapter.associate_tag_with_task tag.id, story.id
          end
          story.removed_tags.each do |tag|
            @asana_adapter.remove_tag_from_task tag.id, story.id
          end
        end
      end

    end

  end

end
