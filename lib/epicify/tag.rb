module Epicify

  class Tag < Struct.new(:id)
    IDS_FOR_POINT_TAGS = { "1" => ENV["EPICIFY_STORY_POINTS_1_TAG_ID"].to_i, "2" => ENV["EPICIFY_STORY_POINTS_2_TAG_ID"].to_i, "3" => ENV["EPICIFY_STORY_POINTS_3_TAG_ID"].to_i}

    def points
      _point_value_for_tag_id self.id
    end

    def self.create_with_points_value points_value
      tag_id = self.new.tag_id_for_point_value points_value.to_s
      Tag.new(tag_id)
    end

    def tag_id_for_point_value point
      IDS_FOR_POINT_TAGS[point]
    end

    def self.tag_id_for_point_value point
      IDS_FOR_POINT_TAGS[point]
    end

    def _point_value_for_tag_id id
      IDS_FOR_POINT_TAGS.key(id).to_i
    end

  end

end
