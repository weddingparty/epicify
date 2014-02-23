module Epicify

  class Section < Struct.new(:id, :name, :stories, :points)

    def is_overview?
      name =~ /^Overview/
    end

    def add_story story
      stories << story
    end

    def all_story_points
      _total_points_for_stories stories
    end

    def completed_story_points
      _total_points_for_stories stories.select{|story| story.is_completed?}
    end

    def report_section_name
      name_preceeding_report = name.sub(/\s+\(\d+ --- \d+\)/, "")
      name_preceeding_report = name_preceeding_report.sub(/\s*:\s*$/, "")

      if all_story_points > 0
        name_preceeding_report + " " + _points_report(completed_story_points, all_story_points) + ":"
      else
        name_preceeding_report + ":"
      end
    end

    private

      def _points_report completed_points, all_points
        "(#{completed_points} --- #{all_points})"
      end

      def _total_points_for_stories stories_to_sum
        stories_to_sum.map{|story| story.points}.reduce(:+) || 0
      end

  end

end
