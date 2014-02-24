require_relative 'spec_helper'

class TestLogger

  def initialize
    @lines = []
  end

  def log message
    @lines << message
  end

  def get_lines
    @lines
  end

end

module Epicify

  class FakeResponse

    def body
      '{"data":"success"}'
    end

  end

  class AsanaAdapter

    def _send_request_to_actual_service http, req
      FakeResponse.new
    end

  end

end

describe "AsanaAdapter" do

  before do
    @logger = TestLogger.new
    @adapter = Epicify::AsanaAdapter.new(nil, @logger)
  end

  it "projects" do
    assert_equal "success", @adapter.get_projects()
    expected = ["_make_request get - /projects/"]
    assert_equal expected, @logger.get_lines()
  end

  it "tasks_for_project" do
    assert_equal "success", @adapter.get_tasks_for_project(89)
    expected = ["_make_request get - /projects/89/tasks?opt_fields=id,name,completed,tags"]
    assert_equal expected, @logger.get_lines()
  end

  it "update_task_name" do
    assert_equal "success", @adapter.update_task_name(2838, "new name")
    expected = ["_make_request put - /tasks/2838"]
    assert_equal expected, @logger.get_lines()
  end

  it "associate_tag_with_task" do
    assert_equal "success", @adapter.associate_tag_with_task(2838, 4188)
    expected = ["_make_request post - /tasks/4188/addTag"]
    assert_equal expected, @logger.get_lines()
  end

  it "remove_tag_from_task" do
    assert_equal "success", @adapter.remove_tag_from_task(2838, 4188)
    expected = ["_make_request post - /tasks/4188/removeTag"]
    assert_equal expected, @logger.get_lines()
  end

end
