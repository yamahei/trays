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
  def storage(orders, master)
    @rect.storage(orders, master)
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
  def storage(orders, master)
    item = orders.find{|order| acceptable?(order)}
    if !item then
      @dead = true
    else
      @item = item
      orders.delete(@item)
      set_inner(@item, orders, master)
    end
  end
  def set_inner(item, orders, master)
    plans = get_rect_plan(item, master)
    #scorering
    plans.each{|plan|
      p plan
      plan[:score] = plan[:inner].each{|rect|
        master.items.count{|item| rect.acceptable?(item) }
      }
    }
    plan = plans.sort{|a, b|
      #句形の少ない順→受け入れアイテムの多い順
      a[:inner].count <=> b[:inner].count ||
      b.score <=> a.score
    }.shift
    item.rotate if plan[:rotate]
    @inner = plan[:inner]
    @inner.each{|rect|
      rect.storage(orders, master)
    }
  end
  def get_rect_plan(item, master, rotate = false)#=> [plan]
    plans = []
    item.rotate if rotate
    if item.width == @width && item.depth == @depth then
      inner = []
      plans << { :rotate => rotate, :inner => inner, :score => nil }
    elsif item.width != @width && item.depth == @depth then
      inner = [Rect.new(@height, @width - item.width, @depth)]
      plans << { :rotate => rotate, :inner => inner, :score => nil }
    elsif item.width == @width && item.depth != @depth then
      inner = [Rect.new(@height, @width, @depth - item.depth)]
      plans << { :rotate => rotate, :inner => inner, :score => nil }
    else
      inner = [
        Rect.new(@height, @width, @depth - item.depth),
        Rect.new(@height, @width - item.width, item.depth),
      ]
      plans << { :rotate => rotate, :inner => inner, :score => nil }
      inner = [
        Rect.new(@height, @width - item.width, @depth),
        Rect.new(@height, item.width, @depth - item.depth),
      ]
      plans << { :rotate => rotate, :inner => inner, :score => nil }
    end
    item.rotate if rotate
    #rotated pattern?
    if !rotate && item.rotatable? then
      plans += get_rect_plan(item, master, true)
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
