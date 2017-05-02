# -*- coding: utf-8 -*-
class Tray
  attr_reader :name, :height, :width, :depth, :area
  def initialize(name, height, width, depth)
    @name, @height, @width, @depth, @area =
      name, height, width, depth, width * depth
    @rect = Rect.new(@height, @width, @depth)
  end
  def acceptable?(item)
    @rect.acceptable?(item)
  end
  def storage(orders)
    @rect.storage(orders)
  end
end



class Rect
  def initialize(height, width, depth)
    @height, @width, @depth, @area =
      height, width, depth, width * depth
    @item, @dead = nil, false
    @inner = []
  end
  def acceptable?(item)
    item.area <= @area &&
    item.height <= @height && (
      (item.width <= @width && item.depth <= @depth)||
      (item.width <= @depth && item.depth <= @width)
    )
  end
  def storage(orders)
    item = orders.find{|order| @rect.acceptable?(order)}
    orders.delete(item)
    set_item(item, orders)
  end
  def set_item(item, orders)
    candies = []
    candies += get_rect_plan(item)
    candies.sort!{|a, b|
      #TODO: デッドスペースの面積の少ない順
      a <=> b

    }
  end
  def get_rect_plan(item, rotate = false)#=> [plan]
    plans = []
    if item.width == @width && item.depth == @depth then
    elsif item.width != @width && item.depth == @depth then
    elsif item.width == @width && item.depth != @depth then
    else
    end

    if !rotate && item.rotatable? then
      plans += get_rect_plan(item, true)
    end
    plans
  end
end



class Item
  attr_reader :name, :height, :width, :depth, :area
  def initialize(name, height, width, depth)
    @name, @height, @width, @depth, @area =
      name, height, width, depth, width * depth
    @rotate = false
  end
  def rotatable?
    @width != @depth
  end
  def rotate
    @width, @depth = @depth, @width
    @rotate = !@rotate
  end
  def to_aa
    aa = []
    @depth.times{ aa << "■" * @width }
    aa.join("\n")
  end
end

class Master
  attr_reader :trays, :items
  def initialize
    @trays = []
    @trays << Tray.new("tall",    3, 8, 6)
    @trays << Tray.new("regular", 2, 6, 5)
    @trays << Tray.new("short",   1, 5, 4)

    @items = []
    #tall
    @items << Item.new("t:3x4", 3, 3, 4)
    @items << Item.new("t:2x3", 3, 2, 3)
    @items << Item.new("t:2x2", 3, 2, 2)
    #regular
    @items << Item.new("r:3x4", 2, 3, 4)
    @items << Item.new("r:2x3", 2, 2, 3)
    @items << Item.new("r:2x2", 2, 2, 2)
    #short
    @items << Item.new("s:3x4", 1, 3, 4)
    @items << Item.new("s:2x3", 1, 2, 3)
    @items << Item.new("s:2x2", 1, 2, 2)

  end

  def get_item_by_name(name)
    @items.find{|item|
      item.name == name
    }
  end
end
