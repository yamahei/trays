# -*- coding: utf-8 -*-
class Tray
  attr_reader :name, :height, :width, :depth, :area, :rect
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
  def size
    "H#{@height} x W#{@width} x D#{@depth}"
  end
  def performance
    capacity = @height * @width * @depth * 1.0
    volume = @rect.volume * 1.0
    volume / capacity * 100
  end
end

class Rect
  attr_reader :height, :width, :depth, :area
  def initialize(height, width, depth)
    @height, @width, @depth, @area =
      height, width, depth, width * depth
    @item, @inner = nil, []
    raise RuntimeError.new('area under 0.') if @area < 0
  end
  def acceptable?(item)
    return false if item.area > @area
    return false if item.height > @height
    if item.width <= @width && item.depth <= @depth then
      return true
    elsif item.width <= @depth && item.depth <= @width then
      return true
    else
      return false
    end
  end
  def storage(orders, master)
    item = orders.find{|order| acceptable?(order)}
    if item then
      @item = item
      orders.delete(@item)
      set_inner(@item, orders, master)
    end
  end
  def set_inner(item, orders, master)
    plans = get_rect_plan(item, master)
    #scorering
    plans.each{|plan|
      plan[:positive] = plan[:inner].map{|rect|
        master.items.map{|_item|
          rect.acceptable?(_item) ? _item.area : 0
        }.max
      }.max
      plan[:negative] = plan[:inner].map{|rect|
        master.items.all?{|_item|
          !rect.acceptable?(_item)
        } ? -rect.area : 0
      }.min
    }
    plan = plans.sort{|a, b|
      b[:negative] <=> a[:negative] || # dead space
      b[:positive] <=> a[:positive] || # acceptable size
      a[:inner].count <=> b[:inner].count ||
      0
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
    if item.width > @width || item.depth > @depth then
      # overflow
    elsif item.width == @width && item.depth == @depth then
      inner = []
      plans << { :rotate => rotate, :inner => inner }
    elsif item.width > @width && item.depth == @depth then
      inner = [Rect.new(@height, @width - item.width, @depth)]
      plans << { :rotate => rotate, :inner => inner }
    elsif item.width == @width && item.depth > @depth then
      inner = [Rect.new(@height, @width, @depth - item.depth)]
      plans << { :rotate => rotate, :inner => inner }
    else
      inner = []
      if @depth - item.depth > 0 then
        inner << Rect.new(@height, @width, @depth - item.depth)
      end
      if @width - item.width > 0 then
        inner << Rect.new(@height, @width - item.width, item.depth)
      end
      plans << { :rotate => rotate, :inner => inner }
      inner = []
      if @width - item.width > 0 then
        inner << Rect.new(@height, @width - item.width, @depth)
      end
      if @depth - item.depth > 0 then
        inner << Rect.new(@height, item.width, @depth - item.depth)
      end
      plans << { :rotate => rotate, :inner => inner }
    end
    item.rotate if rotate
    #rotated pattern?
    if !rotate && item.rotatable? then
      plans += get_rect_plan(item, master, true)
    end
    plans
  end

  def size
    "H#{@height} x W#{@width} x D#{@depth}"
  end
  def inspect(indent=1)
    _indent = "  " * indent
    _item = @item ? @item.to_s : "none"
    _info = "#{_indent}Rect: #{size} - #{_item}"
    @inner.each{|rect|
      _info += "\n" + rect.inspect(indent + 1)
    }
    _info
  end
  def volume
    volume = 0;
    if @item then
      volume += @item.volume
    end
    @inner.each{|rect|
      volume += rect.volume
    }
    volume
  end
end

class Item
  attr_reader :name, :height, :width, :depth, :area
  def initialize(name, height, width, depth)
    @name, @height, @width, @depth, @area =
      name, height, width, depth, width * depth
    @rotate = false
  end
  def clone
    Item.new(@name, @height, @width, @depth)
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
  def size
    "H#{@height} x W#{@width} x D#{@depth}"
  end
  def to_s
    "Item: #{@name}(#{size})" + (@rotate ? "*R" : "")
  end
  def volume
    @height * @width * @depth
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
