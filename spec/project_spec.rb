require_relative 'spec_helper'

class FakeAsanaAdapter

  def initialize
    @log = []
  end

  def update_task_name task_id, name
    @log << "update_task_name #{task_id}, #{name}"
  end

  def associate_tag_with_task tag_id, task_id
    @log << "associate_tag_with_task #{tag_id}, #{task_id}"
  end

  def remove_tag_from_task tag_id, task_id
    @log << "remove_tag_from_task #{tag_id}, #{task_id}"
  end

  def logs
    @log
  end

end

describe "Project" do

  describe "Fixture 1 - Simple" do

    before do

#         -- story is completed
#        |
#        |
      fixture = "
      1    Overview:
      2    Wedding Page (1 --- 3):
      3  *   user can like a photo [1]
      4      user can comment on a photo [2]
      5      -- user can see nice profile photo next to photo
      6    Settings (0 --- 2):
      7       user should be able to update their name [2]
      "

      project_tasks = FixturesParser.new.tasks_for_project_from_fixture(fixture)
      @project = Epicify::Project.project_from_data(project_tasks)
      @stories = @project.stories
    end

    describe "Asana Project Updater" do

      before do
        @fake_asana_adapter = FakeAsanaAdapter.new
        @asana_project_updater = Epicify::AsanaProjectUpdater.new(@project, @fake_asana_adapter)
        @asana_project_updater.update()
      end

      it "should have told Asana about some changes" do
        expected = []
        expected << "update_task_name 1, Overview (1 --- 7) total days - 2 , remaining days: 2:"
        expected << "update_task_name 2, Wedding Page (1 --- 5):"
        expected << "update_task_name 5, user can see nice profile photo next to photo"
        expected << "associate_tag_with_task 2000000000000, 5"
        assert_equal expected, @fake_asana_adapter.logs
      end

    end

  end

  describe "Fixture 2 - More Complex" do

    before do

#         -- story is completed
#        |
#        |
      fixture = "
      1    Overview:
      2    Home Page:
      3      -- user can login from popup
      4         user can see indicator that they are already logged in [1]
      5    Wedding Page (1 --- 3):
      6  *   user can like a photo [1]
      7      user can comment on a photo [2]
      8      -- user can see nice profile photo next to photo
      9    Settings (0 --- 2):
      10     -  user should be able to update their name [2]
      11   Used to have a story with points (0 --- 2):
      12      some task with no story points
      "

      project_tasks = FixturesParser.new.tasks_for_project_from_fixture(fixture)
      @project = Epicify::Project.project_from_data(project_tasks)
      @stories = @project.stories
    end

    describe "Asana Project Updater" do

      before do
        @fake_asana_adapter = FakeAsanaAdapter.new
        @asana_project_updater = Epicify::AsanaProjectUpdater.new(@project, @fake_asana_adapter)
        @asana_project_updater.update()
      end

      it "should have told Asana about some changes" do
        assert @fake_asana_adapter.logs.size > 0
      end

    end

    describe "Project" do

      describe "Overview" do

        it "should be able to get the overview task easily" do
          assert_equal 1, @project.overview_section.id
        end

        it "should calculate the final report" do
          assert_equal "Overview (1 --- 9) total days - 3 , remaining days: 2:", @project.report_overview_name
        end

      end

      it "should get the right number of sections" do
        assert_equal 5, @project.sections.size
      end

      it "should have one completed story" do
        assert_equal 1, @stories.select{|story| story.completed == true}.size
      end

      it "should add a tag to some tasks" do
        affected_stories = @stories.select{|story| story.added_tags.size > 0}
        assert_equal [3, 8, 10], affected_stories.map{|story| story.id}.sort
      end

      it "should only add three tags in total" do
        assert_equal 3, @stories.map{|story| story.added_tags}.flatten.size
      end

      it "should remove one tag from story 10" do
        affected_stories = @stories.select{|story| story.removed_tags.size > 0}
        assert_equal [10], affected_stories.map{|story| story.id}
      end

      it "should only remove one tag in total" do
        assert_equal 1, @stories.map{|story| story.removed_tags}.flatten.size
      end

    end

    describe "Sections" do

      before do
        @wedding_page_section = @project.sections.select{|section| section.name =~ /Wedding Page/}.first
      end

      it "should have the right report for a section" do
        assert_equal "Wedding Page (1 --- 5):", @wedding_page_section.report_section_name
      end

      it "should have the right points for a section" do
        assert_equal 5, @wedding_page_section.all_story_points
        assert_equal 1, @wedding_page_section.completed_story_points
      end

      it "should report correctly on a section with no story points" do
        no_points_section = @project.sections.select{|section| section.name =~ /Used to have/}.first
        assert_equal "Used to have a story with points:", no_points_section.report_section_name
      end

    end

    describe "specific stories" do

      def story_with_id id
        @stories.select{|story| story.id == id}.first
      end

      it "should have the right points for a story where points were added" do
        assert_equal 2, story_with_id(3).points
      end

      it "should have the right points for a story with pre-exising points" do
        assert_equal 1, story_with_id(4).points
      end

    end

  end

end

class FixturesParser

  def tasks_for_project_from_fixture(input_fixture)
    tasks = []
    input_fixture.lines.each do |line|

      line.gsub!(/^\s+/, "") # remove leading spaces

      if line.match(/:$/)
        # section
        if match = line.match(/^(\d+)\s+(.*)/)
          task_params = {}
          task_params["id"] = match[1].to_i
          task_params["name"] = match[2].strip
          task_params["completed"] = false
          task_params["tags"] = []
          tasks << task_params
        end
      else
        # story
        if match = line.match(/^(\d+)([ *]{0,3})([A-Za-z: -]+)([\[123\]]*)/)
          task_params = {}
          task_params["id"] = match[1].to_i
          task_params["completed"] = !! match[2].match(/\*/)
          task_params["name"] = match[3].strip

          existing_points_in_brackets = match[4]
          if points_match = existing_points_in_brackets.match(/(\d)/)
            existing_points = points_match[0].to_i
            task_params["tags"] = [{"id" => tag_id_for(existing_points)}]
          else
            task_params["tags"] = []
          end
          tasks << task_params
        end
      end
    end
    tasks
  end

  def tag_id_for tag_value
    ids_for_point_tags = {1 => ENV["EPICIFY_STORY_POINTS_1_TAG_ID"].to_i, 2 => ENV["EPICIFY_STORY_POINTS_2_TAG_ID"].to_i, 3 => ENV["EPICIFY_STORY_POINTS_3_TAG_ID"].to_i}
    ids_for_point_tags[tag_value]
  end

end
