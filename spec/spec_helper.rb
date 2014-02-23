ENV["EPICIFY_STORY_POINTS_1_TAG_ID"] = "1000000000000"
ENV["EPICIFY_STORY_POINTS_2_TAG_ID"] = "2000000000000"
ENV["EPICIFY_STORY_POINTS_3_TAG_ID"] = "3000000000000"

# Only actually load coveralls when you specifically want to.
# The code slows down tests by 0.4 seconds otherwise.
# This code was copied/pasted from /lib/coveralls.rb in the coveralls-ruby gem
if ENV["CI"] || ENV["JENKINS_URL"] || ENV["COVERALLS_RUN_LOCALLY"]
  require "coveralls"
  Coveralls.wear!
end

require "epicify"

require "minitest/autorun"
