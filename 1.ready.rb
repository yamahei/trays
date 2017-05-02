# -*- coding: utf-8 -*-
require './0.master.rb'

class Enviroment
  attr_reader :order
  def initialize(order={})
    @master = Master.new
    if order.empty? then
      order = {
        #tall
        "t:3x4" => 4,
        "t:2x3" => 4,
        "t:2x2" => 4,
        #regular
        "r:3x4" => 4,
        "r:2x3" => 4,
        "r:2x2" => 4,
        #short
        "s:3x4" => 4,
        "s:2x3" => 4,
        "s:2x2" => 4,
      }
    end
    put_order(order)
    @order = set_order(order) || []
  end

  def get_order
    @order.dup
  end

  def set_order(order)
    _order = []
    order.each{|name, count|
      count.times{
        _order << @master.get_item_by_name(name)
      }
    }
    _order.sort{|a, b|
      b.height <=> a.height || #高い順
      b.area <=> a.area #大きい順
    }
  end

  def put_order(order)
    puts "* 今回のオーダー"
    order.each{|name, count|
      item = @master.get_item_by_name(name)
      puts "#{item.name} x #{count}"
      puts item.to_aa
      puts
    }
  end

  def get_tray_by_item(item)
    @master.trays.find{|tray|
      tray.height == item.height
    }
  end

end

#e = Enviroment.new
