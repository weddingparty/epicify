module Epicify

  class Story < Struct.new(:id, :name, :completed, :tags)

    POINTS_REGEX = %r{^((\s*-\s*){1,3})(.*)}

    def initialize(*args)
      super(*args)
      @added_tags = []
      @removed_tags = []
      @_name_was_changed = false
      _preprocess_tag_hash_array_into_actual_tag_objects
      _preprocess_hyphens_into_tags
    end

    def points
      _process_story_points
    end

    def is_completed?
      self.completed
    end

    def name_was_changed?
      @_name_was_changed
    end

    def added_tags
      @added_tags
    end

    def removed_tags
      @removed_tags
    end

    def _preprocess_tag_hash_array_into_actual_tag_objects
      x = []
      tags.each do |tag_hash|
        x << Tag.new(tag_hash["id"])
      end
      self.tags = x
    end

    def _preprocess_hyphens_into_tags
      if name =~ POINTS_REGEX
        matcher = name.match(POINTS_REGEX)
        if matcher
          num_hyphens = matcher[1].delete(' ').size
          self.name = matcher[3]
          _remove_any_preexisting_points_tags_from_task
          _add_tag_with_value_to_task num_hyphens
          @_name_was_changed = true
        end
      end
    end

    def _process_story_points
      _process_tag_points tags
    end

    def _process_tag_points tags
      points = 0
      if !tags || tags.size == 0
        return points
      end

      tags.each do |tag|
        points = tag.points
      end
      points
    end

    def _add_tag_with_value_to_task tag_value
      new_tag = Tag.create_with_points_value tag_value

      tags << new_tag
      @added_tags << new_tag
    end

    def _remove_any_preexisting_points_tags_from_task
      return if tags.size == 0

      all_tags_point_values = Tag::IDS_FOR_POINT_TAGS.keys.map(&:to_i)

      all_tags_point_values.each do |removed_tag_point_value|
        tag_id = Tag.tag_id_for_point_value removed_tag_point_value.to_s
        if tags.map{|tag| tag["id"]}.include?(tag_id)
          @removed_tags << Tag.new(tag_id)
        end
      end
    end

  end

end
