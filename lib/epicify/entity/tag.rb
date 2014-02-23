module Epicify

  module Entity

    class Tag < Struct.new(:id)

      def self.create_with_points_value points_value
        tag_id = self.new.send :_tag_id_for_point_value, points_value
        Tag.new(tag_id)
      end

      def points
        _point_value_for_tag_id self.id
      end

      private

        def _ids_for_point_tags
          {
            1 => ENV["EPICIFY_STORY_POINTS_1_TAG_ID"].to_i,
            2 => ENV["EPICIFY_STORY_POINTS_2_TAG_ID"].to_i,
            3 => ENV["EPICIFY_STORY_POINTS_3_TAG_ID"].to_i
          }
        end

        def _tag_id_for_point_value point
          _ids_for_point_tags[point]
        end

        def _point_value_for_tag_id id
          _ids_for_point_tags.key(id)
        end

    end

  end

end
