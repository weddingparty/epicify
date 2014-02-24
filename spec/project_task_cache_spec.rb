require_relative 'spec_helper'

require 'tmpdir'

describe "ProjectTasksCache" do

  before do
    temp_dir = Dir.mktmpdir
    @cache = Epicify::ProjectTasksCache.new(temp_dir, 1000000000000)
  end

  it "should be able to set data and see if new data is the same or not" do
    orig_data = {:foo => "bar"}
    @cache.set(orig_data)

    new_but_unchanged_data = {:foo => "bar"}
    assert @cache.previously_cached_data_matches?(new_but_unchanged_data)

    new_and_changed_data = {:foo => "zebra"}
    assert ! @cache.previously_cached_data_matches?(new_and_changed_data)
  end

end
