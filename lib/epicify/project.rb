module Epicify

  class Project

    ACTIVE_NAME_REGEX = %r{^\* }

    def self.project_from_data data
      project = Project.new()
      data.each do |task|
        project.add_task(task["id"], task["name"], task["completed"], task["tags"])
      end
      project
    end

    def initialize
      @sections = []
    end

    def report_overview_name
      "Overview #{_points_report(total_completed_story_points(), total_all_story_points())} total days - #{_report_total_days()} , remaining days: #{_report_remaining_days()}:"
    end

    def add_task id, name, completed, tags
      if name =~ /:$/
        _add_a_section id, name
      else
        _add_a_story_to_the_section id, name, completed, tags
      end
    end

    def sections
      @sections
    end

    def overview_section
      @sections.select{|section| section.is_overview?}.first
    end

    def stories
      @sections.map{|section| section.stories}.flatten
    end

    def total_completed_story_points
      total = 0
      @sections.each do |section|
        total += section.completed_story_points
      end
      total
    end

    def total_all_story_points
      total = 0
      @sections.each do |section|
        total += section.all_story_points
      end
      total
    end

    private

      def _add_a_section id, name
        section = Section.new(id, name, [], 0)
        @sections.push(section)
      end

      def _add_a_story_to_the_section id, line, completed, tags
        story = Story.new(id, line, completed, tags)
        @sections.last.add_story(story)
      end

      def _report_total_days
        (total_all_story_points / 3.0).to_i
      end

      def _report_remaining_days
        ((total_all_story_points - total_completed_story_points()) / 3.0).to_i
      end

      def _points_report completed_points, all_points
        "(#{completed_points} --- #{all_points})"
      end

  end

end
