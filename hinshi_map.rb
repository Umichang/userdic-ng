# coding: utf-8

module UserdicNg
  class HinshiMap
    def initialize(from_maps: $hinshi_f, to_maps: $hinshi_t)
      @from_maps = from_maps
      @to_maps = to_maps
    end

    def from(type, value)
      @from_maps.fetch(type)[value]
    end

    def to(type, value)
      @to_maps.fetch(type)[value]
    end
  end
end
